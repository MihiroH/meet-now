import SwiftUI
import EventKit
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayWindow: OverlayWindow!
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        // Register default defaults
        UserDefaults.standard.register(defaults: ["reminderOffset": 5.0])
        
        setupOverlayWindow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeOverlay), name: .closeOverlay, object: nil)
        
        // Timer to check for overlay trigger
        Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            if let event = EventManager.shared.nextEvent {
                self?.checkShouldShow(event)
            }
        }
    }
    
    private var dismissedEventIdentifiers = Set<String>()
    
    @objc func closeOverlay() {
        if let eventID = EventManager.shared.nextEvent?.eventIdentifier {
            dismissedEventIdentifiers.insert(eventID)
        }
        overlayWindow.orderOut(nil)
    }
    
    func setupOverlayWindow() {
        overlayWindow = OverlayWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        overlayWindow.isOpaque = false
        overlayWindow.backgroundColor = .clear
        overlayWindow.level = .floating
        overlayWindow.ignoresMouseEvents = false
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        if let screen = NSScreen.main {
            overlayWindow.setFrame(screen.visibleFrame, display: true)
        }
        
        EventManager.shared.$upcomingEvents
            .map { $0.first }
            .sink { [weak self] event in
                if let event = event {
                    self?.checkShouldShow(event)
                } else {
                    self?.overlayWindow.orderOut(nil)
                }
            }
            .store(in: &cancellables)
    }
    
    private var currentlyShownEventID: String?
    
    func checkShouldShow(_ event: EventKit.EKEvent) {
        guard !dismissedEventIdentifiers.contains(event.eventIdentifier) else { 
            if currentlyShownEventID == event.eventIdentifier {
                overlayWindow.orderOut(nil)
                currentlyShownEventID = nil
            }
            return 
        }
        
        guard let start = event.startDate else { return }
        let timeUntilStart = start.timeIntervalSinceNow
        
        let offsetMinutes = UserDefaults.standard.double(forKey: "reminderOffset")
        let offsetSeconds = offsetMinutes * 60
        
        let duration = event.endDate.timeIntervalSince(event.startDate)
        if timeUntilStart < offsetSeconds && timeUntilStart > -duration {
            if !overlayWindow.isVisible || currentlyShownEventID != event.eventIdentifier {
                let contentView = OverlayView(event: event)
                overlayWindow.contentView = NSHostingView(rootView: contentView)
                overlayWindow.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                currentlyShownEventID = event.eventIdentifier
            }
        } else {
            if overlayWindow.isVisible && currentlyShownEventID == event.eventIdentifier {
                overlayWindow.orderOut(nil)
                currentlyShownEventID = nil
            }
        }
    }
}
