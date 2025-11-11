//
//  QuickMigrationGuide.swift
//  FootballApp
//
//  Quick reference for updating existing views with new UI/UX improvements
//

import SwiftUI

/*
 ═══════════════════════════════════════════════════════════════
 QUICK MIGRATION GUIDE - FROM OLD TO NEW
 ═══════════════════════════════════════════════════════════════
 
 This file shows how to quickly update your existing views
 to use the new space-efficient, purple-themed design system.
 */

// MARK: - ✅ BEFORE & AFTER: Workout Cards

/*
 ───────────────────────────────────────────────────────────────
 ❌ BEFORE - Basic card with wasted space:
 ───────────────────────────────────────────────────────────────
 
 VStack {
     Text("Tuesday")
         .font(.caption)
         .foregroundColor(.purple)
     
     Text("Cardio Workout")
         .font(.headline)
     
     Text("45 minutes")
         .font(.subheadline)
 }
 .padding(20)  // Too much padding
 .background(Color.white)
 .cornerRadius(12)
 .shadow(radius: 5)
 
 
 ───────────────────────────────────────────────────────────────
 ✅ AFTER - Modern card with optimized spacing:
 ───────────────────────────────────────────────────────────────
 */

struct OptimizedWorkoutCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {  // Reduced from 16
            Text("TUESDAY")
                .dayLabel()  // Pre-styled for consistency
            
            Text("Cardio Workout")
                .font(.title3.bold())
                .foregroundColor(Color.theme.textPrimary)
            
            HStack(spacing: 12) {  // Compact layout
                Label("45 min", systemImage: "clock")
                    .captionText()
            }
        }
        .padding(16)  // Optimal padding
        .workoutCard(isCompleted: false)  // Glass effect built-in
        // Much cleaner, more professional!
    }
}

// MARK: - ✅ BEFORE & AFTER: Buttons

/*
 ───────────────────────────────────────────────────────────────
 ❌ BEFORE - Basic button:
 ───────────────────────────────────────────────────────────────
 
 Button("Start Workout") {
     // Action
 }
 .foregroundColor(.white)
 .padding()
 .background(Color.purple)
 .cornerRadius(12)
 
 
 ───────────────────────────────────────────────────────────────
 ✅ AFTER - Modern button with gradient and glow:
 ───────────────────────────────────────────────────────────────
 */

struct OptimizedButton: View {
    var body: some View {
        Button("Start Workout") {
            // Action
        }
        .primaryButton()  // Includes gradient, shadow, perfect sizing
        // That's it! Much simpler!
    }
}

// MARK: - ✅ BEFORE & AFTER: List Items

/*
 ───────────────────────────────────────────────────────────────
 ❌ BEFORE - Basic list with excessive padding:
 ───────────────────────────────────────────────────────────────
 
 VStack(spacing: 16) {  // Too much space
     ForEach(exercises) { exercise in
         HStack {
             Text(exercise.name)
             Spacer()
             Text(exercise.reps)
         }
         .padding()
         .background(Color.white)
         .cornerRadius(8)
     }
 }
 .padding()
 
 
 ───────────────────────────────────────────────────────────────
 ✅ AFTER - Compact list with optimal spacing:
 ───────────────────────────────────────────────────────────────
 */

struct OptimizedList: View {
    let exercises: [WorkoutExercise]
    
    var body: some View {
        VStack(spacing: 8) {  // Reduced spacing
            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                HStack(spacing: 12) {
                    // Index badge (compact)
                    ZStack {
                        Circle()
                            .fill(Color.theme.primary.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(Color.theme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(exercise.name)
                            .font(.subheadline.weight(.semibold))
                        
                        HStack(spacing: 8) {
                            Label(exercise.sets, systemImage: "repeat")
                            Label(exercise.reps, systemImage: "number")
                        }
                        .captionText()
                    }
                    
                    Spacer(minLength: 0)  // Flexible space
                }
                .exerciseListItem(isCompleted: false)
            }
        }
        .padding(.horizontal, 16)  // Edge-to-edge with minimal padding
    }
}

// MARK: - ✅ BEFORE & AFTER: Weekly Grid

/*
 ───────────────────────────────────────────────────────────────
 ❌ BEFORE - Basic grid with poor spacing:
 ───────────────────────────────────────────────────────────────
 
 let columns = [
     GridItem(.flexible()),
     GridItem(.flexible()),
     GridItem(.flexible())
 ]
 
 LazyVGrid(columns: columns) {
     ForEach(days) { day in
         VStack {
             Text(day.name)
             Image(systemName: "figure.walk")
         }
         .padding()
         .background(Color.white)
     }
 }
 .padding()
 
 
 ───────────────────────────────────────────────────────────────
 ✅ AFTER - Optimized grid with proper spacing:
 ───────────────────────────────────────────────────────────────
 */

struct OptimizedWeeklyGrid: View {
    let days: [WorkoutSession]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),  // Defined spacing
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)   // 4 columns for more efficiency
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(days) { day in
                VStack(spacing: 8) {
                    Text(day.day.prefix(3).uppercased())
                        .dayLabel()
                    
                    Circle()
                        .fill(Color.theme.primaryGradient)
                        .frame(width: 44, height: 44)  // Fixed size
                        .overlay {
                            Image(systemName: "figure.run")
                                .foregroundColor(.white)
                        }
                    
                    Text(day.theme)
                        .font(.system(size: 9))
                        .foregroundColor(Color.theme.textSecondary)
                }
                .gridCardItem()  // Auto-sizing with aspect ratio
            }
        }
        .padding(.horizontal, 16)  // Minimal horizontal padding
    }
}

