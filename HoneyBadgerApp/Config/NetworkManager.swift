//
//  NetworkManager.swift
//  HoneyBadgerApp
//
//  Created by Claude Code
//  Network layer for API communication with Node.js backend
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    @Published var authToken: String? {
        didSet {
            if let token = authToken {
                UserDefaults.standard.set(token, forKey: "authToken")
            } else {
                UserDefaults.standard.removeObject(forKey: "authToken")
            }
        }
    }

    init() {
        // Load token from UserDefaults on initialization
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
    }

    // MARK: - Authentication Methods

    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.login)")!
        print("🔗 Attempting login to: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["loginEmail": email, "loginPassword": password]
        request.httpBody = try JSONEncoder().encode(body)

        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            print("📤 Request body: \(bodyString)")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
            print("📡 Received response: \(response)")
        } catch let error as URLError {
            print("❌ URLError: \(error.localizedDescription)")
            print("   Error Code: \(error.code.rawValue)")
            print("   Failing URL: \(error.failingURL?.absoluteString ?? "none")")
            throw error
        } catch {
            print("❌ Unknown error: \(error)")
            throw error
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Response is not HTTPURLResponse: \(type(of: response))")
            throw NetworkError.invalidResponse
        }

        print("📊 HTTP Status Code: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 {
            // Debug: Print the raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Login Response: \(jsonString)")
            }

            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.authToken = authResponse.token
                print("✅ Login decoded successfully. Token: \(authResponse.token.prefix(20))...")
                return authResponse
            } catch {
                print("❌ Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    print("   Detailed error: \(decodingError)")
                }
                throw error
            }
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Login failed")
        }
    }

    func signup(name: String, email: String, password: String, phone: String?) async throws -> AuthResponse {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.signup)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "signupName": name,
            "signupEmail": email,
            "signupPassword": password
        ]

        // Only include phone if it's not empty
        if let phone = phone, !phone.isEmpty {
            body["signupPhone"] = phone
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            self.authToken = authResponse.token
            return authResponse
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Signup failed")
        }
    }

    func getCurrentUser() async throws -> APIUser {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.me)")!
        let request = authenticatedRequest(url: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
            return userResponse.user
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            self.authToken = nil
            throw NetworkError.unauthorized
        } else {
            throw NetworkError.serverError("Failed to get user")
        }
    }

    func logout() async throws {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.logout)")!
        let request = authenticatedRequest(url: url, method: "POST")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 204 {
            self.authToken = nil
        } else {
            throw NetworkError.serverError("Logout failed")
        }
    }

    // MARK: - Password Reset Methods

    func forgotPassword(email: String) async throws -> ForgotPasswordResponse {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.forgotPassword)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(ForgotPasswordResponse.self, from: data)
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to request password reset")
        }
    }

    func resetPassword(token: String, newPassword: String) async throws -> SimpleResponse {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.resetPassword)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["token": token, "newPassword": newPassword]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            return try JSONDecoder().decode(SimpleResponse.self, from: data)
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to reset password")
        }
    }

    // MARK: - Gift Methods

    func sendGift(recipientPhone: String, giftType: String, challengeType: String, giftDetails: [String: Any]) async throws -> GiftResponse {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.sendGift)")!
        let request = authenticatedRequest(url: url, method: "POST", body: giftDetails)

        print("📤 sendGift request to: \(url.absoluteString)")
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Request body: \(bodyString)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        // Debug: Print raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 sendGift raw response: \(jsonString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        print("📊 sendGift HTTP status: \(httpResponse.statusCode)")

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            do {
                let giftResponse = try JSONDecoder().decode(GiftResponse.self, from: data)
                return giftResponse
            } catch {
                print("❌ sendGift decode error: \(error)")
                throw error
            }
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to send gift")
        }
    }

    func getGifts() async throws -> [Gift] {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.gifts)")!
        let request = authenticatedRequest(url: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            let giftsResponse = try JSONDecoder().decode(GiftsResponse.self, from: data)
            return giftsResponse.gifts
        } else {
            throw NetworkError.serverError("Failed to get gifts")
        }
    }

    func getReceivedGifts() async throws -> [Gift] {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.receivedGifts)")!
        let request = authenticatedRequest(url: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            let giftsResponse = try JSONDecoder().decode(GiftsResponse.self, from: data)
            return giftsResponse.gifts
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            self.authToken = nil
            throw NetworkError.unauthorized
        } else {
            throw NetworkError.serverError("Failed to get received gifts")
        }
    }

    // MARK: - Contact Methods

    func getContacts() async throws -> [APIContact] {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.contacts)")!
        let request = authenticatedRequest(url: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            let contactsResponse = try JSONDecoder().decode(ContactsResponse.self, from: data)
            return contactsResponse.contacts
        } else {
            throw NetworkError.serverError("Failed to get contacts")
        }
    }

    func addContact(name: String, phone: String, email: String?, notes: String?) async throws -> APIContact {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.contacts)")!

        let body: [String: Any] = [
            "name": name,
            "phone": phone,
            "email": email ?? "",
            "notes": notes ?? ""
        ]

        let request = authenticatedRequest(url: url, method: "POST", body: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            let contactResponse = try JSONDecoder().decode(ContactResponse.self, from: data)
            return contactResponse.contact
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to add contact")
        }
    }

    // MARK: - Approval Methods

    func getPendingApprovals() async throws -> [PendingApproval] {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.pendingApprovals)")!
        let request = authenticatedRequest(url: url, method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            let approvalsResponse = try JSONDecoder().decode(PendingApprovalsResponse.self, from: data)
            return approvalsResponse.pendingApprovals
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            self.authToken = nil
            throw NetworkError.unauthorized
        } else {
            throw NetworkError.serverError("Failed to get pending approvals")
        }
    }

    func approveSubmission(submissionId: String) async throws {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.reviewSubmission(id: submissionId))")!
        let body: [String: Any] = ["action": "approve"]
        let request = authenticatedRequest(url: url, method: "PUT", body: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            print("✅ Submission approved successfully")
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            self.authToken = nil
            throw NetworkError.unauthorized
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to approve submission")
        }
    }

    func rejectSubmission(submissionId: String, reason: String?) async throws {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(HoneyBadgerAPIConfig.Endpoints.reviewSubmission(id: submissionId))")!
        var body: [String: Any] = ["action": "reject"]
        if let reason = reason {
            body["rejectionReason"] = reason
        }
        let request = authenticatedRequest(url: url, method: "PUT", body: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            print("✅ Submission rejected successfully")
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            self.authToken = nil
            throw NetworkError.unauthorized
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to reject submission")
        }
    }

    // MARK: - Profile Methods

    func updateProfile(name: String) async throws {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)/api/auth/profile")!
        let body: [String: Any] = ["name": name]
        let request = authenticatedRequest(url: url, method: "PUT", body: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            print("✅ Profile updated successfully")
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            self.authToken = nil
            throw NetworkError.unauthorized
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to update profile")
        }
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)/api/auth/password")!
        let body: [String: Any] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ]
        let request = authenticatedRequest(url: url, method: "PUT", body: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            print("✅ Password changed successfully")
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            throw NetworkError.serverError("Current password is incorrect")
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to change password")
        }
    }

    // MARK: - Helper Methods

    // MARK: - Challenge Submission

    func submitChallengePhoto(trackingId: String, imageData: Data) async throws -> ChallengeSubmissionResponse {
        let url = URL(string: "\(HoneyBadgerAPIConfig.baseURL)/api/gifts/\(trackingId)/submit-challenge")!

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Build multipart body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"challenge.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 201 || httpResponse.statusCode == 200 {
            let decoded = try JSONDecoder().decode(ChallengeSubmissionResponse.self, from: data)
            return decoded
        } else if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            self.authToken = nil
            throw NetworkError.unauthorized
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to submit challenge photo")
        }
    }

    private func authenticatedRequest(url: URL, method: String = "GET", body: [String: Any]? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return request
    }
}

