import SwiftUI
import EventKit

struct OverlayView: View {
    let event: EKEvent
    
    var body: some View {
        let eventColor = Color.from(cgColor: event.calendar.cgColor)
        
        ZStack {
            VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)
            
            eventColor.opacity(0.15)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text(event.title)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if let startDate = event.startDate {
                    Text(startDate, style: .time)
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Button(action: {
                    if let url = event.url {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Join Meeting")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(eventColor)
                        .foregroundColor(.white) // Might need contrast check, but white is usually safe for calendar colors
                        .cornerRadius(12)
                        .shadow(color: eventColor.opacity(0.5), radius: 10, x: 0, y: 0)
                }
                .buttonStyle(.plain)
            }
            .padding(50)
        }
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