// MARK: - ✅ BEFORE & AFTER: Tab Bar

/*
 ───────────────────────────────────────────────────────────────
 ❌ BEFORE - Basic TabView (limited customization):
 ───────────────────────────────────────────────────────────────
 
 TabView {
     WorkoutView()
         .tabItem {
             Image(systemName: "figure.walk")
             Text("Workouts")
         }
     
     ProfileView()
         .tabItem {
             Image(systemName: "person")
             Text("Profile")
         }
 }
 
 
 ───────────────────────────────────────────────────────────────
 ✅ AFTER - Custom tab bar with glass effect:
 ───────────────────────────────────────────────────────────────
 */

struct OptimizedTabBar: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    
    let tabs = ["Workouts", "Nutrition", "Kine", "Profile"]
    let icons = ["figure.walk", "leaf.fill", "plus.circle.fill", "person.fill"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Content area
            contentForTab(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button {
                        withAnimation(.interactiveSpring()) {
                            selectedTab = index
                        }
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                if selectedTab == index {
                                    Capsule()
                                        .fill(.thinMaterial)
                                        .frame(width: 64, height: 40)
                                        .overlay {
                                            Capsule()
                                                .fill(Color.theme.primaryGradient.opacity(0.3))
                                        }
                                        .matchedGeometryEffect(id: "tab", in: animation)
                                }
                                
                                Image(systemName: icons[index])
                                    .tabBarIcon(isSelected: selectedTab == index)
                            }
                            .frame(height: 40)
                            
                            Text(tabs[index])
                                .font(.system(size: 11, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundColor(selectedTab == index ? Color.theme.primary : Color.theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .customTabBar()  // Glass effect with shadows
        }
    }
    
    @ViewBuilder
    func contentForTab(_ tab: Int) -> some View {
        switch tab {
        case 0: Text("Workouts")
        case 1: Text("Nutrition")
        case 2: Text("Kine")
        case 3: Text("Profile")
        default: Text("Unknown")
        }
    }
}

// MARK: - ✅ QUICK WINS: Small Changes, Big Impact

/*
 ═══════════════════════════════════════════════════════════════
 QUICK WINS - Replace these immediately:
 ═══════════════════════════════════════════════════════════════
 */

struct QuickWins {
    
    // 1. Replace basic text styling:
    struct TextStyling: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                // ❌ OLD:
                // Text("Tuesday").font(.caption).foregroundColor(.purple)
                
                // ✅ NEW:
                Text("TUESDAY").dayLabel()
                
                // ❌ OLD:
                // Text("Cardio").font(.headline)
                
                // ✅ NEW:
                Text("Cardio").heroTitle()
                
                // ❌ OLD:
                // Text("45 min").font(.caption).foregroundColor(.gray)
                
                // ✅ NEW:
                Text("45 min").captionText()
            }
        }
    }
    
    // 2. Replace basic backgrounds:
    struct BackgroundStyling: View {
        var body: some View {
            VStack {
                Text("Content")
            }
            // ❌ OLD:
            // .background(Color.white)
            // .cornerRadius(12)
            // .shadow(radius: 5)
            
            // ✅ NEW:
            .glassCard(padding: 16, cornerRadius: 16)
            // Much more modern!
        }
    }
    
    // 3. Replace spacing:
    struct SpacingStyling: View {
        var body: some View {
            VStack {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
            }
            // ❌ OLD:
            // .padding(24) // Too much
            
            // ✅ NEW:
            .compactSpacing()  // Optimal 8pt
        }
    }
    
    // 4. Replace animations:
    struct AnimationStyling: View {
        @State private var isExpanded = false
        
        var body: some View {
            Rectangle()
                .frame(height: isExpanded ? 200 : 100)
            // ❌ OLD:
            // .animation(.default)
            
            // ✅ NEW:
                .animation(.interactiveSpring(), value: isExpanded)
            // Much smoother!
        }
    }
}

// MARK: - ✅ CHECKLIST: Update Your Views

