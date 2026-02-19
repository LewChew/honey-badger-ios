//
//  HoneyBadgerComplete.swift
//  Complete Honey Badger App - All-in-One File
//
//  This file contains the entire app in one place for easy setup
//

import SwiftUI
import Combine
import Contacts
import ContactsUI

// MARK: - Theme and Colors

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct HBTheme {
    static let primaryYellow = Color(hex: "E2FF00")
    static let darkBg = Color(hex: "0a0a0a")
    static let cardBg = Color(hex: "2a2a2a")

    static let buttonGradient = LinearGradient(
        colors: [Color(hex: "E2FF00"), Color(hex: "B8CC00")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Custom TextField Style

struct HBTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 15))
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(HBTheme.cardBg)
            )
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Button Style Extensions

extension View {
    func stylePrimary() -> some View {
        self
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(HBTheme.buttonGradient)
            .cornerRadius(25)
            .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 8, x: 0, y: 4)
    }

    func styleSecondary() -> some View {
        self
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(HBTheme.primaryYellow)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(HBTheme.primaryYellow, lineWidth: 2)
            )
    }
}

// MARK: - Checkbox Toggle Style

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? HBTheme.primaryYellow : .gray)
                .font(.system(size: 20))
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

// MARK: - Disclosure Item Helper

struct DisclosureItem: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundColor(.green)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - SMS Disclosure Detail Sheet

struct SMSDisclosureDetailSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("SMS Messaging Terms")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 16) {
                            smsTermSection(
                                title: "Opt-In Process",
                                content: "Gift recipients receive a single opt-in SMS when you send them a Honey Badger. They must reply YES to receive challenge updates and reminders."
                            )

                            smsTermSection(
                                title: "Message Frequency",
                                content: "During active challenges, recipients may receive 1-3 messages per day including reminders and motivational messages."
                            )

                            smsTermSection(
                                title: "Message & Data Rates",
                                content: "Standard message and data rates may apply. Message frequency varies based on challenge activity."
                            )

                            smsTermSection(
                                title: "Opting Out",
                                content: "Recipients can reply STOP at any time to unsubscribe from all Honey Badger messages. Reply HELP for assistance."
                            )

                            smsTermSection(
                                title: "Privacy",
                                content: "Phone numbers are only used for Honey Badger challenge notifications. We never share numbers with third parties for marketing."
                            )
                        }

                        VStack(spacing: 12) {
                            Link(destination: URL(string: "https://honeybadger.app/sms-terms")!) {
                                Text("View Full SMS Terms")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }

                            Link(destination: URL(string: "https://honeybadger.app/privacy")!) {
                                Text("Privacy Policy")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(HBTheme.primaryYellow)
                }
            }
        }
    }

    private func smsTermSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(HBTheme.primaryYellow)
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HBTheme.cardBg)
        .cornerRadius(12)
    }
}

// MARK: - Models

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct LoginResponse: Codable {
    let success: Bool
    let token: String?
    let user: User?
}

struct Contact: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var phone: String
    var email: String

    init(id: UUID = UUID(), name: String, phone: String, email: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
    }
}

// MARK: - Authentication Manager

class SimpleAuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let networkManager = NetworkManager()

    init() {
        // Check if user is already authenticated
        if networkManager.authToken != nil {
            isAuthenticated = true
            // Load user data
            Task {
                await loadCurrentUser()
            }
        }
    }

    func signup(name: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await networkManager.signup(name: name, email: email, password: password, phone: nil)
                await MainActor.run {
                    // Clear any cached data from previous user before setting new auth state
                    GiftStateManager.shared.clearState()

                    self.isAuthenticated = true
                    self.currentUser = User(id: response.user.id ?? 0, name: response.user.name, email: response.user.email)
                    self.isLoading = false
                    print("✅ Signup successful: \(response.user.name)")

                    // Refresh gift data for the new user (will be empty for new users)
                    Task {
                        await GiftStateManager.shared.refreshAll()
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ Signup error: \(error)")
                }
            }
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await networkManager.login(email: email, password: password)
                await MainActor.run {
                    // Clear any cached data from previous user before setting new auth state
                    GiftStateManager.shared.clearState()

                    self.isAuthenticated = true
                    self.currentUser = User(id: response.user.id ?? 0, name: response.user.name, email: response.user.email)
                    self.isLoading = false
                    print("✅ Login successful: \(response.user.name)")

                    // Refresh gift data for the new user
                    Task {
                        await GiftStateManager.shared.refreshAll()
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ Login error: \(error)")
                }
            }
        }
    }

    func logout() {
        Task {
            do {
                try await networkManager.logout()
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.errorMessage = nil
                    // Clear cached gift data to prevent data leakage between users
                    GiftStateManager.shared.clearState()
                    print("✅ Logout successful")
                }
            } catch {
                await MainActor.run {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.errorMessage = nil
                    // Clear cached gift data even on error to prevent data leakage
                    GiftStateManager.shared.clearState()
                    print("⚠️ Logout error (clearing anyway): \(error)")
                }
            }
        }
    }

    private func loadCurrentUser() async {
        do {
            let user = try await networkManager.getCurrentUser()
            await MainActor.run {
                self.currentUser = User(id: user.id ?? 0, name: user.name, email: user.email)
                print("✅ Loaded current user: \(user.name)")
            }
        } catch {
            await MainActor.run {
                self.isAuthenticated = false
                self.currentUser = nil
                print("❌ Failed to load user: \(error)")
            }
        }
    }

    func updateProfile(name: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                try await networkManager.updateProfile(name: name)
                await MainActor.run {
                    if let user = self.currentUser {
                        self.currentUser = User(id: user.id, name: name, email: user.email)
                    }
                    print("✅ Profile updated successfully")
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    print("❌ Profile update error: \(error)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                try await networkManager.changePassword(currentPassword: currentPassword, newPassword: newPassword)
                await MainActor.run {
                    print("✅ Password changed successfully")
                    completion(true, nil)
                }
            } catch {
                await MainActor.run {
                    print("❌ Password change error: \(error)")
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Main App View

struct HoneyBadgerMainView: View {
    @StateObject private var auth = SimpleAuthManager()

    var body: some View {
        ZStack {
            HBTheme.darkBg.ignoresSafeArea()

            if auth.isAuthenticated {
                DashboardScreen()
                    .environmentObject(auth)
            } else {
                LandingScreen()
                    .environmentObject(auth)
            }
        }
    }
}

// MARK: - Landing Screen

struct LandingScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @State private var showLogin = false
    @State private var showSignup = false
    @State private var showAbout = false
    @State private var carouselIndex = 0

    let words = ["Send", "Unlock", "Relish"]

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 40) {
                        // Header
                        HeaderBar(showLogin: $showLogin)

                        // Hero Section
                        VStack(spacing: 24) {
                            // Logo - clickable to open login
                            Button(action: { showLogin = true }) {
                                Image(systemName: "pawprint.circle.fill")
                                    .resizable()
                                    .frame(width: 200, height: 200)
                                    .foregroundColor(HBTheme.primaryYellow)
                                    .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 20)
                            }

                            // Animated Headline
                            HStack(spacing: 8) {
                                Text(words[carouselIndex])
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(HBTheme.primaryYellow)
                                    .animation(.easeInOut, value: carouselIndex)

                                Text("a Honey Badger")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                                    withAnimation {
                                        carouselIndex = (carouselIndex + 1) % words.count
                                    }
                                }
                            }

                            Text("Send AI-powered gift experiences that motivate, engage, and delight your loved ones")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)

                            // Hero Button
                            Button(action: { showLogin = true }) {
                                Text("SEND A BADGER")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 18)
                                    .background(HBTheme.buttonGradient)
                                    .cornerRadius(30)
                                    .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            .padding(.top, 24)

                            // About Button
                            Button(action: { showAbout = true }) {
                                Text("What's Honey Badger?")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }
                            .padding(.top, 16)

                            // Signup Button
                            Button(action: { showSignup = true }) {
                                Text("Create Account")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(HBTheme.primaryYellow)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(Color.clear)
                                    .cornerRadius(25)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(HBTheme.primaryYellow, lineWidth: 2)
                                    )
                            }
                            .padding(.top, 12)
                        }
                    }
                }
                .sheet(isPresented: $showLogin) {
                    LoginScreen(isPresented: $showLogin)
                        .environmentObject(auth)
                }
                .sheet(isPresented: $showSignup) {
                    SignupScreen(isPresented: $showSignup)
                        .environmentObject(auth)
                }
                .sheet(isPresented: $showAbout) {
                    AboutScreen(isPresented: $showAbout)
                }
            }
        }
    }
}

// MARK: - Header Bar

struct HeaderBar: View {
    @Binding var showLogin: Bool