// MARK: - Response Models

struct AuthResponse: Codable {
    let success: Bool
    let message: String?
    let token: String
    let user: APIUser
}

struct APIUser: Codable {
    let id: Int?
    let name: String
    let email: String
    let phone: String?
    let createdAt: String?
    let isActive: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, createdAt, isActive
    }
}

struct UserResponse: Codable {
    let success: Bool
    let user: APIUser
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

struct ForgotPasswordResponse: Codable {
    let success: Bool
    let message: String
}

struct SimpleResponse: Codable {
    let success: Bool
    let message: String
}

struct GiftResponse: Codable {
    let success: Bool
    let message: String?
    let trackingId: String?
    let sender: String?
    let note: String?

    // Computed property for backwards compatibility
    var giftId: String {
        return trackingId ?? ""
    }
}

struct Gift: Codable, Identifiable {
    let id: String
    let recipientPhone: String?
    let recipientEmail: String?
    let recipientName: String?
    let giftType: String
    let giftValue: String?
    let challengeType: String?
    let status: String
    let createdAt: String
    // Enhanced fields
    let senderName: String?
    let senderEmail: String?
    let challengeDescription: String?
    let personalNote: String?
    let message: String?
    let duration: Int?
    let deliveryMethod: String?
    let reminderFrequency: String?
    let verificationType: String?
    let cardImageUrl: String?
    let challengeId: String?

