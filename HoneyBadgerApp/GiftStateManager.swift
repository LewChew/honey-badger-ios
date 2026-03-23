//
//  GiftStateManager.swift
//  HoneyBadgerApp
//
//  Shared singleton for managing gift state across the app
//  Ensures Dashboard and BadgersInTheWildScreen stay in sync
//

import Foundation
import Combine

@MainActor
class GiftStateManager: ObservableObject {
    static let shared = GiftStateManager()

    @Published var sentGifts: [Gift] = []
    @Published var receivedGifts: [Gift] = []
    @Published var pendingApprovals: [PendingApproval] = []
    @Published var isLoadingSent: Bool = false
    @Published var isLoadingReceived: Bool = false
    @Published var isLoadingApprovals: Bool = false
    @Published var lastRefresh: Date?

    private let networkManager = NetworkManager()
    private var refreshTask: Task<Void, Never>?

    private init() {
        // Load initial data if user is authenticated
        if networkManager.authToken != nil {
            Task {
                await refreshAll()
            }
        }
    }

    // MARK: - Refresh Methods

    func refreshAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.refreshSentGifts() }
            group.addTask { await self.refreshReceivedGifts() }
            group.addTask { await self.refreshPendingApprovals() }
        }
        lastRefresh = Date()
    }

    func refreshSentGifts() async {
        isLoadingSent = true
        do {
            let gifts = try await networkManager.getGifts()
            sentGifts = gifts
            print("✅ GiftStateManager: Loaded \(gifts.count) sent gifts")
        } catch {
            print("❌ GiftStateManager: Error loading sent gifts: \(error)")
        }
        isLoadingSent = false
    }

    func refreshReceivedGifts() async {
        isLoadingReceived = true
        do {
            let gifts = try await networkManager.getReceivedGifts()
            receivedGifts = gifts
            print("✅ GiftStateManager: Loaded \(gifts.count) received gifts")
        } catch {
            print("❌ GiftStateManager: Error loading received gifts: \(error)")
        }
        isLoadingReceived = false
    }

    func refreshPendingApprovals() async {
        isLoadingApprovals = true
        do {
            let approvals = try await networkManager.getPendingApprovals()
            pendingApprovals = approvals
            print("✅ GiftStateManager: Loaded \(approvals.count) pending approvals")
        } catch {
            print("❌ GiftStateManager: Error loading pending approvals: \(error)")
        }
        isLoadingApprovals = false
    }

    // MARK: - Approval Actions

    func approveSubmission(submissionId: String) async -> Bool {
        do {
            try await networkManager.approveSubmission(submissionId: submissionId)
            // Remove from pending approvals
            pendingApprovals.removeAll { $0.submissionId == submissionId }
            // Refresh sent gifts to update status
            await refreshSentGifts()
            return true
        } catch {
            print("❌ GiftStateManager: Error approving submission: \(error)")
            return false
        }
    }

    func rejectSubmission(submissionId: String, reason: String?) async -> Bool {
        do {
            try await networkManager.rejectSubmission(submissionId: submissionId, reason: reason)
            // Remove from pending approvals
            pendingApprovals.removeAll { $0.submissionId == submissionId }
            // Refresh sent gifts to update status
            await refreshSentGifts()
            return true
        } catch {
            print("❌ GiftStateManager: Error rejecting submission: \(error)")
            return false
        }
    }

    // MARK: - Gift Actions (Sender)

    func unlockGift(giftId: String) async -> Bool {
        do {
            try await networkManager.unlockGift(giftId: giftId)
            // Refresh sent gifts to update status
            await refreshSentGifts()
            return true
        } catch {
            print("❌ GiftStateManager: Error unlocking gift: \(error)")
            return false
        }
    }

    func recipientUnlockGift(giftId: String) async -> Bool {
        do {
            try await networkManager.recipientUnlockGift(giftId: giftId)
            await refreshReceivedGifts()
            return true
        } catch {
            print("❌ GiftStateManager: Error recipient-unlocking gift: \(error)")
            return false
        }
    }

    func collectGift(giftId: String) async -> Bool {
        do {
            try await networkManager.collectGift(giftId: giftId)
            await refreshReceivedGifts()
            await refreshSentGifts()
            return true
        } catch {
            print("❌ GiftStateManager: Error collecting gift: \(error)")
            return false
        }
    }

    func sendNudge(giftId: String, customMessage: String? = nil) async -> Bool {
        do {
            try await networkManager.sendNudge(giftId: giftId, customMessage: customMessage)
            return true
        } catch {
            print("❌ GiftStateManager: Error sending nudge: \(error)")
            return false
        }
    }

    // MARK: - Challenge Submission

    func submitChallengePhoto(giftId: String, imageData: Data) async -> Bool {
        do {
            let response = try await networkManager.submitChallengePhoto(trackingId: giftId, imageData: imageData)
            if response.success {
                await refreshReceivedGifts()
                return true
            }
            return false
        } catch {
            print("❌ GiftStateManager: Error submitting challenge photo: \(error)")
            return false
        }
    }

    // MARK: - Computed Properties

    var pendingApprovalsCount: Int {
        pendingApprovals.count
    }

    var hasPendingApprovals: Bool {
        !pendingApprovals.isEmpty
    }

    var isLoading: Bool {
        isLoadingSent || isLoadingReceived || isLoadingApprovals
    }

    var activeSentGifts: [Gift] {
        sentGifts.filter { !$0.isRedeemed }
    }

    var activeReceivedGifts: [Gift] {
        receivedGifts.filter { !$0.isRedeemed }
    }

    var completedGifts: [Gift] {
        let redeemed = sentGifts.filter { $0.isRedeemed } + receivedGifts.filter { $0.isRedeemed }
        return redeemed.sorted { ($0.redeemedAt ?? "") > ($1.redeemedAt ?? "") }
    }

    var mostRecentCompletedGift: Gift? {
        completedGifts.first
    }

    // MARK: - Clear State (for logout)

    func clearState() {
        sentGifts = []
        receivedGifts = []
        pendingApprovals = []
        lastRefresh = nil
    }
}

// Note: PendingApproval and PendingApprovalsResponse types are defined in NetworkManager.swift
