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
    
    func testPreferDedicatedURLLink() {
        let event = EKEvent(eventStore: EKEventStore())
        event.url = URL(string: "https://dedicated.url/123")
        event.notes = "https://meet.google.com/abc-defg-hij"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        // Should prefer dedicated URL field first
        XCTAssertEqual(link?.absoluteString, "https://dedicated.url/123")
    }
    
    func testCheckDedicatedURLFieldFirst() {
        let event = EKEvent(eventStore: EKEventStore())
        event.url = URL(string: "https://generic.link/456")
        event.notes = "No meeting link here"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertEqual(link?.absoluteString, "https://generic.link/456")
    }
    
    func testReturnNilWhenNoLinkFound() {
        let event = EKEvent(eventStore: EKEventStore())
        event.notes = "Just some random notes"
        
        let link = MeetingLinkExtractor.meetingLink(for: event)
        XCTAssertNil(link)
    }
}
