import SwiftUI
import EventKit

struct MenuBarView: View {
    @ObservedObject var eventManager: EventManager
    @Environment(\.dismiss) private var dismiss
    
    private var nowEvents: [EKEvent] {
        let now = Date()
        return eventManager.upcomingEvents.filter { $0.startDate <= now && $0.endDate >= now }
    }
    
    private var futureEvents: [EKEvent] {
        let now = Date()
        return eventManager.upcomingEvents.filter { $0.startDate > now }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if eventManager.upcomingEvents.isEmpty {
                Text("No upcoming events today")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if !nowEvents.isEmpty {
                            SectionHeader(title: "Now")
                            
                            ForEach(nowEvents, id: \.eventIdentifier) { event in
                                EventRow(event: event)
                                if event != nowEvents.last || !futureEvents.isEmpty {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        
                        if !futureEvents.isEmpty {
                            SectionHeader(title: "Upcoming Events")
                            
                            ForEach(futureEvents, id: \.eventIdentifier) { event in
                                EventRow(event: event)
                                if event != futureEvents.last {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Preferences...") {
                    SettingsWindowController.shared.show()
                    dismiss()
                }
                .keyboardShortcut(",")
                .focusEffectDisabled()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .focusEffectDisabled()
            }
            .padding()
        }
        .frame(minWidth: 320, maxHeight: 400)
    }
}
