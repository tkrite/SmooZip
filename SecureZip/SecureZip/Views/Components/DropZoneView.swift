import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// ドラッグ&ドロップでファイルを受け付けるビュー
struct DropZoneView: View {

    @Binding var files: [URL]
    @Binding var errorMessage: String?
    @State private var isDragging = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isDragging ? Color.accentColor : Color.secondary.opacity(0.5),
                    style: StrokeStyle(lineWidth: 2, dash: [8])
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDragging ? Color.accentColor.opacity(0.08) : Color.clear)
                )

            VStack(spacing: 8) {
                Image(systemName: "arrow.down.doc")
                    .font(.system(size: 32))
                    .foregroundStyle(isDragging ? Color.accentColor : Color.secondary)

                if files.isEmpty {
                    Text("ファイルをドロップ、または")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Button("ファイルを選択...") { openFilePicker() }
                } else {
                    Text("\(files.count)個のファイルが選択されています")
                        .font(.callout)
                    Button("クリア") { files.removeAll() }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.red)
                }
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
            handleDrop(providers: providers)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, error in
                if let error {
                    DispatchQueue.main.async { errorMessage = String(format: NSLocalizedString("error.dropFailed", comment: ""), error.localizedDescription) }
                    return
                }
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                DispatchQueue.main.async { files.append(url) }
            }
            handled = true
        }
        return handled
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        if panel.runModal() == .OK {
            files.append(contentsOf: panel.urls)
        }
    }
}
