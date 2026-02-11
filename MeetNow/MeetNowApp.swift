import SwiftUI

@main
struct MeetNowApp: App {
    @StateObject private var eventManager = EventManager.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("MeetNow", systemImage: "calendar") {
            MenuBarView(eventManager: eventManager)
        }
        .menuBarExtraStyle(.window)
    }
}
