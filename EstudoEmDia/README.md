# Estudo em Dia

Atividade Prática 4 (Notificações Push). App iOS nativo feito em Swift/SwiftUI, com Firebase Cloud Messaging (FCM) para receber notificações push.

> O enunciado sugere Flutter/Android. Este projeto cumpre os mesmos três desafios em iOS nativo (Swift + SwiftUI), usando o SDK oficial do Firebase para iOS e o envio manual pelo Firebase Console, no plano gratuito Spark. Os três desafios foram testados em um iPhone 16 Pro.

## Estrutura do projeto

```
EstudoEmDia/                  app (SwiftUI)
  EstudoEmDiaApp.swift        ponto de entrada; liga o AppDelegate
  AppDelegate.swift           Firebase, permissão, token e toque na notificação
  NotificationRouter.swift    ponte entre o toque na notificação e as telas
  Models/StudyTopic.swift     assuntos de estudo (dados fixos no código)
  Views/                      Home, Detalhes e seção de status das notificações
NotificationService/          extensão que anexa a imagem à notificação (desafio 2)
project.yml                   definição do projeto para o XcodeGen
scripts/gerar-icone.swift     gera o ícone do app (livro + sino) com SF Symbols
docs/design.md                decisões técnicas
```

## 1. Estudo em Dia

O Estudo em Dia é um app de lembretes de estudo. Ele mostra uma lista de assuntos, cada um com matéria, tópico e prazo, e recebe notificações enviadas pelo Firebase Console.

O app tem duas telas:

- **Home** (`HomeView`): lista de assuntos. No rodapé, a seção "Notificações" mostra o token FCM, com botão Copiar, e o status da permissão.
- **Detalhes** (`TopicDetailView`): matéria, tópico, prazo, o que revisar, um checklist e uma dica de estudo.

As três notificações do projeto:

- **Simples**: lembra que a sessão de estudo começa agora. É o caso mais básico de push, só com texto. Combina com o tema, porque o app é de lembretes.
- **Com imagem**: avisa sobre uma prova e mostra uma imagem junto. Mostra como enviar mídia rica. A imagem ajuda a chamar atenção para a revisão antes da prova.
- **Com navegação**: leva direto ao assunto que precisa ser revisado. Mostra como enviar dados personalizados e como o app abre a tela certa ao tocar na notificação.

## 2. Requisitos

