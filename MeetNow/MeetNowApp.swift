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
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow!
    var eventManager = EventManager() // We might need to share this, but for now duplicate or single source of truth?
    // Better: Helper to manage window
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupOverlayWindow()
        
        // Listen to EventManager updates
        // Note: In a real app we'd share the instance properly. 
        // For simplicity here, let's just make a new one or use a Singleton if needed.
        // But the App struct creates one. We need access to THAT one or pass it down.
        // It's tricky with Adaptor. 
        // Alternative: Make EventManager a singleton `shared`.
    }
    
    func setupOverlayWindow() {
        overlayWindow = NSWindow(
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
        EventManager.shared.$nextEvent
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
        guard let start = event.startDate else { return }
        let timeUntilStart = start.timeIntervalSinceNow
        
        // Show if starts in less than 5 minutes and hasn't ended
        let duration = event.endDate.timeIntervalSince(event.startDate)
        if timeUntilStart < 300 && timeUntilStart > -duration {
            let contentView = OverlayView(event: event)
            overlayWindow.contentView = NSHostingView(rootView: contentView)
            overlayWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            overlayWindow.orderOut(nil)
        }
    }
}


