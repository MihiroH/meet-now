import SwiftUI
import EventKit

struct OverlayView: View {
    let event: EKEvent
    
    @State private var showHeader = false
    @State private var showTitle = false
    @State private var showTime = false
    @State private var showActions = false
    
    private var timeRangeString: String {
        guard let start = event.startDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: event.endDate))"
    }
    
    var body: some View {
        let eventColor = Color.from(cgColor: event.calendar.cgColor)
        let darkBackground = Color(white: 0.05) // Midnight charcoal
        
        ZStack {
            // Solid Pro Background
            darkBackground
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                // 1. Minimalist Header
                HStack(spacing: 8) {
                    Circle()
                        .fill(eventColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: eventColor.opacity(0.5), radius: 4)
                    
                    Text("STARTING NOW")
                        .font(.system(size: 12, weight: .black))
                        .kerning(1.5)
                        .foregroundColor(eventColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.03))
                .cornerRadius(4)
                .opacity(showHeader ? 1 : 0)
                .offset(y: showHeader ? 0 : 20)
                
                Spacer().frame(height: 48)
                
                // 2. Sharp Pro Title
                VStack(spacing: 12) {
                    Text(event.title)
                        .font(.system(size: 72, weight: .heavy))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .kerning(-1.5)
                }
                .padding(.horizontal, 80)
                .opacity(showTitle ? 1 : 0)
                .scaleEffect(showTitle ? 1 : 0.98)
                
                Spacer().frame(height: 24)
                
                // 3. Simple Time Range
                Text(timeRangeString)
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                    .opacity(showTime ? 1 : 0)
                    .offset(y: showTime ? 0 : 10)
                
                Spacer().frame(height: 80)
                
                // 4. Focused Action Blocks
                VStack(spacing: 32) {
                    if let url = MeetingLinkExtractor.getMeetingLink(for: event) {
                        Button(action: { 
                            NSWorkspace.shared.open(url) 
                            NotificationCenter.default.post(name: Notification.Name("CloseOverlay"), object: nil)
                        }) {
                            HStack(spacing: 12) {
                                Text("Join Meeting")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 50)
                            .padding(.vertical, 22)
                            .background(eventColor.brightness(-0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8) // Sharper, more professional corners
                            .shadow(color: eventColor.opacity(0.3), radius: 20, x: 0, y: 10)
                        }
                        .buttonStyle(ProButtonStyle())
                        .focusEffectDisabled()
                    }
                    
                    Button(action: {
                        NotificationCenter.default.post(name: Notification.Name("CloseOverlay"), object: nil)
                    }) {
                        Text("Dismiss")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.25))
                            .kerning(1)
                    }
                    .buttonStyle(.plain)
                    .focusEffectDisabled()
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
        
        withAnimation(spring.delay(0.1)) { showHeader = true }
        withAnimation(spring.delay(0.2)) { showTitle = true }
        withAnimation(spring.delay(0.3)) { showTime = true }
        withAnimation(spring.delay(0.4)) { showActions = true }
    }
}

// Re-using the tactile button interaction
struct ProButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}


// Helper for Visual Effect Blur (NSVisualEffectView wrapper)
struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
