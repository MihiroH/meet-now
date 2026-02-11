import Foundation
import EventKit

struct MeetingLinkExtractor {
    static func meetingLink(for event: EKEvent) -> URL? {
        // Check the dedicated URL field first
        if let url = event.url {
            return url
        }
        
        // Check Notes and Location for meeting service URLs
        let combinedText = (event.notes ?? "") + "\n" + (event.location ?? "")
        return extractURL(from: combinedText) ?? event.url
    }
    
    private static func extractURL(from text: String) -> URL? {
        let patterns = [
            "https?:\\/\\/meet\\.google\\.com\\/[a-z]{3}-[a-z]{4}-[a-z]{3}",
            "https?:\\/\\/([a-z0-9-]+\\.)?zoom\\.us\\/[a-z0-9\\/]+",
            "https?:\\/\\/teams\\.microsoft\\.com\\/l\\/meetup-join\\/[a-zA-Z0-9\\/%_\\-\\=\\.\\+]+",
            "https?:\\/\\/([a-z0-9-]+\\.)?webex\\.com\\/[a-zA-Z0-9\\/%_\\-\\=\\.\\+]+"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                
                let range = Range(match.range, in: text)!
                let urlString = String(text[range])
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }
        
        return nil
    }
}
