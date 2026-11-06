import SwiftUI

struct TopicDetailView: View {
    let topic: StudyTopic
    // Checklist só visual: estado em memória, some ao fechar o app.
    @State private var done: Set<String> = []

    var body: some View {
        List {
            Section {
                LabeledContent("Matéria") {
                    Label(topic.subject, systemImage: topic.symbol)
                        .foregroundStyle(topic.color)
                }
                LabeledContent("Tópico", value: topic.title)
                LabeledContent("Prazo") {
                    Text(topic.deadline.formatted(date: .complete, time: .omitted))
                }
            }

            Section("O que revisar") {
                Text(topic.summary)
            }

            Section("Checklist") {
                ForEach(topic.checklist, id: \.self) { item in
                    Button {
                        if done.contains(item) { done.remove(item) } else { done.insert(item) }
                    } label: {
                        Label(item, systemImage: done.contains(item) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(done.contains(item) ? topic.color : .primary)
                    }
                    .sensoryFeedback(.selection, trigger: done)
                }
            }

            Section("Dica de estudo") {
                Label(topic.tip, systemImage: "lightbulb")
            }
        }
        .navigationTitle(topic.subject)
        .navigationBarTitleDisplayMode(.inline)
    }
}
