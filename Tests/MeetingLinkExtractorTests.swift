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
    
    func testTrailingPunctuation() {
        let event = EKEvent(eventStore: EKEventStore())
        
        // Test Zoom with trailing period
        event.notes = "Join https://zoom.us/j/123?pwd=abc."
        XCTAssertEqual(MeetingLinkExtractor.meetingLink(for: event)?.absoluteString, "https://zoom.us/j/123?pwd=abc")
        
        // Test Teams with trailing period
        event.notes = "Teams https://teams.microsoft.com/l/meetup-join/abc."
        XCTAssertEqual(MeetingLinkExtractor.meetingLink(for: event)?.absoluteString, "https://teams.microsoft.com/l/meetup-join/abc")
        
        // Test URL in parentheses
        event.notes = "Check (https://meet.google.com/abc-defg-hij)."
        XCTAssertEqual(MeetingLinkExtractor.meetingLink(for: event)?.absoluteString, "https://meet.google.com/abc-defg-hij")
    }
    
    func testDoNotReturnGenericEventURL() {
        let event = EKEvent(eventStore: EKEventStore())
        event.url = URL(string: "https://generic.link/456")
        event.notes = "No meeting link here"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
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

    func testMassiveInput() {
        let event = EKEvent(eventStore: EKEventStore())
        let massiveString = String(repeating: "a", count: 30_000)
        let validLink = "https://meet.google.com/abc-defg-hij"
        
        // Case 1: Link is within the first 20k chars (should be found)
        event.notes = massiveString.prefix(100) + validLink + massiveString.suffix(100)
        XCTAssertNotNil(MeetingLinkExtractor.meetingLink(for: event))
        
        // Case 2: Link is after the first 20k chars (should be truncated/nil)
        event.notes = massiveString.prefix(25_000) + validLink
        XCTAssertNil(MeetingLinkExtractor.meetingLink(for: event))
    }
}
