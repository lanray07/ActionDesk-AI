import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case inbox, documents, assistant, search, settings

    var title: LocalizedStringKey {
        switch self {
        case .inbox: "tab.inbox"
        case .documents: "tab.documents"
        case .assistant: "tab.assistant"
        case .search: "tab.search"
        case .settings: "tab.settings"
        }
    }

    var symbol: String {
        switch self {
        case .inbox: "tray.full"
        case .documents: "doc.text"
        case .assistant: "sparkles"
        case .search: "magnifyingglass"
        case .settings: "gearshape"
        }
    }
}

enum SheetDestination: Identifiable, Equatable {
    case capture, paywall
    var id: String { self == .capture ? "capture" : "paywall" }
}

