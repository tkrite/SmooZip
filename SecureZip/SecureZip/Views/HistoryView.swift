import SwiftUI

struct HistoryView: View {

    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("履歴")
                    .font(.title2.bold())
                Spacer()
            }
            .padding()

            Divider()

            if vm.isLoading {
                ProgressView().padding()
            } else if vm.filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.badge.xmark")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("送付履歴はありません")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("ファイルを送付すると履歴が表示されます。")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(vm.filteredItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.fileName).fontWeight(.medium)
                            Text(item.recipientEmail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Label(item.status.displayName, systemImage: item.status.symbolName)
                                .font(.caption)
                            if let sentAt = item.sentAt {
                                Text(sentAt, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .searchable(text: $vm.searchText, prompt: "送付先・ファイル名で検索")
            }
        }
        .task { await vm.loadHistory() }
    }
}
