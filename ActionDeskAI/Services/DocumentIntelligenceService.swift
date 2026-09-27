import Foundation

protocol DocumentIntelligenceService: Sendable {
    func analyze(text: String, outputLanguage: Locale.Language) async throws -> AdminItem
}

struct PreviewDocumentIntelligenceService: DocumentIntelligenceService {
    func analyze(text: String, outputLanguage: Locale.Language) async throws -> AdminItem {
        try await Task.sleep(for: .milliseconds(650))
        let lowered = text.lowercased()
        let isBill = lowered.contains("bill") || lowered.contains("due") || lowered.contains("£")
        return AdminItem(
            title: isBill ? "Imported bill" : "Imported document", source: "Pasted text", summary: "ActionDesk found information that may require your review. Verify important details against the original.",
            category: isBill ? .bills : .other, status: .review, priority: .dueSoon,
            deadline: nil, amount: nil, currencyCode: nil, suggestedAction: "Review the extracted information and add any missing deadline.",
            evidence: [.init(kind: .confirmed, label: "Source", value: "Pasted text"), .init(kind: .interpretation, label: "Document type", value: isBill ? "Possible bill" : "Unclassified document"), .init(kind: .unclear, label: "Deadline", value: "Not confidently identified")],
            nextSteps: [.init(title: "Check the extracted information"), .init(title: "Add a deadline if one applies")], timeline: [.init(date: .now, title: "Text imported", symbol: "doc.on.clipboard"), .init(date: .now, title: "Local preview analysis completed", symbol: "sparkles")]
        )
    }
}

