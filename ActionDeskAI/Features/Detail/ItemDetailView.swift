import SwiftUI

struct ItemDetailView: View {
    @Environment(AppStore.self) private var store
    let itemID: UUID
    @State private var reminderChoice: Int?
    @State private var showReminderConfirmation = false

    private var item: AdminItem? { store.items.first { $0.id == itemID } }

    var body: some View {
        Group {
            if let item {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header(item)
                        nextSteps(item)
                        evidence(item)
                        actions(item)
                        timeline(item)
                        Text("detail.disclaimer").font(.caption).foregroundStyle(.secondary).padding(.horizontal, 4)
                    }.padding(16)
                }.background(ADColor.background)
                    .navigationTitle(item.title).navigationBarTitleDisplayMode(.inline)
                    .toolbar { Menu { Button("action.resolve") { store.setStatus(.resolved, for: item.id) }; Button("action.archive") { store.setStatus(.archived, for: item.id) } } label: { Image(systemName: "ellipsis.circle") } }
            } else { ContentUnavailableView("detail.missing", systemImage: "doc.questionmark") }
        }
        .alert("reminder.created", isPresented: $showReminderConfirmation) { Button("action.ok", role: .cancel) {} }
    }

    private func header(_ item: AdminItem) -> some View {
        ADCard { VStack(alignment: .leading, spacing: 12) {
            HStack { Label(item.source, systemImage: item.category.symbol).font(.subheadline.weight(.semibold)); Spacer(); StatusPill(status: item.status) }
            Text(item.summary).font(.title3.weight(.medium)).fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 18) {
                if let amount = item.amount, let code = item.currencyCode { Label(amount.formatted(.currency(code: code)), systemImage: "sterlingsign.circle").font(.headline) }
                if let deadline = item.deadline { Label { Text(deadline, format: .dateTime.day().month(.wide)) } icon: { Image(systemName: "calendar") }.font(.headline) }
            }
        } }
    }

    private func nextSteps(_ item: AdminItem) -> some View {
        ADCard { VStack(alignment: .leading, spacing: 14) {
            Label("detail.nextSteps", systemImage: "checklist").font(.title3.bold())
            ForEach(Array(item.nextSteps.enumerated()), id: \.element.id) { index, step in
                Button { toggleStep(step.id, in: item) } label: {
                    HStack(alignment: .top, spacing: 12) { Image(systemName: step.isComplete ? "checkmark.circle.fill" : "\(index + 1).circle").foregroundStyle(step.isComplete ? ADColor.accent : .secondary); Text(step.title).strikethrough(step.isComplete).foregroundStyle(.primary); Spacer(); if step.canRemind { Image(systemName: "bell").foregroundStyle(.secondary) } }
                }.buttonStyle(.plain)
                if index < item.nextSteps.count - 1 { Divider().padding(.leading, 34) }
            }
        } }
    }

    private func evidence(_ item: AdminItem) -> some View {
        VStack(spacing: 12) {
            EvidenceSection(title: "detail.confirmed", symbol: "checkmark.shield", color: ADColor.accent, items: item.evidence.filter { $0.kind == .confirmed })
            EvidenceSection(title: "detail.interpretation", symbol: "sparkles", color: ADColor.calm, items: item.evidence.filter { $0.kind == .interpretation })
            EvidenceSection(title: "detail.unclear", symbol: "questionmark.diamond", color: ADColor.warning, items: item.evidence.filter { $0.kind == .unclear })
        }
    }

    private func actions(_ item: AdminItem) -> some View {
        ADCard { VStack(alignment: .leading, spacing: 12) {
            Text("detail.actions").font(.headline)
            HStack { ActionButton(title: "action.remind", symbol: "bell") { Task { try? await ReminderService.schedule(for: item, daysBefore: 3); showReminderConfirmation = true } }; ActionButton(title: "action.draft", symbol: "square.and.pencil") {}; ActionButton(title: "action.askAI", symbol: "sparkles") {} }
        } }
    }

    private func timeline(_ item: AdminItem) -> some View {
        ADCard { VStack(alignment: .leading, spacing: 14) { Text("detail.timeline").font(.headline); ForEach(item.timeline.sorted { $0.date > $1.date }) { event in HStack(alignment: .top, spacing: 12) { Image(systemName: event.symbol).foregroundStyle(ADColor.accent).frame(width: 22); VStack(alignment: .leading) { Text(event.title).font(.subheadline.weight(.medium)); Text(event.date, format: .dateTime.day().month(.abbreviated).hour().minute()).font(.caption).foregroundStyle(.secondary) } } } } }
    }

    private func toggleStep(_ id: UUID, in item: AdminItem) { var changed = item; guard let index = changed.nextSteps.firstIndex(where: { $0.id == id }) else { return }; changed.nextSteps[index].isComplete.toggle(); store.update(changed) }
}

private struct EvidenceSection: View {
    let title: LocalizedStringKey; let symbol: String; let color: Color; let items: [EvidenceItem]
    var body: some View { if !items.isEmpty { ADCard { VStack(alignment: .leading, spacing: 12) { Label(title, systemImage: symbol).font(.headline).foregroundStyle(color); ForEach(items) { item in HStack(alignment: .top) { Text(item.label).foregroundStyle(.secondary); Spacer(); Text(item.value).multilineTextAlignment(.trailing).fontWeight(.medium) } } } } } }
}

private struct ActionButton: View {
    let title: LocalizedStringKey; let symbol: String; let action: () -> Void
    var body: some View { Button(action: action) { VStack(spacing: 7) { Image(systemName: symbol).font(.title3); Text(title).font(.caption.weight(.semibold)).lineLimit(1).minimumScaleFactor(0.7) }.frame(maxWidth: .infinity).padding(.vertical, 11).background(ADColor.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12)) }.buttonStyle(.plain).foregroundStyle(ADColor.accent) }
}

