//
//  APIConfig.swift
//  HoneyBadgerApp
//
//  Created by Claude Code
//  API configuration for Node.js backend connection
//

import Foundation

struct HoneyBadgerAPIConfig {
    // Production backend
    static let baseURL = "https://api.badgerbot.net"

    // Mascot service
    static let mascotServiceURL = "https://mascot.honeybadger.app"

    struct Endpoints {
        static let login = "/api/login"
        static let signup = "/api/signup"
        static let me = "/api/auth/me"
        static let logout = "/api/auth/logout"
        static let forgotPassword = "/api/auth/forgot-password"
        static let resetPassword = "/api/auth/reset-password"
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

        static func submitChallengeByGift(trackingId: String) -> String {
            return "/api/gifts/\(trackingId)/submit-challenge"
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

        // SMS Consent Endpoints
        static let smsConsentStatus = "/api/sms/consent-status"

        static func checkConsentStatus(phone: String) -> String {
            return "/api/sms/consent/\(phone)"
        }

        static let smsWebhookIncoming = "/api/sms/webhook/incoming"
    }

    // Legal Pages
    struct LegalURLs {
        static let termsOfService = "https://honeybadger.app/terms"
        static let privacyPolicy = "https://honeybadger.app/privacy"
        static let smsTerms = "https://honeybadger.app/sms-terms"
    }
}
