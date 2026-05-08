import Foundation

// MARK: - Session metrics (local only)
struct MindGardenSessionMetrics: Codable, Identifiable {
    let id: UUID
    let createdAt: Date

    // Interaction 1: Stars (seconds)
    var starsTimeS: Double?

    // Interaction 2: Petals (tap counts)
    var petalTargetTaps: Int?
    var petalNonTargetTaps: Int?

    // Interaction 3: Vine (tap counts)
    var vineCorrectTaps: Int?
    var vineEarlyTaps: Int?
    var vineNonTargetTaps: Int?

    init(id: UUID = UUID(), createdAt: Date = Date()) {
        self.id = id
        self.createdAt = createdAt
    }

    var isComplete: Bool {
        starsTimeS != nil &&
        petalTargetTaps != nil && petalNonTargetTaps != nil &&
        vineCorrectTaps != nil && vineEarlyTaps != nil && vineNonTargetTaps != nil
    }
}

// MARK: - Local store (UserDefaults + JSON)
@MainActor
final class MindGardenMetricsStore {
    static let shared = MindGardenMetricsStore()

    private let key = "MindGardenSessionMetrics.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // Load all sessions (ascending by time)
    func loadAll() -> [MindGardenSessionMetrics] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        do {
            return try decoder.decode([MindGardenSessionMetrics].self, from: data)
        } catch {
            // Return empty on decode failure
            return []
        }
    }

    // Overwrite all sessions
    private func saveAll(_ list: [MindGardenSessionMetrics]) {
        guard let data = try? encoder.encode(list) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    // Start new session
    @discardableResult
    func startNewSession() -> UUID {
        var list = loadAll()
        let s = MindGardenSessionMetrics()
        list.append(s)
        saveAll(list)
        return s.id
    }

    // Ensure latest session (auto-create if empty)
    private func ensureLatestSession() -> (list: [MindGardenSessionMetrics], index: Int) {
        var list = loadAll()
        if list.isEmpty {
            let s = MindGardenSessionMetrics()
            list.append(s)
            saveAll(list)
            return (list, 0)
        }
        return (list, list.count - 1)
    }

    // Optional write by sessionId
    private func findSessionIndex(_ id: UUID, in list: [MindGardenSessionMetrics]) -> Int? {
        list.firstIndex(where: { $0.id == id })
    }

    // MARK: - Write: Interaction 1
    func recordStars(timeS: Double, sessionId: UUID? = nil) {
        var list = loadAll()
        let idx: Int
        if let sid = sessionId, let i = findSessionIndex(sid, in: list) {
            idx = i
        } else {
            let ensured = ensureLatestSession()
            list = ensured.list
            idx = ensured.index
        }

        list[idx].starsTimeS = timeS
        saveAll(list)
    }

    // MARK: - Write: Interaction 2
    func recordPetals(targetTaps: Int, nonTargetTaps: Int, sessionId: UUID? = nil) {
        var list = loadAll()
        let idx: Int
        if let sid = sessionId, let i = findSessionIndex(sid, in: list) {
            idx = i
        } else {
            let ensured = ensureLatestSession()
            list = ensured.list
            idx = ensured.index
        }

        list[idx].petalTargetTaps = targetTaps
        list[idx].petalNonTargetTaps = nonTargetTaps
        saveAll(list)
    }

    // MARK: - Write: Interaction 3
    func recordVine(correct: Int, early: Int, nonTarget: Int, sessionId: UUID? = nil) {
        var list = loadAll()
        let idx: Int
        if let sid = sessionId, let i = findSessionIndex(sid, in: list) {
            idx = i
        } else {
            let ensured = ensureLatestSession()
            list = ensured.list
            idx = ensured.index
        }

        list[idx].vineCorrectTaps = correct
        list[idx].vineEarlyTaps = early
        list[idx].vineNonTargetTaps = nonTarget
        saveAll(list)
    }

    // MARK: - Read: Latest session
    func latest() -> MindGardenSessionMetrics? {
        loadAll().last
    }

    // MARK: - Clear store
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
