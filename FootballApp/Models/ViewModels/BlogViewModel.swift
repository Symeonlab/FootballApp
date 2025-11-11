//
//  BlogViewModel.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import Foundation
import Combine

class BlogViewModel: ObservableObject {
    @Published var posts: [BlogPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load mock data for now
        loadMockData()
    }
    
    func fetchBlogPosts() {
        // TODO: Implement API call when endpoint is ready
        // For now, we'll use mock data
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.loadMockData()
            self?.isLoading = false
        }
        
        /* When API is ready, use this:
        APIService.shared.request(endpoint: "/api/blog-posts", method: "GET")
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] (posts: [BlogPost]) in
                self?.posts = posts
            })
            .store(in: &cancellables)
        */
    }
    
    private func loadMockData() {
        posts = [
            BlogPost(
                id: 1,
                title: "5 Essential Warm-Up Exercises for Football Players",
                slug: "warm-up-exercises-football",
                excerpt: "Discover the most effective warm-up routines to prevent injuries and boost performance on the field.",
                content: """
                Warming up is crucial for every football player, whether you're a beginner or a professional. A proper warm-up routine not only helps prevent injuries but also prepares your body and mind for peak performance.
                
                Here are the 5 essential warm-up exercises every football player should do:
                
                1. Dynamic Stretching
                Unlike static stretching, dynamic stretches involve movement and help increase blood flow to your muscles. Try leg swings, arm circles, and walking lunges.
                
                2. Light Jogging
                Start with a 5-10 minute light jog to gradually increase your heart rate and body temperature. This prepares your cardiovascular system for more intense activity.
                
                3. High Knees and Butt Kicks
                These exercises activate your leg muscles and improve coordination. Perform 2-3 sets of 20 seconds each.
                
                4. Lateral Movements
                Football requires quick lateral movements. Practice side shuffles and carioca runs to warm up those stabilizing muscles.
                
                5. Ball Work
                Finish your warm-up with some light ball touches, passing drills, or juggling. This helps you get into the right mental state for the game.
                
                Remember, a good warm-up should take 15-20 minutes and leave you feeling energized, not exhausted. Make these exercises part of your routine before every training session or match.
                """,
                category: "training",
                author: "Coach Mike Johnson",
                image_url: nil,
                published_at: "2025-11-10",
                tags: ["warm-up", "training", "injury prevention"]
            ),
            BlogPost(
                id: 2,
                title: "Nutrition Guide: What to Eat Before a Match",
                slug: "pre-match-nutrition-guide",
                excerpt: "Learn what foods to eat and when to eat them for optimal performance on game day.",
                content: """
                Proper nutrition is just as important as training when it comes to football performance. What you eat before a match can significantly impact your energy levels, endurance, and overall performance.
                
                Timing is Everything
                
                3-4 Hours Before:
                This is your main pre-match meal. Focus on complex carbohydrates like pasta, rice, or whole grain bread. Add lean protein such as chicken or fish, and include some vegetables. Avoid fatty and fried foods that are hard to digest.
                
                1-2 Hours Before:
                Have a lighter snack if needed. Good options include a banana, energy bar, or toast with honey. Keep it simple and easy to digest.
                
                30 Minutes Before:
                If you need a quick energy boost, try a sports drink or a small amount of easily digestible carbs like dried fruit.
                
                Hydration Matters
                
                Start hydrating 24 hours before your match. Drink water consistently throughout the day, and consider adding electrolyte drinks if you expect to sweat heavily.
                
                Foods to Avoid:
                - High-fat foods (burgers, fried foods)
                - High-fiber foods (can cause digestive issues)
                - New or unfamiliar foods (stick to what you know works)
                - Large amounts of protein (takes longer to digest)
                
                Every athlete is different, so experiment during training to find what works best for you. Keep a food journal to track how different meals affect your performance.
                """,
                category: "nutrition",
                author: "Dr. Sarah Williams",
                image_url: nil,
                published_at: "2025-11-08",
                tags: ["nutrition", "pre-match", "performance"]
            ),
            BlogPost(
                id: 3,
                title: "Recovery Techniques: Ice Baths vs. Compression",
                slug: "recovery-techniques-comparison",
                excerpt: "Compare different recovery methods and find out which one is best for you.",
                content: """
                Recovery is an often overlooked but critical component of athletic performance. The right recovery techniques can reduce muscle soreness, prevent injuries, and help you train more effectively.
                
                Ice Baths (Cold Water Immersion)
                
                Benefits:
                - Reduces inflammation and muscle soreness
                - Helps remove metabolic waste from muscles
                - Can improve recovery time between sessions
                
                How to Use:
                Immerse yourself in 10-15°C (50-60°F) water for 10-15 minutes. Do this within 30 minutes after intense training.
                
                Best For: After high-intensity training or matches
                
                Compression Therapy
                
                Benefits:
                - Improves blood circulation
                - Reduces swelling and muscle fatigue
                - Can be used anytime, anywhere
                
                How to Use:
                Wear compression garments during or after exercise, or use compression boots for 20-30 minutes.
                
                Best For: Between training sessions, during travel
                
                Active Recovery
                
                Don't underestimate the power of light movement! A 20-30 minute walk, swim, or gentle yoga session can be just as effective as more intense recovery methods.
                
                The Bottom Line
                
                The best recovery method depends on your individual needs, the intensity of your training, and what your body responds to best. Many professional athletes use a combination of methods. Listen to your body and experiment to find what works for you.
                
                Remember: Quality sleep and proper nutrition are the foundation of all recovery methods!
                """,
                category: "recovery",
                author: "Alex Thompson, PT",
                image_url: nil,
                published_at: "2025-11-05",
                tags: ["recovery", "ice bath", "compression", "injury prevention"]
            ),
            BlogPost(
                id: 4,
                title: "Building Mental Toughness for High-Pressure Games",
                slug: "mental-toughness-guide",
                excerpt: "Develop the mental skills you need to perform under pressure and stay focused during crucial moments.",
                content: """
                Physical skills will only take you so far in football. The mental game is what separates good players from great ones, especially in high-pressure situations.
                
                Visualization Techniques
                
                Spend 10-15 minutes each day visualizing yourself performing successfully. See yourself making perfect passes, scoring goals, or making crucial defensive plays. Make it as vivid as possible—engage all your senses.
                
                Pre-Game Routines
                
                Develop a consistent pre-game routine that helps you get into the right mental state. This could include:
                - Listening to specific music
                - Performing the same warm-up sequence
                - Meditation or breathing exercises
                - Reviewing key tactical points
                
                Managing Pressure
                
                When you feel pressure mounting:
                1. Focus on your breathing (4 counts in, 4 counts hold, 4 counts out)
                2. Remind yourself of past successes
                3. Focus on what you can control
                4. Break the game down into smaller moments
                
                Positive Self-Talk
                
                Replace negative thoughts with positive, constructive ones:
                - "I can't do this" → "I've trained for this"
                - "What if I mess up?" → "I'm prepared and ready"
                - "They're better than me" → "I'll give my best performance"
                
                Learning from Mistakes
                
                Even the best players make mistakes. What matters is how you respond:
                - Acknowledge the mistake quickly
                - Let it go immediately
                - Refocus on the next play
                - Review and learn after the game
                
                Building mental toughness is a skill that develops over time with consistent practice. Just like physical training, it requires dedication and patience.
                """,
                category: "mindset",
                author: "Dr. James Martinez",
                image_url: nil,
                published_at: "2025-11-12",
                tags: ["mental game", "psychology", "performance", "pressure"]
            ),
            BlogPost(
                id: 5,
                title: "Strength Training for Football: A Complete Guide",
                slug: "strength-training-football-guide",
                excerpt: "Build explosive power and prevent injuries with these football-specific strength training exercises.",
                content: """
                Strength training is essential for modern football players. It builds power, improves acceleration, increases resilience to injury, and enhances overall performance.
                
                Key Principles
                
                1. Functional Movements
                Focus on exercises that mimic football movements: squats, lunges, deadlifts, and explosive jumps.
                
                2. Core Stability
                A strong core is crucial for balance, power transfer, and injury prevention. Include planks, Russian twists, and anti-rotation exercises.
                
                3. Unilateral Training
                Train one leg at a time to address imbalances and improve stability. Single-leg squats and split squats are excellent choices.
                
                Sample Weekly Program
                
                Monday - Lower Body Power:
                - Back Squats: 4x6
                - Romanian Deadlifts: 3x8
                - Box Jumps: 4x5
                - Single-leg RDLs: 3x8 each leg
                
                Wednesday - Upper Body & Core:
                - Bench Press: 4x6
                - Pull-ups: 3x8-10
                - Shoulder Press: 3x8
                - Plank variations: 3x45 seconds
                - Medicine ball throws: 3x10
                
                Friday - Full Body & Explosiveness:
                - Power Cleans: 4x4
                - Front Squats: 3x6
                - Nordic Curls: 3x6
                - Sled Pushes: 4x20m
                - Core circuit: 3 rounds
                
                Important Tips
                
                - Prioritize proper form over heavy weight
                - Allow 48-72 hours between heavy sessions
                - Adjust intensity based on your match schedule
                - Include mobility work before and after
                - Work with a qualified coach when possible
                
                Periodization
                
                Vary your training intensity throughout the season:
                - Off-season: Higher volume, building foundation
                - Pre-season: Increase intensity, reduce volume
                - In-season: Maintain strength, focus on recovery
                
                Remember, strength training should complement your football training, not replace it. The goal is to become a better football player, not just stronger in the gym.
                """,
                category: "training",
                author: "Marcus Williams, CSCS",
                image_url: nil,
                published_at: "2025-11-01",
                tags: ["strength training", "power", "exercises", "program"]
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
}
