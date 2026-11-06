import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Sem o plist o app continua abrindo, só sem push.
        let configured = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        if configured {
            FirebaseApp.configure()
            Messaging.messaging().delegate = self
        } else {
            print("Aviso: GoogleService-Info.plist ausente. Firebase não configurado.")
        }

        // Desafio 3: o delegate precisa estar definido ANTES de retornar daqui.
        // Com o app fechado, o iOS entrega o toque da notificação logo após o launch;
        // se o delegate ainda for nil, o toque se perde.
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        Task { @MainActor in
            NotificationRouter.shared.firebaseConfigured = configured
            let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
            NotificationRouter.shared.permissionStatus = await center.notificationSettings().authorizationStatus
            if granted && configured {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }

    // Desafio 1: como o proxy do Firebase está desligado, entregamos o token APNs ao FCM manualmente.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Falha ao registrar para push remoto: \(error.localizedDescription)")
    }
}

extension AppDelegate: MessagingDelegate {
    // O FCM chama isto quando gera (ou renova) o token do aparelho.
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM token: \(fcmToken ?? "nil")")
        Task { @MainActor in
            NotificationRouter.shared.fcmToken = fcmToken
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Usamos as versões com completion handler (e não as `async`): o UIKit exige que
    // o completion seja chamado na main thread, e a versão `async nonisolated` o chamava
    // numa thread de fundo, derrubando o app ao tocar na notificação.

    // Mostra a notificação mesmo com o app aberto (por padrão o iOS a esconderia).
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        DispatchQueue.main.async {
            completionHandler([.banner, .list, .sound])
        }
    }

    // Desafio 3: chamado ao tocar na notificação (segundo plano ou cold start).
    // Lemos o dado personalizado "topicId" enviado pelo Console.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let topicId = response.notification.request.content.userInfo["topicId"] as? String
        DispatchQueue.main.async {
            if let topicId {
                NotificationRouter.shared.open(topicId: topicId)
            }
            completionHandler()
        }
    }
}
