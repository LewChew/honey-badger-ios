//
//  MascotImageView.swift
//  HoneyBadgerApp
//
//  Reusable SwiftUI component for displaying AI-generated mascot images
//  with automatic fallback to bundled assets
//

import SwiftUI

struct MascotImageView: View {
    let occasion: String?
    let size: CGFloat
    let useFeatured: Bool
    let showLoadingIndicator: Bool
    let fullScreen: Bool

    @State private var mascotImage: MascotImage?
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var fallbackImageName: String

    private let service = MascotImageService.shared

    init(
        occasion: String? = nil,
        size: CGFloat = 200,
        useFeatured: Bool = false,
        showLoadingIndicator: Bool = false,
        fullScreen: Bool = false
    ) {
        self.occasion = occasion
        self.size = size
        self.useFeatured = useFeatured
        self.showLoadingIndicator = showLoadingIndicator
        self.fullScreen = fullScreen
        self._fallbackImageName = State(initialValue: MascotImageService.shared.getFallbackImageName())
    }

    var body: some View {
        Group {
            if loadFailed || mascotImage == nil {
                // Fallback to bundled asset
                if fullScreen {
                    fullScreenBundledImage
                } else {
                    bundledImage
                }
            } else if let mascot = mascotImage, let url = mascot.imageURL {
                // Load from CDN
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        if showLoadingIndicator {
                            loadingView
                        } else if fullScreen {
                            fullScreenBundledImage
                        } else {
                            bundledImage
                        }
                    case .success(let image):
                        if fullScreen {
                            fullScreenRendered(image: image)
                        } else {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: size)
                        }
                    case .failure:
                        if fullScreen {
                            fullScreenBundledImage
                        } else {
                            bundledImage
                        }
                    @unknown default:
                        bundledImage
                    }
                }
            } else {
                if fullScreen {
                    fullScreenBundledImage
                } else {
                    bundledImage
                }
            }
        }
        .task {
            await loadMascotImage()
        }
    }

    private var bundledImage: some View {
        Image(fallbackImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size)
    }

    private var fullScreenBundledImage: some View {
        GeometryReader { geo in
            Image(fallbackImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }

    private func fullScreenRendered(image: Image) -> some View {
        GeometryReader { geo in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
    }

    private var loadingView: some View {
        ZStack {
            bundledImage
                .opacity(0.5)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
        }
    }

    private func loadMascotImage() async {
        do {
            if useFeatured {
                mascotImage = try await service.getFeaturedImage()
            } else if let occasion = occasion {
                mascotImage = try await service.getImageForOccasion(occasion)
            } else {
                mascotImage = try await service.getRandomImage()
            }
            loadFailed = false
        } catch {
            print("Failed to load mascot image: \(error.localizedDescription)")
            loadFailed = true
        }
        isLoading = false
    }
}

// MARK: - Convenience Initializers

extension MascotImageView {
    /// Create a featured mascot view for splash screens (full screen)
    static func featured(size: CGFloat = 250) -> MascotImageView {
        MascotImageView(size: size, useFeatured: true)
    }

    /// Create a full-screen featured mascot for splash/transition
    static func featuredFullScreen() -> MascotImageView {
        MascotImageView(useFeatured: true, fullScreen: true)
    }

    /// Create a full-screen random mascot for transitions
    static func randomFullScreen() -> MascotImageView {
        MascotImageView(fullScreen: true)
    }

    /// Create an occasion-specific mascot view
    static func forOccasion(_ occasion: String, size: CGFloat = 180) -> MascotImageView {
        MascotImageView(occasion: occasion, size: size)
    }

    /// Create a random mascot view
    static func random(size: CGFloat = 180) -> MascotImageView {
        MascotImageView(size: size)
    }
}

// MARK: - Dynamic Mascot URL Provider

/// Provides dynamic mascot URLs for email templates
struct DynamicMascotURL {
    private static let baseURL = "https://mascot.honeybadger.app"

    /// Get the URL for a mascot image by occasion
    /// Falls back to static URL if service is unavailable
    static func forOccasion(_ occasion: String) -> String {
        let mappedOccasion = MascotOccasion(from: occasion)
        return "\(baseURL)/api/mascot/by-occasion/\(mappedOccasion.rawValue)/redirect"
    }

    /// Get the featured mascot URL
    static var featured: String {
        return "\(baseURL)/api/mascot/featured/redirect"
    }

    /// Get a random mascot URL
    static var random: String {
        return "\(baseURL)/api/mascot/random/redirect"
    }

    /// Static fallback URL (for when service might be down)
    static var fallback: String {
        return "https://api.badgerbot.net/images/honey-badger-mascot.png"
    }
}

// MARK: - Preview

#if DEBUG
struct MascotImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MascotImageView.featured(size: 200)
            MascotImageView.forOccasion("Birthday", size: 150)
            MascotImageView.random(size: 100)
        }
        .padding()
        .background(Color.black)
    }
}
#endif
