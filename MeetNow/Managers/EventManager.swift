import Foundation
import EventKit
import Combine

class EventManager: ObservableObject {
    static let shared = EventManager()
    private let store = EKEventStore()
    @Published var upcomingEvents: [EKEvent] = []
    
    var nextEvent: EKEvent? {
        upcomingEvents.first
    }
    
    @Published var hasAccess: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        requestAccess()
    }
    
    func requestAccess() {
        store.requestFullAccessToEvents { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.hasAccess = granted
                if granted {
                    self?.fetchEvents()
                    self?.observeStoreChanges()
                }
            }
        }
    }
    
    private func observeStoreChanges() {
        NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: store)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchEvents()
            }
            .store(in: &cancellables)
    }
    
    func fetchEvents() {
        let now = Date()
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: now) else { return }
        
        let predicate = store.predicateForEvents(withStart: now, end: end, calendars: nil)
        let events = store.events(matching: predicate)
        
        let upcoming = events
            .filter { !$0.isAllDay && $0.endDate > now }
            .sorted { $0.startDate < $1.startDate }
        
        DispatchQueue.main.async {
            self.upcomingEvents = upcoming
        }
    }
}
