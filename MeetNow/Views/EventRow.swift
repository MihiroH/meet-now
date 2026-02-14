import SwiftUI
import EventKit

struct EventRow: View {
    let event: EventKit.EKEvent
    @Environment(\.dismiss) private var dismiss
    
    private static let timeFormatter: DateFormatter = {
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
                Text("\(Self.timeFormatter.string(from: event.startDate)) - \(Self.timeFormatter.string(from: event.endDate))")
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
                
                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
            
            // Link Indicator at Right Edge
            if let url = MeetingLinkExtractor.meetingLink(for: event) {
                Image(systemName: "video.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .overlay(
                        Button(action: { 
                            NSWorkspace.shared.open(url) 
                            dismiss()
                        }) {
                            Color.clear
                        }
                        .buttonStyle(.plain)
                        .frame(width: 40, height: 40)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = MeetingLinkExtractor.meetingLink(for: event) {
                NSWorkspace.shared.open(url)
                dismiss()
            }
        }
    }
}
