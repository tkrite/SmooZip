import SwiftUI

struct SettingsView: View {

    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("設定")
                    .font(.title2.bold())
                Spacer()
            }
            .padding()

            Divider()

            Form {
                // Gmail 連携
                Section("Gmail 連携") {
                    if vm.isGmailConnected {
                        LabeledContent("接続済み", value: vm.connectedEmail)
                        Button("連携解除", role: .destructive) {
                            Task { await vm.disconnectGmail() }
                        }
                    } else {
                        Button("Gmail と連携する") {
                            Task { await vm.connectGmail() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    if let msg = vm.errorMessage {
                        Text(msg)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                // パスワード生成設定
                Section("パスワード生成") {
                    Stepper("文字数: \(vm.passwordLength)",
                            value: $vm.passwordLength, in: 8...64)
                    Toggle("大文字を含む", isOn: $vm.includeUppercase)
                    Toggle("小文字を含む", isOn: $vm.includeLowercase)
                    Toggle("数字を含む",   isOn: $vm.includeNumbers)
                    Toggle("記号を含む",   isOn: $vm.includeSymbols)
                }

                // 送信設定
                Section("送信設定") {
                    Stepper("キャンセル猶予: \(vm.cancelDelaySeconds)秒",
                            value: $vm.cancelDelaySeconds, in: 1...30)
                    Toggle("デフォルトでパスワードを別送する",
                           isOn: $vm.separatePasswordByDefault)
                }

                // 自動削除
                Section("履歴の自動削除") {
                    Toggle("自動削除を有効にする", isOn: $vm.isAutoDeleteEnabled)
                    if vm.isAutoDeleteEnabled {
                        Stepper("保存期間: \(vm.autoDeleteDays)日",
                                value: $vm.autoDeleteDays, in: 1...365)
                    }
                }
            }
            .formStyle(.grouped)
        }
    }
}