/*
 ═══════════════════════════════════════════════════════════════
 MIGRATION CHECKLIST
 ═══════════════════════════════════════════════════════════════
 
 Use this checklist for each view you update:
 
 [ ] 1. Replace hardcoded colors with Color.theme.*
 [ ] 2. Replace .font() calls with typography helpers (.heroTitle(), .dayLabel(), etc.)
 [ ] 3. Replace .padding() with .compactSpacing() or specific values
 [ ] 4. Replace basic backgrounds with .glassCard() or .workoutCard()
 [ ] 5. Replace basic buttons with .primaryButton() or .secondaryButton()
 [ ] 6. Add .purpleGlow() to important CTAs
 [ ] 7. Replace Grid spacing with defined column spacing
 [ ] 8. Add .pressableScale() to interactive elements
 [ ] 9. Add haptic feedback to buttons (.mediumHaptic())
 [ ] 10. Add .accessibleCard() for VoiceOver support
 
 ═══════════════════════════════════════════════════════════════
 */

// MARK: - 🎯 PRIORITY ORDER: What to Update First

/*
 ═══════════════════════════════════════════════════════════════
 UPDATE PRIORITY
 ═══════════════════════════════════════════════════════════════
 
 1. HIGH PRIORITY (Do these first):
    - Tab bar (most visible)
    - Main workout cards
    - Primary buttons
    - Day labels in calendar
 
 2. MEDIUM PRIORITY:
    - Exercise list items
    - Progress dashboard
    - Section headers
    - Quick action buttons
 
 3. LOW PRIORITY (Nice to have):
    - Animations
    - Haptic feedback
    - Accessibility labels
    - Inner shadows
 
 ═══════════════════════════════════════════════════════════════
 */

// MARK: - 💡 PRO TIPS

/*
 ═══════════════════════════════════════════════════════════════
 PRO TIPS FOR SMOOTH MIGRATION
 ═══════════════════════════════════════════════════════════════
 
 1. Update one view at a time
    - Start with the most visible view (e.g., main workout list)
    - Test thoroughly before moving to the next
 
 2. Use previews extensively
    - Add #Preview blocks to test your changes
    - Compare old vs new side-by-side
 
 3. Consistency is key
    - Use the same modifiers throughout the app
    - Don't mix old and new styles in the same view
 
 4. Keep it simple
    - Don't over-complicate - the modifiers do most of the work
    - Trust the design system
 
 5. Performance matters
    - Use .compactSpacing() to fit more content on screen
    - Avoid nested .padding() calls
    - Use .gridCardItem() for automatic sizing
 
 6. Test on different devices
    - Small phones (iPhone SE)
    - Large phones (iPhone Pro Max)
    - iPad
 
 7. Dark mode compatibility
    - Materials (.ultraThinMaterial) adapt automatically
    - Test in both light and dark mode
 
 ═══════════════════════════════════════════════════════════════
 */

// MARK: - 🚨 Common Mistakes to Avoid

/*
 ═══════════════════════════════════════════════════════════════
 COMMON MISTAKES
 ═══════════════════════════════════════════════════════════════
 
 ❌ DON'T stack too many .padding() calls
    Bad: .padding().padding(.horizontal).padding(.top)
    ✅ Good: .padding(16)
 
 ❌ DON'T use hardcoded colors
    Bad: .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.8))
    ✅ Good: .foregroundColor(Color.theme.primary)
 
 ❌ DON'T ignore spacing in grids
    Bad: GridItem(.flexible())
    ✅ Good: GridItem(.flexible(), spacing: 12)
 
 ❌ DON'T forget corner radius when using materials
    Bad: .background(.ultraThinMaterial)
    ✅ Good: .glassCard(cornerRadius: 16)
 
 ❌ DON'T apply shadows multiple times
    Bad: .shadow(...).shadow(...).shadow(...)
    ✅ Good: .cardShadow() // Handles multiple shadows internally
 
 ❌ DON'T use generic animations
    Bad: .animation(.default, value: state)
    ✅ Good: .animation(.interactiveSpring(), value: state)
 
 ═══════════════════════════════════════════════════════════════
 */

// MARK: - 📱 Platform-Specific Considerations

/*
 ═══════════════════════════════════════════════════════════════
 PLATFORM NOTES
 ═══════════════════════════════════════════════════════════════
 
 iPhone:
 - Use 4-column grids for weekly calendar
 - Compact spacing (8-12pt)
 - Tab bar with glass effect
 - Edge-to-edge content
 
 iPad:
 - Can use 5-7 column grids
 - Slightly larger padding (16-20pt)
 - Consider sidebar navigation instead of tab bar
 - More whitespace acceptable
 
 Accessibility:
 - All modifiers support Dynamic Type
 - Glass materials work in Dark Mode
 - VoiceOver labels included
 - Respect Reduce Motion setting
 
 ═══════════════════════════════════════════════════════════════
 */

// Preview for testing
#Preview("Quick Wins Demo") {
    VStack(spacing: 20) {
        OptimizedWorkoutCard()
        OptimizedButton()
    }
    .padding()
    .background(Color.theme.background)
}
