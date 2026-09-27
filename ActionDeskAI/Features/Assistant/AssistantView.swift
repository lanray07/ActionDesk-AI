import SwiftUI

struct AssistantView: View {
    @Environment(AppStore.self) private var store
    @State private var draft = ""
    @State private var messages: [ChatMessage] = [.init(role: .assistant, text: String(localized: "assistant.welcome"))]
    @FocusState private var focused: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    quickPrompts
                    ForEach(messages) { message in MessageBubble(message: message).id(message.id) }
                }.padding(16)
            }
            .background(ADColor.background).navigationTitle("assistant.title")
            .safeAreaInset(edge: .bottom) { inputBar }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.count) { _, _ in if let id = messages.last?.id { withAnimation { proxy.scrollTo(id, anchor: .bottom) } } }
        }
    }

    private var quickPrompts: some View {
        ScrollView(.horizontal, showsIndicators: false) { HStack { ForEach(["assistant.prompt.attention", "assistant.prompt.renewals", "assistant.prompt.waiting"], id: \.self) { key in Button(String(localized: String.LocalizationValue(key))) { submit(String(localized: String.LocalizationValue(key))) }.buttonStyle(.bordered).buttonBorderShape(.capsule) } } }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            Button { draft = String(localized: "assistant.voice.preview") } label: { Image(systemName: "waveform.circle.fill").font(.title2) }.accessibilityLabel("assistant.voice")
            TextField("assistant.input", text: $draft, axis: .vertical).lineLimit(1...4).focused($focused).textFieldStyle(.plain)
            Button { submit(draft) } label: { Image(systemName: "arrow.up.circle.fill").font(.title2) }.disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty).accessibilityLabel("assistant.send")
        }.padding(12).background(.regularMaterial).overlay(alignment: .top) { Divider() }
    }

    private func submit(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines); guard !query.isEmpty else { return }
        messages.append(.init(role: .user, text: query)); draft = ""
        let response: String
        if query.localizedCaseInsensitiveContains("waiting") { response = store.items.filter { $0.status == .waiting }.isEmpty ? String(localized: "assistant.noneWaiting") : store.items.filter { $0.status == .waiting }.map(\.title).joined(separator: "\n• ") }
        else if query.localizedCaseInsensitiveContains("due") || query.localizedCaseInsensitiveContains("attention") { response = store.items.filter { $0.status == .actionNeeded || $0.priority == .urgent }.map { "• \($0.title): \($0.suggestedAction)" }.joined(separator: "\n") }
        else { response = String(localized: "assistant.scope") }
        messages.append(.init(role: .assistant, text: response.isEmpty ? String(localized: "assistant.noMatches") : response))
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    var body: some View { HStack { if message.role == .user { Spacer(minLength: 48) }; Text(message.text).font(.body).padding(13).background(message.role == .user ? ADColor.accent : ADColor.surface, in: RoundedRectangle(cornerRadius: 16)).foregroundStyle(message.role == .user ? .white : .primary); if message.role == .assistant { Spacer(minLength: 48) } }.frame(maxWidth: .infinity) }
}

