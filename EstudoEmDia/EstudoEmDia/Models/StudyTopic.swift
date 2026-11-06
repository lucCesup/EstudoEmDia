import SwiftUI

/// Um assunto de estudo. Dados fixos no código: o foco do trabalho é o push, não o armazenamento.
struct StudyTopic: Identifiable, Hashable {
    /// O mesmo valor que a notificação do desafio 3 manda em `topicId`.
    let id: String
    let subject: String
    let title: String
    let deadline: Date
    let summary: String
    let checklist: [String]
    let tip: String
    let symbol: String
    let color: Color

    /// Prazos relativos a hoje, para nunca ficarem no passado na hora de gravar o vídeo.
    private static func inDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
    }

    static var samples: [StudyTopic] {
        [
            StudyTopic(
                id: "matematica-derivadas", subject: "Matemática",
                title: "Derivadas e regra da cadeia", deadline: inDays(2),
                summary: "Revisar as regras básicas de derivação e praticar a regra da cadeia em funções compostas.",
                checklist: ["Rever a tabela de derivadas", "Resolver 5 exercícios de regra da cadeia", "Refazer os erros da última lista"],
                tip: "Identifique primeiro a função de fora e a de dentro; só depois derive.",
                symbol: "function", color: .blue),
            StudyTopic(
                id: "programacao-recursao", subject: "Programação",
                title: "Recursão", deadline: inDays(3),
                summary: "Entender caso base e caso recursivo, e acompanhar a pilha de chamadas passo a passo.",
                checklist: ["Escrever fatorial e Fibonacci", "Desenhar a pilha de chamadas", "Converter um laço em recursão"],
                tip: "Sempre escreva o caso base antes de qualquer outra coisa.",
                symbol: "chevron.left.forwardslash.chevron.right", color: .indigo),
            StudyTopic(
                id: "banco-normalizacao", subject: "Banco de Dados",
                title: "Normalização (1FN–3FN)", deadline: inDays(4),
                summary: "Aplicar a 1ª, 2ª e 3ª formas normais para eliminar redundância em tabelas.",
                checklist: ["Identificar dependências funcionais", "Normalizar o exemplo da aula até a 3FN", "Montar o diagrama final"],
                tip: "Pergunte a cada coluna: ela depende da chave, de toda a chave e só da chave?",
                symbol: "cylinder.split.1x2", color: .orange),
            StudyTopic(
                id: "redes-subredes", subject: "Redes",
                title: "Sub-redes IPv4", deadline: inDays(5),
                summary: "Calcular máscara, endereço de rede, broadcast e faixa de hosts de uma sub-rede.",
                checklist: ["Converter máscaras CIDR", "Dividir uma rede /24 em 4 sub-redes", "Fazer 3 exercícios de hosts por sub-rede"],
                tip: "Pense em potências de 2: cada bit emprestado dobra o número de sub-redes.",
                symbol: "network", color: .teal),
            StudyTopic(
                id: "fisica-newton", subject: "Física",
                title: "Leis de Newton", deadline: inDays(6),
                summary: "Rever inércia, F = m·a e ação e reação, aplicando em diagramas de forças.",
                checklist: ["Desenhar o diagrama de forças", "Resolver problemas de plano inclinado", "Revisar exemplos de ação e reação"],
                tip: "Comece sempre pelo diagrama de corpo livre, antes de escrever equações.",
                symbol: "atom", color: .red),
            StudyTopic(
                id: "ingles-present-perfect", subject: "Inglês",
                title: "Present Perfect", deadline: inDays(7),
                summary: "Usar have/has + particípio para experiências e ações com ligação ao presente.",
                checklist: ["Listar 10 particípios irregulares", "Escrever 5 frases com for e since", "Diferenciar do Past Simple"],
                tip: "Se o momento exato não importa, provavelmente é Present Perfect.",
                symbol: "character.book.closed", color: .green),
        ]
    }

    /// Procura um assunto pelo id vindo da notificação.
    static func find(id: String) -> StudyTopic? {
        samples.first { $0.id == id }
    }
}
