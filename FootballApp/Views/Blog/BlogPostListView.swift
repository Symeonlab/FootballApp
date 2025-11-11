//
//  BlogPostListView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

struct BlogPostListView: View {
    @StateObject private var viewModel = BlogViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: BlogCategory = .all
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(BlogCategory.allCases) { category in
                            CategoryChip(
                                title: category.title,
                                isSelected: selectedCategory == category,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.theme.surface)
                
                // Blog Posts List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if filteredPosts.isEmpty {
                    EmptyBlogState()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredPosts) { post in
                                NavigationLink(destination: BlogPostDetailView(post: post)) {
                                    BlogPostCard(post: post)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.fetchBlogPosts()
                    }
                }
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Blog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if viewModel.posts.isEmpty {
                    viewModel.fetchBlogPosts()
                }
            }
        }
    }
    
    private var filteredPosts: [BlogPost] {
        if selectedCategory == .all {
            return viewModel.posts
        }
        return viewModel.posts.filter { $0.category == selectedCategory.rawValue }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(isSelected ? .white : Color.theme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.theme.primary : Color.theme.background)
                )
        }
    }
}

// MARK: - Blog Post Card
struct BlogPostCard: View {
    let post: BlogPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            if let imageUrl = post.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 180)
                .clipped()
                .cornerRadius(12)
            } else {
                // Placeholder with gradient
                LinearGradient(
                    colors: [Color.theme.primary.opacity(0.3), Color.theme.accent.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .overlay(
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                )
                .cornerRadius(12)
            }
            
            // Category Badge
            Text(post.category.uppercased())
                .font(.caption2.bold())
                .foregroundColor(Color.theme.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.theme.primary.opacity(0.1))
                .cornerRadius(6)
            
            // Title
            Text(post.title)
                .font(.headline.bold())
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(2)
            
            // Excerpt
            if let excerpt = post.excerpt {
                Text(excerpt)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Meta Info
            HStack {
                if let author = post.author {
                    Label(author, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if let date = post.published_at {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.surface)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Empty State
struct EmptyBlogState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No blog posts yet")
                .font(.headline)
                .foregroundColor(Color.theme.textPrimary)
            Text("Check back later for training tips and insights")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Blog Post Detail View
struct BlogPostDetailView: View {
    let post: BlogPost
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Image
                if let imageUrl = post.image_url, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .overlay(ProgressView())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 250)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // Category
                    Text(post.category.uppercased())
                        .font(.caption.bold())
                        .foregroundColor(Color.theme.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.theme.primary.opacity(0.1))
                        .cornerRadius(6)
                    
                    // Title
                    Text(post.title)
                        .font(.title.bold())
                        .foregroundColor(Color.theme.textPrimary)
                    
                    // Meta
                    HStack {
                        if let author = post.author {
                            HStack(spacing: 6) {
                                Image(systemName: "person.fill")
                                Text(author)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        if let date = post.published_at {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(formatDate(date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Content
                    Text(post.content)
                        .font(.body)
                        .foregroundColor(Color.theme.textPrimary)
                        .lineSpacing(6)
                }
                .padding()
            }
        }
        .background(Color.theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Blog Category Enum
enum BlogCategory: String, CaseIterable, Identifiable {
    case all = "all"
    case training = "training"
    case nutrition = "nutrition"
    case recovery = "recovery"
    case mindset = "mindset"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .training: return "Training"
        case .nutrition: return "Nutrition"
        case .recovery: return "Recovery"
        case .mindset: return "Mindset"
        }
    }
}

#Preview {
    BlogPostListView()
        .environmentObject(LanguageManager())
}
