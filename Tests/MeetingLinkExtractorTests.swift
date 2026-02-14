import XCTest
import EventKit
@testable import MeetNow

final class MeetingLinkExtractorTests: XCTestCase {
    
    func testExtractGoogleMeet() {
        let event = EKEvent(eventStore: EKEventStore())
        event.notes = "Here is a link: https://meet.google.com/abc-defg-hij"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertEqual(link?.absoluteString, "https://meet.google.com/abc-defg-hij")
    }
    
    func testExtractZoomWithPassword() {
        let event = EKEvent(eventStore: EKEventStore())
        event.notes = "Zoom link: https://zoom.us/j/123456789?pwd=abc-def-123"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertEqual(link?.absoluteString, "https://zoom.us/j/123456789?pwd=abc-def-123")
    }
    
    func testExtractTeams() {
        let event = EKEvent(eventStore: EKEventStore())
        event.notes = "Teams link: https://teams.microsoft.com/l/meetup-join/abc123percent20sign"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertEqual(link?.absoluteString, "https://teams.microsoft.com/l/meetup-join/abc123percent20sign")
    }
    
    func testPreferRegexMatchOverGenericURL() {
        let event = EKEvent(eventStore: EKEventStore())
        event.url = URL(string: "https://generic.link/123")
        event.notes = "Actual meeting: https://meet.google.com/abc-defg-hij"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        // Should prefer regex match in notes over generic URL field
        XCTAssertEqual(link?.absoluteString, "https://meet.google.com/abc-defg-hij")
    }
    
    func testDoNotReturnGenericEventURL() {
        let event = EKEvent(eventStore: EKEventStore())
        event.url = URL(string: "https://generic.link/456")
        event.notes = "No meeting link here"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        // Should return nil because the URL is generic and not a confirmed meeting link
        XCTAssertNil(link)
    }
    
    func testExtractFromTitle() {
        let event = EKEvent(eventStore: EKEventStore())
        event.title = "Meeting: https://meet.google.com/abc-defg-hij"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertEqual(link?.absoluteString, "https://meet.google.com/abc-defg-hij")
    }
    
    func testReturnNilWhenNoLinkFound() {
        let event = EKEvent(eventStore: EKEventStore())
        event.notes = "Just some random notes"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertNil(link)
    }
}
