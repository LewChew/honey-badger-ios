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
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.login)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            self.authToken = authResponse.token
            return authResponse
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Login failed")
        }
    }

    func signup(name: String, email: String, password: String, phone: String?) async throws -> AuthResponse {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.signup)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "phone": phone ?? ""
        ]
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

    func getCurrentUser() async throws -> User {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.me)")!
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
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.logout)")!
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

    // MARK: - Gift Methods

    func sendGift(recipientPhone: String, giftType: String, challengeType: String, giftDetails: [String: Any]) async throws -> GiftResponse {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.sendGift)")!
        let request = authenticatedRequest(url: url, method: "POST", body: giftDetails)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            let giftResponse = try JSONDecoder().decode(GiftResponse.self, from: data)
            return giftResponse
        } else {
            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(errorResponse?.message ?? "Failed to send gift")
        }
    }

    func getGifts() async throws -> [Gift] {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.gifts)")!
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

    // MARK: - Contact Methods

    func getContacts() async throws -> [Contact] {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.contacts)")!
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

    func addContact(name: String, phone: String, email: String?, notes: String?) async throws -> Contact {
        let url = URL(string: "\(APIConfig.baseURL)\(APIConfig.Endpoints.contacts)")!

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

    // MARK: - Helper Methods

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
    let token: String
    let user: User
}

struct User: Codable {
    let id: String?
    let name: String
    let email: String
    let phone: String?
}

struct UserResponse: Codable {
    let success: Bool
    let user: User
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
}

struct GiftResponse: Codable {
    let success: Bool
    let giftId: String
    let challengeId: String?
}

struct Gift: Codable {
    let id: String
    let recipientPhone: String
    let giftType: String
    let challengeType: String?
    let status: String
    let createdAt: String
}

struct GiftsResponse: Codable {
    let success: Bool
    let gifts: [Gift]
}

struct Contact: Codable {
    let id: String
    let name: String
    let phone: String
    let email: String?
    let notes: String?
}

struct ContactResponse: Codable {
    let success: Bool
    let contact: Contact
}

struct ContactsResponse: Codable {
    let success: Bool
    let contacts: [Contact]
}

// MARK: - Network Errors

enum NetworkError: Error {
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError

    var localizedDescription: String {
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