    var body: some View {
        HStack {
            // Logo - clickable to open login
            Button(action: { showLogin = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(HBTheme.primaryYellow)
                        .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 8)

                    Text("HONEY BADGER")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(HBTheme.primaryYellow)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.black.opacity(0.95))
    }
}

// MARK: - Login Screen

struct LoginScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var showForgotPassword = false

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Logo
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(HBTheme.primaryYellow)
                        .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 20)

                    Text("Identification Please")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Your Honey Badger awaits")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)

                    // Form
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(HBTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(HBTextFieldStyle())
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 20)

                    // Forgot Password Link
                    HStack {
                        Spacer()
                        Button(action: { showForgotPassword = true }) {
                            Text("Forgot Password?")
                                .font(.system(size: 14))
                                .foregroundColor(HBTheme.primaryYellow)
                        }
                    }
                    .padding(.horizontal, 32)

                    // Error message
                    if let errorMessage = auth.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 32)
                    }

                    Button(action: login) {
                        if auth.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("LOGIN")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .stylePrimary()
                    .disabled(email.isEmpty || password.isEmpty || auth.isLoading)
                    .padding(.horizontal, 32)

                    // Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Button(action: { showSignup = true }) {
                            Text("Sign Up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(HBTheme.primaryYellow)
                        }
                    }
                    .padding(.top, 16)

                    Spacer()
                }
            }
            .sheet(isPresented: $showSignup) {
                SignupScreen(isPresented: $showSignup)
                    .environmentObject(auth)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordScreen(isPresented: $showForgotPassword)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func login() {
        auth.login(email: email, password: password)

        // Close after API call completes and user is authenticated
        Task {
            // Wait up to 5 seconds for authentication
            for _ in 0..<50 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                if auth.isAuthenticated {
                    await MainActor.run {
                        isPresented = false
                    }
                    break
                }
            }
        }
    }
}

// MARK: - Forgot Password Screen

struct ForgotPasswordScreen: View {
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var isLoading = false
    @State private var emailSent = false
    @State private var errorMessage: String?

    private let networkManager = NetworkManager()

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    if emailSent {
                        // Success state - check your email
                        Image(systemName: "envelope.badge.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(HBTheme.primaryYellow)
                            .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 20)

                        Text("Check Your Email")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("We sent a password reset link to \(email). Open the link in your email to set a new password.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Button(action: requestReset) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("RESEND EMAIL")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .styleSecondary()
                        .disabled(isLoading)
                        .padding(.horizontal, 32)

                        Button(action: { isPresented = false }) {
                            Text("BACK TO LOGIN")
                                .frame(maxWidth: .infinity)
                        }
                        .stylePrimary()
                        .padding(.horizontal, 32)
                    } else {
                        // Form state
                        Image(systemName: "lock.rotation")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(HBTheme.primaryYellow)
                            .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 20)

                        Text("Reset Password")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Enter your email and we'll send you a reset link")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        TextField("Email", text: $email)
                            .textFieldStyle(HBTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding(.horizontal, 32)
                            .padding(.top, 12)

                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 32)
                        }

                        Button(action: requestReset) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("SEND RESET LINK")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .stylePrimary()
                        .disabled(email.isEmpty || isLoading)
                        .padding(.horizontal, 32)
                    }

                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func requestReset() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let _ = try await networkManager.forgotPassword(email: email)
                await MainActor.run {
                    emailSent = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Signup Screen

struct SignupScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @Binding var isPresented: Bool
    @State private var currentStep = 1
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var showLogin = false

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Progress Indicator
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { step in
                            Circle()
                                .fill(step <= currentStep ? HBTheme.primaryYellow : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.top, 20)

                    Spacer()

                    // Logo
                    Image(systemName: "pawprint.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(HBTheme.primaryYellow)
                        .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 20)

                    // Step Content
                    if currentStep == 1 {
                        Step1View(email: $email)
                    } else if currentStep == 2 {
                        Step2View(name: $name)
                    } else {
                        Step3View(password: $password, confirmPassword: $confirmPassword, agreedToTerms: $agreedToTerms)
                    }

                    // Error message
                    if let errorMessage = auth.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 32)
                    }

                    // Navigation Buttons
                    HStack(spacing: 16) {
                        if currentStep > 1 {
                            Button(action: previousStep) {
                                Text("BACK")
                                    .frame(maxWidth: .infinity)
                            }
                            .styleSecondary()
                        }

                        Button(action: nextStepOrSignup) {
                            if auth.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text(currentStep == 3 ? "CREATE ACCOUNT" : "NEXT")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .stylePrimary()
                        .disabled(!canProceed || auth.isLoading)
                    }
                    .padding(.horizontal, 32)

                    // Login Link
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        Button(action: { showLogin = true }) {
                            Text("Login")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(HBTheme.primaryYellow)
                        }
                    }
                    .padding(.top, 16)

                    Spacer()
                }
            }
            .sheet(isPresented: $showLogin) {
                LoginScreen(isPresented: $showLogin)
                    .environmentObject(auth)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 1: return !email.isEmpty && email.contains("@")
        case 2: return name.count >= 2
        case 3: return !password.isEmpty && password.count >= 6 && password == confirmPassword && agreedToTerms
        default: return false
        }
    }

    private func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
            auth.errorMessage = nil
        }
    }

    private func nextStepOrSignup() {
        if currentStep < 3 {
            currentStep += 1
            auth.errorMessage = nil
        } else {
            signup()
        }
    }

    private func signup() {
        auth.signup(name: name, email: email, password: password)

        // Close after API call completes and user is authenticated
        Task {
            // Wait up to 5 seconds for authentication
            for _ in 0..<50 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                if auth.isAuthenticated {
                    await MainActor.run {
                        isPresented = false
                    }
                    break
                }
            }
        }
    }
}

// MARK: - Signup Step Views

struct Step1View: View {
    @Binding var email: String

    var body: some View {
        VStack(spacing: 16) {
            Text("What's your email?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("We'll use this to send you Badgers")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            TextField("Email", text: $email)
                .textFieldStyle(HBTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .padding(.horizontal, 32)
                .padding(.top, 20)
        }
    }
}

struct Step2View: View {
    @Binding var name: String

    var body: some View {
        VStack(spacing: 16) {
            Text("What's your name?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Let's personalize your experience")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            TextField("Full Name", text: $name)
                .textFieldStyle(HBTextFieldStyle())
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 32)
                .padding(.top, 20)
        }
    }
}

struct Step3View: View {
    @Binding var password: String
    @Binding var confirmPassword: String
    @Binding var agreedToTerms: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Create a password")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Must be at least 6 characters")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            VStack(spacing: 16) {
                SecureField("Password", text: $password)
                    .textFieldStyle(HBTextFieldStyle())

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(HBTextFieldStyle())
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)

            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                Text("Passwords don't match")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }

            // Terms and Privacy consent
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $agreedToTerms) {
                    HStack(spacing: 4) {
                        Text("I agree to the")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Link("Terms of Service", destination: URL(string: "https://honeybadger.app/terms")!)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(HBTheme.primaryYellow)
                        Text("and")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Link("Privacy Policy", destination: URL(string: "https://honeybadger.app/privacy")!)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(HBTheme.primaryYellow)
                    }
                }
                .toggleStyle(CheckboxToggleStyle())

                Text("Gift recipients will receive SMS messages from Honey Badger.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
    }
}

// MARK: - Dashboard Screen

