//
//  YouTubeHelper.swift
//  FootballApp
//
//  Shared YouTube URL utilities used across Kine and Workout views.
//

import Foundation

extension String {
    /// Extracts a YouTube video ID from various URL formats.
    /// Supports: youtu.be/ID, youtube.com/watch?v=ID, youtube.com/embed/ID, youtube.com/shorts/ID
    var youTubeVideoID: String? {
        // Handle youtu.be short URLs
        if self.contains("youtu.be/") {
            return self.components(separatedBy: "youtu.be/").last?.components(separatedBy: "?").first
        }

        // Handle youtube.com URLs
        if self.contains("youtube.com") {
            // shorts/ID format
            if self.contains("/shorts/") {
                if let range = self.range(of: "/shorts/") {
                    let idString = String(self[range.upperBound...])
                    return idString.components(separatedBy: CharacterSet(charactersIn: "?&#/")).first
                }
            }

            // watch?v=ID format
            if let range = self.range(of: "v=") {
                let idStart = range.upperBound
                let remaining = String(self[idStart...])
                return remaining.components(separatedBy: CharacterSet(charactersIn: "&?#")).first
            }

            // embed/ID or v/ID format
            if self.contains("/embed/") || self.contains("/v/") {
                if let id = self.components(separatedBy: "/").last?.components(separatedBy: "?").first {
                    return id.isEmpty ? nil : id
                }
            }
        }

        return nil
    }

    /// Whether this URL is a YouTube video URL
    var isYouTubeURL: Bool {
        self.contains("youtube.com") || self.contains("youtu.be")
    }
}
