import SwiftUI
import AVKit
import SafariServices
import WebKit

// MARK: - Modern Full-Screen Reels View
struct KineReelsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: KineViewModel
    let exercises: [APIExercise]

    @State private var currentIndex: Int = 0
    @State private var showInfo: Bool = false
    @State private var showTips: Bool = false
    @GestureState private var dragOffset: CGFloat = 0

    // Key for storing tutorial shown state
    private static let tutorialShownKey = "kine_reels_tutorial_shown"

    init(viewModel: KineViewModel, exercises: [APIExercise]) {
        self.viewModel = viewModel
        self.exercises = exercises

        // Check if tutorial has been shown before
        let hasSeenTutorial = UserDefaults.standard.bool(forKey: KineReelsView.tutorialShownKey)
        _showTips = State(initialValue: !hasSeenTutorial)
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

            // Onboarding Tips Overlay (shows only on first launch)
            if showTips {
                ReelsTipsOverlay(showTips: $showTips, onDismiss: {
                    // Mark tutorial as shown when dismissed
                    UserDefaults.standard.set(true, forKey: KineReelsView.tutorialShownKey)
                })
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .zIndex(1000)
            }
        }
        .statusBarHidden()
        .onAppear {
            // Auto-hide tips after 5 seconds (only if showing)
            if showTips {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showTips = false
                        // Mark tutorial as shown
                        UserDefaults.standard.set(true, forKey: KineReelsView.tutorialShownKey)
                    }
                }
            }
        }
    }
}