struct DashboardScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var giftStateManager = GiftStateManager.shared
    @State private var showSendBadger = false
    @State private var showAddContact = false
    @State private var showAbout = false
    @State private var showAccountEdit = false
    @State private var showBadgersScreen = false
    @State private var badgersScreenInitialTab = 0
    @State private var showPendingApprovals = false
    @State private var contacts: [Contact] = []
    @State private var selectedGift: Gift? = nil
    @State private var showGiftDetail = false

    // Use shared state manager for gifts
    private var sentGifts: [Gift] {
        giftStateManager.sentGifts
    }

    private var loadingGifts: Bool {
        giftStateManager.isLoadingSent
    }

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Spacer()

                            Button(action: { showAccountEdit = true }) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Dashboard Summary Stats
                        dashboardSummary

                        // Send Badger Button
                        Button(action: { showSendBadger = true }) {
                            HStack(spacing: 16) {
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.black)

                                Text("SEND A HONEY BADGER")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(HBTheme.buttonGradient)
                            .cornerRadius(30)
                            .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)

                        // Badgers Section
                        badgersSection

                        // Your People Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(HBTheme.primaryYellow)
                                    Text("Your People")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Spacer()

                                Button(action: { showAddContact = true }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(HBTheme.primaryYellow)
                                }
                            }

                            if contacts.isEmpty {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(HBTheme.primaryYellow.opacity(0.15))
                                            .frame(width: 44, height: 44)

                                        Image(systemName: "person.3.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(HBTheme.primaryYellow)
                                    }

                                    Text("Add Your People")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.gray)

                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(contacts) { contact in
                                        HStack(spacing: 12) {
                                            // Contact Icon
                                            ZStack {
                                                Circle()
                                                    .fill(HBTheme.primaryYellow)
                                                    .frame(width: 50, height: 50)
                                                Text(String(contact.name.prefix(1).uppercased()))
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(.black)
                                            }

                                            // Contact Info
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(contact.name)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.white)
                                                if !contact.email.isEmpty {
                                                    Text(contact.email)
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.gray)
                                                }
                                                if !contact.phone.isEmpty {
                                                    Text(contact.phone)
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.gray)
                                                }
                                            }

                                            Spacer()

                                            // Send button
                                            Button(action: {
                                                // TODO: Pre-fill send badger with this contact
                                                showSendBadger = true
                                            }) {
                                                Image(systemName: "paperplane.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(HBTheme.primaryYellow)
                                            }
                                        }
                                        .padding(12)
                                        .background(HBTheme.cardBg.opacity(0.5))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(HBTheme.cardBg)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)

                        // About Button
                        Button(action: { showAbout = true }) {
                            Text("What's Honey Badger?")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(HBTheme.primaryYellow)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showSendBadger) {
                SendBadgerScreen(isPresented: $showSendBadger)
                    .environmentObject(auth)
                    .onDisappear {
                        // Reload gifts when send badger screen closes
                        loadGifts()
                    }
            }
            .sheet(isPresented: $showAddContact) {
                AddContactScreen(isPresented: $showAddContact, contacts: $contacts)
            }
            .sheet(isPresented: $showAbout) {
                AboutScreen(isPresented: $showAbout)
            }
            .sheet(isPresented: $showAccountEdit) {
                AccountEditScreen(isPresented: $showAccountEdit)
                    .environmentObject(auth)
            }
            .sheet(item: $selectedGift) { gift in
                GiftDetailScreen(gift: gift, isSentGift: true)
                    .presentationBackground(HBTheme.darkBg)
            }
            .sheet(isPresented: $showBadgersScreen) {
                BadgersInTheWildScreen(isPresented: $showBadgersScreen, initialTab: badgersScreenInitialTab)
            }
            .sheet(isPresented: $showPendingApprovals) {
                PendingApprovalsScreen(isPresented: $showPendingApprovals)
            }
            .onAppear {
                loadGifts()
                // Also refresh pending approvals
                Task {
                    await giftStateManager.refreshPendingApprovals()
                }
            }
        }
    }

    // MARK: - Dashboard Summary

    private var dashboardSummary: some View {
        HStack(spacing: 12) {
            // Sent
            summaryCard(
                count: sentGifts.filter { $0.status != "completed" }.count,
                label: "Sent",
                icon: "paperplane.fill",
                color: HBTheme.primaryYellow,
                action: {
                    badgersScreenInitialTab = 0
                    showBadgersScreen = true
                }
            )

            // Received
            summaryCard(
                count: giftStateManager.receivedGifts.filter { $0.status != "completed" }.count,
                label: "Received",
                icon: "gift.fill",
                color: Color.green,
                action: {
                    badgersScreenInitialTab = 1
                    showBadgersScreen = true
                }
            )

            // Approvals
            summaryCard(
                count: giftStateManager.pendingApprovalsCount,
                label: "Approvals",
                icon: "checkmark.circle.fill",
                color: Color.orange,
                action: { showPendingApprovals = true }
            )
        }
        .padding(.horizontal, 20)
    }

    private func summaryCard(count: Int, label: String, icon: String, color: Color, action: (() -> Void)? = nil) -> some View {
        Button(action: { action?() }) {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)

                    Text("\(count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(HBTheme.cardBg)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }

    // Combined count for determining if we should show "See All"
    private var totalBadgersCount: Int {
        giftStateManager.pendingApprovals.count + sentGifts.count
    }

    private var hasBadgersContent: Bool {
        !giftStateManager.pendingApprovals.isEmpty || !sentGifts.isEmpty
    }

    private var badgersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Badgers")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if totalBadgersCount > 3 {
                    Button(action: { showBadgersScreen = true }) {
                        HStack(spacing: 4) {
                            Text("See All")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(HBTheme.primaryYellow)
                    }
                }
            }

            if loadingGifts && giftStateManager.isLoadingApprovals {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: HBTheme.primaryYellow))
                        .scaleEffect(1.2)
                    Text("Loading your badgers...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else if !hasBadgersContent {
                badgersEmptyState
            } else {
                badgersList
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(HBTheme.cardBg)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
    }

    private var badgersEmptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(HBTheme.primaryYellow.opacity(0.15))
                    .frame(width: 80, height: 80)

                ZStack {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 24))
                        .foregroundColor(HBTheme.primaryYellow.opacity(0.6))
                        .offset(x: -10, y: -8)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 28))
                        .foregroundColor(HBTheme.primaryYellow.opacity(0.8))
                        .offset(x: 8, y: 2)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 22))
                        .foregroundColor(HBTheme.primaryYellow)
                        .offset(x: -8, y: 12)
                }
            }
            .padding(.top, 8)

            Text("No badgers in the wild yet!")
                .foregroundColor(.gray)

            Text("Send your first Honey Badger to get started!")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var badgersList: some View {
        let pendingApprovals = giftStateManager.pendingApprovals
        let maxItems = 3
        let pendingCount = min(pendingApprovals.count, maxItems)
        let remainingSlots = max(0, maxItems - pendingCount)
        let giftsToShow = Array(sentGifts.prefix(remainingSlots))

        return VStack(spacing: 8) {
            // Pending approvals first
            ForEach(Array(pendingApprovals.prefix(pendingCount))) { approval in
                pendingApprovalRow(approval: approval)
            }

            // Then sent gifts
            ForEach(giftsToShow, id: \.id) { gift in
                compactBadgerRow(gift: gift)
            }
        }
    }

    private func pendingApprovalRow(approval: PendingApproval) -> some View {
        Button(action: { showPendingApprovals = true }) {
            HStack(spacing: 10) {
                // Pending indicator icon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: "photo.badge.checkmark")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(approval.giftType)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        // Awaiting approval badge
                        Text("Awaiting Approval")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }

                    if let recipientName = approval.recipientName, !recipientName.isEmpty {
                        Text("To: \(recipientName)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(HBTheme.cardBg.opacity(0.5))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func compactBadgerRow(gift: Gift) -> some View {
        Button(action: {
            selectedGift = gift
            showGiftDetail = true
        }) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(HBTheme.primaryYellow.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: gift.status == "completed" ? "checkmark.seal.fill" : "pawprint.fill")
                        .font(.system(size: 16))
                        .foregroundColor(HBTheme.primaryYellow)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(gift.giftType)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if let recipientName = gift.recipientName, !recipientName.isEmpty {
                        Text("To: \(recipientName)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    } else if let recipientEmail = gift.recipientEmail, !recipientEmail.isEmpty {
                        Text("To: \(recipientEmail)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    } else if let recipientPhone = gift.recipientPhone, !recipientPhone.isEmpty {
                        Text("To: \(recipientPhone)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Status indicator
                Circle()
                    .fill(gift.status == "completed" ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)
            }
            .padding(10)
            .background(HBTheme.cardBg.opacity(0.5))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func badgerRow(gift: Gift) -> some View {
        Button(action: {
            selectedGift = gift
            showGiftDetail = true
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(HBTheme.primaryYellow.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: gift.status == "completed" ? "checkmark.seal.fill" : "pawprint.fill")
                        .font(.system(size: 20))
                        .foregroundColor(HBTheme.primaryYellow)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(gift.giftType)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    if let recipientName = gift.recipientName, !recipientName.isEmpty {
                        Text("To: \(recipientName)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    } else if let recipientEmail = gift.recipientEmail, !recipientEmail.isEmpty {
                        Text("To: \(recipientEmail)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    } else if let recipientPhone = gift.recipientPhone, !recipientPhone.isEmpty {
                        Text("To: \(recipientPhone)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill((gift.status == "completed" ? Color.green : Color.orange).opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: gift.status == "completed" ? "lock.open.fill" : "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(gift.status == "completed" ? .green : .orange)
                }
            }
            .padding(16)
            .background(HBTheme.cardBg.opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func loadGifts() {
        Task {
            await giftStateManager.refreshSentGifts()
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Splash Image Screen

struct SplashImageScreen: View {
    let useFeatured: Bool
    @State private var driftOffset: CGFloat = 0

    var body: some View {
        ZStack {
            HBTheme.darkBg.ignoresSafeArea()

            // Subtle ambient glow
            RadialGradient(
                gradient: Gradient(colors: [
                    HBTheme.primaryYellow.opacity(0.07),
                    Color.clear
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 350
            )
            .ignoresSafeArea()

            // Full-screen mascot with gentle drift
            Group {
                if useFeatured {
                    MascotImageView.featuredFullScreen()
                } else {
                    MascotImageView.randomFullScreen()
                }
            }
            .scaleEffect(1.08)
            .offset(y: driftOffset)
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                driftOffset = 8
            }
        }
    }
}

// MARK: - About Screen

struct AboutScreen: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Honey Badger Toon Image
                        Image("HoneyBadger_toon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .padding(.horizontal, 40)
                            .padding(.top, 40)

                        VStack(spacing: 16) {
                            Text("About Honey Badger")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text("Gifts Worth Fighting For")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(HBTheme.primaryYellow)
                        }

                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "gift.fill")
                                        .foregroundColor(HBTheme.primaryYellow)
                                        .font(.system(size: 20))
                                    Text("What is Honey Badger?")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text("Honey Badger is an AI-powered gift delivery platform that makes giving more meaningful. Send gift cards, cash, photos, and messages to loved ones—but with a twist: they have to complete fun challenges to unlock them!")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundColor(HBTheme.primaryYellow)
                                        .font(.system(size: 20))
                                    Text("AI-Powered Motivation")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text("Our Honey Badger mascot acts as a persistent, motivational coach via SMS. It encourages recipients to complete their challenges with humor, determination, and just the right amount of sass.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(HBTheme.primaryYellow)
                                        .font(.system(size: 20))
                                    Text("Challenge-Based Unlocking")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text("Create custom challenges like photo submissions, video messages, keyword hunts, or multi-day tasks. Recipients must complete these challenges to unlock their gifts, making every gift an adventure!")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(HBTheme.primaryYellow)
                                        .font(.system(size: 20))
                                    Text("Why Honey Badger?")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text("Because honey badgers are fierce, relentless, and never give up—just like the determination we inspire in your gift recipients. We turn ordinary gifts into memorable experiences that create lasting connections.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .lineSpacing(4)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }
}

// MARK: - Account Edit Screen

struct AccountEditScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var isLoading = false
    @State private var showSuccessMessage = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        // Profile Icon
                        ZStack {
                            Circle()
                                .fill(HBTheme.primaryYellow.opacity(0.2))
                                .frame(width: 64, height: 64)

                            Image(systemName: "person.fill")
                                .font(.system(size: 26))
                                .foregroundColor(HBTheme.primaryYellow)
                        }
                        .padding(.top, 10)

                        // Profile Information Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Profile Information")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Name")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    TextField("Full Name", text: $name)
                                        .textFieldStyle(HBTextFieldStyle())
                                        .textInputAutocapitalization(.words)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Email")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    TextField("Email", text: $email)
                                        .textFieldStyle(HBTextFieldStyle())
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .disabled(true)
                                        .opacity(0.6)
                                }
                            }

                            Button(action: updateProfile) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("UPDATE PROFILE")
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .stylePrimary()
                            .disabled(name.count < 2 || isLoading)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(HBTheme.cardBg)
                        )
                        .padding(.horizontal, 16)

                        // Change Password Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Change Password")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Password")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    SecureField("Current Password", text: $currentPassword)
                                        .textFieldStyle(HBTextFieldStyle())
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("New Password")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    SecureField("New Password", text: $newPassword)
                                        .textFieldStyle(HBTextFieldStyle())
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Confirm New Password")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    SecureField("Confirm New Password", text: $confirmNewPassword)
                                        .textFieldStyle(HBTextFieldStyle())
                                }

                                if !newPassword.isEmpty && !confirmNewPassword.isEmpty && newPassword != confirmNewPassword {
                                    Text("Passwords don't match")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                }
                            }

                            Button(action: changePassword) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("CHANGE PASSWORD")
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .stylePrimary()
                            .disabled(!canChangePassword || isLoading)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(HBTheme.cardBg)
                        )
                        .padding(.horizontal, 16)

                        // Error/Success Messages
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                        }

                        if showSuccessMessage {
                            Text("Profile updated successfully!")
                                .font(.system(size: 13))
                                .foregroundColor(.green)
                                .padding(.horizontal, 16)
                        }

                        // Logout Button
                        Button(action: {
                            isPresented = false
                            auth.logout()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 15))
                                Text("Log Out")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        Spacer(minLength: 16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
            }
            .onAppear {
                // Load current user data
                if let user = auth.currentUser {
                    name = user.name
                    email = user.email
                }
            }
        }
    }

    private var canChangePassword: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmNewPassword
    }

    private func updateProfile() {
        isLoading = true
        errorMessage = nil
        showSuccessMessage = false

        auth.updateProfile(name: name) { success, error in
            isLoading = false
            if success {
                showSuccessMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccessMessage = false
                }
            } else {
                errorMessage = error ?? "Failed to update profile"
            }
        }
    }

    private func changePassword() {
        isLoading = true
        errorMessage = nil
        showSuccessMessage = false

        auth.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, error in
            isLoading = false
            if success {
                showSuccessMessage = true
                currentPassword = ""
                newPassword = ""
                confirmNewPassword = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showSuccessMessage = false
                }
            } else {
                errorMessage = error ?? "Failed to change password"
            }
        }
    }
}

// MARK: - Pending Approvals Screen

struct PendingApprovalsScreen: View {
    @Binding var isPresented: Bool
    @StateObject private var giftStateManager = GiftStateManager.shared
    @State private var selectedApproval: PendingApproval? = nil
    @State private var showRejectSheet = false
    @State private var rejectionReason = ""
    @State private var isProcessing = false
    @State private var showSuccessMessage = false
    @State private var successMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    if giftStateManager.isLoadingApprovals {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: HBTheme.primaryYellow))
                                .scaleEffect(1.2)
                            Text("Loading pending approvals...")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else if giftStateManager.pendingApprovals.isEmpty {
                        Spacer()
                        emptyStateView
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(giftStateManager.pendingApprovals) { approval in
                                    ApprovalCard(
                                        approval: approval,
                                        onApprove: { approveSubmission(approval) },
                                        onReject: {
                                            selectedApproval = approval
                                            showRejectSheet = true
                                        },
                                        isProcessing: isProcessing
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                }

                // Success toast
                if showSuccessMessage {
                    VStack {
                        Spacer()
                        Text(successMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(HBTheme.primaryYellow)
                            .cornerRadius(25)
                            .padding(.bottom, 30)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showSuccessMessage)
                }
            }
            .navigationTitle("Pending Approvals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(HBTheme.primaryYellow)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await giftStateManager.refreshPendingApprovals()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(HBTheme.primaryYellow)
                    }
                }
            }
            .sheet(isPresented: $showRejectSheet) {
                RejectSubmissionSheet(
                    approval: selectedApproval,
                    rejectionReason: $rejectionReason,
                    onReject: {
                        if let approval = selectedApproval {
                            rejectSubmission(approval, reason: rejectionReason)
                        }
                        showRejectSheet = false
                        rejectionReason = ""
                    },
                    onCancel: {
                        showRejectSheet = false
                        rejectionReason = ""
                    }
                )
            }
            .onAppear {
                Task {
                    await giftStateManager.refreshPendingApprovals()
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(HBTheme.primaryYellow.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(HBTheme.primaryYellow)
            }

            Text("All caught up!")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            Text("No pending photo approvals right now")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }

    private func approveSubmission(_ approval: PendingApproval) {
        isProcessing = true
        Task {
            let success = await giftStateManager.approveSubmission(submissionId: approval.submissionId)
            await MainActor.run {
                isProcessing = false
                if success {
                    successMessage = "Photo approved! Gift unlocked!"
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessMessage = false
                    }
                }
            }
        }
    }

    private func rejectSubmission(_ approval: PendingApproval, reason: String) {
        isProcessing = true
        Task {
            let success = await giftStateManager.rejectSubmission(submissionId: approval.submissionId, reason: reason.isEmpty ? nil : reason)
            await MainActor.run {
                isProcessing = false
                if success {
                    successMessage = "Photo submission rejected"
                    showSuccessMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccessMessage = false
                    }
                }
            }
        }
    }
}

// MARK: - Approval Card

struct ApprovalCard: View {
    let approval: PendingApproval
    let onApprove: () -> Void
    let onReject: () -> Void
    let isProcessing: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Photo preview
            AsyncImage(url: URL(string: "\(HoneyBadgerAPIConfig.baseURL)\(approval.photoUrl)")) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(HBTheme.cardBg)
                            .frame(height: 200)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: HBTheme.primaryYellow))
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                case .failure:
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(HBTheme.cardBg)
                            .frame(height: 200)
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                @unknown default:
                    EmptyView()
                }
            }

            // Gift info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(approval.recipientName ?? "Unknown")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(approval.giftType)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(HBTheme.primaryYellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(HBTheme.primaryYellow.opacity(0.2))
                        .cornerRadius(8)
                }

                if let challenge = approval.challengeDescription {
                    Text(challenge)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Text("Submitted \(formatDate(approval.submittedAt))")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.7))
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: onReject) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Reject")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.red)
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(10)
                }
                .disabled(isProcessing)

                Button(action: onApprove) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Approve")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.black)
                    .background(HBTheme.buttonGradient)
                    .cornerRadius(10)
                }
                .disabled(isProcessing)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(HBTheme.cardBg)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = RelativeDateTimeFormatter()
            displayFormatter.unitsStyle = .short
            return displayFormatter.localizedString(for: date, relativeTo: Date())
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = RelativeDateTimeFormatter()
            displayFormatter.unitsStyle = .short
            return displayFormatter.localizedString(for: date, relativeTo: Date())
        }
        return dateString
    }
}

