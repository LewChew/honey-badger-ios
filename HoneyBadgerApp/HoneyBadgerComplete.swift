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

    func signup(name: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil

        // Simulate signup delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isAuthenticated = true
            self.currentUser = User(id: Int.random(in: 1...10000), name: name, email: email)
            self.isLoading = false
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        // Simulate login delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isAuthenticated = true
            self.currentUser = User(id: 1, name: "Demo User", email: email)
            self.isLoading = false
        }
    }

    func logout() {
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
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

                    Text("Welcome Back!")
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

        // Close after a brief delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if auth.isAuthenticated {
                isPresented = false
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
                        Step1View(name: $name)
                    } else if currentStep == 2 {
                        Step2View(email: $email)
                    } else {
                        Step3View(password: $password, confirmPassword: $confirmPassword)
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
        case 1: return !name.isEmpty
        case 2: return !email.isEmpty && email.contains("@")
        case 3: return !password.isEmpty && password.count >= 6 && password == confirmPassword
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

        // Close after a brief delay to show loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if auth.isAuthenticated {
                isPresented = false
            }
        }
    }
}

// MARK: - Signup Step Views

struct Step1View: View {
    @Binding var name: String

    var body: some View {
        VStack(spacing: 16) {
            Text("What's your name?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Let's start with the basics")
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

struct Step2View: View {
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

struct Step3View: View {
    @Binding var password: String
    @Binding var confirmPassword: String

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
        }
    }
}

// MARK: - Dashboard Screen

struct DashboardScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @State private var showSendBadger = false
    @State private var showAddContact = false
    @State private var showAbout = false
    @State private var contacts: [Contact] = []

    var body: some View {
        NavigationView {
            ZStack {
                HBTheme.darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Dashboard Header
                        HStack {
                            Text("Dashboard")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Spacer()

                            Button(action: { auth.logout() }) {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 22))
                                    .foregroundColor(HBTheme.primaryYellow)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

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

                        // Network Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "person.2.fill")
                                        .foregroundColor(HBTheme.primaryYellow)
                                    Text("People to Gift")
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
                                VStack(spacing: 12) {
                                    Image("HB_Gift")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 180)
                                        .padding(.horizontal, 10)

                                    Text("Add contacts to start sending Honey Badgers!")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 10)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
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

                        // Badgers Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Badgers In the Wild")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                Image("CyberBadger")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .padding(.horizontal, 10)

                                Text("No badgers sent or received yet")
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
            }
            .sheet(isPresented: $showAddContact) {
                AddContactScreen(isPresented: $showAddContact, contacts: $contacts)
            }
            .sheet(isPresented: $showAbout) {
                AboutScreen(isPresented: $showAbout)
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

// MARK: - Send Badger Screen

struct SendBadgerScreen: View {
    @EnvironmentObject var auth: SimpleAuthManager
    @Binding var isPresented: Bool
    @State private var showSplash = true
    @State private var showMainContent = false
    @State private var currentStep = 1
    @State private var recipientName = ""
    @State private var recipientEmail = ""
    @State private var recipientPhone = ""
    @State private var challengeType = "Photo Challenge"
    @State private var challengePrompt = ""
    @State private var occasion = "Birthday"
    @State private var giftType = "Photo or Video"
    @State private var giftAmount = "25"
    @State private var message = ""

    let challengeTypes = ["Photo Challenge", "Video Challenge", "Custom Challenge"]
    let occasions = ["Birthday", "Congratulations", "Thank You", "Just Because", "Holiday", "Get Well"]
    let giftTypes = ["Photo or Video", "Promise", "Gift Card / Money"]
    let amounts = ["10", "25", "50", "100"]

    var body: some View {
        ZStack {
            if showSplash {
                // Combined Splash Screen
                ZStack {
                    HBTheme.darkBg.ignoresSafeArea()
                    VStack(spacing: 40) {
                        Image("HoneyBadger_toon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 250)
                            .padding(.horizontal, 40)

                        Image("HB_Gift")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .padding(.horizontal, 40)
                    }
                }
                .onAppear {
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
                                    recipientPhone: $recipientPhone
                                )
                            } else if currentStep == 2 {
                                ChallengeSelectionView(
                                    challengeType: $challengeType,
                                    challengeTypes: challengeTypes
                                )
                            } else if currentStep == 3 {
                                ChallengeConfigView(
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
                            Text(currentStep == 4 ? "SEND BADGER" : "NEXT")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(canProceed ? HBTheme.buttonGradient : LinearGradient(colors: [Color.gray], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .cornerRadius(30)
                                .shadow(color: canProceed ? HBTheme.primaryYellow.opacity(0.4) : Color.clear, radius: 12, x: 0, y: 6)
                        }
                        .disabled(!canProceed)
                        .opacity(canProceed ? 1.0 : 0.5)
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
                }
            }
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 1:
            let nameValid = recipientName.count >= 3
            let emailValid = !recipientEmail.isEmpty && recipientEmail.contains("@") && recipientEmail.contains(".")
            let phoneValid = !recipientPhone.isEmpty && recipientPhone.count >= 10
            return nameValid && (emailValid || phoneValid)
        case 2: return !challengeType.isEmpty
        case 3: return !challengePrompt.isEmpty
        case 4: return true
        default: return false
        }
    }

    private func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }

    private func nextStepOrSend() {
        if currentStep < 4 {
            currentStep += 1
        } else {
            sendBadger()
        }
    }

    private func sendBadger() {
        // TODO: Implement actual send logic
        isPresented = false
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
    @Binding var challengeType: String
    let challengeTypes: [String]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text("Choose the Unlock")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                Text("How will they earn their gift?")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }

            VStack(spacing: 16) {
                ForEach(challengeTypes, id: \.self) { challenge in
                    Button(action: { challengeType = challenge }) {
                        HStack {
                            // Icon based on challenge type
                            Image(systemName: iconForChallenge(challenge))
                                .font(.system(size: 24))
                                .foregroundColor(challengeType == challenge ? .black : HBTheme.primaryYellow)
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(challenge)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(challengeType == challenge ? .black : .white)

                                Text(descriptionForChallenge(challenge))
                                    .font(.system(size: 13))
                                    .foregroundColor(challengeType == challenge ? .black.opacity(0.7) : .gray)
                            }

                            Spacer()

                            if challengeType == challenge {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity)
                        .background(challengeType == challenge ? HBTheme.primaryYellow : HBTheme.cardBg)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(challengeType == challenge ? HBTheme.primaryYellow : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }

    private func iconForChallenge(_ challenge: String) -> String {
        switch challenge {
        case "Photo Challenge": return "camera.fill"
        case "Video Challenge": return "video.fill"
        case "Custom Challenge": return "star.fill"
        default: return "lock.fill"
        }
    }

    private func descriptionForChallenge(_ challenge: String) -> String {
        switch challenge {
        case "Photo Challenge": return "Send a photo to unlock"
        case "Video Challenge": return "Record a video message"
        case "Custom Challenge": return "Create your own challenge"
        default: return ""
        }
    }
}

// MARK: - Challenge Config View

struct ChallengeConfigView: View {
    let challengeType: String
    @Binding var challengePrompt: String
    @Binding var occasion: String
    let occasions: [String]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text("Setup the Challenge")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                Text(instructionText)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            VStack(spacing: 20) {
                // Occasion Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's the occasion?")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(occasions, id: \.self) { item in
                            Button(action: { occasion = item }) {
                                Text(item)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(occasion == item ? .black : HBTheme.primaryYellow)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(occasion == item ? HBTheme.primaryYellow : Color.clear)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(HBTheme.primaryYellow, lineWidth: 1)
                                    )
                            }
                        }
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
        switch challengeType {
        case "Photo Challenge":
            return "What photo should they send to unlock their gift?"
        case "Video Challenge":
            return "What video should they record to unlock their gift?"
        case "Custom Challenge":
            return "Describe what they need to do to unlock their gift"
        default:
            return "Describe the challenge"
        }
    }

    private var promptLabel: String {
        switch challengeType {
        case "Photo Challenge":
            return "Photo Instructions"
        case "Video Challenge":
            return "Video Instructions"
        case "Custom Challenge":
            return "Challenge Instructions"
        default:
            return "Instructions"
        }
    }

    private var placeholderText: String {
        switch challengeType {
        case "Photo Challenge":
            return "Example: Take a selfie at your favorite coffee shop"
        case "Video Challenge":
            return "Example: Record a 15-second video doing your happy dance"
        case "Custom Challenge":
            return "Example: Send me your best dad joke"
        default:
            return "Enter instructions..."
        }
    }

    private var exampleText: String {
        "The recipient will receive these instructions via SMS when they get the Honey Badger"
    }
}

// MARK: - Who View

struct WhoView: View {
    @Binding var recipientName: String
    @Binding var recipientEmail: String
    @Binding var recipientPhone: String
    @State private var showContactPicker = false

    var isValidInput: Bool {
        let nameValid = recipientName.count >= 3
        let emailValid = !recipientEmail.isEmpty && recipientEmail.contains("@") && recipientEmail.contains(".")
        let phoneValid = !recipientPhone.isEmpty && recipientPhone.count >= 10

        return nameValid && (emailValid || phoneValid)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Future Envelope Image
            Image("HB_Future_Envelope")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 180)
                .padding(.horizontal, 30)
                .padding(.top, 10)

            VStack(spacing: 6) {
                Text("Always Be Gifting")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Text("Share the love with Honey Badgers")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Send To")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    ZStack(alignment: .leading) {
                        if recipientName.isEmpty {
                            Text("Name")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.leading, 14)
                        }
                        TextField("", text: $recipientName)
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
                    Text("Email")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    ZStack(alignment: .leading) {
                        if recipientEmail.isEmpty {
                            Text("Email")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.leading, 14)
                        }
                        TextField("", text: $recipientEmail)
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

                VStack(alignment: .leading, spacing: 6) {
                    Text("Phone #")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    ZStack(alignment: .leading) {
                        if recipientPhone.isEmpty {
                            Text("Phone #")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.leading, 14)
                        }
                        TextField("", text: $recipientPhone)
                            .font(.system(size: 16))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .foregroundColor(.white)
                            .keyboardType(.phonePad)
                    }
                    .background(HBTheme.cardBg)
                    .cornerRadius(10)
                }

                // Add Contact Button
                Button(action: { showContactPicker = true }) {
                    Text("Select from Contacts")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(HBTheme.primaryYellow)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPicker(recipientName: $recipientName, recipientEmail: $recipientEmail, recipientPhone: $recipientPhone)
        }
    }
}

// MARK: - Gift Details View

struct GiftDetailsView: View {
    @Binding var giftType: String
    @Binding var giftAmount: String
    @Binding var message: String
    let giftTypes: [String]
    let amounts: [String]

    var body: some View {
        VStack(spacing: 24) {
            Text("Choose a gift")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Pick the perfect reward")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gift Type")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    VStack(spacing: 12) {
                        ForEach(giftTypes, id: \.self) { type in
                            Button(action: { giftType = type }) {
                                Text(type)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(giftType == type ? .black : HBTheme.primaryYellow)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(giftType == type ? HBTheme.primaryYellow : Color.clear)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(HBTheme.primaryYellow, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }

                if giftType == "Gift Card / Money" {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount ($)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            ForEach(amounts, id: \.self) { amount in
                                Button(action: { giftAmount = amount }) {
                                    Text("$\(amount)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(giftAmount == amount ? .black : HBTheme.primaryYellow)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(giftAmount == amount ? HBTheme.primaryYellow : Color.clear)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(HBTheme.primaryYellow, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Personal Message")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    ZStack(alignment: .topLeading) {
                        if message.isEmpty {
                            Text("Add a personal touch...")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.top, 14)
                                .padding(.leading, 14)
                        }
                        TextEditor(text: $message)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 100)
                            .padding(10)
                    }
                    .background(HBTheme.cardBg)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
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
                    VStack(spacing: 8) {
                        Image("HB_Gift")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .padding(.horizontal, 30)

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

// MARK: - Custom Styles

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

// MARK: - Preview

#Preview {
    HoneyBadgerMainView()
}
