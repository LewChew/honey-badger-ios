//
//  EmailTemplates.swift
//  HoneyBadgerApp
//
//  Email template configurations for Honey Badger notifications
//

import Foundation

struct EmailTemplates {

    // App download/signup URL
    static let appSignupURL = "https://honeybadger.app/signup"
    static let appDownloadURL = "https://honeybadger.app/download"

    // Hosted image URLs (these should be hosted on your CDN/server)
    static let honeyBadgerLogoURL = "https://api.badgerbot.net/images/honey-badger-logo.png"
    static let honeyBadgerMascotURL = "https://api.badgerbot.net/images/honey-badger-mascot.png"
    static let giftIconURL = "https://api.badgerbot.net/images/gift-icon.png"

    // Dynamic mascot URLs (fetches occasion-specific AI-generated mascots)
    static func dynamicMascotURL(for occasion: String) -> String {
        return DynamicMascotURL.forOccasion(occasion)
    }

    static var featuredMascotURL: String {
        return DynamicMascotURL.featured
    }

    // MARK: - Gift Notification Email

    static func giftNotificationEmail(
        recipientName: String?,
        senderName: String,
        giftType: String,
        challengeDescription: String?,
        personalMessage: String?
    ) -> String {
        let displayName = recipientName ?? "Friend"
        let challenge = challengeDescription ?? "Complete a fun challenge"
        let message = personalMessage ?? ""

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>You've Received a Honey Badger!</title>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                    background-color: #1a1a2e;
                    color: #ffffff;
                }
                .container {
                    max-width: 600px;
                    margin: 0 auto;
                    background-color: #1a1a2e;
                }
                .header {
                    background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                    padding: 30px 20px;
                    text-align: center;
                }
                .header h1 {
                    margin: 0;
                    color: #1a1a2e;
                    font-size: 28px;
                    font-weight: bold;
                }
                .header p {
                    margin: 10px 0 0;
                    color: #1a1a2e;
                    font-size: 16px;
                }
                .mascot-section {
                    text-align: center;
                    padding: 30px 20px;
                    background-color: #252542;
                }
                .mascot-image {
                    width: 180px;
                    height: auto;
                    border-radius: 20px;
                }
                .content {
                    padding: 30px 25px;
                    background-color: #1a1a2e;
                }
                .greeting {
                    font-size: 24px;
                    font-weight: bold;
                    color: #FFD700;
                    margin-bottom: 20px;
                }
                .message-box {
                    background-color: #252542;
                    border-radius: 12px;
                    padding: 20px;
                    margin: 20px 0;
                    border-left: 4px solid #FFD700;
                }
                .message-box p {
                    margin: 0;
                    color: #e0e0e0;
                    font-size: 16px;
                    line-height: 1.6;
                }
                .gift-details {
                    background-color: #252542;
                    border-radius: 12px;
                    padding: 20px;
                    margin: 20px 0;
                }
                .gift-details h3 {
                    margin: 0 0 15px;
                    color: #FFD700;
                    font-size: 18px;
                }
                .gift-detail-row {
                    display: flex;
                    justify-content: space-between;
                    padding: 8px 0;
                    border-bottom: 1px solid #3a3a5c;
                }
                .gift-detail-row:last-child {
                    border-bottom: none;
                }
                .detail-label {
                    color: #888;
                    font-size: 14px;
                }
                .detail-value {
                    color: #fff;
                    font-size: 14px;
                    font-weight: 600;
                }
                .cta-section {
                    text-align: center;
                    padding: 30px 20px;
                }
                .cta-button {
                    display: inline-block;
                    background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                    color: #1a1a2e !important;
                    text-decoration: none;
                    padding: 16px 40px;
                    border-radius: 30px;
                    font-size: 18px;
                    font-weight: bold;
                    box-shadow: 0 4px 15px rgba(255, 215, 0, 0.4);
                }
                .cta-button:hover {
                    opacity: 0.9;
                }
                .cta-subtext {
                    color: #888;
                    font-size: 14px;
                    margin-top: 15px;
                }
                .footer {
                    background-color: #252542;
                    padding: 25px 20px;
                    text-align: center;
                }
                .footer-logo {
                    width: 40px;
                    height: auto;
                    margin-bottom: 10px;
                }
                .footer p {
                    color: #888;
                    font-size: 12px;
                    margin: 5px 0;
                }
                .footer a {
                    color: #FFD700;
                    text-decoration: none;
                }
                .social-links {
                    margin-top: 15px;
                }
                .social-links a {
                    display: inline-block;
                    margin: 0 10px;
                    color: #FFD700;
                    font-size: 14px;
                }
                @media only screen and (max-width: 480px) {
                    .header h1 {
                        font-size: 24px;
                    }
                    .greeting {
                        font-size: 20px;
                    }
                    .cta-button {
                        padding: 14px 30px;
                        font-size: 16px;
                    }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <!-- Header -->
                <div class="header">
                    <h1>You've Got a Honey Badger!</h1>
                    <p>Someone special is thinking of you</p>
                </div>

                <!-- Mascot Image -->
                <div class="mascot-section">
                    <img src="\(honeyBadgerMascotURL)" alt="Honey Badger" class="mascot-image">
                </div>

                <!-- Content -->
                <div class="content">
                    <div class="greeting">Hey \(displayName)!</div>

                    <p style="color: #e0e0e0; font-size: 16px; line-height: 1.6;">
                        Great news! <strong style="color: #FFD700;">\(senderName)</strong> just sent you a Honey Badger gift!
                        But here's the fun part - you'll need to complete a challenge to unlock it.
                    </p>

                    \(message.isEmpty ? "" : """
                    <div class="message-box">
                        <p>"\(message)"</p>
                        <p style="margin-top: 10px; color: #FFD700; font-size: 14px;">- \(senderName)</p>
                    </div>
                    """)

                    <!-- Gift Details -->
                    <div class="gift-details">
                        <h3>Your Challenge Details</h3>
                        <div class="gift-detail-row">
                            <span class="detail-label">Gift Type</span>
                            <span class="detail-value">\(giftType)</span>
                        </div>
                        <div class="gift-detail-row">
                            <span class="detail-label">Challenge</span>
                            <span class="detail-value">\(challenge)</span>
                        </div>
                        <div class="gift-detail-row">
                            <span class="detail-label">From</span>
                            <span class="detail-value">\(senderName)</span>
                        </div>
                    </div>
                </div>

                <!-- CTA Section -->
                <div class="cta-section">
                    <a href="\(appSignupURL)" class="cta-button">
                        Claim Your Gift
                    </a>
                    <p class="cta-subtext">
                        Download the Honey Badger app to complete your challenge and unlock your gift!
                    </p>
                </div>

                <!-- Footer -->
                <div class="footer">
                    <img src="\(honeyBadgerLogoURL)" alt="Honey Badger" class="footer-logo">
                    <p><strong>Honey Badger</strong></p>
                    <p>Gifts Worth Fighting For</p>
                    <p style="margin-top: 15px;">
                        <a href="\(appDownloadURL)">Download the App</a> |
                        <a href="https://honeybadger.app/help">Help Center</a>
                    </p>
                    <p style="margin-top: 15px; font-size: 11px; color: #666;">
                        You received this email because \(senderName) sent you a gift through Honey Badger.<br>
                        &copy; 2024 Honey Badger. All rights reserved.
                    </p>
                </div>
            </div>
        </body>
        </html>
        """
    }

    // MARK: - Challenge Reminder Email

    static func challengeReminderEmail(
        recipientName: String?,
        senderName: String,
        challengeDescription: String,
        daysRemaining: Int
    ) -> String {
        let displayName = recipientName ?? "Friend"

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Reminder: Your Honey Badger Awaits!</title>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                    background-color: #1a1a2e;
                    color: #ffffff;
                }
                .container {
                    max-width: 600px;
                    margin: 0 auto;
                    background-color: #1a1a2e;
                }
                .header {
                    background: linear-gradient(135deg, #FF6B35 0%, #FFD700 100%);
                    padding: 25px 20px;
                    text-align: center;
                }
                .header h1 {
                    margin: 0;
                    color: #1a1a2e;
                    font-size: 24px;
                    font-weight: bold;
                }
                .content {
                    padding: 30px 25px;
                }
                .urgency-badge {
                    display: inline-block;
                    background-color: #FF6B35;
                    color: #fff;
                    padding: 8px 16px;
                    border-radius: 20px;
                    font-size: 14px;
                    font-weight: bold;
                    margin-bottom: 20px;
                }
                .mascot-inline {
                    width: 100px;
                    height: auto;
                    float: right;
                    margin-left: 15px;
                }
                .challenge-box {
                    background-color: #252542;
                    border-radius: 12px;
                    padding: 20px;
                    margin: 20px 0;
                    border: 2px solid #FFD700;
                }
                .cta-button {
                    display: inline-block;
                    background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                    color: #1a1a2e !important;
                    text-decoration: none;
                    padding: 14px 35px;
                    border-radius: 30px;
                    font-size: 16px;
                    font-weight: bold;
                }
                .footer {
                    background-color: #252542;
                    padding: 20px;
                    text-align: center;
                }
                .footer p {
                    color: #888;
                    font-size: 12px;
                    margin: 5px 0;
                }
                .footer a {
                    color: #FFD700;
                    text-decoration: none;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Don't Forget Your Gift!</h1>
                </div>

                <div class="content">
                    <span class="urgency-badge">\(daysRemaining) days remaining</span>

                    <img src="\(honeyBadgerMascotURL)" alt="Honey Badger" class="mascot-inline">

                    <p style="color: #e0e0e0; font-size: 16px; line-height: 1.6;">
                        Hey \(displayName)! Your Honey Badger from <strong style="color: #FFD700;">\(senderName)</strong>
                        is still waiting for you to complete your challenge!
                    </p>

                    <div class="challenge-box">
                        <p style="margin: 0; color: #FFD700; font-size: 14px; font-weight: bold;">YOUR CHALLENGE:</p>
                        <p style="margin: 10px 0 0; color: #fff; font-size: 16px;">\(challengeDescription)</p>
                    </div>

                    <div style="text-align: center; margin-top: 30px;">
                        <a href="\(appSignupURL)" class="cta-button">Complete Challenge</a>
                    </div>
                </div>

                <div class="footer">
                    <p><strong>Honey Badger</strong> - Gifts Worth Fighting For</p>
                    <p><a href="\(appDownloadURL)">Download the App</a></p>
                </div>
            </div>
        </body>
        </html>
        """
    }

