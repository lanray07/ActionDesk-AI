import Foundation
import SwiftUI

enum ActionStatus: String, Codable, CaseIterable, Hashable {
    case new, review, actionNeeded, waiting, scheduled, resolved, archived
    var title: LocalizedStringKey { LocalizedStringKey("status.\(rawValue)") }
    var titleText: String { String(localized: String.LocalizationValue("status.\(rawValue)")) }
    var color: Color {
        switch self { case .new, .review: ADColor.calm; case .actionNeeded: ADColor.urgent; case .waiting, .scheduled: ADColor.warning; case .resolved: ADColor.accent; case .archived: .secondary }
    }
}

enum ActionPriority: String, Codable, Hashable { case urgent, dueSoon, upcoming, routine }
enum DocumentCategory: String, Codable, CaseIterable, Hashable { case bills, subscriptions, insurance, receipts, warranties, returns, appointments, contracts, government, health, other }
enum EvidenceKind: String, Codable, Hashable { case confirmed, interpretation, unclear }

struct EvidenceItem: Identifiable, Codable, Hashable {
    var id = UUID(); let kind: EvidenceKind; let label: String; let value: String
}

struct NextStep: Identifiable, Codable, Hashable {
    var id = UUID(); var title: String; var isComplete = false; var canRemind = true
}

struct TimelineEvent: Identifiable, Codable, Hashable {
    var id = UUID(); let date: Date; let title: String; let symbol: String
}

struct AdminItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var source: String
    var summary: String
    var category: DocumentCategory
    var status: ActionStatus
    var priority: ActionPriority
    var deadline: Date?
    var amount: Decimal?
    var currencyCode: String?
    var suggestedAction: String
    var evidence: [EvidenceItem]
    var nextSteps: [NextStep]
    var timeline: [TimelineEvent]
    var createdAt: Date = .now
}

struct ChatMessage: Identifiable, Hashable {
    var id = UUID(); let role: Role; let text: String
    enum Role: Hashable { case user, assistant }
}

