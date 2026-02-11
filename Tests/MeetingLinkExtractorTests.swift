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
    
    func testExtractZoom() {
        let event = EKEvent(eventStore: EKEventStore())
        event.location = "Join Zoom: https://zoom.us/j/123456789"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertEqual(link?.absoluteString, "https://zoom.us/j/123456789")
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
    
    func testFallbackToEventURLWhenNoRegexMatch() {
        let event = EKEvent(eventStore: EKEventStore())
        event.url = URL(string: "https://generic.link/456")
        event.notes = "No meeting link here"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        // Should fallback to event.url even if it doesn't match regex
        XCTAssertEqual(link?.absoluteString, "https://generic.link/456")
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
