import Foundation

class ScenarioDataManager: ObservableObject {
    static var shared = ScenarioDataManager()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    @Published var scenarios: [Scenario]

    // MARK: - Init

    init() {
        scenarios = []
        scenarios = get().sorted(by: { $0.timestamp > $1.timestamp })
    }

    // MARK: - Get

    fileprivate func get() -> [Scenario] {
        guard !UserProperties.scenariosData.isEmpty else { return [] }

        do {
            return try decoder.decode([Scenario].self, from: UserProperties.scenariosData)
        } catch {
            RuntimeError.track(error)
            return []
        }
    }

    func scenario(withId id: UUID) -> Scenario? {
        return get().first(where: { $0.id == id })
    }

    // MARK: - Set

    func set(scenarios: [Scenario]) {
        do {
            UserProperties.scenariosData = try encoder.encode(scenarios)
            self.scenarios = get()
        } catch {
            RuntimeError.track(error)
        }
    }

    // MARK: - Add

    func add(_ scenario: Scenario) {
        var scenarios = get()
        scenarios.insert(scenario, at: 0)
        set(scenarios: scenarios)
    }

    // MARK: - Edit

    func edit(_ scenario: Scenario) {
        var scenarios = get()
        if let index = scenarios.firstIndex(where: { $0.id == scenario.id }) {
            scenarios.remove(at: index)
            scenarios.insert(scenario, at: index)
        }
        set(scenarios: scenarios)
    }

    // MARK: - Remove

    func remove(_ scenario: Scenario) {
        var scenarios = get()
        if let index = scenarios.firstIndex(where: { $0.id == scenario.id }) {
            scenarios.remove(at: index)
        }
        set(scenarios: scenarios)
    }

    func remove(_ scenarioId: UUID) {
        var scenarios = get()
        if let index = scenarios.firstIndex(where: { $0.id == scenarioId }) {
            scenarios.remove(at: index)
        }
        set(scenarios: scenarios)
    }

    func remove(at index: Int) {
        var scenarios = get()
        scenarios.remove(at: index)
        set(scenarios: scenarios)
    }
}
