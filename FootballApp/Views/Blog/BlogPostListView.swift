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
    @State private var searchText: String = ""
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark purple animated background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header Section
                    blogHeaderSection

                    // Search Bar
                    searchBarSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)

                    // Category Filter
                    categoryFilterSection

                    // Blog Posts Content
                    if viewModel.isLoading {
                        BlogLoadingView()
                            .frame(maxHeight: .infinity)
                    } else if filteredPosts.isEmpty {
                        EnhancedEmptyBlogState(
                            isFiltered: selectedCategory != .all || !searchText.isEmpty
                        )
                        .frame(maxHeight: .infinity)
                    } else {
                        blogPostsScrollView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("tab.blog".localizedString)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                if viewModel.posts.isEmpty {
                    viewModel.fetchBlogPosts()
                }
            }
        }

    }

    // MARK: - Header Section
    private var blogHeaderSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.theme.primary.opacity(0.4), radius: 10, x: 0, y: 4)

                    Image(systemName: "book.fill")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("blog.header_title".localizedString)
                        .font(.headline.bold())
                        .foregroundColor(.white)

                    Text(String(format: "blog.articles_count".localizedString, viewModel.posts.count))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Search Bar
    private var searchBarSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))
                .font(.body)

            TextField("blog.search_articles".localizedString, text: $searchText)
                .foregroundColor(.white)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    // MARK: - Category Filter
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(BlogCategory.allCases) { category in
                    EnhancedCategoryChip(
                        title: category.title,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        namespace: namespace,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Blog Posts Scroll View
    private var blogPostsScrollView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // Featured Post (first post)
                if let firstPost = filteredPosts.first {
                    NavigationLink(destination: EnhancedBlogPostDetailView(post: firstPost)) {
                        FeaturedBlogCard(post: firstPost)
                    }
                    .buttonStyle(.plain)
                }

                // Regular Posts
                ForEach(Array(filteredPosts.dropFirst())) { post in
                    NavigationLink(destination: EnhancedBlogPostDetailView(post: post)) {
                        EnhancedBlogPostCard(post: post)
                    }
                    .buttonStyle(.plain)
                }

                // Bottom padding for tab bar safe area
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .refreshable {
            viewModel.fetchBlogPosts()
        }
    }

    // MARK: - Filtered Posts
    private var filteredPosts: [BlogPost] {
        var posts = viewModel.posts

        // Filter by category
        if selectedCategory != .all {
            posts = posts.filter { $0.category == selectedCategory.rawValue }
        }

        // Filter by search text
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespaces)
        if !trimmedSearch.isEmpty {
            posts = posts.filter {
                $0.title.localizedCaseInsensitiveContains(trimmedSearch) ||
                ($0.excerpt?.localizedCaseInsensitiveContains(trimmedSearch) ?? false) ||
                $0.content.localizedCaseInsensitiveContains(trimmedSearch)
            }
        }

        return posts
    }
}

