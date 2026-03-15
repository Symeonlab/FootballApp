//
//  BlogViewModel.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import Foundation
import Combine
import os.log

class BlogViewModel: ObservableObject {
    @Published var posts: [BlogPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "BlogViewModel")

    // Preview detection
    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    init() {
        logger.info("📚 BlogViewModel initialized (Preview: \(self.isPreview))")

        if isPreview {
            loadMockData()
        }
    }

    // MARK: - Fetch Blog Posts from API
    func fetchBlogPosts() {
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchBlogPosts() - running in preview mode")
            return
        }

        logger.info("📥 BlogViewModel: Fetching blog posts from API...")
        isLoading = true
        errorMessage = nil

        // Fetch from the correct API endpoint
        APIService.shared.request(
            endpoint: "/api/posts",
            method: "GET",
            body: nil as Data?,
            requiresAuth: false // Blog posts are public
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self else { return }
            self.isLoading = false

            if case .failure(let error) = completion {
                self.logger.error("❌ BlogViewModel: Failed to fetch posts - \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                // Don't fallback to mock data in production - show empty state or error
            } else {
                self.logger.info("✅ BlogViewModel: Successfully fetched \(self.posts.count) posts")
            }
        } receiveValue: { [weak self] (response: PostsResponse) in
            guard let self else { return }
            // Convert Post to BlogPost
            self.posts = response.data.map { post in
                BlogPost(
                    id: post.id,
                    title: post.title,
                    slug: post.slug,
                    excerpt: post.excerpt,
                    content: post.content ?? "",
                    category: "general",
                    author: post.author,
                    image_url: post.featuredImage,
                    published_at: post.publishedAt,
                    tags: nil,
                    reading_time: post.readingTime
                )
            }
            self.logger.info("📚 BlogViewModel: Loaded \(self.posts.count) blog posts from API")
        }
        .store(in: &cancellables)
    }

    // MARK: - Async Fetch
    @MainActor
    func fetchBlogPostsAsync() async {
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchBlogPostsAsync() - running in preview mode")
            loadMockData()
            return
        }

        logger.info("📥 BlogViewModel: Fetching blog posts (async)...")
        isLoading = true
        errorMessage = nil

