//
//  SupabaseAuthManager.swift
//  HoneyBadgerApp
//
//  Authentication manager using Supabase
//

import Foundation
import SwiftUI
import Combine
import Supabase

class SupabaseAuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let supabase = SupabaseConfig.shared

    init() {
        // Check if user is already logged in on app launch
        Task {
            await checkCurrentSession()
        }
    }

    // MARK: - Authentication Methods

    @MainActor
    func checkCurrentSession() async {
        do {
            let session = try await supabase.auth.session
            let supabaseUser = session.user

            // User is logged in, create our User model
            self.currentUser = User(
                id: supabaseUser.id.uuidString.hashValue,
                name: supabaseUser.email ?? "User",
                email: supabaseUser.email ?? ""
            )
            self.isAuthenticated = true
        } catch {
            // No active session
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }

    @MainActor
    func signup(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // Sign up with Supabase
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )

            // Create user profile in our database
            let userId = response.user.id
            try await createUserProfile(
                userId: userId.uuidString,
                name: name,
                email: email
            )

            // Update state
            let supabaseUser = response.user
            self.currentUser = User(
                id: supabaseUser.id.uuidString.hashValue,
                name: name,
                email: email
            )
            self.isAuthenticated = true

            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // Sign in with Supabase
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )

            // Fetch user profile from database
            let userId = response.user.id
            let profile = try await fetchUserProfile(userId: userId.uuidString)

            self.currentUser = User(
                id: userId.uuidString.hashValue,
                name: profile["name"] as? String ?? email,
                email: email
            )
            self.isAuthenticated = true

            isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    @MainActor
    func logout() async {
        do {
            try await supabase.auth.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Database Methods

    private func createUserProfile(userId: String, name: String, email: String) async throws {
        try await supabase
            .from("user_profiles")
            .insert([
                "id": userId,
                "name": name,
                "email": email
            ])
            .execute()
    }

    private func fetchUserProfile(userId: String) async throws -> [String: Any] {
        let response = try await supabase
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()

        // Parse response data
        let data = response.data
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json
        }

        return [:]
    }

    // MARK: - Get Access Token (for Node.js API calls)

    func getAccessToken() async -> String? {
        do {
            let session = try await supabase.auth.session
            return session.accessToken
        } catch {
            return nil
        }
    }
}