    enum CodingKeys: String, CodingKey {
        case id, recipientPhone, recipientEmail, recipientName
        case giftType, giftValue, challengeType, status, createdAt
        case senderName, senderEmail, challengeDescription
        case personalNote, message, duration, deliveryMethod
        case reminderFrequency, verificationType, cardImageUrl
        case challengeId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        recipientPhone = try container.decodeIfPresent(String.self, forKey: .recipientPhone)
        recipientEmail = try container.decodeIfPresent(String.self, forKey: .recipientEmail)
        recipientName = try container.decodeIfPresent(String.self, forKey: .recipientName)
        giftType = try container.decode(String.self, forKey: .giftType)
        giftValue = try container.decodeIfPresent(String.self, forKey: .giftValue)
        challengeType = try container.decodeIfPresent(String.self, forKey: .challengeType)
        status = try container.decode(String.self, forKey: .status)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        senderName = try container.decodeIfPresent(String.self, forKey: .senderName)
        senderEmail = try container.decodeIfPresent(String.self, forKey: .senderEmail)
        challengeDescription = try container.decodeIfPresent(String.self, forKey: .challengeDescription)
        personalNote = try container.decodeIfPresent(String.self, forKey: .personalNote)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        deliveryMethod = try container.decodeIfPresent(String.self, forKey: .deliveryMethod)
        reminderFrequency = try container.decodeIfPresent(String.self, forKey: .reminderFrequency)
        verificationType = try container.decodeIfPresent(String.self, forKey: .verificationType)
        cardImageUrl = try container.decodeIfPresent(String.self, forKey: .cardImageUrl)
        challengeId = try container.decodeIfPresent(String.self, forKey: .challengeId)

        // Handle duration which might come as Int or String
        if let durationInt = try? container.decodeIfPresent(Int.self, forKey: .duration) {
            duration = durationInt
        } else if let durationString = try? container.decodeIfPresent(String.self, forKey: .duration),
                  let durationInt = Int(durationString) {
            duration = durationInt
        } else {
            duration = nil
        }
    }
}

struct GiftsResponse: Codable {
    let success: Bool
    let gifts: [Gift]
}

struct APIContact: Codable {
    let id: String
    let name: String
    let phone: String
    let email: String?
    let notes: String?
}

struct ContactResponse: Codable {
    let success: Bool
    let contact: APIContact
}

struct ContactsResponse: Codable {
    let success: Bool
    let contacts: [APIContact]
}

// MARK: - Pending Approval Models

struct PendingApproval: Identifiable, Codable {
    let submissionId: String
    let photoUrl: String
    let submittedAt: String
    let recipientName: String?
    let recipientPhone: String?
    let recipientEmail: String?
    let giftType: String
    let giftValue: String?
    let giftId: String
    let challengeDescription: String?

    var id: String { submissionId }

    enum CodingKeys: String, CodingKey {
        case submissionId, photoUrl, submittedAt, recipientName
        case recipientPhone, recipientEmail, giftType, giftValue
        case giftId, challengeDescription
    }
}

struct PendingApprovalsResponse: Codable {
    let success: Bool
    let pendingApprovals: [PendingApproval]
    let count: Int
}

// MARK: - Challenge Submission Models

struct ChallengeSubmissionResponse: Codable {
    let success: Bool
    let data: ChallengeSubmissionData?
}

struct ChallengeSubmissionData: Codable {
    let submissionId: String
    let photoUrl: String
    let status: String
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - Please login again"
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
