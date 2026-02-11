import Foundation
import EventKit
import Combine

class EventManager: ObservableObject {
    static let shared = EventManager()
    private let store = EKEventStore()
    @Published var nextEvent: EKEvent?
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
                    self?.startTimer()
                }
            }
        }
    }
    
    func startTimer() {
        // Check every minute
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.fetchEvents()
        }
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
            self.nextEvent = upcoming.first
        }
    }
}