// MARK: - Reject Submission Sheet

struct RejectSubmissionSheet: View {
    let approval: PendingApproval?
    @Binding var rejectionReason: String
    let onReject: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Reject Submission")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Optionally provide a reason for rejection. This will be sent to the recipient.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    TextEditor(text: $rejectionReason)
                        .scrollContentBackground(.hidden)
                        .background(HBTheme.cardBg)
                        .foregroundColor(.white)
                        .frame(height: 120)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)

                    HStack(spacing: 16) {
                        Button(action: onCancel) {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }
                        .styleSecondary()

                        Button(action: onReject) {
                            Text("Reject")
                                .frame(maxWidth: .infinity)
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarHidden(true)
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Badgers In The Wild Screen

struct BadgersInTheWildScreen: View {
    @Binding var isPresented: Bool
    var initialTab: Int = 0
    @StateObject private var giftStateManager = GiftStateManager.shared
    @State private var selectedTab = 0 // 0 = Sent, 1 = Received
    @State private var selectedGift: Gift? = nil
    @State private var showGiftDetail = false

    private var isLoading: Bool {
        giftStateManager.isLoadingSent || giftStateManager.isLoadingReceived
    }

    private var sentGifts: [Gift] {
        giftStateManager.sentGifts
    }

    private var receivedGifts: [Gift] {
        giftStateManager.receivedGifts
    }

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented Control
                    Picker("Gift Type", selection: $selectedTab) {
                        Text("Sent (\(sentGifts.count))").tag(0)
                        Text("Received (\(receivedGifts.count))").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 16)

                    if isLoading {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: HBTheme.primaryYellow))
                                .scaleEffect(1.2)
                            Text("Loading your badgers...")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        let currentGifts = selectedTab == 0 ? sentGifts : receivedGifts
                        if currentGifts.isEmpty {
                            Spacer()
                            emptyStateView
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(currentGifts) { gift in
                                        EnhancedBadgerRow(gift: gift, isSentGift: selectedTab == 0)
                                            .onTapGesture {
                                                selectedGift = gift
                                                showGiftDetail = true
                                            }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                            .refreshable {
                                await giftStateManager.refreshAll()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Active Badgers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(HBTheme.primaryYellow)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await giftStateManager.refreshAll()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(HBTheme.primaryYellow)
                    }
                }
            }
            .sheet(item: $selectedGift) { gift in
                GiftDetailScreen(gift: gift, isSentGift: selectedTab == 0)
                    .presentationBackground(HBTheme.darkBg)
            }
            .onAppear {
                selectedTab = initialTab
                Task {
                    await giftStateManager.refreshAll()
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(HBTheme.primaryYellow.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: selectedTab == 0 ? "paperplane.fill" : "tray.fill")
                    .font(.system(size: 32))
                    .foregroundColor(HBTheme.primaryYellow)
            }

            Text(selectedTab == 0 ? "No gifts sent yet" : "No gifts received yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text(selectedTab == 0 ? "Send your first Honey Badger!" : "Gifts you receive will appear here")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }

}

// MARK: - Enhanced Badger Row

struct EnhancedBadgerRow: View {
    let gift: Gift
    let isSentGift: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: statusIcon)
                    .font(.system(size: 20))
                    .foregroundColor(statusColor)
            }

            // Gift info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(gift.giftType)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    if let value = gift.giftValue, !value.isEmpty {
                        Text("$\(value)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(HBTheme.primaryYellow)
                    }
                }

                // Show recipient (if sent) or sender (if received)
                if isSentGift {
                    if let name = gift.recipientName, !name.isEmpty {
                        Text("To: \(name)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    } else if let email = gift.recipientEmail, !email.isEmpty {
                        Text("To: \(email)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                } else {
                    if let senderName = gift.senderName, !senderName.isEmpty {
                        Text("From: \(senderName)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                // Challenge preview
                if let challengeType = gift.challengeType, !challengeType.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 10))
                        Text(challengeType)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(HBTheme.primaryYellow.opacity(0.8))
                }
            }

            Spacer()

            // Lock status
            VStack(spacing: 4) {
                Image(systemName: gift.status == "completed" ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(gift.status == "completed" ? .green : .orange)

                Text(gift.status == "completed" ? "Unlocked" : "Locked")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(gift.status == "completed" ? .green : .orange)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(HBTheme.cardBg)
        .cornerRadius(12)
    }

    private var statusColor: Color {
        switch gift.status.lowercased() {
        case "completed":
            return .green
        case "pending":
            return .orange
        case "active":
            return HBTheme.primaryYellow
        default:
            return .gray
        }
    }

    private var statusIcon: String {
        switch gift.status.lowercased() {
        case "completed":
            return "checkmark.seal.fill"
        case "pending":
            return "clock.fill"
        case "active":
            return "pawprint.fill"
        default:
            return "gift.fill"
        }
    }
}

// MARK: - Challenge Progress View

struct ChallengeProgressView: View {
    let currentStep: Int
    let totalSteps: Int
    let challengeDescription: String?

    var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let description = challengeDescription, !description.isEmpty {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [HBTheme.primaryYellow, HBTheme.primaryYellow.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            // Step indicator
            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HBTheme.primaryYellow)
            }
        }
    }
}

// MARK: - Gift Detail Screen

struct GiftDetailScreen: View {
    let gift: Gift
    var isSentGift: Bool = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HBTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(HBTheme.primaryYellow)
                    }
                    Spacer()
                    Text("Gift Details")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    // Spacer for balance
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(HBTheme.darkBg)

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with honey badger icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(HBTheme.primaryYellow.opacity(0.15))
                                    .frame(width: 100, height: 100)

                                Image(systemName: gift.status == "completed" ? "checkmark.seal.fill" : "pawprint.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }

                            HStack(spacing: 8) {
                                Text(gift.giftType)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)

                                if let value = gift.giftValue, !value.isEmpty {
                                    Text("$\(value)")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(HBTheme.primaryYellow)
                                }
                            }

                            // Status badge
                            HStack(spacing: 8) {
                                Image(systemName: gift.status == "completed" ? "lock.open.fill" : "lock.fill")
                                    .font(.system(size: 14))
                                Text(gift.status == "completed" ? "Unlocked" : "Locked")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(gift.status == "completed" ? .green : .orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill((gift.status == "completed" ? Color.green : Color.orange).opacity(0.2))
                            )
                        }
                        .padding(.top, 20)

                        // Challenge Section
                        if let challengeType = gift.challengeType, !challengeType.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: "flag.fill")
                                        .foregroundColor(HBTheme.primaryYellow)
                                    Text("Challenge")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text(challengeType)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)

                                if let description = gift.challengeDescription, !description.isEmpty {
                                    Text(description)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }

                                ChallengeProgressView(
                                    currentStep: gift.status == "completed" ? 1 : 0,
                                    totalSteps: 1,
                                    challengeDescription: nil
                                )
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(HBTheme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(HBTheme.primaryYellow.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }

                        // Gift Details Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(HBTheme.primaryYellow)
                                Text("Details")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            if isSentGift {
                                DetailRow(label: "Recipient", value: gift.recipientName ?? gift.recipientEmail ?? gift.recipientPhone ?? "Unknown")
                            } else {
                                if let senderName = gift.senderName, !senderName.isEmpty {
                                    DetailRow(label: "From", value: senderName)
                                }
                            }

                            if let email = gift.recipientEmail, !email.isEmpty, isSentGift {
                                DetailRow(label: "Email", value: email)
                            }

                            if let phone = gift.recipientPhone, !phone.isEmpty, isSentGift {
                                DetailRow(label: "Phone", value: phone)
                            }

                            if let deliveryMethod = gift.deliveryMethod, !deliveryMethod.isEmpty {
                                DetailRow(label: "Delivery", value: deliveryMethod.capitalized)
                            }

                            if let duration = gift.duration, duration > 0 {
                                DetailRow(label: "Duration", value: "\(duration) days")
                            }

                            if let reminderFrequency = gift.reminderFrequency, !reminderFrequency.isEmpty {
                                DetailRow(label: "Reminders", value: reminderFrequency.capitalized)
                            }

                            DetailRow(label: "Created", value: formatRelativeDate(gift.createdAt))

                            DetailRow(label: "Status", value: gift.status.capitalized)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(HBTheme.cardBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(HBTheme.primaryYellow.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)

                        // Personal Message Section
                        if let message = gift.message ?? gift.personalNote, !message.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(HBTheme.primaryYellow)
                                    Text("Personal Message")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                Text(message)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                                    .italic()
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(HBTheme.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(HBTheme.primaryYellow.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HBTheme.darkBg)
    }

    private func formatRelativeDate(_ dateString: String) -> String {
        // Try multiple date formats
        let formatters: [DateFormatter] = {
            let iso8601 = DateFormatter()
            iso8601.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

            let iso8601Simple = DateFormatter()
            iso8601Simple.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

            let sqlDate = DateFormatter()
            sqlDate.dateFormat = "yyyy-MM-dd HH:mm:ss"

            return [iso8601, iso8601Simple, sqlDate]
        }()

        var date: Date?
        for formatter in formatters {
            if let parsedDate = formatter.date(from: dateString) {
                date = parsedDate
                break
            }
        }

        guard let parsedDate = date else {
            return dateString
        }

        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        return relativeFormatter.localizedString(for: parsedDate, relativeTo: Date())
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(HBTheme.primaryYellow.opacity(0.8))
                .tracking(1)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

// MARK: - Send Badger Screen

struct SendBadgerScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @StateObject private var networkManager = NetworkManager()
    @Binding var isPresented: Bool
    @State private var showSplash = true
    @State private var showMainContent = false
    @State private var showTransitionFlash = false
    @State private var currentStep = 1
    @State private var sendingBadger = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var recipientName = ""
    @State private var recipientEmail = ""
    @State private var recipientPhone = ""
    @State private var unlockCategory = "Simple Unlock"
    @State private var challengeType = "Photo"
    @State private var challengePrompt = ""
    @State private var motivatingChallengeDays = "7"
    @State private var motivatingChallengeGoal = ""
    @State private var occasion = "Birthday"
    @State private var giftType = "Photo or Video"
    @State private var giftAmount = "25"
    @State private var message = ""
    @State private var showGiftCardScreen = false
    @State private var showPhotoUpload = false
    @State private var selectedImageData: Data? = nil
    @State private var giftCardConfigured = false
    @State private var currentSplashImage = "HoneyBadger_toon"
    @State private var smsConsentAcknowledged = false

    let badgerImages = ["HoneyBadger_toon", "CyberBadger", "honey-badger-ninja"]
    let unlockCategories = ["Simple Unlock", "Motivating Unlock"]
    let occasions = ["Birthday", "Congratulations", "Thank You", "Just Because", "Holiday", "Get Well"]
    let giftTypes = ["Photo or Video", "Promise", "Gift Card / Money"]
    let amounts = ["10", "25", "50", "100"]
    let dayOptions = ["3", "7", "14", "21", "30"]

    var body: some View {
        ZStack {
            if showSplash {
                // Full-screen splash — image fills the entire display
                SplashImageScreen(useFeatured: true)
                .onAppear {
                    MascotImageService.shared.preloadFeaturedImage()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showSplash = false
                            showMainContent = true
                        }
                    }
                }
            } else if showMainContent {
                mainContentView
            }

            // Flash transition overlay — full screen random badger
            if showTransitionFlash {
                SplashImageScreen(useFeatured: false)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
    }

    var mainContentView: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 24) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Icon
                            if currentStep == 2 {
                                Image(systemName: "lock.shield.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(HBTheme.primaryYellow)
                                    .padding(.top, 20)
                            } else if currentStep == 3 {
                                Image(systemName: "pencil.and.list.clipboard")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(HBTheme.primaryYellow)
                                    .padding(.top, 20)
                            } else if currentStep == 4 {
                                Image(systemName: "gift.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(HBTheme.primaryYellow)
                                    .padding(.top, 20)
                            }

                            // Step Content
                            if currentStep == 1 {
                                WhoView(
                                    recipientName: $recipientName,
                                    recipientEmail: $recipientEmail,
                                    recipientPhone: $recipientPhone,
                                    smsConsentAcknowledged: $smsConsentAcknowledged,
                                    currentUserEmail: auth.currentUser?.email ?? ""
                                )
                            } else if currentStep == 2 {
                                ChallengeSelectionView(
                                    unlockCategory: $unlockCategory,
                                    challengeType: $challengeType,
                                    motivatingChallengeDays: $motivatingChallengeDays,
                                    motivatingChallengeGoal: $motivatingChallengeGoal,
                                    dayOptions: dayOptions
                                )
                            } else if currentStep == 3 {
                                ChallengeConfigView(
                                    unlockCategory: unlockCategory,
                                    challengeType: challengeType,
                                    challengePrompt: $challengePrompt,
                                    occasion: $occasion,
                                    occasions: occasions
                                )
                            } else {
                                GiftDetailsView(
                                    giftType: $giftType,
                                    giftAmount: $giftAmount,
                                    message: $message,
                                    showGiftCardScreen: $showGiftCardScreen,
                                    showPhotoUpload: $showPhotoUpload,
                                    selectedImageData: $selectedImageData,
                                    giftCardConfigured: $giftCardConfigured,
                                    giftTypes: giftTypes,
                                    amounts: amounts
                                )
                            }
                        }
                    }

                    // Navigation Buttons
                    HStack(spacing: 16) {
                        if currentStep > 1 {
                            Button(action: previousStep) {
                                Text("BACK")
                                    .frame(maxWidth: .infinity)
                            }
                            .styleSecondary()
                        }

                        Button(action: nextStepOrSend) {
                            HStack {
                                if sendingBadger {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .scaleEffect(0.8)
                                }
                                Text(sendingBadger ? "SENDING..." : (currentStep == 4 ? "SEND BADGER" : "NEXT"))
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canProceed && !sendingBadger ? HBTheme.buttonGradient : LinearGradient(colors: [Color.gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(30)
                            .shadow(color: canProceed && !sendingBadger ? HBTheme.primaryYellow.opacity(0.4) : Color.clear, radius: 12, x: 0, y: 6)
                        }
                        .disabled(!canProceed || sendingBadger)
                        .opacity(canProceed && !sendingBadger ? 1.0 : 0.5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .disabled(sendingBadger)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showGiftCardScreen) {
                GiftCardConfigScreen(
                    isPresented: $showGiftCardScreen,
                    giftAmount: $giftAmount,
                    giftCardConfigured: $giftCardConfigured,
                    amounts: amounts
                )
            }
            .sheet(isPresented: $showPhotoUpload) {
                PhotoUploadScreen(
                    isPresented: $showPhotoUpload,
                    selectedImageData: $selectedImageData
                )
            }
        }
    }

    // Check if recipient is the same as current user
    private var isSendingToSelf: Bool {
        guard let currentUser = auth.currentUser else { return false }
        let emailMatch = !recipientEmail.isEmpty && recipientEmail.lowercased() == currentUser.email.lowercased()
        return emailMatch
    }

    private var canProceed: Bool {
        switch currentStep {
        case 1:
            // Prevent sending to self
            if isSendingToSelf { return false }
            let emailValid = !recipientEmail.isEmpty && recipientEmail.contains("@") && recipientEmail.contains(".")
            let phoneValid = !recipientPhone.isEmpty && recipientPhone.count >= 10
            // Require SMS consent acknowledgment if phone is provided
            if phoneValid && !smsConsentAcknowledged { return false }
            return emailValid || phoneValid
        case 2:
            if unlockCategory == "Simple Unlock" {
                return !challengeType.isEmpty
            } else {
                return !motivatingChallengeGoal.isEmpty && !motivatingChallengeDays.isEmpty
            }
        case 3: return !challengePrompt.isEmpty
        case 4: return true
        default: return false
        }
    }

    private func previousStep() {
        if currentStep > 1 {
            // Pick a new random badger for the flash
            currentSplashImage = badgerImages.randomElement() ?? "HoneyBadger_toon"
            withAnimation(.easeIn(duration: 0.15)) {
                showTransitionFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentStep -= 1
                withAnimation(.easeOut(duration: 0.15)) {
                    showTransitionFlash = false
                }
            }
        }
    }

    private func nextStepOrSend() {
        if currentStep < 4 {
            // Pick a new random badger for the flash
            currentSplashImage = badgerImages.randomElement() ?? "HoneyBadger_toon"
            withAnimation(.easeIn(duration: 0.15)) {
                showTransitionFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentStep += 1
                withAnimation(.easeOut(duration: 0.15)) {
                    showTransitionFlash = false
                }
            }
        } else {
            sendBadger()
        }
    }

    private func sendBadger() {
        Task {
            await MainActor.run {
                sendingBadger = true
            }

            do {
                // Get sender name for email
                let senderName = auth.currentUser?.name ?? "A friend"

                // Prepare gift details with email template info
                let giftDetails: [String: Any] = [
                    "recipientName": recipientName,
                    "recipientEmail": recipientEmail,
                    "recipientPhone": recipientPhone,
                    "unlockCategory": unlockCategory,
                    "challengeType": challengeType,
                    "challengePrompt": challengePrompt,
                    "motivatingChallengeDays": motivatingChallengeDays,
                    "motivatingChallengeGoal": motivatingChallengeGoal,
                    "occasion": occasion,
                    "giftType": giftType,
                    "giftAmount": giftAmount,
                    "message": message,
                    "senderName": senderName,
                    // SMS consent acknowledgment
                    "smsConsentAcknowledged": smsConsentAcknowledged,
                    "smsConsentTimestamp": ISO8601DateFormatter().string(from: Date()),
                    // Email configuration
                    "emailConfig": [
                        "appSignupURL": EmailTemplates.appSignupURL,
                        "appDownloadURL": EmailTemplates.appDownloadURL,
                        "honeyBadgerLogoURL": EmailTemplates.honeyBadgerLogoURL,
                        "honeyBadgerMascotURL": EmailTemplates.honeyBadgerMascotURL
                    ]
                ]

                print("📤 Sending Honey Badger:")
                print("   To: \(recipientName) (\(recipientEmail))")
                print("   Type: \(unlockCategory)")
                print("   Challenge: \(challengePrompt)")

                // Call the API
                let response = try await networkManager.sendGift(
                    recipientPhone: recipientPhone,
                    giftType: giftType,
                    challengeType: challengeType,
                    giftDetails: giftDetails
                )

                print("✅ Honey Badger sent successfully!")
                print("   Gift ID: \(response.giftId)")

                // Close the screen on success
                await MainActor.run {
                    sendingBadger = false
                    isPresented = false
                }
            } catch {
                print("❌ Error sending Honey Badger: \(error)")
                await MainActor.run {
                    sendingBadger = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Contact Picker

struct ContactPicker: UIViewControllerRepresentable {
    @Binding var recipientName: String
    @Binding var recipientEmail: String
    @Binding var recipientPhone: String
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPicker

        init(_ parent: ContactPicker) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            // Get name
            let firstName = contact.givenName
            let lastName = contact.familyName
            parent.recipientName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)

            // Get email
            if let email = contact.emailAddresses.first?.value as String? {
                parent.recipientEmail = email
            }

            // Get phone number
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                parent.recipientPhone = phoneNumber
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Challenge Selection View

struct ChallengeSelectionView: View {
    @Binding var unlockCategory: String
    @Binding var challengeType: String
    @Binding var motivatingChallengeDays: String
    @Binding var motivatingChallengeGoal: String
    let dayOptions: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("Choose the Unlock")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)

                    Text("How will they earn their gift?")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }

                VStack(spacing: 20) {
                    // Simple Unlock Section
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: { unlockCategory = "Simple Unlock" }) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(unlockCategory == "Simple Unlock" ? .black : HBTheme.primaryYellow)
                                    .frame(width: 32)

                                Text("Simple Unlock")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(unlockCategory == "Simple Unlock" ? .black : .white)

                                Spacer()

                                if unlockCategory == "Simple Unlock" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(16)
                            .background(unlockCategory == "Simple Unlock" ? HBTheme.primaryYellow : HBTheme.cardBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(unlockCategory == "Simple Unlock" ? HBTheme.primaryYellow : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                        }

                        // Simple Unlock Options (shown when selected)
                        if unlockCategory == "Simple Unlock" {
                            VStack(spacing: 12) {
                                // Photo Option
                                Button(action: { challengeType = "Photo" }) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(challengeType == "Photo" ? HBTheme.primaryYellow : .gray)
                                            .frame(width: 32)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Photo")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            Text("They send a photo to unlock")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        if challengeType == "Photo" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(HBTheme.primaryYellow)
                                        }
                                    }
                                    .padding(14)
                                    .background(HBTheme.cardBg.opacity(0.5))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(challengeType == "Photo" ? HBTheme.primaryYellow : Color.gray.opacity(0.2), lineWidth: 1.5)
                                    )
                                }

                                // Video Option
                                Button(action: { challengeType = "Video" }) {
                                    HStack {
                                        Image(systemName: "video.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(challengeType == "Video" ? HBTheme.primaryYellow : .gray)
                                            .frame(width: 32)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Video")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                            Text("They send a video to unlock")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()

                                        if challengeType == "Video" {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(HBTheme.primaryYellow)
                                        }
                                    }
                                    .padding(14)
                                    .background(HBTheme.cardBg.opacity(0.5))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(challengeType == "Video" ? HBTheme.primaryYellow : Color.gray.opacity(0.2), lineWidth: 1.5)
                                    )
                                }
                            }
                            .padding(.leading, 16)
                        }
                    }

                    // Motivating Unlock Section
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: { unlockCategory = "Motivating Unlock" }) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(unlockCategory == "Motivating Unlock" ? .black : HBTheme.primaryYellow)
                                    .frame(width: 32)

                                Text("Motivating Unlock")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(unlockCategory == "Motivating Unlock" ? .black : .white)

                                Spacer()

                                if unlockCategory == "Motivating Unlock" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(16)
                            .background(unlockCategory == "Motivating Unlock" ? HBTheme.primaryYellow : HBTheme.cardBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(unlockCategory == "Motivating Unlock" ? HBTheme.primaryYellow : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                        }

                        // Motivating Unlock Configuration (shown when selected)
                        if unlockCategory == "Motivating Unlock" {
                            VStack(spacing: 16) {
                                // Daily Goal Input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Daily Challenge")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)

                                    TextField("e.g., Do 50 pushups", text: $motivatingChallengeGoal)
                                        .padding(14)
                                        .background(HBTheme.cardBg.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }

                                // Number of Days Picker
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Duration")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)

                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(dayOptions, id: \.self) { days in
                                                Button(action: { motivatingChallengeDays = days }) {
                                                    VStack(spacing: 4) {
                                                        Text(days)
                                                            .font(.system(size: 20, weight: .bold))
                                                            .foregroundColor(motivatingChallengeDays == days ? .black : .white)
                                                        Text("days")
                                                            .font(.system(size: 12))
                                                            .foregroundColor(motivatingChallengeDays == days ? .black.opacity(0.7) : .gray)
                                                    }
                                                    .frame(width: 70, height: 60)
                                                    .background(motivatingChallengeDays == days ? HBTheme.primaryYellow : HBTheme.cardBg.opacity(0.5))
                                                    .cornerRadius(10)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(motivatingChallengeDays == days ? HBTheme.primaryYellow : Color.gray.opacity(0.3), lineWidth: 1.5)
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }

                                // Example
                                HStack(spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(HBTheme.primaryYellow.opacity(0.7))
                                    Text("Example: \"Do 50 pushups\" for 14 days")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                .padding(12)
                                .background(HBTheme.cardBg.opacity(0.3))
                                .cornerRadius(8)
                            }
                            .padding(.leading, 16)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Challenge Config View

struct ChallengeConfigView: View {
    let unlockCategory: String
    let challengeType: String
    @Binding var challengePrompt: String
    @Binding var occasion: String
    let occasions: [String]

    // Sample challenges for ticker - no emojis
    let sampleChallenges = [
        "Take a birthday selfie with your cake",
        "Show us your happy dance",
        "Send a thank you video message",
        "Capture your morning workout",
        "Share your favorite holiday moment",
        "Record yourself opening the gift",
        "Take a pic at your favorite spot",
        "Show us your biggest smile",
        "Capture a sunset selfie",
        "Send a get well soon message"
    ]

    // Digital green color for stock ticker
    private let digitalGreen = Color(red: 0.0, green: 0.9, blue: 0.3)

    @State private var tickerOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 16) {
            Text("Setup the Challenge")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 10)

            VStack(spacing: 16) {
                // Stock Ticker Style Inspiration
                VStack(alignment: .leading, spacing: 4) {
                    Text("IDEAS FOR INSPIRATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)

                    ZStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 44)

                        GeometryReader { geo in
                            let tickerText = sampleChallenges.joined(separator: "  ///  ")
                            HStack(spacing: 0) {
                                Text(tickerText + "  ///  " + tickerText)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(digitalGreen)
                                    .fixedSize()
                            }
                            .offset(x: tickerOffset)
                            .onAppear {
                                startTickerAnimation(width: geo.size.width)
                            }
                        }
                        .frame(height: 44)
                        .clipped()
                    }
                    .onTapGesture {
                        // Cycle through challenges on tap
                        let currentIndex = sampleChallenges.firstIndex(of: challengePrompt) ?? -1
                        let nextIndex = (currentIndex + 1) % sampleChallenges.count
                        challengePrompt = sampleChallenges[nextIndex]
                    }
                }

                // Challenge Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text(promptLabel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    ZStack(alignment: .topLeading) {
                        if challengePrompt.isEmpty {
                            Text(placeholderText)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.top, 14)
                                .padding(.leading, 14)
                        }
                        TextEditor(text: $challengePrompt)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 120)
                            .padding(10)
                    }
                    .background(HBTheme.cardBg)
                    .cornerRadius(10)

                    Text(exampleText)
                        .font(.system(size: 13))
                        .foregroundColor(.gray.opacity(0.8))
                        .italic()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            Spacer()
        }
        .padding(.top, 20)
    }

    private var instructionText: String {
        if unlockCategory == "Simple Unlock" {
            switch challengeType {
            case "Photo":
                return "What photo should they send to unlock their gift?"
            case "Video":
                return "What video should they record to unlock their gift?"
            default:
                return "Describe the challenge"
            }
        } else {
            return "Add a personal message about their motivating challenge"
        }
    }

    private var promptLabel: String {
        if unlockCategory == "Simple Unlock" {
            switch challengeType {
            case "Photo":
                return "Photo Instructions"
            case "Video":
                return "Video Instructions"
            default:
                return "Instructions"
            }
        } else {
            return "Motivational Message"
        }
    }

    private var placeholderText: String {
        if unlockCategory == "Simple Unlock" {
            switch challengeType {
            case "Photo":
                return "Example: Take a selfie at your favorite coffee shop"
            case "Video":
                return "Example: Record a 15-second video doing your happy dance"
            default:
                return "Enter instructions..."
            }
        } else {
            return "Example: You've got this! Push yourself every day and you'll earn your reward!"
        }
    }

    private var exampleText: String {
        if unlockCategory == "Simple Unlock" {
            return "The recipient will receive these instructions via SMS when they get the Honey Badger"
        } else {
            return "The Honey Badger will send daily reminders and encouragement throughout the challenge"
        }
    }

    private func startTickerAnimation(width: CGFloat) {
        let tickerText = sampleChallenges.joined(separator: "  ///  ")
        // Estimate text width (~11 points per character for 18pt bold monospaced)
        let textWidth = CGFloat(tickerText.count) * 11

        // Start from right edge
        tickerOffset = 0

        // Animate continuously — slow scroll for readability
        withAnimation(.linear(duration: 50).repeatForever(autoreverses: false)) {
            tickerOffset = -textWidth
        }
    }
}

