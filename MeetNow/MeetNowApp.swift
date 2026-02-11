import SwiftUI
import EventKit
import Combine

@main
struct MeetNowApp: App {
    @ObservedObject private var eventManager = EventManager.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("MeetNow", systemImage: "calendar") {
            MenuBarView(eventManager: eventManager)
        }
        
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: OverlayWindow!
    // var eventManager = EventManager() // Removed redundant instance
    // Better: Helper to manage window
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register default defaults
        UserDefaults.standard.register(defaults: ["reminderOffset": 5.0])
        
        setupOverlayWindow()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeOverlay), name: Notification.Name("CloseOverlay"), object: nil)
        
        // Timer to check for overlay trigger
        Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            if let event = EventManager.shared.nextEvent {
                self?.checkShouldShow(event)
            }
        }
    }
    
    var dismissedEventIdentifiers = Set<String>()
    
    @objc func closeOverlay() {
        if let eventID = EventManager.shared.nextEvent?.eventIdentifier {
            dismissedEventIdentifiers.insert(eventID)
        }
        overlayWindow.orderOut(nil)
    }
    
    func setupOverlayWindow() {
        overlayWindow = OverlayWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600), // Size doesn't matter much if fullscreen
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        overlayWindow.isOpaque = false
        overlayWindow.backgroundColor = .clear
        overlayWindow.level = .floating // Keep it on top
        overlayWindow.ignoresMouseEvents = false
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Center or Fullscreen
        if let screen = NSScreen.main {
            overlayWindow.setFrame(screen.visibleFrame, display: true)
        }
        
        // We need to access the EventManager to know when to show the window
        // Let's use a Singleton for EventManager to simplify communication
        EventManager.shared.$upcomingEvents
            .map { $0.first }
            .sink { [weak self] event in
                if let event = event {
                    // Logic: Show if starting soon (e.g. < 2 mins)
                    // For demo, just show if there is ANY next event that is starting soon?
                    // Let's rely on EventManager to tell us "shouldShowOverlay" or check time here.
                    self?.checkShouldShow(event)
                } else {
                    self?.overlayWindow.orderOut(nil)
                }
            }
            .store(in: &cancellables)
    }
    
    func checkShouldShow(_ event: EventKit.EKEvent) {
        guard !dismissedEventIdentifiers.contains(event.eventIdentifier) else { return }
        
        guard let start = event.startDate else { return }
        let timeUntilStart = start.timeIntervalSinceNow
        
        // Get reminder offset from settings (default 5.0 minutes)
        let offsetMinutes = UserDefaults.standard.double(forKey: "reminderOffset")
        let offsetSeconds = offsetMinutes * 60
        
        // Show if starts in less than X minutes and hasn't ended
        let duration = event.endDate.timeIntervalSince(event.startDate)
        if timeUntilStart < offsetSeconds && timeUntilStart > -duration {
            let contentView = OverlayView(event: event)
            overlayWindow.contentView = NSHostingView(rootView: contentView)
            overlayWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            overlayWindow.orderOut(nil)
        }
    }
}


