import Foundation
import EventKit
import Combine

class EventManager: ObservableObject {
    static let shared = EventManager()
    private let store = EKEventStore()
    @Published var upcomingEvents: [EKEvent] = []
    
    var nextEvent: EKEvent? {
        return upcomingEvents.first
    }
    
    @Published var hasAccess: Bool = false
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged), name: .EKEventStoreChanged, object: store)
    }
    
    @objc func storeChanged() {
        fetchEvents()
    }
    
    func fetchEvents() {
        // Look for events in the next 24 hours
        let now = Date()
        let end = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        let predicate = store.predicateForEvents(withStart: now, end: end, calendars: nil)
        let events = store.events(matching: predicate)
        
        // Filter for events that haven't ended yet and are not all-day (unless requested)
        let upcoming = events
            .filter { !$0.isAllDay && $0.endDate > now }
            .sorted { $0.startDate < $1.startDate }
        
        DispatchQueue.main.async {
            self.upcomingEvents = upcoming
        }
    }
}
