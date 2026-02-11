import Foundation
import EventKit

struct MeetingLinkExtractor {
    static func getMeetingLink(for event: EKEvent) -> URL? {
        // 1. Check the dedicated URL field first
        if let url = event.url, isValidMeetingURL(url) {
            return url
        }
        
        // 2. Check Notes and Location
        let combinedText = (event.notes ?? "") + "\n" + (event.location ?? "")
        return extractURL(from: combinedText) ?? event.url // Fallback to event.url even if not "valid" meeting link
    }
    
    private static func isValidMeetingURL(_ url: URL) -> Bool {
        // Simple check if it looks like a meeting URL, or just return true if we want to support any URL in the URL field
        // For now, let's trust the URL field if it's set.
        return true 
    }
    
    private static func extractURL(from text: String) -> URL? {
        // Regex patterns for common meeting services
        // Google Meet: meet.google.com/abc-defg-hij
        // Zoom: zoom.us/j/123456789 or zoom.us/my/name
        // Teams: teams.microsoft.com/l/meetup-join/...
        // WebEx: *.webex.com/...
        
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