// MARK: - Who View

struct WhoView: View {
    @Binding var recipientName: String
    @Binding var recipientEmail: String
    @Binding var recipientPhone: String
    @Binding var smsConsentAcknowledged: Bool
    var currentUserEmail: String = ""
    @State private var showContactPicker = false
    @State private var showSMSDisclosure = false
    @State private var appearAnimation = false

    var isValidInput: Bool {
        let emailValid = !recipientEmail.isEmpty && recipientEmail.contains("@") && recipientEmail.contains(".")
        let phoneValid = !recipientPhone.isEmpty && recipientPhone.count >= 10

        return emailValid || phoneValid
    }

    var isSendingToSelf: Bool {
        !recipientEmail.isEmpty && recipientEmail.lowercased() == currentUserEmail.lowercased()
    }

    var hasValidPhone: Bool {
        recipientPhone.count >= 10
    }

    var body: some View {
        VStack(spacing: 0) {
            // Hero header with envelope image
            ZStack {
                // Accent glow behind envelope
                Circle()
                    .fill(HBTheme.primaryYellow.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(y: -10)

                Image("HB_Future_Envelope")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .scaleEffect(appearAnimation ? 1.0 : 0.8)
                    .opacity(appearAnimation ? 1.0 : 0.0)
            }
            .padding(.top, 8)

            // Title
            VStack(spacing: 4) {
                Text("Who's the lucky one?")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Text("Enter their details or pick a contact")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.top, 12)
            .padding(.bottom, 20)

            // Input cards
            VStack(spacing: 12) {
                // Email field card
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(HBTheme.primaryYellow.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 16))
                            .foregroundColor(HBTheme.primaryYellow)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Email")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(HBTheme.primaryYellow)
                            .textCase(.uppercase)
                        ZStack(alignment: .leading) {
                            if recipientEmail.isEmpty {
                                Text("recipient@email.com")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white.opacity(0.25))
                            }
                            TextField("", text: $recipientEmail)
                                .font(.system(size: 15))
                                .foregroundColor(isSendingToSelf ? .red : .white)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                        }
                    }
                }
                .padding(14)
                .background(HBTheme.cardBg)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSendingToSelf ? Color.red.opacity(0.8) : Color.white.opacity(0.06), lineWidth: 1)
                )

                if isSendingToSelf {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("You can't send a Honey Badger to yourself!")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.red)
                }

                // Phone field card
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(HBTheme.primaryYellow.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16))
                            .foregroundColor(HBTheme.primaryYellow)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Phone")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(HBTheme.primaryYellow)
                            .textCase(.uppercase)
                        ZStack(alignment: .leading) {
                            if recipientPhone.isEmpty {
                                Text("+1 (555) 000-0000")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.white.opacity(0.25))
                            }
                            TextField("", text: $recipientPhone)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .keyboardType(.phonePad)
                        }
                    }
                }
                .padding(14)
                .background(HBTheme.cardBg)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )

                // Quick action: Select from contacts
                Button(action: { showContactPicker = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 18))
                        Text("Select from Contacts")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(HBTheme.buttonGradient)
                    .cornerRadius(14)
                    .shadow(color: HBTheme.primaryYellow.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 4)

                // SMS Disclosure - appears when phone number is valid
                if hasValidPhone {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "message.badge.filled.fill")
                                .font(.system(size: 14))
                                .foregroundColor(HBTheme.primaryYellow)
                            Text("SMS Disclosure")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(HBTheme.primaryYellow)
                            Spacer()
                            Button(action: { showSMSDisclosure = true }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            DisclosureItem(text: "Recipient receives initial opt-in SMS")
                            DisclosureItem(text: "Only after they reply YES will they get reminders")
                            DisclosureItem(text: "Message frequency: 1-3 per day during challenges")
                            DisclosureItem(text: "Msg&Data rates may apply")
                            DisclosureItem(text: "Recipients can reply STOP anytime")
                        }

                        Toggle(isOn: $smsConsentAcknowledged) {
                            Text("I acknowledge the recipient will be asked to consent")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                    }
                    .padding(16)
                    .background(HBTheme.cardBg.opacity(0.8))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(HBTheme.primaryYellow.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPicker(recipientName: $recipientName, recipientEmail: $recipientEmail, recipientPhone: $recipientPhone)
        }
        .sheet(isPresented: $showSMSDisclosure) {
            SMSDisclosureDetailSheet()
        }
    }
}

