//
//  APIConfig.swift
//  HoneyBadgerApp
//
//  Created by Claude Code
//  API configuration for Node.js backend connection
//

import Foundation

struct HoneyBadgerAPIConfig {
    // Development: Local backend
    // Production: Update with your production API URL
    static let baseURL = "http://localhost:3000"
    // static let baseURL = "https://api.honeybadger.com" // Uncomment for production

    struct Endpoints {
        static let login = "/api/login"
        static let signup = "/api/signup"
        static let me = "/api/auth/me"
        static let logout = "/api/auth/logout"
        static let sendGift = "/api/send-honey-badger"
        static let gifts = "/api/honey-badgers"
        static let receivedGifts = "/api/my-received-gifts"
        static let contacts = "/api/contacts"
        static let chat = "/api/chat"

        // Pending approvals (for senders)
        static let pendingApprovals = "/api/my-pending-approvals"

        // Challenge endpoints
        static func challengeProgress(id: String) -> String {
            return "/api/challenges/\(id)/progress"
        }

        static func submitPhoto(challengeId: String) -> String {
            return "/api/challenges/\(challengeId)/submit-photo"
        }

        static func uploadPhoto(challengeId: String) -> String {
            return "/api/challenges/\(challengeId)/upload-photo"
        }

        // Submission review endpoints
        static func reviewSubmission(id: String) -> String {
            return "/api/submissions/\(id)/review"
        }

        // Contact special dates
        static func contactSpecialDates(contactId: String) -> String {
            return "/api/contacts/\(contactId)/special-dates"
        }

        static func deleteSpecialDate(id: String) -> String {
            return "/api/special-dates/\(id)"
        }

        // Recipient gifts
        static func recipientGifts(phone: String) -> String {
            return "/api/recipients/\(phone)/gifts"
        }
    }
}
