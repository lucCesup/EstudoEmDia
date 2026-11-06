import SwiftUI

struct HomeView: View {
    private let topics = StudyTopic.samples
    @State private var path: [StudyTopic] = []
    private let router = NotificationRouter.shared

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Próximos assuntos") {
                    ForEach(topics) { topic in
                        NavigationLink(value: topic) {
                            TopicRow(topic: topic)
                        }
                    }
                }
                NotificationStatusSection()
            }
            .navigationTitle("Estudo em Dia")
            .navigationDestination(for: StudyTopic.self) { topic in
                TopicDetailView(topic: topic)
            }
        }
        // Desafio 3: reage a um toque com o app já rodando...
        .onChange(of: router.pendingTopicId) { _, _ in openPendingTopic() }
        // ...e ao cold start, em que o id já estava definido antes de a tela aparecer.
        .onAppear { openPendingTopic() }
    }

    private func openPendingTopic() {
        guard let id = router.pendingTopicId else { return }
        router.pendingTopicId = nil
        guard let topic = StudyTopic.find(id: id) else {
            print("topicId desconhecido na notificação: \(id)")
            return
        }
        // Limpa o path antes para o detalhe não empilhar sobre outro.
        path = [topic]
    }
}

private struct TopicRow: View {
    let topic: StudyTopic

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(topic.subject)
                    .font(.caption)
                    .foregroundStyle(topic.color)
                Text(topic.title)
                    .font(.headline)
                Text("Prazo: \(topic.deadline.formatted(date: .abbreviated, time: .omitted))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: topic.symbol)
                .foregroundStyle(topic.color)
        }
        .padding(.vertical, 2)
    }
}