// MARK: - Gift Details View

struct GiftDetailsView: View {
    @Binding var giftType: String
    @Binding var giftAmount: String
    @Binding var message: String
    @Binding var showGiftCardScreen: Bool
    @Binding var showPhotoUpload: Bool
    @Binding var selectedImageData: Data?
    @Binding var giftCardConfigured: Bool
    let giftTypes: [String]
    let amounts: [String]

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose a gift")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 8)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gift Type")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    VStack(spacing: 10) {
                        ForEach(giftTypes, id: \.self) { type in
                            Button(action: { giftType = type }) {
                                HStack {
                                    Text(type)
                                        .font(.system(size: 15, weight: .medium))
                                    Spacer()
                                    if type == "Photo or Video" && selectedImageData != nil {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else if type == "Gift Card / Money" && giftCardConfigured {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .foregroundColor(giftType == type ? .black : HBTheme.primaryYellow)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 14)
                                .background(giftType == type ? HBTheme.primaryYellow : Color.clear)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(HBTheme.primaryYellow, lineWidth: 2)
                                )
                            }
                        }
                    }
                }

                // Photo/Video Upload Section
                if giftType == "Photo or Video" {
                    Button(action: { showPhotoUpload = true }) {
                        HStack(spacing: 12) {
                            if selectedImageData != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Media uploaded successfully")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Tap to change")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(HBTheme.primaryYellow)
                                Text("Tap to upload photo or video")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(14)
                        .background(HBTheme.cardBg)
                        .cornerRadius(10)
                    }
                }

                // Gift Card Section
                if giftType == "Gift Card / Money" {
                    Button(action: { showGiftCardScreen = true }) {
                        HStack(spacing: 12) {
                            if giftCardConfigured {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("$\(giftAmount) Gift Card")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Tap to change")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 24))
                                    .foregroundColor(HBTheme.primaryYellow)
                                Text("Tap to configure gift card")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(14)
                        .background(HBTheme.cardBg)
                        .cornerRadius(10)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Personal Message")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Add a personal touch...")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .padding(.top, 12)
                                .padding(.leading, 12)
                        }
                        TextEditor(text: $message)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 80)
                            .padding(8)
                    }
                    .background(HBTheme.cardBg)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Gift Card Configuration Screen