// MARK: - Enhanced Category Chip
private struct EnhancedCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())

                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .matchedGeometryEffect(id: "categoryBackground", in: namespace)
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                        )
                }
            }
            .shadow(color: isSelected ? Color.theme.primary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Featured Blog Card
private struct FeaturedBlogCard: View {
    let post: BlogPost

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Section
            ZStack(alignment: .topLeading) {
                if let imageUrl = post.image_url, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            featuredPlaceholder
                                .overlay(ProgressView().tint(.white))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            featuredPlaceholder
                        @unknown default:
                            featuredPlaceholder
                        }
                    }
                } else {
                    featuredPlaceholder
                }

                // Featured Badge
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption2.bold())
                    Text("blog.featured".localized)
                        .font(.caption2.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .padding(12)
            }
            .frame(height: 200)
            .clipped()

            // Content Section
            VStack(alignment: .leading, spacing: 10) {
                // Category Badge
                Text(post.category.uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(Color.theme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.theme.primary.opacity(0.15))
                    .clipShape(Capsule())

                // Title
                Text(post.title)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(2)

                // Excerpt
                if let excerpt = post.excerpt {
                    Text(excerpt)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }

                // Meta Info
                HStack {
                    if let author = post.author {
                        HStack(spacing: 4) {
                            Image(systemName: "person.circle.fill")
                                .font(.caption)
                            Text(author)
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.6))
                    }

                    Spacer()

                    if let date = post.published_at {
                        Text(formatDate(date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundColor(Color.theme.primary)
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
    }

    private var featuredPlaceholder: some View {
        LinearGradient(
            colors: [Color.theme.primary.opacity(0.5), Color.theme.accent.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "book.fill")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
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

// MARK: - Enhanced Blog Post Card
private struct EnhancedBlogPostCard: View {
    let post: BlogPost

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            ZStack {
                if let imageUrl = post.image_url, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            thumbnailPlaceholder
                                .overlay(ProgressView().tint(.white).scaleEffect(0.7))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            thumbnailPlaceholder
                        @unknown default:
                            thumbnailPlaceholder
                        }
                    }
                } else {
                    thumbnailPlaceholder
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Category
                Text(post.category.uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(categoryColor)

                // Title
                Text(post.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .lineLimit(2)

                // Meta
                HStack(spacing: 8) {
                    if let author = post.author {
                        Text(author)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    if let date = post.published_at {
                        Text("•")
                            .foregroundColor(.white.opacity(0.3))
                        Text(formatDate(date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Read time estimate (uses API value or calculates from content)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(String(format: "blog.read_time".localizedString, post.readingTimeMinutes))
                        .font(.caption2)
                }
                .foregroundColor(Color.theme.primary.opacity(0.8))
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var thumbnailPlaceholder: some View {
        LinearGradient(
            colors: [categoryColor.opacity(0.3), categoryColor.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: categoryIcon)
                .font(.title3)
                .foregroundColor(categoryColor.opacity(0.5))
        )
    }

    private var categoryColor: Color {
        switch post.category {
        case "training": return .blue
        case "nutrition": return .green
        case "recovery": return .orange
        case "mindset": return .purple
        default: return Color.theme.primary
        }
    }

    private var categoryIcon: String {
        switch post.category {
        case "training": return "figure.run"
        case "nutrition": return "leaf.fill"
        case "recovery": return "heart.fill"
        case "mindset": return "brain.head.profile"
        default: return "book.fill"
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Blog Loading View
private struct BlogLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Featured skeleton
            VStack(alignment: .leading, spacing: 0) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 160)

                VStack(alignment: .leading, spacing: 10) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 80, height: 14)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 18)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 12)
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Regular post skeletons
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 90, height: 90)

                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 60, height: 10)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 16)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 10)
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
            }
        }
        .padding(.horizontal, 16)
        .shimmer()
    }
}

// MARK: - Enhanced Empty State
private struct EnhancedEmptyBlogState: View {
    let isFiltered: Bool

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.theme.primary.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: isFiltered ? "magnifyingglass" : "book.closed")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 8) {
                Text(isFiltered ? "blog.no_matching".localizedString : "blog.no_posts".localizedString)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Text(isFiltered ? "blog.try_adjusting".localizedString : "blog.check_back".localizedString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Enhanced Blog Post Detail View
struct EnhancedBlogPostDetailView: View {
    let post: BlogPost
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero Image
                    ZStack(alignment: .bottomLeading) {
                        if let imageUrl = post.image_url, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    heroPlaceholder
                                        .overlay(ProgressView().tint(.white))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure:
                                    heroPlaceholder
                                @unknown default:
                                    heroPlaceholder
                                }
                            }
                        } else {
                            heroPlaceholder
                        }

                        // Gradient overlay
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .frame(height: 280)
                    .clipped()

                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Category & Reading Time
                        HStack(spacing: 12) {
                            Label(post.category.capitalized, systemImage: categoryIcon)
                                .font(.caption.bold())
                                .foregroundColor(Color.theme.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.theme.primary.opacity(0.15))
                                .clipShape(Capsule())

                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                Text(String(format: "blog.read_time".localizedString, post.readingTimeMinutes))
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))

                            Spacer()
                        }

                        // Title
                        Text(post.title)
                            .font(.title.bold())
                            .foregroundColor(.white)

                        // Author & Date
                        HStack(spacing: 16) {
                            if let author = post.author {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.theme.primary.opacity(0.3))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Text(String(author.prefix(1)))
                                                .font(.headline)
                                                .foregroundColor(.white)
                                        )

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(author)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)

                                        if let date = post.published_at {
                                            Text(formatDate(date))
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                    }
                                }
                            }

                            Spacer()

                            // Share Button
                            Button(action: { showShareSheet = true }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.body.bold())
                                    .foregroundColor(Color.theme.primary)
                                    .frame(width: 40, height: 40)
                                    .background(Color.theme.primary.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Content
                        Text(post.content)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(8)

                        // Tags
                        if let tags = post.tags, !tags.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("blog.related".localizedString)
                                    .font(.headline.bold())
                                    .foregroundColor(.white)

                                FlowLayout(spacing: 8) {
                                    ForEach(tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption.bold())
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.top, 16)
                        }

                        // Bottom padding
                        Color.clear.frame(height: 60)
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showShareSheet = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var heroPlaceholder: some View {
        LinearGradient(
            colors: [Color.theme.primary.opacity(0.5), Color.theme.accent.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
        )
    }

    private var categoryIcon: String {
        switch post.category {
        case "training": return "figure.run"
        case "nutrition": return "leaf.fill"
        case "recovery": return "heart.fill"
        case "mindset": return "brain.head.profile"
        default: return "book.fill"
        }
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

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
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
        case .all: return "blog.category.all".localizedString
        case .training: return "blog.category.training".localizedString
        case .nutrition: return "blog.category.nutrition".localizedString
        case .recovery: return "blog.category.recovery".localizedString
        case .mindset: return "blog.category.mindset".localizedString
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .training: return "figure.run"
        case .nutrition: return "leaf.fill"
        case .recovery: return "heart.fill"
        case .mindset: return "brain.head.profile"
        }
    }
}

