//
//  MascotImageService.swift
//  HoneyBadgerApp
//
//  Service for fetching AI-generated mascot images from the mascot microservice
//

import Foundation

// MARK: - Mascot Image Model

struct MascotImage: Codable, Identifiable {
    let id: String
    let file_key: String
    let cdn_url: String
    let thumbnail_url: String?
    let theme: String?
    let style_variant: String?
    let is_featured: Bool
    let usage_count: Int

    var imageURL: URL? {
        URL(string: cdn_url)
    }

    var thumbnailURL: URL? {
        guard let thumbnail = thumbnail_url else { return nil }
        return URL(string: thumbnail)
    }
}

struct MascotAPIResponse: Codable {
    let success: Bool
    let data: MascotImage?
    let fallback: Bool?
    let error: String?
}

struct MascotLibraryResponse: Codable {
    let success: Bool
    let data: [MascotImage]
    let pagination: Pagination?

    struct Pagination: Codable {
        let limit: Int
        let offset: Int
        let count: Int
    }
}

struct MascotTheme: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
}

struct MascotThemesResponse: Codable {
    let success: Bool
    let data: [MascotTheme]
}

// MARK: - Mascot Occasion Mapping

enum MascotOccasion: String, CaseIterable {
    case birthday = "birthday"
    case congratulations = "congratulations"
    case thankYou = "thank_you"
    case justBecause = "just_because"
    case holiday = "holiday"
    case getWell = "get_well"
    case `default` = "default"

    init(from occasion: String) {
        switch occasion.lowercased() {
        case "birthday":
            self = .birthday
        case "congratulations":
            self = .congratulations
        case "thank you", "thank_you", "thanks":
            self = .thankYou
        case "just because", "just_because":
            self = .justBecause
        case "holiday", "christmas":
            self = .holiday
        case "get well", "get_well":
            self = .getWell
        default:
            self = .default
        }
    }
}

// MARK: - Mascot Image Service

class MascotImageService {
    static let shared = MascotImageService()

    private let baseURL: String
    private let session: URLSession
    private var imageCache: [String: MascotImage] = [:]
    private let cacheQueue = DispatchQueue(label: "com.honeybadger.mascot.cache")

    // Bundled fallback images
    private let fallbackImages = ["HoneyBadger_toon", "CyberBadger", "honey-badger-ninja"]

    private init() {
        self.baseURL = "https://mascot.honeybadger.app"

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API

    /// Get the featured mascot image
    func getFeaturedImage() async throws -> MascotImage {
        if let cached = getCachedImage(for: "featured") {
            return cached
        }

        let image = try await fetchImage(from: "/api/mascot/featured")
        cacheImage(image, for: "featured")
        return image
    }

    /// Get a random mascot image
    func getRandomImage(theme: String? = nil) async throws -> MascotImage {
        var endpoint = "/api/mascot/random"
        if let theme = theme {
            endpoint += "?theme=\(theme)"
        }
        return try await fetchImage(from: endpoint)
    }

    /// Get a mascot image for a specific occasion
    func getImageForOccasion(_ occasion: String) async throws -> MascotImage {
        let mappedOccasion = MascotOccasion(from: occasion)
        let cacheKey = "occasion:\(mappedOccasion.rawValue)"

        if let cached = getCachedImage(for: cacheKey) {
            return cached
        }

        let image = try await fetchImage(from: "/api/mascot/by-occasion/\(mappedOccasion.rawValue)")
        cacheImage(image, for: cacheKey)
        return image
    }

    /// Get mascot library with pagination
    func getLibrary(theme: String? = nil, limit: Int = 20, offset: Int = 0) async throws -> [MascotImage] {
        var endpoint = "/api/mascot/library?limit=\(limit)&offset=\(offset)"
        if let theme = theme {
            endpoint += "&theme=\(theme)"
        }

        guard let url = URL(string: baseURL + endpoint) else {
            throw MascotServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MascotServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MascotServiceError.httpError(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(MascotLibraryResponse.self, from: data)

        guard decoded.success else {
            throw MascotServiceError.apiError("Failed to fetch library")
        }

        return decoded.data
    }

    /// Get available themes
    func getAvailableThemes() async throws -> [MascotTheme] {
        guard let url = URL(string: baseURL + "/api/mascot/themes") else {
            throw MascotServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MascotServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(MascotThemesResponse.self, from: data)
        return decoded.data
    }

    /// Get a random fallback image name (for bundled assets)
    func getFallbackImageName() -> String {
        return fallbackImages.randomElement() ?? "HoneyBadger_toon"
    }

    /// Get fallback image name for a specific occasion
    func getFallbackImageName(for occasion: String) -> String {
        // For now, return random - could be expanded later
        return getFallbackImageName()
    }

    // MARK: - Cache Management

    func clearCache() {
        cacheQueue.sync {
            imageCache.removeAll()
        }
    }

    func preloadFeaturedImage() {
        Task {
            do {
                _ = try await getFeaturedImage()
            } catch {
                print("Failed to preload featured image: \(error)")
            }
        }
    }

    // MARK: - Private Helpers

    private func fetchImage(from endpoint: String) async throws -> MascotImage {
        guard let url = URL(string: baseURL + endpoint) else {
            throw MascotServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MascotServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw MascotServiceError.httpError(httpResponse.statusCode)
        }

        let decoded = try JSONDecoder().decode(MascotAPIResponse.self, from: data)

        guard decoded.success, let image = decoded.data else {
            throw MascotServiceError.apiError(decoded.error ?? "Unknown error")
        }

        return image
    }

    private func getCachedImage(for key: String) -> MascotImage? {
        cacheQueue.sync {
            imageCache[key]
        }
    }

    private func cacheImage(_ image: MascotImage, for key: String) {
        cacheQueue.sync {
            imageCache[key] = image
        }
    }
}

// MARK: - Errors

enum MascotServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case noImageData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return message
        case .noImageData:
            return "No image data received"
        }
    }
}