- Mac com Xcode recente (testado no Xcode 27.2; o Firebase iOS SDK 13 é baixado automaticamente pelo Swift Package Manager).
- [XcodeGen](https://github.com/yonaskolb/XcodeGen), usado para gerar o projeto Xcode a partir do `project.yml`:

  ```bash
  brew install xcodegen
  ```

- Conta **Apple Developer paga**. Ela é necessária para push, porque o envio passa pelo APNs (Apple Push Notification service).
- **iPhone físico** (recomendado). Notificações push não chegam de forma confiável no simulador.
- Projeto no **Firebase** no plano **Spark** (gratuito).

## 3. Configuração do Firebase (passo a passo)

### 3.1 Criar o projeto Firebase

1. Acesse [console.firebase.google.com](https://console.firebase.google.com).
2. Clique em **Adicionar projeto** e escolha um nome.
3. O plano Spark não exige cartão. Você pode desligar o Google Analytics, porque ele não é usado aqui.

### 3.2 Adicionar o app iOS

1. No projeto, clique em **Adicionar app** e escolha **iOS**.
2. Em **ID do pacote Apple**, informe exatamente:

   ```
   com.lucasmaues.estudoemdia
   ```

   **Apelido do app** (opcional): `Estudo em Dia`. **ID da App Store** (opcional): deixe em branco.

3. Baixe o arquivo `GoogleService-Info.plist`.
4. Coloque o arquivo em:

   ```
   EstudoEmDia/GoogleService-Info.plist
   ```

   Esse arquivo está no `.gitignore`, então ele não vai para o repositório. Cada pessoa deve baixar o seu.

5. Pode pular as etapas seguintes do assistente do Firebase. O código já está pronto.

### 3.3 Gerar a chave APNs

1. Acesse [developer.apple.com](https://developer.apple.com), entre em **Certificates, Identifiers & Profiles**.
2. Vá em **Keys** e clique em **+**.
3. Dê um nome à chave e marque **Apple Push Notifications service (APNs)**.
4. Em **Configure**, escolha:
   - **Environment:** **Sandbox & Production**. O app rodando pelo Xcode usa o ambiente Sandbox (`aps-environment = development`); uma chave só de Production não entrega para ele.
   - **Key Restriction:** **Team Scoped (All Topics)**, para a chave valer para todos os apps da conta.
5. Clique em **Save**, **Continue** e depois em **Register**.
6. Baixe o arquivo `.p8`. **A Apple só permite baixar uma vez.** Guarde o arquivo em local seguro e nunca o coloque no repositório.
7. Anote o **Key ID**. Ele também está no nome do arquivo: `AuthKey_<KEY_ID>.p8`.
8. Anote o **Team ID**: `X8Q64G6VT8`.

### 3.4 Enviar a chave para o Firebase

1. No Firebase Console, abra **Configurações do projeto** (ícone de engrenagem).
2. Vá na aba **Cloud Messaging**.
3. Em **Configuração do app Apple**, na seção **Chave de autenticação de APNs**, clique em **Fazer upload**.
4. Envie o arquivo `.p8`, informe o **Key ID** e o **Team ID** (`X8Q64G6VT8`) e salve.

## 4. Rodando

No Terminal, dentro da pasta do projeto:

```bash
xcodegen generate
open EstudoEmDia.xcodeproj
```

No Xcode:

1. Se necessário, entre com sua conta Apple em **Xcode > Settings > Accounts**. A assinatura é automática e usa o Team ID do `project.yml`.
2. Escolha o seu iPhone na lista de destinos.
3. Clique em **Run** (⌘R).
4. Aceite a permissão de notificações quando o app pedir.
5. Copie o token FCM. Ele aparece na seção **Notificações** da tela inicial, com o botão Copiar. Também sai no console do Xcode, na linha `FCM token: …`.

## 5. Enviando as notificações pelo Console

Caminho no Firebase Console: no menu da esquerda, **Executar** (ou **Engajar**) **> Messaging**. Se não encontrar, digite `Messaging` na busca do topo.

Depois: **Criar primeira campanha** (ou **Nova campanha**) **> Mensagens do Firebase Notifications > Criar**.

Preencha os campos de cada desafio abaixo. Depois de preencher, clique em **Enviar mensagem de teste**, cole o token copiado do app, clique em **+** e em **Testar**. O token fica salvo para os próximos envios.

### Desafio 1: notificação simples

- **Título:** ⏰ Hora de estudar!
- **Texto:** Sua sessão de 25 min de Banco de Dados começa agora. Bora?

### Desafio 2: notificação com imagem

- **Título:** 📚 Prova de Redes na sexta
- **Texto:** Revise sub-redes IPv4 hoje: 3 exercícios e você está pronto.
- **Imagem da notificação:** URL pública com HTTPS de uma imagem JPG ou PNG com menos de 300 KB. A usada nos testes (diagrama de roteadores, Wikimedia Commons): `https://upload.wikimedia.org/wikipedia/commons/5/58/Basic_Topology_-en.png`

### Desafio 3: notificação com navegação

- **Título:** 🔁 Hora de revisar
- **Texto:** Leis de Newton caem na prova. Toque para ver o que revisar.
- **Dados personalizados** (avance até a etapa **Outras opções**):
  - Chave: `topicId`
  - Valor: `fisica-newton`

### Valores válidos de `topicId`

Use um destes IDs no Desafio 3. O app abre o assunto correspondente.

| `topicId` | Matéria | Tópico |
|---|---|---|
| `matematica-derivadas` | Matemática | Derivadas e regra da cadeia |
| `programacao-recursao` | Programação | Recursão |
| `banco-normalizacao` | Banco de Dados | Normalização (1FN–3FN) |
| `redes-subredes` | Redes | Sub-redes IPv4 |
| `fisica-newton` | Física | Leis de Newton |
| `ingles-present-perfect` | Inglês | Present Perfect |

## 6. Roteiro de teste

| Desafio | Cenário | Resultado esperado |
|---|---|---|
| 1. Simples | App em segundo plano | Banner com título e texto. Ao tocar, o app abre na Home. |
| 1. Simples | App fechado | Banner com título e texto. Ao tocar, o app abre na Home. |
| 1. Simples | App aberto | Banner aparece no topo, mesmo com o app em uso. Tocar não navega. |
| 2. Com imagem | App em segundo plano | Banner com a imagem anexada. Ao tocar, o app abre na Home. |
| 2. Com imagem | App fechado | Banner com a imagem anexada. Ao tocar, o app abre na Home. |
| 2. Com imagem | App aberto | Banner com a imagem anexada. |
| 3. Com navegação | App em segundo plano | Banner. Ao tocar, abre o detalhe de **Leis de Newton**. |
| 3. Com navegação | App fechado (o toque abre o app) | Ao tocar, o app inicia e abre o detalhe de **Leis de Newton**. |
| 3. Com navegação | App aberto | Banner aparece. Ao tocar, abre o detalhe de **Leis de Newton**. |

Observações:

- "App fechado" significa encerrado pelo seletor de apps (deslizar para cima). Notificações com título e texto continuam chegando nesse caso.
- Para ver a imagem do Desafio 2 em tamanho grande, pressione e segure a notificação (ou puxe-a para baixo).
- O Desafio 3 com o app fechado é o caso mais difícil, porque o toque precisa chegar ao app enquanto ele ainda está iniciando (cold start).

## 7. Como funciona no iOS

- **Entrega:** o Firebase Console envia a mensagem ao FCM. O FCM entrega ao iPhone pelo APNs, usando a chave `.p8` enviada na seção 3.4. O app recebe o token APNs e o repassa ao Firebase, que gera o token FCM.
- **Imagem:** a notificação com imagem precisa de uma **Notification Service Extension** (pasta `NotificationService/`). O iOS roda essa extensão antes de mostrar o banner. Ela chama `Messaging.serviceExtension().populateNotificationContent(_:withContentHandler:)`, que baixa a imagem indicada em `fcm_options.image` e a anexa à notificação. Se o tempo acabar (`serviceExtensionTimeWillExpire`), a notificação é mostrada sem imagem. A extensão precisa estar embutida no app para funcionar.
- **Toque na notificação:** o método `userNotificationCenter(_:didReceive:)` do `AppDelegate` lê `topicId` em `userInfo`. Em seguida, chama `NotificationRouter.shared.open(topicId:)`. O router guarda o ID pendente, e a `HomeView` abre a `TopicDetailView` do assunto. No cold start, o delegate é definido antes do fim do launch, e a `HomeView` verifica o ID pendente quando aparece.
- **Main thread:** os métodos do `UNUserNotificationCenterDelegate` usam a versão com *completion handler*, chamado na main thread. A versão `async` chamava o completion numa thread de fundo, e o UIKit derrubava o app ao tocar na notificação (erro em `_performBlockAfterCATransactionCommitSynchronizes`).
- **App aberto:** o método `userNotificationCenter(_:willPresent:)` retorna `.banner`, `.list` e `.sound`. Sem isso, o iOS não mostra o banner com o app em uso.

## 8. Problemas comuns

**Não aparece o token**

- Confira se `EstudoEmDia/GoogleService-Info.plist` existe. Sem esse arquivo, o app abre, mas mostra "Firebase não configurado" e não gera token.
- Confira se a permissão de notificações foi aceita. Se foi negada, vá em **Ajustes > Notificações > Estudo em Dia** e ative.
- Confira se a chave `.p8` foi enviada ao Firebase, com o Key ID e o Team ID corretos.

**A imagem não aparece**

- A URL precisa ser HTTPS. URLs HTTP são ignoradas.
- A imagem precisa ter menos de 300 KB e ser JPG ou PNG.
- A extensão `NotificationService` precisa estar embutida no app. Confira no Xcode se o target da extensão aparece em **Embed Foundation Extensions** do target `EstudoEmDia`.
- Quando a imagem falha, a notificação ainda chega, só sem imagem.

**A notificação não chega**

- Use um iPhone físico. O simulador não recebe push de forma confiável.
- Confira se a chave APNs foi criada com o ambiente **Sandbox** (ou **Sandbox & Production**).
- Confira se o token colado é o atual. Depois de reinstalar o app, o token muda. Copie de novo.
- Confira se a chave APNs e o Team ID estão corretos no Firebase.

**O toque não abre o assunto (Desafio 3)**

- Confira se a chave é `topicId` e o valor é um dos IDs da tabela da seção 5. Um ID desconhecido é ignorado e aparece uma mensagem no console do Xcode.
