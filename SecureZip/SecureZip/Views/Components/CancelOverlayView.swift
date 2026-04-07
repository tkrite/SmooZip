import SwiftUI

/// 送信カウントダウン・キャンセルオーバーレイ
struct CancelOverlayView: View {

    let countdown: Int
    let totalSeconds: Int
    let isSending: Bool
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                if isSending {
                    ProgressView()
                        .scaleEffect(1.4)
                    Text("送信中...")
                        .font(.headline)
                } else {
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 6)
                            .frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0, to: totalSeconds > 0 ? Double(countdown) / Double(totalSeconds) : 1)
                            .stroke(Color.accentColor, lineWidth: 6)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: countdown)
                        Text("\(countdown)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                    Text("送信まで \(countdown) 秒")
                        .font(.headline)
                    Text("キャンセルするには下のボタンを押してください")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("キャンセル", action: onCancel)
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(isSending)
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
        }
    }
}

#Preview {
    CancelOverlayView(countdown: 4, totalSeconds: 5, isSending: false) {}
}
