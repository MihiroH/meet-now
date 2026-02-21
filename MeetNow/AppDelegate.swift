import Combine
import EventKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayWindow: OverlayWindow!
    private var cancellables = Set<AnyCancellable>()
    private var dismissedEventIdentifiers = Set<String>()
    private var currentlyShownEventID: String?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        UserDefaults.standard.register(defaults: ["reminderOffset": 5.0])

        setupOverlayWindow()

        NotificationCenter.default.addObserver(
            self, selector: #selector(closeOverlay), name: .closeOverlay, object: nil)

        // Resize overlay when display configuration changes
        NotificationCenter.default.publisher(
            for: NSApplication.didChangeScreenParametersNotification
        )
        .sink { [weak self] _ in
            if let screen = NSScreen.main {
                self?.overlayWindow.setFrame(screen.visibleFrame, display: true)
            }
        }
        .store(in: &cancellables)
    }

    @objc private func closeOverlay() {
        if let eventID = currentlyShownEventID {
            dismissedEventIdentifiers.insert(eventID)
        }
        overlayWindow.orderOut(nil)
        currentlyShownEventID = nil
    }

    private func setupOverlayWindow() {
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

        // Multi-source Combine pipeline: triggers on calendar changes OR every 10 seconds
        Publishers.CombineLatest(
            EventManager.shared.$upcomingEvents,
            Timer.publish(every: 10, on: .main, in: .common).autoconnect().prepend(Date())
        )
        .map { [weak self] events, _ -> EKEvent? in
            guard let self = self else { return events.first }
            
            // Prune dismissed IDs for events that are no longer in today's list
            let currentIDs = Set(events.compactMap(\.eventIdentifier))
            self.dismissedEventIdentifiers.formIntersection(currentIDs)
            
            // Back-to-back priority logic:
            // Find an event that hasn't been dismissed and is within its reminder window.
            let offsetMinutes = UserDefaults.standard.double(forKey: "reminderOffset")
            let offsetSeconds = offsetMinutes * 60
            
            // Priority 1: Events that haven't started yet but are within the reminder window.
            if let upcoming = events.first(where: { event in
                let timeUntilStart = event.startDate.timeIntervalSinceNow
                return timeUntilStart > 0 && timeUntilStart < offsetSeconds && !self.dismissedEventIdentifiers.contains(event.eventIdentifier)
            }) {
                return upcoming
            }
            
            // Priority 2: Currently active event (started but not yet finished), if not dismissed.
            if let active = events.first(where: { event in
                let timeUntilStart = event.startDate.timeIntervalSinceNow
                let duration = event.endDate.timeIntervalSince(event.startDate)
                return timeUntilStart <= 0 && timeUntilStart > -duration && !self.dismissedEventIdentifiers.contains(event.eventIdentifier)
            }) {
                return active
            }
            
            return events.first
        }
        .sink { [weak self] event in
            if let event = event {
                self?.checkShouldShow(event)
            } else {
                self?.overlayWindow.orderOut(nil)
            }
        }
        .store(in: &cancellables)
    }

    private func checkShouldShow(_ event: EventKit.EKEvent) {
        guard !dismissedEventIdentifiers.contains(event.eventIdentifier) else {
            if currentlyShownEventID == event.eventIdentifier {
                overlayWindow.orderOut(nil)
                currentlyShownEventID = nil
            }
            return
        }

        let timeUntilStart = event.startDate.timeIntervalSinceNow

        let offsetMinutes = UserDefaults.standard.double(forKey: "reminderOffset")
        let offsetSeconds = offsetMinutes * 60

        let duration = event.endDate.timeIntervalSince(event.startDate)
        if timeUntilStart < offsetSeconds && timeUntilStart > -duration {
            if !overlayWindow.isVisible || currentlyShownEventID != event.eventIdentifier {
                // Determine the active screen (where the mouse is)
                let mouseLocation = NSEvent.mouseLocation
                let activeScreen = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) } ?? NSScreen.main
                
                if let screen = activeScreen {
                    overlayWindow.setFrame(screen.visibleFrame, display: true)
                }

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
