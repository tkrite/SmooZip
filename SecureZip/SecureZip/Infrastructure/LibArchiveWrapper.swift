import Foundation

/// libarchive C API の Swift ラッパー
///
/// ZIP 圧縮・解凍は libarchive C API で AES-256 暗号化に対応する。
/// TAR 系（TAR.GZ / TAR.BZ2 / TAR.ZST）は暗号化不要のため Process ベースを維持する。
///
/// **Xcode プロジェクト設定（必須）:**
/// 1. Build Settings > Other Linker Flags に `-larchive` を追加済み
/// 2. ブリッジングヘッダー `SecureZip-Bridging-Header.h` に `#import <archive.h>` を記述済み
final class LibArchiveWrapper {

    // MARK: - Constants

    private static let blockSize: Int = 65536  // 64KB ストリーミングバッファ

    // MARK: - Compress

    func compress(
        sources: [URL],
        destination: URL,
        format: CompressionFormat,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        switch format {
        case .zip:
            try await compressZipCAPI(
                sources: sources, destination: destination,
                password: password, progress: progress
            )
        case .tarGz:
            try await compressTar(
                sources: sources, destination: destination,
                compressionFlag: "z", progress: progress
            )
        case .tarBz2:
            try await compressTar(
                sources: sources, destination: destination,
                compressionFlag: "j", progress: progress
            )
        case .tarZst:
            try await compressTar(
                sources: sources, destination: destination,
                compressionFlag: "--zstd", progress: progress
            )
        }
    }

    // MARK: - Decompress

    func decompress(
        source: URL,
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        let ext = source.pathExtension.lowercased()
        let name = source.deletingPathExtension().pathExtension.lowercased()

        if ext == "zip" {
            try await decompressZipCAPI(
                source: source, destination: destination,
                password: password, progress: progress
            )
        } else if ext == "gz" && name == "tar" {
            try await decompressTar(source: source, destination: destination,
                                    flags: ["xzf"], progress: progress)
        } else if ext == "bz2" && name == "tar" {
            try await decompressTar(source: source, destination: destination,
                                    flags: ["xjf"], progress: progress)
        } else if ext == "zst" && name == "tar" {
            try await decompressTar(source: source, destination: destination,
                                    flags: ["x", "--zstd", "-f"], progress: progress)
        } else {
            try await runProcess(
                executable: "/usr/bin/ditto",
                arguments: ["-xk", source.path, destination.path],
                progress: progress
            )
        }
    }

    // MARK: - ZIP C API（圧縮）