    // MARK: - Gift Unlocked Email (to sender)

    static func giftUnlockedEmail(
        senderName: String,
        recipientName: String,
        giftType: String
    ) -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Your Gift Was Unlocked!</title>
            <style>
                body {
                    margin: 0;
                    padding: 0;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                    background-color: #1a1a2e;
                    color: #ffffff;
                }
                .container {
                    max-width: 600px;
                    margin: 0 auto;
                    background-color: #1a1a2e;
                }
                .header {
                    background: linear-gradient(135deg, #00C853 0%, #69F0AE 100%);
                    padding: 30px 20px;
                    text-align: center;
                }
                .header h1 {
                    margin: 0;
                    color: #1a1a2e;
                    font-size: 28px;
                    font-weight: bold;
                }
                .celebration {
                    text-align: center;
                    padding: 30px 20px;
                }
                .celebration img {
                    width: 150px;
                    height: auto;
                }
                .content {
                    padding: 20px 25px;
                    text-align: center;
                }
                .success-box {
                    background-color: #252542;
                    border-radius: 12px;
                    padding: 25px;
                    margin: 20px 0;
                    border: 2px solid #00C853;
                }
                .cta-button {
                    display: inline-block;
                    background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                    color: #1a1a2e !important;
                    text-decoration: none;
                    padding: 14px 35px;
                    border-radius: 30px;
                    font-size: 16px;
                    font-weight: bold;
                    margin-top: 20px;
                }
                .footer {
                    background-color: #252542;
                    padding: 20px;
                    text-align: center;
                }
                .footer p {
                    color: #888;
                    font-size: 12px;
                    margin: 5px 0;
                }
                .footer a {
                    color: #FFD700;
                    text-decoration: none;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Challenge Complete!</h1>
                </div>

                <div class="celebration">
                    <img src="\(honeyBadgerMascotURL)" alt="Celebrating Honey Badger">
                </div>

                <div class="content">
                    <p style="color: #e0e0e0; font-size: 18px; line-height: 1.6;">
                        Great news, \(senderName)!
                    </p>

                    <div class="success-box">
                        <p style="margin: 0; color: #00C853; font-size: 20px; font-weight: bold;">
                            \(recipientName) completed their challenge!
                        </p>
                        <p style="margin: 15px 0 0; color: #e0e0e0; font-size: 16px;">
                            Your <strong style="color: #FFD700;">\(giftType)</strong> gift has been unlocked and delivered.
                        </p>
                    </div>

                    <p style="color: #888; font-size: 14px;">
                        Want to send another Honey Badger?
                    </p>

                    <a href="\(appSignupURL)" class="cta-button">Send Another Gift</a>
                </div>

                <div class="footer">
                    <p><strong>Honey Badger</strong> - Gifts Worth Fighting For</p>
                    <p><a href="\(appDownloadURL)">Open the App</a></p>
                </div>
            </div>
        </body>
        </html>
        """
    }
}

// MARK: - SMS Templates

struct SMSTemplates {
    static let smsTermsURL = "honeybadger.app/sms-terms"

    // MARK: - Initial Consent Request
    /// Sent to recipients when they first receive a gift with SMS enabled
    static func initialConsentRequest(senderName: String) -> String {
        return """
        \(senderName) sent you a Honey Badger gift challenge!

        To receive challenge updates via text, reply YES.

        Msg frequency varies. Msg&Data rates may apply. Reply HELP for help, STOP to cancel.

        Terms: \(smsTermsURL)
        """
    }

    // MARK: - Opt-In Confirmation
    /// Sent after recipient replies YES
    static func optInConfirmation(challengeDescription: String) -> String {
        return """
        You're subscribed to Honey Badger! Your challenge: \(challengeDescription)

        Reply STOP to opt out anytime. Msg&Data rates may apply.
        """
    }

    // MARK: - STOP Response
    /// Sent when recipient replies STOP
    static let stopResponse = """
        You've been unsubscribed from Honey Badger. Reply START to re-subscribe.
        """

    // MARK: - HELP Response
    /// Sent when recipient replies HELP
    static let helpResponse = """
        Honey Badger Help: Reply STOP to unsubscribe, START to re-subscribe.
        Support: support@honeybadger.app
        Terms: honeybadger.app/sms-terms
        """

    // MARK: - Challenge Reminder
    /// Daily reminder during active challenges
    static func challengeReminder(
        dayNumber: Int,
        totalDays: Int,
        challengeDescription: String
    ) -> String {
        return """
        Day \(dayNumber)/\(totalDays): \(challengeDescription)

        Keep going! Reply STOP to opt out.
        """
    }

    // MARK: - Challenge Complete
    /// Sent when recipient completes their challenge
    static func challengeComplete(giftType: String) -> String {
        return """
        Congrats! You completed your Honey Badger challenge! Your \(giftType) gift is unlocked.

        Open the app to claim it!
        """
    }

    // MARK: - New Gift Notification (for opted-in users)
    /// Sent to already opted-in users when they receive a new gift
    static func newGiftNotification(senderName: String) -> String {
        return """
        \(senderName) sent you a new Honey Badger gift! Open the app to see your challenge.

        Reply STOP to opt out.
        """
    }
}
