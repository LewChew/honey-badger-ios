//
//  APIConfig.swift
//  HoneyBadgerApp
//
//  Created by Claude Code
//  API configuration for Node.js backend connection
//

import Foundation

struct APIConfig {
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
        static let contacts = "/api/contacts"
        static let chat = "/api/chat"

        // Challenge endpoints
        static func challengeProgress(id: String) -> String {
            return "/api/challenges/\(id)/progress"
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
