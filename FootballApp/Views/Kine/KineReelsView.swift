import SwiftUI
import AVKit

// MARK: - Modern Full-Screen Reels View
struct KineReelsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: KineViewModel
    let exercises: [APIExercise]
    
    @State private var currentIndex: Int = 0
    @State private var showInfo: Bool = false
    @State private var showTips: Bool = true
    @GestureState private var dragOffset: CGFloat = 0
    
    init(viewModel: KineViewModel, exercises: [APIExercise]) {
        self.viewModel = viewModel
        self.exercises = exercises
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Swipeable Reels
            TabView(selection: $currentIndex) {
                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                    ReelPlayerView(
                        exercise: exercise,
                        viewModel: viewModel,
                        showInfo: $showInfo,
                        currentIndex: $currentIndex,
                        totalCount: exercises.count
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Top Controls Overlay
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                    
                    Text("\(currentIndex + 1) / \(exercises.count)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding()
                .padding(.top, 8)
                
                Spacer()
            }
            
            // Onboarding Tips Overlay (shows on first launch)
            if showTips {
                ReelsTipsOverlay(showTips: $showTips)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(1000)
            }
        }
        .statusBarHidden()
        .onAppear {
            // Auto-hide tips after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showTips = false
                }
            }
        }
    }
}

// MARK: - Individual Reel Player
struct ReelPlayerView: View {
    let exercise: APIExercise
    @ObservedObject var viewModel: KineViewModel
    @Binding var showInfo: Bool
    @Binding var currentIndex: Int
    let totalCount: Int
    
    @State private var player: AVPlayer?
    @State private var isPlaying = true
    @State private var showControls = false
    @State private var showDescription = false
    
    private var isFavorite: Bool {
        viewModel.isFavorite(exerciseID: exercise.id)
    }
    
    var body: some View {
        ZStack {
            // Video Player Background
            if let urlString = exercise.video_url, let url = URL(string: urlString) {
                // Check if it's a YouTube URL
                if isYouTubeURL(urlString) {
                    // YouTube Thumbnail with Play Button
                    YouTubePreviewView(
                        exercise: exercise,
                        url: url,
                        onTap: {
                            openYouTubeVideo(url: url)
                        }
                    )
                } else {
                    // Regular video player for non-YouTube videos
                    VideoPlayer(player: player)
                        .ignoresSafeArea()
                        .onAppear {
                            setupPlayer(url: url)
                        }
                        .onDisappear {
                            cleanup()
                        }
                }
            } else {
                // Fallback for missing video
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "7B2CBF").opacity(0.6) as Color,
                            Color(hex: "9D4EDD").opacity(0.8) as Color
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "video.slash.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Video Not Available")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Tap to pause/play
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    togglePlayPause()
                }
            
            // Bottom Gradient for better text visibility
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7), .black.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300)
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
            
            // Content Overlay
            VStack {
                Spacer()
                
                HStack(alignment: .bottom, spacing: 16) {
                    // Left: Exercise Info
                    VStack(alignment: .leading, spacing: 12) {
                        // Exercise Name
                        Text(exercise.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .lineLimit(2)
                        
                        // Category Badge
                        if !exercise.category.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                Text(exercise.category)
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                        }
                        
                        // Show More Button
                        if let description = exercise.description, !description.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showDescription.toggle()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(showDescription ? "Show Less" : "Show More")
                                        .font(.subheadline.bold())
                                    Image(systemName: showDescription ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                            }
                        }
                        
                        // Expandable Description
                        if showDescription, let description = exercise.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineSpacing(4)
                                .padding()
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right: Action Buttons
                    VStack(spacing: 24) {
                        // Favorite Button
                        ActionButton(
                            icon: isFavorite ? "star.fill" : "star",
                            color: isFavorite ? .yellow : .white,
                            count: nil
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                viewModel.toggleFavorite(exerciseID: exercise.id)
                            }
                        }
                        
                        // Share Button
                        ActionButton(
                            icon: "square.and.arrow.up",
                            color: .white,
                            count: nil
                        ) {
                            shareExercise()
                        }
                        
                        // Info Button
                        ActionButton(
                            icon: "info.circle",
                            color: .white,
                            count: nil
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showInfo.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            
            // Play/Pause Indicator
            if showControls {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(30)
                    .background(.ultraThinMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            // Pause when scrolling away
            if oldValue != newValue {
                player?.pause()
            }
        }
    }
    
    private func setupPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        
        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    private func cleanup() {
        player?.pause()
        player = nil
    }
    
    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
        
        // Show control indicator
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showControls = true
        }
        
        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showControls = false
            }
        }
    }
    
    private func shareExercise() {
        // Implement share functionality
        let shareText = "Check out this exercise: \(exercise.name)"
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    // MARK: - YouTube Helpers
    
    private func isYouTubeURL(_ urlString: String) -> Bool {
        return urlString.contains("youtube.com") || urlString.contains("youtu.be")
    }
    
    private func openYouTubeVideo(url: URL) {
        // Try to open in YouTube app first, fallback to Safari
        var youtubeAppURL: URL?
        
        if url.absoluteString.contains("youtube.com/watch") {
            // Extract video ID from youtube.com/watch?v=VIDEO_ID
            if let videoID = extractYouTubeID(from: url.absoluteString) {
                youtubeAppURL = URL(string: "youtube://\(videoID)")
            }
        } else if url.absoluteString.contains("youtu.be/") {
            // Extract video ID from youtu.be/VIDEO_ID
            if let videoID = extractYouTubeID(from: url.absoluteString) {
                youtubeAppURL = URL(string: "youtube://\(videoID)")
            }
        }
        
        // Try YouTube app first
        if let appURL = youtubeAppURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else {
            // Fallback to Safari
            UIApplication.shared.open(url)
        }
    }
    
    private func extractYouTubeID(from urlString: String) -> String? {
        // Extract from youtube.com/watch?v=VIDEO_ID
        if let range = urlString.range(of: "v=") {
            let idString = String(urlString[range.upperBound...])
            let endIndex = idString.firstIndex(of: "&") ?? idString.endIndex
            return String(idString[..<endIndex])
        }
        
        // Extract from youtu.be/VIDEO_ID
        if let range = urlString.range(of: "youtu.be/") {
            let idString = String(urlString[range.upperBound...])
            let endIndex = idString.firstIndex(of: "?") ?? idString.endIndex
            return String(idString[..<endIndex])
        }
        
        return nil
    }
}

