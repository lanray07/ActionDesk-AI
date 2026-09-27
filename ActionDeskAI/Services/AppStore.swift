import Foundation
import Observation

@MainActor @Observable
final class AppStore {
    var items: [AdminItem] = []
    var isLoaded = false
    private let repository = LocalRepository()

    func load() async {
        guard !isLoaded else { return }
        items = (try? await repository.load()) ?? AdminItem.fixtures
        if items.isEmpty { items = AdminItem.fixtures }
        isLoaded = true
    }

    func add(_ item: AdminItem) { items.insert(item, at: 0); persist() }
    func update(_ item: AdminItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item; persist()
    }
    func setStatus(_ status: ActionStatus, for id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].status = status
        items[index].timeline.append(.init(date: .now, title: status == .resolved ? "Marked resolved" : "Status updated", symbol: status == .resolved ? "checkmark.circle" : "arrow.triangle.2.circlepath"))
        persist()
    }
    func deleteAll() async { items = []; try? await repository.deleteAll() }
    private func persist() { let snapshot = items; Task { try? await repository.save(snapshot) } }
}

