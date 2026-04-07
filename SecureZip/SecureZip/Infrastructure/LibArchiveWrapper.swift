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
                isDecompression: true,
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

        // UTF-8 フラグ（EFS フラグ）を設定し Windows でファイル名が文字化けしないようにする
        // ZIP 6.3.0 の Language Encoding Flag により Windows エクスプローラーが UTF-8 として解釈する
        archive_write_set_options(archive, "zip:hdrcharset=UTF-8")

        if let pw = password, !pw.isEmpty {
            archive_write_set_passphrase(archive, pw)
            let optResult = archive_write_set_options(archive, "zip:encryption=aes256")
            if optResult != ARCHIVE_OK {
                // ARCHIVE_WARN(-20) = AES-256 非サポート → ZipCrypto へのフォールバックを防ぐためエラーにする
                throw SecureZipError.compressionFailed(
                    underlying: NSError(
                        domain: "LibArchive",
                        code: Int(optResult),
                        userInfo: [NSLocalizedDescriptionKey: "AES-256 暗号化を設定できませんでした。システム libarchive がこのオプションをサポートしていない可能性があります。"]
                    )
                )
            }
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
                // macOS は HFS+/APFS の NFD 正規化ファイル名を返すため NFC に変換して
                // Windows 互換性を確保する（NFD のまま格納すると Windows で文字化けする）
                if let srcPathPtr = archive_entry_sourcepath(entry) {
                    let srcURL = URL(fileURLWithPath: String(cString: srcPathPtr))
                    let rel = relativePath(of: srcURL, from: baseURL)
                    let nfcRel = rel.precomposedStringWithCanonicalMapping
                    archive_entry_set_pathname(entry, nfcRel)
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
        // 一時ディレクトリに展開し、全エントリ成功後のみ destination に移動する（アトミック展開）
        // → 途中でエラーが発生しても destination に不完全なファイルが残らない
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: tempDir) }

        try performExtract(source: source, destination: tempDir, password: password, progress: progress)

        // 展開成功 → tempDir の内容を destination に移動
        for item in try fm.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil) {
            let target = destination.appendingPathComponent(item.lastPathComponent)
            try fm.moveItem(at: item, to: target)
        }
    }

    private static func performExtract(
        source: URL,
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) throws {
        // ZIP ファイルサイズを進捗の分母に使用（取得できない場合は 0 = 進捗不明）
        let totalCompressedSize = (try? source.resourceValues(forKeys: [.fileSizeKey]).fileSize)
            .flatMap { Int64($0) } ?? 0

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

        var entry: OpaquePointer?
        while true {
            let r = archive_read_next_header(archive, &entry)
            if r == ARCHIVE_EOF { break }
            if r < ARCHIVE_OK {
                throw SecureZipError.decompressionFailed(underlying: makeArchiveError(archive))
            }

            // 展開先フルパスを設定（ZIP Slip 対策: ".." コンポーネントを除去してパストラバーサルを防ぐ）
            if let e = entry, let currentPath = archive_entry_pathname(e) {
                let entryPath = String(cString: currentPath)
                let sanitized = entryPath
                    .components(separatedBy: "/")
                    .filter { $0 != ".." && $0 != "." && !$0.isEmpty }
                    .joined(separator: "/")
                guard !sanitized.isEmpty else { continue }
                // 他ツール（旧 Mac / 一部 Linux 等）が NFD で格納したファイル名を NFC に正規化する
                // これにより解凍後のファイル名が一貫した NFC 形式になり、他アプリとの互換性が向上する
                let nfcSanitized = sanitized.precomposedStringWithCanonicalMapping
                let fullURL = destination.appendingPathComponent(nfcSanitized).standardizedFileURL
                let destPath = destination.standardizedFileURL.path
                guard fullURL.path.hasPrefix(destPath + "/") || fullURL.path == destPath else {
                    throw SecureZipError.decompressionFailed(
                        underlying: NSError(
                            domain: "SecureZip", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "不正なパスを検出しました: \(sanitized)"]
                        )
                    )
                }
                archive_entry_set_pathname(e, fullURL.path)
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
                let written = buf.withUnsafeBytes { ptr in
                    archive_write_data(disk, ptr.baseAddress, size_t(n))
                }
                if written < 0 {
                    throw SecureZipError.decompressionFailed(underlying: makeArchiveError(disk))
                }
            }

            guard archive_write_finish_entry(disk) == ARCHIVE_OK else {
                throw SecureZipError.decompressionFailed(underlying: makeArchiveError(disk))
            }

            // 圧縮済みバイト数で進捗を更新（0〜0.95 の範囲で通知し、完了時に 1.0 を別途送出）
            if totalCompressedSize > 0 {
                let read = archive_filter_bytes(archive, -1)
                let ratio = min(Double(read) / Double(totalCompressedSize), 0.95)
                progress(ratio)
            }
        }

        guard archive_read_close(archive) == ARCHIVE_OK else {
            throw SecureZipError.decompressionFailed(underlying: makeArchiveError(archive))
        }
        guard archive_write_close(disk) == ARCHIVE_OK else {
            throw SecureZipError.decompressionFailed(underlying: makeArchiveError(disk))
        }

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
        args += ["--"] + sources.map { $0.path }
        // tar はバイト単位の進捗取得が困難なため時間ベースでシミュレートする
        let progressTask = Task {
            for step in [0.2, 0.35, 0.5, 0.65, 0.8, 0.9] as [Double] {
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled else { return }
                progress(step)
            }
        }
        defer { progressTask.cancel() }
        try await runProcess(executable: "/usr/bin/tar", arguments: args, isDecompression: false, progress: { _ in })
        progress(1.0)
    }

    /// TAR アーカイブのエントリパスを事前検証する（ZIP Slip 対策）
    ///
    /// libarchive でエントリを列挙し、展開先ディレクトリの外を指すパスが
    /// 含まれている場合はエラーをスローする。検証のみ行い展開はしない。
    private func validateTarPaths(source: URL, destination: URL) throws {
        guard let archive = archive_read_new() else {
            throw SecureZipError.decompressionFailed(underlying: Self.makeArchiveError(nil))
        }
        defer { archive_read_free(archive) }

        archive_read_support_format_tar(archive)
        archive_read_support_filter_gzip(archive)
        archive_read_support_filter_bzip2(archive)
        archive_read_support_filter_zstd(archive)
        archive_read_support_filter_none(archive)

        guard archive_read_open_filename(archive, source.path, Int(Self.blockSize)) == ARCHIVE_OK else {
            throw SecureZipError.decompressionFailed(underlying: Self.makeArchiveError(archive))
        }

        let destPath = destination.standardizedFileURL.path
        var entry: OpaquePointer?

        while true {
            let r = archive_read_next_header(archive, &entry)
            if r == ARCHIVE_EOF { break }
            if r < ARCHIVE_OK {
                throw SecureZipError.decompressionFailed(underlying: Self.makeArchiveError(archive))
            }
            guard let e = entry, let rawPath = archive_entry_pathname(e) else { continue }

            let entryPath = String(cString: rawPath)
            let sanitized = entryPath
                .components(separatedBy: "/")
                .filter { $0 != ".." && $0 != "." && !$0.isEmpty }
                .joined(separator: "/")
            guard !sanitized.isEmpty else { continue }

            let fullURL = destination.appendingPathComponent(sanitized).standardizedFileURL
            guard fullURL.path.hasPrefix(destPath + "/") || fullURL.path == destPath else {
                throw SecureZipError.decompressionFailed(
                    underlying: NSError(
                        domain: "SecureZip", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "不正なパスを検出しました: \(sanitized)"]
                    )
                )
            }
        }
    }

    private func decompressTar(
        source: URL,
        destination: URL,
        flags: [String],
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        // ZIP Slip 対策：実行前にアーカイブエントリのパスを検証
        try validateTarPaths(source: source, destination: destination)
        progress(0.1)
        let args = flags + ["--", source.path, "-C", destination.path]
        let progressTask = Task {
            for step in [0.2, 0.35, 0.5, 0.65, 0.8, 0.9] as [Double] {
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled else { return }
                progress(step)
            }
        }
        defer { progressTask.cancel() }
        try await runProcess(executable: "/usr/bin/tar", arguments: args, isDecompression: true, progress: { _ in })
        progress(1.0)
    }

    // MARK: - Process Runner

    private func runProcess(
        executable: String,
        arguments: [String],
        stdinData: Data? = nil,
        isDecompression: Bool = false,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                let makeError: (Error) -> SecureZipError = isDecompression
                    ? { .decompressionFailed(underlying: $0) }
                    : { .compressionFailed(underlying: $0) }

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
                        continuation.resume(throwing: makeError(error))
                    }
                } catch {
                    continuation.resume(throwing: makeError(error))
                }
            }
        }
    }
}
