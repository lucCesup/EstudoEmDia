import SwiftUI
import UserNotifications

/// Seção de rodapé da Home: token FCM (para o "Enviar mensagem de teste") e status da permissão.
struct NotificationStatusSection: View {
    private let router = NotificationRouter.shared
    @State private var copied = false

    var body: some View {
        Section {
            if !router.firebaseConfigured {
                Label("Firebase não configurado", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            } else if let token = router.fcmToken {
                Text(token)
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .lineLimit(3)
                Button {
                    UIPasteboard.general.string = token
                    copied = true
                } label: {
                    Label(copied ? "Copiado" : "Copiar token", systemImage: copied ? "checkmark" : "doc.on.doc")
                }
                .sensoryFeedback(.success, trigger: copied)
            } else {
                Label("Aguardando token…", systemImage: "hourglass")
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Permissão", value: statusText)
        } header: {
            Text("Notificações")
        } footer: {
            Text("Cole o token no Firebase Console para enviar uma mensagem de teste.")
        }
    }

    private var statusText: String {
        switch router.permissionStatus {
        case .authorized: "Permitida"
        case .denied: "Negada"
        case .provisional: "Provisória"
        case .ephemeral: "Temporária"
        case .notDetermined: "Não solicitada"
        @unknown default: "Desconhecida"
        }
    }
}