// MARK: - Individual Reel Player (TikTok/Reels Style)
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
    @State private var showSafariPlayer = false
    @State private var hasVideoError = false

    private var isFavorite: Bool {
        viewModel.isFavorite(exerciseID: exercise.id)
    }

    var body: some View {
        ZStack {
            // Video Player Background - Full Screen TikTok Style
            if let urlString = exercise.video_url, !urlString.isEmpty {
                // Check if it's a YouTube URL
                if urlString.isYouTubeURL, let videoID = urlString.youTubeVideoID {
                    // Use inline auto-playing YouTube player (like TikTok/Reels)
                    KineInlineYouTubePlayer(
                        videoID: videoID,
                        hasError: $hasVideoError,
                        onTapFullscreen: { showSafariPlayer = true }
                    )
                    .ignoresSafeArea()
                } else if let url = URL(string: urlString) {
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
                        Text("video.unavailable".localizedString)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }
                }
            }

            // Bottom Gradient for better text visibility
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5), .black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()

            // Content Overlay - TikTok Style Layout
            VStack {
                Spacer()

                HStack(alignment: .bottom, spacing: 12) {
                    // Left: Exercise Info
                    VStack(alignment: .leading, spacing: 10) {
                        // Exercise Name
                        Text(exercise.name)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                            .lineLimit(2)

                        // Category Badge
                        if !exercise.category.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .font(.caption2)
                                Text(exercise.category)
                                    .font(.caption.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2), in: Capsule())
                        }

                        // Show More Button
                        if let description = exercise.description, !description.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showDescription.toggle()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(showDescription ? "common.show_less".localizedString : "common.show_more".localizedString)
                                        .font(.caption.bold())
                                    Image(systemName: showDescription ? "chevron.up" : "chevron.down")
                                        .font(.caption2)
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                        }

                        // Expandable Description
                        if showDescription, let description = exercise.description {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(3)
                                .padding(10)
                                .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Right: Action Buttons (TikTok Style - Vertical)
                    VStack(spacing: 20) {
                        // Fullscreen/YouTube Button
                        if let urlString = exercise.video_url, urlString.isYouTubeURL {
                            ReelActionButton(
                                icon: "play.rectangle.fill",
                                label: "YouTube",
                                color: .red
                            ) {
                                showSafariPlayer = true
                            }
                        }

                        // Favorite Button
                        ReelActionButton(
                            icon: isFavorite ? "heart.fill" : "heart",
                            label: isFavorite ? "kine.favorited".localizedString : "kine.favorite".localizedString,
                            color: isFavorite ? .red : .white
                        ) {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                viewModel.toggleFavorite(exerciseID: exercise.id)
                            }
                        }

                        // Share Button
                        ReelActionButton(
                            icon: "paperplane.fill",
                            label: "common.share".localizedString,
                            color: .white
                        ) {
                            shareExercise()
                        }

                        // Info Button
                        ReelActionButton(
                            icon: "info.circle.fill",
                            label: "Info",
                            color: .white
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showInfo.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 36)
            }
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            // Pause when scrolling away
            if oldValue != newValue {
                player?.pause()
            }
        }
        .fullScreenCover(isPresented: $showSafariPlayer) {
            if let urlString = exercise.video_url,
               let videoID = urlString.youTubeVideoID,
               let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
                KineSafariView(url: url)
                    .ignoresSafeArea()
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
        let shareText = "kine.share_text".localizedString(with: exercise.name)
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
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
                    Text("workout.watch_on_youtube".localizedString)
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Text("workout.tap_youtube".localizedString)
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
        guard let videoID = url.absoluteString.youTubeVideoID else { return }
        
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

// MARK: - Tips Overlay (Localized, One-Time)
struct ReelsTipsOverlay: View {
    @Binding var showTips: Bool
    var onDismiss: (() -> Void)? = nil

    private func dismissTips() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showTips = false
        }
        onDismiss?()
    }

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

                    Text("kine.reels.tutorial.title".localizedString)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("kine.reels.tutorial.subtitle".localizedString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                // Tips
                VStack(spacing: 24) {
                    TipRow(
                        icon: "arrow.up.arrow.down",
                        title: "kine.reels.tutorial.swipe.title".localizedString,
                        description: "kine.reels.tutorial.swipe.description".localizedString
                    )

                    TipRow(
                        icon: "play.circle.fill",
                        title: "kine.reels.tutorial.tap.title".localizedString,
                        description: "kine.reels.tutorial.tap.description".localizedString
                    )

                    TipRow(
                        icon: "star.fill",
                        title: "kine.reels.tutorial.favorite.title".localizedString,
                        description: "kine.reels.tutorial.favorite.description".localizedString
                    )

                    TipRow(
                        icon: "square.and.arrow.up",
                        title: "kine.reels.tutorial.share.title".localizedString,
                        description: "kine.reels.tutorial.share.description".localizedString
                    )
                }
                .padding(.horizontal, 32)

                // Got It Button
                Button {
                    dismissTips()
                } label: {
                    Text("kine.reels.tutorial.got_it".localizedString)
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
            dismissTips()
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

// MARK: - Safari View for YouTube (Kine)
struct KineSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true

        let safari = SFSafariViewController(url: url, configuration: config)
        safari.dismissButtonStyle = .close

        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - YouTube Thumbnail View for Kine
/// Full-screen YouTube thumbnail that fits the frame and opens Safari on tap
struct KineYouTubeThumbnailView: View {
    let videoID: String
    let onTap: () -> Void

    // Use maxresdefault for highest quality, with fallback
    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/maxresdefault.jpg")
    }

    private var fallbackThumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen thumbnail background
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    case .failure:
                        // Fallback to lower quality thumbnail
                        AsyncImage(url: fallbackThumbnailURL) { fallbackPhase in
                            switch fallbackPhase {
                            case .success(let fallbackImage):
                                fallbackImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                            default:
                                gradientPlaceholder
                            }
                        }
                    case .empty:
                        ZStack {
                            gradientPlaceholder
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                        }
                    @unknown default:
                        gradientPlaceholder
                    }
                }

                // Subtle dark overlay
                Color.black.opacity(0.2)

                // Centered play button
                Button(action: onTap) {
                    ZStack {
                        // Red YouTube-style play button
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.red)
                            .frame(width: 80, height: 56)
                            .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)

                        Image(systemName: "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: 2)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .ignoresSafeArea()
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [
                Color(hex: "7B2CBF").opacity(0.6),
                Color(hex: "9D4EDD").opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - TikTok-Style Action Button
struct ReelActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(color)
                    .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Inline YouTube Player for Kine (Auto-playing, Looping)
struct KineInlineYouTubePlayer: View {
    let videoID: String
    @Binding var hasError: Bool
    var onTapFullscreen: () -> Void

    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/maxresdefault.jpg")
    }

    var body: some View {
        ZStack {
            if hasError {
                // Fallback: Show thumbnail with play button
                KineYouTubeThumbnailView(
                    videoID: videoID,
                    onTap: onTapFullscreen
                )
            } else {
                // Auto-playing inline YouTube player
                KineInlineYouTubeWebView(videoID: videoID, hasError: $hasError)
            }
        }
    }
}

// MARK: - WebView for YouTube Embedding (Auto-play, Loop, Muted)
private struct KineInlineYouTubeWebView: UIViewRepresentable {
    let videoID: String
    @Binding var hasError: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(hasError: $hasError)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        webConfiguration.defaultWebpagePreferences = preferences

        // Add message handler for error detection
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "errorHandler")
        webConfiguration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.navigationDelegate = context.coordinator

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Full-screen YouTube embed with auto-play, loop, and muted
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; }
                html, body {
                    width: 100%;
                    height: 100%;
                    background: #000;
                    overflow: hidden;
                }
                .video-container {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                }
                iframe {
                    position: absolute;
                    top: 50%;
                    left: 50%;
                    width: 177.78vh;
                    height: 100vh;
                    min-width: 100%;
                    min-height: 56.25vw;
                    transform: translate(-50%, -50%);
                    border: none;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe id="player"
                    src="https://www.youtube-nocookie.com/embed/\(videoID)?autoplay=1&mute=1&loop=1&playlist=\(videoID)&playsinline=1&controls=0&showinfo=0&rel=0&modestbranding=1&iv_load_policy=3&disablekb=1&enablejsapi=1&origin=https://www.youtube-nocookie.com"
                    allow="autoplay; encrypted-media; picture-in-picture"
                    allowfullscreen>
                </iframe>
            </div>
            <script>
                var iframe = document.getElementById('player');
                iframe.onerror = function() {
                    window.webkit.messageHandlers.errorHandler.postMessage('error');
                };
                setTimeout(function() {
                    try {
                        if (!iframe.contentWindow || iframe.contentWindow.length === 0) {
                            window.webkit.messageHandlers.errorHandler.postMessage('timeout');
                        }
                    } catch(e) {
                        window.webkit.messageHandlers.errorHandler.postMessage('blocked');
                    }
                }, 5000);
            </script>
        </body>
        </html>
        """

        webView.loadHTMLString(embedHTML, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        @Binding var hasError: Bool

        init(hasError: Binding<Bool>) {
            _hasError = hasError
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "errorHandler" {
                DispatchQueue.main.async {
                    self.hasError = true
                }
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code != -999 && nsError.code != 102 {
                DispatchQueue.main.async {
                    self.hasError = true
                }
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code != -999 && nsError.code != 102 {
                DispatchQueue.main.async {
                    self.hasError = true
                }
            }
        }
    }
}

