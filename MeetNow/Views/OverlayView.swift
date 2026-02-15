import AppKit
import EventKit
import SwiftUI

struct OverlayView: View {
    let event: EKEvent

    @State private var showTitle = false
    @State private var showTime = false
    @State private var showActions = false

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private var timeRangeString: String {
        let formatter = Self.timeFormatter
        return
            "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
    }

    private var meetingURL: URL? {
        MeetingLinkExtractor.meetingLink(for: event)
    }

    var body: some View {
        let buttonGradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.75, green: 1.0, blue: 0.4), Color(red: 0.2, green: 0.9, blue: 0.8),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        ZStack {
            // "Pro" Native macOS Blur
            VisualEffectView(
                material: .headerView,
                blendingMode: .behindWindow,
                appearance: NSAppearance(named: .aqua)
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Spacer()

                Spacer().frame(height: 48)

                // 1. Sharp Pro Title
                VStack(spacing: 12) {
                    Text(event.title)
                        .font(.system(size: 64, weight: .heavy))
                        .foregroundColor(Color(white: 0.1))
                        .multilineTextAlignment(.center)
                        .kerning(-1.5)
                }
                .padding(.horizontal, 80)
                .opacity(showTitle ? 1 : 0)
                .scaleEffect(showTitle ? 1 : 0.98)

                Spacer().frame(height: 24)

                // 2. Simple Time Range
                Text(timeRangeString)
                    .font(.system(size: 32, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.black.opacity(0.3))
                    .opacity(showTime ? 1 : 0)
                    .offset(y: showTime ? 0 : 10)

                // Adaptive Spacing: Tighter if no join button
                Spacer().frame(height: meetingURL == nil ? 48 : 80)

                // 3. Focused Action Blocks
                VStack(spacing: meetingURL == nil ? 0 : 32) {
                    if let url = meetingURL {
                        Button(action: {
                            NSWorkspace.shared.open(url)
                            NotificationCenter.default.post(name: .closeOverlay, object: nil)
                        }) {
                            Text("JOIN")
                                .font(.system(size: 24, weight: .black))
                                .kerning(1)
                                .padding(.horizontal, 60)
                                .padding(.vertical, 22)
                                .background(buttonGradient)
                                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.4))  // Darker teal text
                                .clipShape(Capsule())
                                .shadow(
                                    color: Color(red: 0.75, green: 1.0, blue: 0.4).opacity(0.5),
                                    radius: 20, x: 0, y: 10)
                        }
                        .buttonStyle(ProButtonStyle())
                        .focusEffectDisabled()
                    }

                    if meetingURL == nil {
                        Button(action: {
                            NotificationCenter.default.post(name: .closeOverlay, object: nil)
                        }) {
                            Text("Dismiss")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.horizontal, 60)
                                .padding(.vertical, 22)
                                .background(Color.black.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8).stroke(
                                        Color.black.opacity(0.05), lineWidth: 1)
                                )
                                .foregroundColor(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(ProButtonStyle())
                        .focusEffectDisabled()
                    } else {
                        Button(action: {
                            NotificationCenter.default.post(name: .closeOverlay, object: nil)
                        }) {
                            Text("Dismiss")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.black.opacity(0.2))
                                .kerning(1)
                        }
                        .buttonStyle(.plain)
                        .focusEffectDisabled()
                    }
                }
                .opacity(showActions ? 1 : 0)
                .offset(y: showActions ? 0 : 30)

                Spacer()
            }
            .padding(60)
        }
        .onAppear { animateIn() }
    }

    private func animateIn() {
        let spring = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)

        withAnimation(spring.delay(0.2)) { showTitle = true }
        withAnimation(spring.delay(0.3)) { showTime = true }
        withAnimation(spring.delay(0.4)) { showActions = true }
    }
}
