import SwiftUI
import EventKit

struct MenuBarView: View {
    @ObservedObject var eventManager: EventManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Upcoming Events")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            Divider()
            
            if eventManager.upcomingEvents.isEmpty {
                Text("No upcoming events today")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(eventManager.upcomingEvents, id: \.eventIdentifier) { event in
                    EventRow(event: event)
                    Divider()
                }
            }
            
            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .padding()
        }
        .frame(minWidth: 250)
    }
}

struct EventRow: View {
    let event: EventKit.EKEvent
    
    var isNow: Bool {
        event.startDate < Date() && event.endDate > Date()
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                if isNow {
                    Text("NOW")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text(event.startDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 50, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text(event.title)
                    .fontWeight(isNow ? .semibold : .regular)
                    .lineLimit(2)
                
                Text(event.location ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isNow ? Color.green.opacity(0.1) : Color.clear)
    }
}