struct GiftCardConfigScreen: View {
    @Binding var isPresented: Bool
    @Binding var giftAmount: String
    @Binding var giftCardConfigured: Bool
    let amounts: [String]

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(HBTheme.primaryYellow.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 36))
                                .foregroundColor(HBTheme.primaryYellow)
                        }

                        Text("Gift Card Amount")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Choose how much to gift")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)

                    // Amount Selection
                    VStack(spacing: 16) {
                        ForEach(amounts, id: \.self) { amount in
                            Button(action: { giftAmount = amount }) {
                                HStack {
                                    Text("$\(amount)")
                                        .font(.system(size: 24, weight: .bold))
                                    Spacer()
                                    if giftAmount == amount {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                    }
                                }
                                .foregroundColor(giftAmount == amount ? .black : HBTheme.primaryYellow)
                                .padding(.vertical, 20)
                                .padding(.horizontal, 24)
                                .background(giftAmount == amount ? HBTheme.primaryYellow : Color.clear)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(HBTheme.primaryYellow, lineWidth: 2)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Confirm Button
                    Button(action: {
                        giftCardConfigured = true
                        isPresented = false
                    }) {
                        Text("CONFIRM AMOUNT")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(HBTheme.buttonGradient)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
            }
        }
    }
}

// MARK: - Photo Upload Screen

