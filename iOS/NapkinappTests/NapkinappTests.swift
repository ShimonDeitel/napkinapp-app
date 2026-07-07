import XCTest
@testable import Napkinapp

@MainActor
final class NapkinappTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(NapkinappEntry(clientName: "Test", amount: 10, note: "n", date: Date()))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        let store = Store()
        store.entries = []
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtFreeLimit() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            NapkinappEntry(clientName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = false
        XCTAssertFalse(store.canAddMore)
        let result = store.add(NapkinappEntry(clientName: "Over", amount: 1, note: "", date: Date()))
        XCTAssertFalse(result)
    }

    func testProUserCanAlwaysAdd() {
        let store = Store()
        store.entries = (0..<Store.freeLimit).map { i in
            NapkinappEntry(clientName: "E\(i)", amount: 1, note: "", date: Date())
        }
        store.isPro = true
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteEntry() {
        let store = Store()
        let entry = NapkinappEntry(clientName: "ToDelete", amount: 5, note: "", date: Date())
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntry() {
        let store = Store()
        var entry = NapkinappEntry(clientName: "Original", amount: 5, note: "", date: Date())
        store.add(entry)
        entry.clientName = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.clientName, "Updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        store.entries = []
        store.add(NapkinappEntry(clientName: "A", amount: 1, note: "", date: Date()))
        store.add(NapkinappEntry(clientName: "B", amount: 1, note: "", date: Date()))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
    }
}