    private func compressZipCAPI(
        sources: [URL],
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        let totalBytes = calculateTotalSize(sources: sources)
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try Self.performCompress(
                        sources: sources, destination: destination,
                        password: password, totalBytes: totalBytes, progress: progress
                    )
                    progress(1.0)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func performCompress(
        sources: [URL],
        destination: URL,
        password: String?,
        totalBytes: Int64,
        progress: @escaping @Sendable (Double) -> Void
    ) throws {
        guard let archive = archive_write_new() else {
            throw SecureZipError.compressionFailed(underlying: makeArchiveError(nil))
        }
        defer { archive_write_free(archive) }

        archive_write_set_format_zip(archive)

        if let pw = password, !pw.isEmpty {
            archive_write_set_passphrase(archive, pw)
            // ARCHIVE_WARN (-20) は警告のみ → AES-256 非サポート時は ZipCrypto にフォールバック
            _ = archive_write_set_options(archive, "zip:encryption=aes256")
        }

        guard archive_write_open_filename(archive, destination.path) == ARCHIVE_OK else {
            throw SecureZipError.compressionFailed(underlying: makeArchiveError(archive))
        }

        guard let entry = archive_entry_new() else {
            throw SecureZipError.compressionFailed(underlying: makeArchiveError(nil))
        }
        defer { archive_entry_free(entry) }

        var writtenBytes: Int64 = 0

        for source in sources {
            let baseURL = source.deletingLastPathComponent()

            guard let disk = archive_read_disk_new() else {
                throw SecureZipError.compressionFailed(underlying: makeArchiveError(nil))
            }
            defer { archive_read_free(disk) }

            archive_read_disk_set_standard_lookup(disk)

            guard archive_read_disk_open(disk, source.path) == ARCHIVE_OK else {
                throw SecureZipError.compressionFailed(underlying: makeArchiveError(disk))
            }

            while true {
                let r = archive_read_next_header2(disk, entry)
                if r == ARCHIVE_EOF { break }
                if r < ARCHIVE_OK {
                    throw SecureZipError.compressionFailed(underlying: makeArchiveError(disk))
                }

                // ディレクトリの場合に再帰走査
                archive_read_disk_descend(disk)

                // アーカイブ内パスを相対パスに変換
                if let srcPathPtr = archive_entry_sourcepath(entry) {
                    let srcURL = URL(fileURLWithPath: String(cString: srcPathPtr))
                    let rel = relativePath(of: srcURL, from: baseURL)
                    archive_entry_set_pathname(entry, rel)
                }

                guard archive_write_header(archive, entry) == ARCHIVE_OK else {
                    throw SecureZipError.compressionFailed(underlying: makeArchiveError(archive))
                }

                // 通常ファイルのみデータ書き込み（AE_IFREG = 0o100000）
                let fileType = archive_entry_filetype(entry)
                let fileSize = archive_entry_size(entry)
                if fileType == 0o100000 && fileSize > 0,
                   let srcPathPtr = archive_entry_sourcepath(entry) {
                    let srcURL = URL(fileURLWithPath: String(cString: srcPathPtr))
                    try writeFileData(
                        from: srcURL, to: archive,
                        writtenBytes: &writtenBytes, totalBytes: totalBytes, progress: progress
                    )
                }
            }

            archive_read_close(disk)
        }

        guard archive_write_close(archive) == ARCHIVE_OK else {
            throw SecureZipError.compressionFailed(underlying: makeArchiveError(archive))
        }
    }

    // MARK: - ZIP C API（解凍）

    private func decompressZipCAPI(
        source: URL,
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try Self.performDecompress(
                        source: source, destination: destination,
                        password: password, progress: progress
                    )
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func performDecompress(
        source: URL,
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) throws {
        guard let archive = archive_read_new() else {
            throw SecureZipError.decompressionFailed(underlying: makeArchiveError(nil))
        }
        defer { archive_read_free(archive) }

        archive_read_support_format_zip(archive)
        archive_read_support_filter_all(archive)

        if let pw = password, !pw.isEmpty {
            archive_read_add_passphrase(archive, pw)
        }

        guard archive_read_open_filename(archive, source.path, Int(blockSize)) == ARCHIVE_OK else {
            throw SecureZipError.decompressionFailed(underlying: makeArchiveError(archive))
        }

        guard let disk = archive_write_disk_new() else {
            throw SecureZipError.decompressionFailed(underlying: makeArchiveError(nil))
        }
        defer { archive_write_free(disk) }

        let extractFlags = Int32(ARCHIVE_EXTRACT_TIME | ARCHIVE_EXTRACT_PERM)
        archive_write_disk_set_options(disk, extractFlags)
        archive_write_disk_set_standard_lookup(disk)

        progress(0.1)

        var entry: OpaquePointer?
        while true {
            let r = archive_read_next_header(archive, &entry)
            if r == ARCHIVE_EOF { break }
            if r < ARCHIVE_OK {
                throw SecureZipError.decompressionFailed(underlying: makeArchiveError(archive))
            }

            // 展開先フルパスを設定
            if let e = entry, let currentPath = archive_entry_pathname(e) {
                let fullPath = destination
                    .appendingPathComponent(String(cString: currentPath)).path
                archive_entry_set_pathname(e, fullPath)
            }

            guard archive_write_header(disk, entry) == ARCHIVE_OK else {
                throw SecureZipError.decompressionFailed(underlying: makeArchiveError(disk))
            }

            // ブロック単位でデータコピー
            var buf = [UInt8](repeating: 0, count: blockSize)
            while true {
                let n = buf.withUnsafeMutableBytes { ptr in
                    archive_read_data(archive, ptr.baseAddress, blockSize)
                }
                if n == 0 { break }
                if n < 0 {
                    throw SecureZipError.decompressionFailed(underlying: makeArchiveError(archive))
                }
                buf.withUnsafeBytes { ptr in
                    _ = archive_write_data(disk, ptr.baseAddress, n)
                }
            }

            guard archive_write_finish_entry(disk) == ARCHIVE_OK else {
                throw SecureZipError.decompressionFailed(underlying: makeArchiveError(disk))
            }
        }

        guard archive_read_close(archive) == ARCHIVE_OK else {
            throw SecureZipError.decompressionFailed(underlying: makeArchiveError(archive))
        }
        archive_write_close(disk)

        progress(1.0)
    }

    // MARK: - Helpers

    private func calculateTotalSize(sources: [URL]) -> Int64 {
        let fm = FileManager.default
        var total: Int64 = 0
        for source in sources {
            guard let enumerator = fm.enumerator(
                at: source,
                includingPropertiesForKeys: [.fileSizeKey],
                options: [.skipsHiddenFiles]
            ) else { continue }
            for case let url as URL in enumerator {
                let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                total += Int64(size)
            }
        }
        return max(total, 1)
    }

    private static func relativePath(of url: URL, from base: URL) -> String {
        let basePath = base.standardized.path.hasSuffix("/")
            ? base.standardized.path
            : base.standardized.path + "/"
        let srcPath = url.standardized.path
        guard srcPath.hasPrefix(basePath) else { return url.lastPathComponent }
        let rel = String(srcPath.dropFirst(basePath.count))
        return rel.isEmpty ? url.lastPathComponent : rel
    }

    private static func makeArchiveError(_ archive: OpaquePointer?) -> NSError {
        let msg = archive
            .flatMap { archive_error_string($0) }
            .map { String(cString: $0) }
            ?? "不明なエラー"
        return NSError(domain: "LibArchive", code: -1,
                       userInfo: [NSLocalizedDescriptionKey: msg])
    }

    private static func writeFileData(
        from url: URL,
        to archive: OpaquePointer,
        writtenBytes: inout Int64,
        totalBytes: Int64,
        progress: @escaping @Sendable (Double) -> Void
    ) throws {
        guard let fd = fopen(url.path, "rb") else {
            let msg = String(cString: strerror(errno))
            throw SecureZipError.compressionFailed(
                underlying: NSError(domain: "LibArchive", code: Int(errno),
                                    userInfo: [NSLocalizedDescriptionKey: msg])
            )
        }
        defer { fclose(fd) }

        var buf = [UInt8](repeating: 0, count: blockSize)
        while true {
            let n = buf.withUnsafeMutableBytes { ptr in
                fread(ptr.baseAddress, 1, blockSize, fd)
            }
            if n == 0 { break }
            let written = buf.withUnsafeBytes { ptr in
                archive_write_data(archive, ptr.baseAddress, n)
            }
            if written < 0 {
                throw SecureZipError.compressionFailed(underlying: makeArchiveError(archive))
            }
            writtenBytes += Int64(n)
            let ratio = min(Double(writtenBytes) / Double(totalBytes), 0.99)
            progress(ratio)
        }
    }

    // MARK: - TAR (Process ベース)

    private func compressTar(
        sources: [URL],
        destination: URL,
        compressionFlag: String,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        progress(0.1)
        var args: [String]
        if compressionFlag.hasPrefix("--") {
            args = ["-c", compressionFlag, "-f", destination.path]
        } else {
            args = ["-c\(compressionFlag)f", destination.path]
        }
        args += sources.map { $0.path }
        try await runProcess(executable: "/usr/bin/tar", arguments: args, progress: progress)
        progress(1.0)
    }

    private func decompressTar(
        source: URL,
        destination: URL,
        flags: [String],
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        progress(0.1)
        let args = flags + [source.path, "-C", destination.path]
        try await runProcess(executable: "/usr/bin/tar", arguments: args, progress: progress)
        progress(1.0)
    }

    // MARK: - Process Runner

    private func runProcess(
        executable: String,
        arguments: [String],
        stdinData: Data? = nil,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: executable)
                process.arguments = arguments

                let errorPipe = Pipe()
                process.standardError = errorPipe

                let inputPipe: Pipe?
                if stdinData != nil {
                    let pipe = Pipe()
                    process.standardInput = pipe
                    inputPipe = pipe
                } else {
                    inputPipe = nil
                }

                do {
                    try process.run()

                    if let data = stdinData, let pipe = inputPipe {
                        pipe.fileHandleForWriting.write(data)
                        pipe.fileHandleForWriting.closeFile()
                    }

                    process.waitUntilExit()

                    if process.terminationStatus == 0 {
                        progress(1.0)
                        continuation.resume()
                    } else {
                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        let errorMessage = String(data: errorData, encoding: .utf8) ?? "不明なエラー"
                        let error = NSError(
                            domain: "LibArchiveWrapper",
                            code: Int(process.terminationStatus),
                            userInfo: [NSLocalizedDescriptionKey: errorMessage]
                        )
                        continuation.resume(throwing: SecureZipError.compressionFailed(underlying: error))
                    }
                } catch {
                    continuation.resume(throwing: SecureZipError.compressionFailed(underlying: error))
                }
            }
        }
    }
}