struct PhotoUploadScreen: View {
    @Binding var isPresented: Bool
    @Binding var selectedImageData: Data?
    @State private var showImagePicker = false

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(HBTheme.primaryYellow.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: "photo.fill")
                                .font(.system(size: 36))
                                .foregroundColor(HBTheme.primaryYellow)
                        }

                        Text("Upload Gift Media")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Add a photo or video as your gift")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)

                    // Preview or Upload Button
                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        VStack(spacing: 16) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 250)
                                .cornerRadius(16)
                                .padding(.horizontal, 20)

                            Button(action: { showImagePicker = true }) {
                                Text("Change Photo")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }
                        }
                    } else {
                        Button(action: { showImagePicker = true }) {
                            VStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        .foregroundColor(HBTheme.primaryYellow.opacity(0.5))
                                        .frame(height: 200)

                                    VStack(spacing: 12) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(HBTheme.primaryYellow)

                                        Text("Tap to select photo or video")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    Spacer()

                    // Done Button
                    if selectedImageData != nil {
                        Button(action: { isPresented = false }) {
                            Text("DONE")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(HBTheme.buttonGradient)
                                .cornerRadius(30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(imageData: $selectedImageData)
            }
        }
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image", "public.movie"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Add Contact Screen

struct AddContactScreen: View {
    @Binding var isPresented: Bool
    @Binding var contacts: [Contact]
    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var showContactPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    // Header
                    VStack(spacing: 12) {
                        // Minimalist Icon
                        ZStack {
                            Circle()
                                .fill(HBTheme.primaryYellow.opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 36))
                                .foregroundColor(HBTheme.primaryYellow)
                        }

                        Text("Add to Network")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("Grow your gifting network")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }

                    // Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            ZStack(alignment: .leading) {
                                if name.isEmpty {
                                    Text("Full Name")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .padding(.leading, 14)
                                }
                                TextField("", text: $name)
                                    .font(.system(size: 16))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 14)
                                    .foregroundColor(.white)
                                    .textInputAutocapitalization(.words)
                            }
                            .background(HBTheme.cardBg)
                            .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone Number")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            ZStack(alignment: .leading) {
                                if phone.isEmpty {
                                    Text("Phone")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .padding(.leading, 14)
                                }
                                TextField("", text: $phone)
                                    .font(.system(size: 16))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 14)
                                    .foregroundColor(.white)
                                    .keyboardType(.phonePad)
                            }
                            .background(HBTheme.cardBg)
                            .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email (Optional)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            ZStack(alignment: .leading) {
                                if email.isEmpty {
                                    Text("Email")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .padding(.leading, 14)
                                }
                                TextField("", text: $email)
                                    .font(.system(size: 16))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 14)
                                    .foregroundColor(.white)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                            }
                            .background(HBTheme.cardBg)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 10)

                    Button(action: addContact) {
                        Text("ADD CONTACT")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(HBTheme.buttonGradient)
                            .cornerRadius(30)
                            .shadow(color: HBTheme.primaryYellow.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                    .opacity((name.isEmpty || phone.isEmpty) ? 0.5 : 1.0)
                    .padding(.horizontal, 32)

                    Text("OR")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)

                    Button(action: { showContactPicker = true }) {
                        Text("Select from Contacts")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(HBTheme.primaryYellow)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.clear)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(HBTheme.primaryYellow, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
            }
            .sheet(isPresented: $showContactPicker) {
                ContactPicker(recipientName: $name, recipientEmail: $email, recipientPhone: $phone)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("✕") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func addContact() {
        let newContact = Contact(
            name: name,
            phone: phone,
            email: email
        )
        contacts.append(newContact)
        isPresented = false
    }
}

// MARK: - Preview

#Preview {
    HoneyBadgerMainView()
}
