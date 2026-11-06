import Foundation
import Observation
import UserNotifications

/// Ponte entre o AppDelegate (UIKit) e as telas (SwiftUI).
/// Fica na main actor porque as views leem estas propriedades.
@MainActor
@Observable
final class NotificationRouter {
    static let shared = NotificationRouter()

    /// Token FCM, mostrado na Home para colar no Console ("Enviar mensagem de teste").
    var fcmToken: String?
    var permissionStatus: UNAuthorizationStatus = .notDetermined
    /// False quando falta o GoogleService-Info.plist.
    var firebaseConfigured = false

    /// Desafio 3: id recebido ao tocar na notificação. A Home consome e zera.
    /// Como vive aqui, funciona também no cold start: o toque chega antes de a tela existir.
    var pendingTopicId: String?

    private init() {}

    func open(topicId: String) {
        pendingTopicId = topicId
    }
}
