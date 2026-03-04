import SwiftUI
import AppKit

struct DecompressView: View {

    @StateObject private var vm = DecompressViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("解凍")
                    .font(.title2.bold())
                Spacer()
            }
            .padding()

            Divider()

            VStack(alignment: .leading, spacing: 20) {

                // ファイル選択
                GroupBox("解凍するファイルを選択") {
                    HStack {
                        Text(vm.selectedFile?.lastPathComponent ?? "ファイルが選択されていません")
                            .foregroundStyle(vm.selectedFile == nil ? .secondary : .primary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button("選択...") { openFilePicker() }
                    }
                    .padding(4)
                }

                // パスワード
                GroupBox("パスワード（暗号化ファイルの場合）") {
                    SecureField("パスワード（任意）", text: $vm.password)
                        .padding(4)
                }

                // 実行ボタン
                HStack {
                    Spacer()
                    Button("解凍する") { openFolderPicker() }
                        .buttonStyle(.borderedProminent)
                        .disabled(!vm.canDecompress || vm.isDecompressing)
                }

                if vm.isDecompressing {
                    ProgressView(value: vm.progress)
                }

                if vm.isCompleted {
                    Label("解凍が完了しました", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }

                if let msg = vm.errorMessage {
                    Text(msg).foregroundStyle(.red).font(.caption)
                }
            }
            .padding()

            Spacer()
        }
    }

    // MARK: - Private

    /// 解凍対象ファイルを選択する
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = "解凍するファイルを選択"
        panel.allowedContentTypes = []  // 全形式を許可
        if panel.runModal() == .OK {
            vm.selectedFile = panel.url
        }
    }

    /// 解凍先フォルダを選択して解凍を開始する
    private func openFolderPicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.title = "解凍先フォルダを選択"
        if panel.runModal() == .OK, let url = panel.url {
            Task { await vm.decompress(destination: url) }
        }
    }
}
