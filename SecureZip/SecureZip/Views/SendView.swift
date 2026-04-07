import SwiftUI
import AppKit

struct SendView: View {

    @StateObject private var vm = SendViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Text("送信")
                        .font(.title2.bold())
                    Spacer()
                }
                .padding()

                Divider()

                if !vm.isGmailAuthenticated {
                    VStack(spacing: 8) {
                        Image(systemName: "envelope.badge.shield.half.filled")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Gmail 連携が必要です")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("設定画面から Gmail と連携してください。")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {

                            GroupBox("送付先") {
                                TextField("メールアドレス", text: $vm.recipientEmail)
                                    .padding(4)
                            }

                            GroupBox("添付ファイル") {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        if let file = vm.selectedFile {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(file.lastPathComponent)
                                                    .lineLimit(1)
                                                    .truncationMode(.middle)
                                                Text(file.fileSizeDescription)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        } else {
                                            Text("ファイルが選択されていません")
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Button("選択...") { openFilePicker() }
                                    }
                                    if vm.selectedFile != nil {
                                        HStack(spacing: 4) {
                                            TextField("送信ファイル名", text: $vm.archiveFileName)
                                            Text(".zip")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(4)
                            }

                            GroupBox("パスワード") {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        SecureField("暗号化パスワード", text: $vm.password)
                                        Button("生成") {
                                            vm.generatePassword()
                                        }
                                    }
                                    Text("windows.zip.hint")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(4)
                            }

                            GroupBox("件名・本文") {
                                VStack(alignment: .leading) {
                                    TextField("件名", text: $vm.subject)
                                    Divider()
                                    TextEditor(text: $vm.body)
                                        .frame(height: 80)
                                }
                                .padding(4)
                            }

                            GroupBox("オプション") {
                                Toggle("パスワードを別メールで送付する",
                                       isOn: $vm.isSeparatePasswordEnabled)
                                    .padding(4)
                            }

                            HStack {
                                Spacer()
                                Button("送信する") { vm.requestSend() }
                                    .buttonStyle(.borderedProminent)
                                    .disabled(!vm.canSend)
                            }

                            if let msg = vm.errorMessage {
                                Text(msg).foregroundStyle(.red).font(.caption)
                            }

                            if vm.isCompleted {
                                Label("送信が完了しました", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding()
                    }
                }
            }

            // 送信カウントダウン・送信中オーバーレイ
            if vm.isCountingDown || vm.isSending {
                CancelOverlayView(
                    countdown: vm.countdown,
                    totalSeconds: vm.cancelDelaySeconds,
                    isSending: vm.isSending
                ) {
                    vm.cancelSending()
                }
            }
        }
        .alert("password.email.warning.title", isPresented: $vm.showPasswordEmailWarning) {
            Button("送信する", role: .destructive) { vm.startSending() }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("password.email.warning.message")
        }
    }

    // MARK: - Private

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.title = NSLocalizedString("送付するファイルを選択", comment: "")
        if panel.runModal() == .OK, let url = panel.url {
            vm.selectFile(url)
        }
    }
}
