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
                Text("No Upcoming Events: Next 24h")
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
                            SectionHeader(title: "Upcoming Events: Next 24h")

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

            VStack(spacing: 0) {
                MenuButton(title: "Settings...", shortcut: "⌘ ,") {
                    SettingsWindowController.shared.show()
                    dismiss()
                }
                .keyboardShortcut(",")

                MenuButton(title: "Quit", shortcut: "⌘ Q") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .padding(.vertical, 6)
        }
        .frame(minWidth: 320, maxHeight: 400)
    }
}

struct MenuButton: View {
    let title: String
    let shortcut: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 13))

                Spacer()

                Text(shortcut)
                    .font(.system(size: 12))
                    .foregroundColor(isHovered ? .white.opacity(0.8) : .secondary.opacity(0.6))
            }
            .foregroundColor(isHovered ? .white : .primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isHovered ? Color.accentColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 6)
        }
        .buttonStyle(.plain)
        .focusEffectDisabled()
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
