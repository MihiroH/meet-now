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
        .menuBarExtraStyle(.window)
    }
}