// MARK: - Blog Tab View (for MainTabView)
struct BlogTabView: View {
    @StateObject private var viewModel = BlogViewModel()
    @State private var selectedCategory: BlogCategory = .all
    @State private var searchText: String = ""
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ZStack {
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search Bar
                    blogSearchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    // Category Filter
                    categoryFilterSection

                    // Blog Posts Content
                    if viewModel.isLoading {
                        BlogLoadingView()
                            .frame(maxHeight: .infinity)
                    } else if filteredPosts.isEmpty {
                        EnhancedEmptyBlogState(
                            isFiltered: selectedCategory != .all || !searchText.isEmpty
                        )
                        .frame(maxHeight: .infinity)
                    } else {
                        blogPostsScrollView
                    }
                }
            }
            .navigationTitle("tab.blog".localizedString)
            .navigationBarTitleDisplayMode(.large)
            .task {
                if viewModel.posts.isEmpty {
                    viewModel.fetchBlogPosts()
                }
            }
            .refreshable {
                viewModel.fetchBlogPosts()
            }
        }
    }

    // MARK: - Search Bar
    private var blogSearchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))
                .font(.body)

            TextField("blog.search_articles".localizedString, text: $searchText)
                .foregroundColor(.white)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    // MARK: - Category Filter
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(BlogCategory.allCases) { category in
                    EnhancedCategoryChip(
                        title: category.title,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        namespace: namespace,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Blog Posts Scroll View
    private var blogPostsScrollView: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                // Featured Post (first post)
                if let firstPost = filteredPosts.first {
                    NavigationLink(destination: EnhancedBlogPostDetailView(post: firstPost)) {
                        FeaturedBlogCard(post: firstPost)
                    }
                    .buttonStyle(.plain)
                }

                // Regular Posts
                ForEach(Array(filteredPosts.dropFirst())) { post in
                    NavigationLink(destination: EnhancedBlogPostDetailView(post: post)) {
                        EnhancedBlogPostCard(post: post)
                    }
                    .buttonStyle(.plain)
                }

                // Bottom padding for tab bar
                Color.clear.frame(height: 120)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Filtered Posts
    private var filteredPosts: [BlogPost] {
        var posts = viewModel.posts

        // Filter by category
        if selectedCategory != .all {
            posts = posts.filter { $0.category == selectedCategory.rawValue }
        }

        // Filter by search text
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespaces)
        if !trimmedSearch.isEmpty {
            posts = posts.filter {
                $0.title.localizedCaseInsensitiveContains(trimmedSearch) ||
                ($0.excerpt?.localizedCaseInsensitiveContains(trimmedSearch) ?? false) ||
                $0.content.localizedCaseInsensitiveContains(trimmedSearch)
            }
        }

        return posts
    }
}

#Preview {
    BlogPostListView()
        .environmentObject(LanguageManager())
}
