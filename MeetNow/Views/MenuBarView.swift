import SwiftUI

struct MenuBarView: View {
    @ObservedObject var eventManager: EventManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let event = eventManager.nextEvent {
                Text("Up Next:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    if let color = event.calendar?.cgColor {
                         Circle()
                            .fill(Color(nsColor: NSColor(cgColor: color) ?? .blue))
                            .frame(width: 8, height: 8)
                    }
                    Text(event.title)
                        .font(.headline)
                }
                
                if let startDate = event.startDate {
                    Text(startDate, style: .relative) + Text(" remaining")
                }
                
                Divider()
                
                Button("Join Now") {
                    if let url = event.url {
                        NSWorkspace.shared.open(url)
                    }
                }
            } else {
                Text("No upcoming events")
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding()
    }
}