        do {
            let (apiPosts, _) = try await APIService.shared.getPosts()
            // Convert Post to BlogPost
            self.posts = apiPosts.map { post in
                BlogPost(
                    id: post.id,
                    title: post.title,
                    slug: post.slug,
                    excerpt: post.excerpt,
                    content: post.content ?? "",
                    category: "general",
                    author: post.author,
                    image_url: post.featuredImage,
                    published_at: post.publishedAt,
                    tags: nil,
                    reading_time: post.readingTime
                )
            }
            self.isLoading = false
            logger.info("✅ BlogViewModel: Successfully fetched \(self.posts.count) posts (async)")
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            logger.error("❌ BlogViewModel: Failed to fetch posts - \(error.localizedDescription)")
            // Don't fallback to mock data in production - show empty state or error
        }
    }

    // MARK: - Mock Data for Preview/Fallback
    private func loadMockData() {
        posts = [
            BlogPost(
                id: 1,
                title: "5 Essential Warm-Up Exercises for Football Players",
                slug: "warm-up-exercises-football",
                excerpt: "Discover the most effective warm-up routines to prevent injuries and boost performance on the field.",
                content: """
                Warming up is crucial for every football player. A proper warm-up routine not only helps prevent injuries but also prepares your body and mind for peak performance.

                Essential exercises include:
                1. Dynamic Stretching - leg swings, arm circles, walking lunges
                2. Light Jogging - 5-10 minutes to increase heart rate
                3. High Knees and Butt Kicks - activate leg muscles
                4. Lateral Movements - side shuffles and carioca runs
                5. Ball Work - light touches, passing drills, juggling
                """,
                category: "training",
                author: "Coach Mike Johnson",
                image_url: nil,
                published_at: "2025-11-10",
                tags: ["warm-up", "training", "injury prevention"],
                reading_time: 3
            ),
            BlogPost(
                id: 2,
                title: "Nutrition Guide: What to Eat Before a Match",
                slug: "pre-match-nutrition-guide",
                excerpt: "Learn what foods to eat and when to eat them for optimal performance on game day.",
                content: """
                Proper nutrition is just as important as training for football performance.

                Timing Guide:
                - 3-4 Hours Before: Complex carbs, lean protein, vegetables
                - 1-2 Hours Before: Light snack (banana, energy bar)
                - 30 Minutes Before: Sports drink or dried fruit

                Foods to Avoid: High-fat, high-fiber, unfamiliar foods
                """,
                category: "nutrition",
                author: "Dr. Sarah Williams",
                image_url: nil,
                published_at: "2025-11-08",
                tags: ["nutrition", "pre-match", "performance"],
                reading_time: 2
            ),
            BlogPost(
                id: 3,
                title: "Recovery Techniques: Ice Baths vs. Compression",
                slug: "recovery-techniques-comparison",
                excerpt: "Compare different recovery methods and find out which one is best for you.",
                content: """
                Recovery is critical for athletic performance.

                Ice Baths: Reduces inflammation, removes metabolic waste, improves recovery time.

                Compression Therapy: Improves circulation, reduces swelling, portable.

                Active Recovery: 20-30 minute walk, swim, or gentle yoga.

                Quality sleep and proper nutrition are the foundation of all recovery!
                """,
                category: "recovery",
                author: "Alex Thompson, PT",
                image_url: nil,
                published_at: "2025-11-05",
                tags: ["recovery", "ice bath", "compression"],
                reading_time: 2
            ),
            BlogPost(
                id: 4,
                title: "Building Mental Toughness for High-Pressure Games",
                slug: "mental-toughness-guide",
                excerpt: "Develop the mental skills you need to perform under pressure.",
                content: """
                The mental game separates good players from great ones.

                Key Techniques:
                - Visualization: 10-15 minutes daily
                - Pre-Game Routines: Music, warm-up, meditation
                - Pressure Management: Breathing exercises, focus on controllables
                - Positive Self-Talk: Replace negative thoughts
                - Learning from Mistakes: Acknowledge, release, refocus
                """,
                category: "mindset",
                author: "Dr. James Martinez",
                image_url: nil,
                published_at: "2025-11-12",
                tags: ["mental game", "psychology", "performance"],
                reading_time: 3
            ),
            BlogPost(
                id: 5,
                title: "Strength Training for Football: A Complete Guide",
                slug: "strength-training-football-guide",
                excerpt: "Build explosive power and prevent injuries with football-specific exercises.",
                content: """
                Strength training is essential for modern football players.

                Key Principles:
                1. Functional Movements - squats, lunges, deadlifts
                2. Core Stability - planks, Russian twists
                3. Unilateral Training - single-leg exercises

                Weekly Split: Lower Body (Mon), Upper Body (Wed), Full Body (Fri)
                """,
                category: "training",
                author: "Marcus Williams, CSCS",
                image_url: nil,
                published_at: "2025-11-01",
                tags: ["strength training", "power", "exercises"],
                reading_time: 2
            )
        ]
    }
}

// MARK: - Blog Post Model
struct BlogPost: Identifiable, Codable {
    let id: Int
    let title: String
    let slug: String
    let excerpt: String?
    let content: String
    let category: String
    let author: String?
    let image_url: String?
    let published_at: String?
    let tags: [String]?
    let reading_time: Int?

    // Computed property for reading time - uses API value if available, otherwise calculates
    var readingTimeMinutes: Int {
        if let time = reading_time, time > 0 {
            return time
        }
        // Fallback calculation: ~200 words per minute
        let wordCount = content.split(separator: " ").count
        return max(1, wordCount / 200)
    }
}
