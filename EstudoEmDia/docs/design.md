# Estudo em Dia — design técnico

Atividade Prática 4 (Notificações Push) feita em **Swift/SwiftUI + Firebase Cloud Messaging** (o enunciado pede Flutter; o aluno optou por iOS nativo).

## O app
Lembretes de estudo. Duas telas:
- **Home** (`HomeView`): lista de assuntos (`StudyTopic`) com matéria, tópico e prazo. No rodapé, uma seção "Notificações" mostrando o token FCM com botão Copiar (necessário para "Enviar mensagem de teste" no Console) e o status da permissão.
- **Detalhes** (`TopicDetailView`): matéria, tópico, prazo, descrição do que revisar, checklist (só visual, estado em memória) e uma dica de estudo.

Dados fixos no código (`StudyTopic.samples`), matérias genéricas. IDs (usados pela notificação do desafio 3):

| id | matéria | tópico |
|---|---|---|
| `matematica-derivadas` | Matemática | Derivadas e regra da cadeia |
| `programacao-recursao` | Programação | Recursão |
| `banco-normalizacao` | Banco de Dados | Normalização (1FN–3FN) |
| `redes-subredes` | Redes | Sub-redes IPv4 |
| `fisica-newton` | Física | Leis de Newton |
| `ingles-present-perfect` | Inglês | Present Perfect |

Prazos: datas relativas a hoje (ex.: hoje + 2 dias), para nunca ficarem no passado no vídeo.

## As três notificações (enviadas pelo Firebase Console)
1. **Simples** — título "⏰ Hora de estudar!", corpo "Sua sessão de 25 min de Banco de Dados começa agora. Bora?".
2. **Com imagem** — título "📚 Prova de Redes na sexta", corpo "Revise sub-redes IPv4 hoje: 3 exercícios e você está pronto.", campo "Imagem da notificação" com URL pública HTTPS de uma imagem (< 300 KB, JPG/PNG).
3. **Com navegação** — título "🔁 Hora de revisar", corpo "Leis de Newton caem na prova. Toque para ver o que revisar.", **Dados personalizados**: chave `topicId`, valor `fisica-newton`. Ao tocar, abre `TopicDetailView` desse assunto — com app em segundo plano e com app fechado (cold start).

## Arquitetura
- **XcodeGen** (`project.yml`), iOS 17.0, Swift language mode 5, `DEVELOPMENT_TEAM: X8Q64G6VT8`, assinatura automática, iPhone apenas, pt-BR.
- **SPM**: `https://github.com/firebase/firebase-ios-sdk` (última major estável). App: `FirebaseCore`, `FirebaseMessaging`. Extensão: `FirebaseMessaging`.
- **Targets**
  - `EstudoEmDia` (app) — bundle `com.lucasmaues.estudoemdia`. Entitlement `aps-environment: development`. Info: `UIBackgroundModes: [remote-notification]`, `FirebaseAppDelegateProxyEnabled: false` (token APNs repassado manualmente — explícito e didático). Embute a extensão.
  - `NotificationService` (app-extension, `com.apple.usernotifications.service`) — bundle `com.lucasmaues.estudoemdia.NotificationService`. Usa `Messaging.serviceExtension().populateNotificationContent(_:withContentHandler:)` para baixar e anexar a imagem (`fcm_options.image`). Implementa `serviceExtensionTimeWillExpire` entregando o conteúdo sem imagem.
- **GoogleService-Info.plist**: fornecido pelo aluno em `EstudoEmDia/GoogleService-Info.plist`; está no `.gitignore` e é referenciado como fonte opcional no project.yml. Se faltar, o app NÃO crasha: pula `FirebaseApp.configure()`, loga um aviso e a seção de notificações mostra "Firebase não configurado".

### Fluxo
- `EstudoEmDiaApp` usa `@UIApplicationDelegateAdaptor(AppDelegate.self)`.
- `AppDelegate.didFinishLaunching`: configura Firebase; define `UNUserNotificationCenter.current().delegate = self` e `Messaging.messaging().delegate = self` **antes de retornar** (requisito para o toque em cold start chegar); pede permissão (`.alert, .badge, .sound`); se concedida, `registerForRemoteNotifications()`.
- `didRegisterForRemoteNotificationsWithDeviceToken` → `Messaging.messaging().apnsToken = deviceToken`.
- `messaging(_:didReceiveRegistrationToken:)` → publica o token no `NotificationRouter` e imprime no console (`print("FCM token: …")`).
- `userNotificationCenter(_:willPresent:)` → `[.banner, .list, .sound]` (aparece também com app aberto).
- `userNotificationCenter(_:didReceive:)` → lê `userInfo["topicId"] as? String` → `NotificationRouter.shared.open(topicId:)`.
- `NotificationRouter`: `@MainActor @Observable final class`, singleton `shared`, propriedades `fcmToken: String?`, `permissionStatus`, `pendingTopicId: String?`. `HomeView` usa `NavigationStack(path:)` e, via `.onChange(of: router.pendingTopicId)` + verificação no `.onAppear` (cold start), resolve o id em `StudyTopic` e empilha o detalhe (limpando o path antes), depois zera `pendingTopicId`. Id desconhecido → ignora com log.

## Estrutura de pastas
```
estudo-em-dia/
  project.yml
  .gitignore            (xcodeproj gerado? NÃO — versionar o .xcodeproj gerado; ignorar DerivedData, xcuserdata, GoogleService-Info.plist, .DS_Store)
  README.md
  docs/design.md
  EstudoEmDia/
    EstudoEmDiaApp.swift
    AppDelegate.swift
    NotificationRouter.swift
    Models/StudyTopic.swift
    Views/HomeView.swift
    Views/TopicDetailView.swift
    Views/NotificationStatusSection.swift
    Assets.xcassets (AppIcon vazio, AccentColor)
    EstudoEmDia.entitlements
  NotificationService/
    NotificationService.swift
    Info.plist
```

## Verificação
`xcodegen generate` e `xcodebuild -project EstudoEmDia.xcodeproj -scheme EstudoEmDia -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build` precisa passar sem erros (sem GoogleService-Info.plist presente).

## Fora do escopo
Login, banco de dados, backend, testes automatizados, publicação.
