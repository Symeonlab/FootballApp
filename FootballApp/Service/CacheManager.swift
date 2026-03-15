import Foundation
import UIKit

/// A simple in-memory cache manager with TTL (time-to-live) support
class CacheManager {
    static let shared = CacheManager()

    private let cache = NSCache<NSString, CacheEntry>()

    private init() {
        // Set default limits
        cache.countLimit = 100 // Maximum number of cached items
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB max
    }

    /// Cache entry wrapper with expiration date
    class CacheEntry {
        let data: Data
        let expiry: Date

        init(data: Data, ttl: TimeInterval) {
            self.data = data
            self.expiry = Date().addingTimeInterval(ttl)
        }

        var isExpired: Bool {
            Date() > expiry
        }
    }

    /// Cache an object with a specific TTL (default 5 minutes)
    /// - Parameters:
    ///   - object: The Codable object to cache
    ///   - key: The cache key
    ///   - ttl: Time-to-live in seconds (default 300 = 5 minutes)
    func cache<T: Codable>(_ object: T, forKey key: String, ttl: TimeInterval = 300) {
        guard let data = try? JSONEncoder().encode(object) else { return }
        let entry = CacheEntry(data: data, ttl: ttl)
        cache.setObject(entry, forKey: key as NSString)
    }

    /// Retrieve a cached object
    /// - Parameter key: The cache key
    /// - Returns: The cached object if found and not expired, nil otherwise
    func retrieve<T: Codable>(forKey key: String) -> T? {
        guard let entry = cache.object(forKey: key as NSString),
              !entry.isExpired else {
            // Remove expired entry
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: entry.data)
    }

    /// Check if a valid (non-expired) cache entry exists
    /// - Parameter key: The cache key
    /// - Returns: True if valid cache exists
    func hasValidCache(forKey key: String) -> Bool {
        guard let entry = cache.object(forKey: key as NSString) else {
            return false
        }
        if entry.isExpired {
            cache.removeObject(forKey: key as NSString)
            return false
        }
        return true
    }

    /// Invalidate a specific cache entry
    /// - Parameter key: The cache key to invalidate
    func invalidate(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    /// Invalidate all cached data
    func invalidateAll() {
        cache.removeAllObjects()
    }
}

// MARK: - Cache Keys
extension CacheManager {
    /// Predefined cache keys for common data
    enum CacheKey {
        static let workoutPlan = "workout_plan"
        static let nutritionPlan = "nutrition_plan"
        static let dashboardMetrics = "dashboard_metrics"
        static let userProfile = "user_profile"
        static let goals = "goals"
        static let activeGoal = "active_goal"
        static let achievements = "achievements"
        static let posts = "posts"
        static let kineData = "kine_data"
        static let kineFavorites = "kine_favorites"

        static func post(slug: String) -> String { "post_\(slug)" }
        static func goal(id: Int) -> String { "goal_\(id)" }
    }
}

// MARK: - Image Cache
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    func get(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}
