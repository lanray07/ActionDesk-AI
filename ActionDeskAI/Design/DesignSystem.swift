import SwiftUI

enum ADColor {
    static let accent = Color(red: 0.08, green: 0.42, blue: 0.38)
    static let urgent = Color(red: 0.78, green: 0.22, blue: 0.18)
    static let warning = Color(red: 0.83, green: 0.48, blue: 0.08)
    static let calm = Color(red: 0.18, green: 0.42, blue: 0.68)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    static let background = Color(uiColor: .systemGroupedBackground)
}

struct ADCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(16)
            .background(ADColor.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct StatusPill: View {
    let status: ActionStatus
    var body: some View {
        Text(status.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 9).padding(.vertical, 5)
            .background(status.color.opacity(0.12), in: Capsule())
            .accessibilityLabel(Text("accessibility.status \(status.titleText)"))
    }
}

