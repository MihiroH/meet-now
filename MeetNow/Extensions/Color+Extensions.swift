import SwiftUI

extension Color {
    static func from(cgColor: CGColor?) -> Color {
        guard let cgColor = cgColor else { return .blue } // Default to blue
        return Color(nsColor: NSColor(cgColor: cgColor) ?? .blue)
    }
}
