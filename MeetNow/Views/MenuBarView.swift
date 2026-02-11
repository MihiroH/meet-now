import SwiftUI
import EventKit

struct MenuBarView: View {
    @ObservedObject var eventManager: EventManager
    

    
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

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 2)
    }
}

struct EventRow: View {
    let event: EventKit.EKEvent
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var isNow: Bool {
        let now = Date()
        return event.startDate <= now && event.endDate >= now
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Time Section
            VStack(alignment: .center) {
                Text("\(timeFormatter.string(from: event.startDate)) - \(timeFormatter.string(from: event.endDate))")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(isNow ? .white : .primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isNow ? Color.green : Color.clear)
                    )
            }
            .frame(width: 110)
            
            // Info Section
            VStack(alignment: .leading, spacing: 0) {
                Text(event.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