// MARK: - YouTube Preview View
struct YouTubePreviewView: View {
    let exercise: APIExercise
    let url: URL
    let onTap: () -> Void
    
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "1A0B2E"),
                    Color(hex: "7B2CBF"),
                    Color(hex: "9D4EDD")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Thumbnail if available
            if let thumbnail = thumbnailImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            }
            
            // Dark overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Play button overlay
            VStack(spacing: 24) {
                // Large YouTube play button
                Button(action: onTap) {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 100, height: 100)
                            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .offset(x: 4) // Slight offset to center visually
                    }
                }
                
                VStack(spacing: 12) {
                    Text("Watch on YouTube")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text("Tap to open in YouTube app or browser")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            loadYouTubeThumbnail()
        }
    }
    
    private func loadYouTubeThumbnail() {
        guard let videoID = extractVideoID(from: url.absoluteString) else { return }
        
        // Try to load thumbnail from YouTube
        let thumbnailURLString = "https://img.youtube.com/vi/\(videoID)/maxresdefault.jpg"
        
        if let thumbnailURL = URL(string: thumbnailURLString) {
            URLSession.shared.dataTask(with: thumbnailURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.thumbnailImage = image
                    }
                }
            }.resume()
        }
    }
    
    private func extractVideoID(from urlString: String) -> String? {
        // Extract from youtube.com/watch?v=VIDEO_ID
        if let range = urlString.range(of: "v=") {
            let idString = String(urlString[range.upperBound...])
            let endIndex = idString.firstIndex(of: "&") ?? idString.endIndex
            return String(idString[..<endIndex])
        }
        
        // Extract from youtu.be/VIDEO_ID
        if let range = urlString.range(of: "youtu.be/") {
            let idString = String(urlString[range.upperBound...])
            let endIndex = idString.firstIndex(of: "?") ?? idString.endIndex
            return String(idString[..<endIndex])
        }
        
        return nil
    }
}

// MARK: - Action Button Component
struct ActionButton: View {
    let icon: String
    let color: Color
    let count: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                if let count = count {
                    Text("\(count)")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
    }
}

// MARK: - Tips Overlay
struct ReelsTipsOverlay: View {
    @Binding var showTips: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("How to Use Reels")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Learn the gestures")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Tips
                VStack(spacing: 24) {
                    TipRow(
                        icon: "arrow.up.arrow.down",
                        title: "Swipe Up/Down",
                        description: "Navigate between exercises"
                    )
                    
                    TipRow(
                        icon: "hand.tap",
                        title: "Tap to Pause",
                        description: "Pause or resume the video"
                    )
                    
                    TipRow(
                        icon: "star.fill",
                        title: "Favorite",
                        description: "Save exercises for quick access"
                    )
                    
                    TipRow(
                        icon: "square.and.arrow.up",
                        title: "Share",
                        description: "Share with your team"
                    )
                }
                .padding(.horizontal, 32)
                
                // Got It Button
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showTips = false
                    }
                } label: {
                    Text("Got It!")
                        .font(.headline.bold())
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
            }
            .padding(.vertical, 40)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showTips = false
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.white.opacity(0.2)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

