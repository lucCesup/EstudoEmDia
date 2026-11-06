import FirebaseMessaging
import UserNotifications

/// Desafio 2: roda em um processo separado quando chega um push com `mutable-content`.
/// O Console marca isso ao preencher "Imagem da notificação"; aqui baixamos e anexamos a imagem.
final class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

        guard let content = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        // O FCM lê `fcm_options.image`, baixa o arquivo e cria o anexo para nós.
        Messaging.serviceExtension().populateNotificationContent(content, withContentHandler: contentHandler)
    }

    // O iOS dá ~30 s; se o download não terminou, entrega o texto sem a imagem.
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
