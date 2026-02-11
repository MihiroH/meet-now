import Foundation
import EventKit

struct MeetingLinkExtractor {
    static func meetingLink(for event: EKEvent) -> URL? {
        // 1. Attempt regex-based extraction from Title, Notes, and Location first.
        // This takes priority in case the URL field contains a non-meeting link.
        let combinedText = "\(event.title ?? "")\n\(event.notes ?? "")\n\(event.location ?? "")"
        if let extracted = extractURL(from: combinedText) {
            return extracted
        }
        
        // 2. Fall back to dedicated URL detection.
        // If the URL field is present and matches a meeting service, return it.
        if let url = event.url, extractURL(from: url.absoluteString) != nil {
            return url
        }
        
        // 3. Final fallback: return the URL field if present, even if it didn't match regex.
        return event.url
    }
    
    private static let meetingPatterns: [Regex<AnyRegexOutput>] = {
        let patternStrings = [
            #"https?://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}"#,
            #"https?://([a-z0-9-]+\.)?zoom\.us/[a-z0-9/]+"#,
            #"https?://teams\.microsoft\.com/l/meetup-join/[a-zA-Z0-9/%_\-=.+]+"#,
            #"https?://([a-z0-9-]+\.)?webex\.com/[a-zA-Z0-9/%_\-=.+]+"#
        ]
        return patternStrings.compactMap { try? Regex($0).ignoresCase() }
    }()
    
    private static func extractURL(from text: String) -> URL? {
        for pattern in meetingPatterns {
            if let match = text.firstMatch(of: pattern) {
                let urlString = String(text[match.range])
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }
        return nil
    }
}
