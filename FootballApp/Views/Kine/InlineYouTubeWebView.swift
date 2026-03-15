import SwiftUI
import WebKit
import SafariServices

/// A YouTube player view that uses the most reliable method for iOS playback.
/// Pass a YouTube `videoID` (not a full URL). The parent view controls sizing and clipping.
public struct InlineYouTubeWebView: View {
    public let videoID: String
    public let autoPlay: Bool

    @State private var isLoading = true
    @State private var hasError = false
    @State private var showSafari = false

    // Explicit public initializer to ensure proper linking
    public init(videoID: String, autoPlay: Bool = false) {
        self.videoID = videoID
        self.autoPlay = autoPlay
    }

    // Clean the video ID
    private var cleanVideoID: String {
        var cleanID = videoID.components(separatedBy: CharacterSet(charactersIn: "?&")).first ?? videoID
        cleanID = cleanID.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return cleanID
    }

    // YouTube thumbnail URL
    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(cleanVideoID)/hqdefault.jpg")
    }

    // YouTube watch URL for Safari
    private var youtubeWatchURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(cleanVideoID)")
    }

    public var body: some View {
        ZStack {
            // Thumbnail background
            if let thumbnailURL = thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        gradientPlaceholder
                    }
                }
            } else {
                gradientPlaceholder
            }

            // Dark overlay
            Color.black.opacity(0.3)

            // Play button
            Button(action: {
                print("🎬 Opening YouTube video: \(cleanVideoID)")
                showSafari = true
            }) {
                ZStack {
                    // YouTube-style red play button
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.red)
                        .frame(width: 68, height: 48)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 2)
                }
            }
            .buttonStyle(ScaleButtonStyle())

            // YouTube logo badge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("YouTube")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(8)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .fullScreenCover(isPresented: $showSafari) {
            if let url = youtubeWatchURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    private var gradientPlaceholder: some View {
        LinearGradient(
            colors: [Color.theme.primary.opacity(0.3), Color.theme.accent.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Safari View Controller Wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true

        let safari = SFSafariViewController(url: url, configuration: config)
        safari.dismissButtonStyle = .close

        return safari
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Embedded WebView Player (for inline autoplay)
/// Plays YouTube videos inline using a WKWebView embed with autoplay support.
/// Falls back to a thumbnail + Safari if the embed fails.
public struct EmbeddedYouTubePlayer: View {
    public let videoID: String
    public let autoPlay: Bool

    @State private var isLoading = true
    @State private var hasError = false
    @State private var showSafari = false

    public init(videoID: String, autoPlay: Bool = false) {
        self.videoID = videoID
        self.autoPlay = autoPlay
    }

    private var cleanVideoID: String {
        var cleanID = videoID.components(separatedBy: CharacterSet(charactersIn: "?&")).first ?? videoID
        cleanID = cleanID.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return cleanID
    }

    private var youtubeWatchURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(cleanVideoID)")
    }

    public var body: some View {
        ZStack {
            // Always render the WebView underneath for smooth loading
            if !hasError {
                YouTubeEmbedWebView(
                    videoID: cleanVideoID,
                    autoPlay: autoPlay,
                    isLoading: $isLoading,
                    hasError: $hasError
                )
            }

            // Loading overlay with thumbnail
            if isLoading && !hasError {
                ZStack {
                    AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(cleanVideoID)/maxresdefault.jpg")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            LinearGradient(
                                colors: [Color(hex: "1A0B2E"), Color(hex: "2D1B69")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                    Color.black.opacity(0.35)

                    // Loading indicator
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.1)
                        Text("kine.loading_video".localizedString)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }

            // Error state - thumbnail with play button to open in Safari
            if hasError {
                ZStack {
                    AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(cleanVideoID)/hqdefault.jpg")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            LinearGradient(
                                colors: [Color(hex: "1A0B2E"), Color(hex: "2D1B69")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }

                    Color.black.opacity(0.5)

                    VStack(spacing: 14) {
                        Button(action: { showSafari = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: .red.opacity(0.4), radius: 12, x: 0, y: 6)

                                Image(systemName: "play.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: 2)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())

                        Text("kine.tap_to_watch".localizedString)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .background(Color.black)
        .animation(.easeInOut(duration: 0.3), value: isLoading)
        .animation(.easeInOut(duration: 0.3), value: hasError)
        .fullScreenCover(isPresented: $showSafari) {
            if let url = youtubeWatchURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

// MARK: - WebView for Embedded Player
private struct YouTubeEmbedWebView: UIViewRepresentable {
    let videoID: String
    let autoPlay: Bool
    @Binding var isLoading: Bool
    @Binding var hasError: Bool

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        print("🎬 YouTube Embed: Loading video ID: \(videoID)")
        loadVideo(in: webView)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.currentVideoID != videoID {
            context.coordinator.currentVideoID = videoID
            loadVideo(in: webView)
        }
    }

    private func loadVideo(in webView: WKWebView) {
        // Build embed URL with autoplay + mute (iOS requires muted for autoplay)
        // Loop the video, hide related, enable JS API
        var params = "playsinline=1&rel=0&controls=1&fs=1&modestbranding=1&enablejsapi=1&iv_load_policy=3"
        params += "&origin=https://www.youtube-nocookie.com"
        if autoPlay {
            params += "&autoplay=1&mute=1&loop=1&playlist=\(videoID)"
        }
        let embedURL = "https://www.youtube-nocookie.com/embed/\(videoID)?\(params)"
        if let url = URL(string: embedURL) {
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentVideoID: videoID, isLoading: $isLoading, hasError: $hasError)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var currentVideoID: String
        @Binding var isLoading: Bool
        @Binding var hasError: Bool

        init(currentVideoID: String, isLoading: Binding<Bool>, hasError: Binding<Bool>) {
            self.currentVideoID = currentVideoID
            self._isLoading = isLoading
            self._hasError = hasError
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ YouTube Embed: Loaded video \(currentVideoID)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == -999 || nsError.code == 102 { return }
            print("⚠️ YouTube Embed failed: \(error.localizedDescription)")
            isLoading = false
            hasError = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            if nsError.code == -999 || nsError.code == 102 { return }
            print("⚠️ YouTube Embed provisional failed: \(error.localizedDescription)")
            isLoading = false
            hasError = true
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.request.url != nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("kine.tap_to_watch".localizedString)
            .foregroundColor(.white)

        InlineYouTubeWebView(videoID: "dQw4w9WgXcQ")
            .aspectRatio(16/9, contentMode: .fit)
            .padding()
    }
    .background(Color.black)
}
