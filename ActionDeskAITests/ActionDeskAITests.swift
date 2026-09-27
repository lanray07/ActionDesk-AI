import XCTest
@testable import ActionDeskAI

final class ActionDeskAITests: XCTestCase {
    func testFixtureHasEvidenceAndNextSteps() {
        let item = AdminItem.fixtures[0]
        XCTAssertFalse(item.evidence.filter { $0.kind == .confirmed }.isEmpty)
        XCTAssertFalse(item.nextSteps.isEmpty)
        XCTAssertNotNil(item.deadline)
    }

    func testEveryStatusHasDisplayText() {
        XCTAssertTrue(ActionStatus.allCases.allSatisfy { !$0.titleText.isEmpty })
    }
}
