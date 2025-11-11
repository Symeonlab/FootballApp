import SwiftUI
import WebKit
import Combine

/// A modern, visually enhanced inline YouTube player using WKWebView.
/// Pass a YouTube `videoID` (not a full URL). The parent view controls sizing and clipping.
struct InlineYouTubeWebView: View {
    let videoID: String
    @State private var isLoading = true
    @State private var showPlayOverlay = true

    var body: some View {
        ZStack {
            // Gradient background while loading
            if isLoading {
                LinearGradient(
                    colors: [Color.theme.primary.opacity(0.3), Color.theme.accent.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("Loading video...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            YouTubeWebViewRepresentable(videoID: videoID, isLoading: $isLoading)
                .background(Color.black)
                .opacity(isLoading ? 0 : 1)
            
            // Play button overlay (appears before first play)
            if showPlayOverlay && !isLoading {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showPlayOverlay = false
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .offset(x: 3) // Optical centering
                    }
                }
                .buttonStyle(PlayButtonStyle())
            }
        }
        .accessibilityLabel("YouTube video player")
        .animation(.easeInOut(duration: 0.3), value: isLoading)
    }
}

// Custom button style for play button with scale effect
struct PlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - UIViewRepresentable
private struct YouTubeWebViewRepresentable: UIViewRepresentable {
    let videoID: String
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        // Allow autoplay without user gesture when muted; we are not auto-playing by default here.
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator

        loadHTML(in: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Reload only if the current videoID differs from what was last loaded.
        if context.coordinator.currentVideoID != videoID {
            loadHTML(in: webView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentVideoID: videoID, isLoading: $isLoading)
    }

    private func loadHTML(in webView: WKWebView) {
        let html = makeHTML(for: videoID)
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
        // Track the loaded video ID
        webView.evaluateJavaScript("void(0)") { _, _ in }
    }

    private func makeHTML(for id: String) -> String {
        // Enhanced responsive 16:9 container with better styling
        let iframeSrc = "https://www.youtube.com/embed/\(id)?playsinline=1&modestbranding=1&rel=0&controls=1&autoplay=0&enablejsapi=1"
        return """
        <!doctype html>
        <html>
        <head>
            <meta name=\"viewport\" content=\"initial-scale=1.0, maximum-scale=1.0, user-scalable=no, width=device-width\">
            <style>
                html, body { 
                    margin:0; 
                    padding:0; 
                    background: #000; 
                    overflow: hidden;
                }
                .wrap { 
                    position: relative; 
                    width: 100%; 
                    padding-top: 56.25%; /* 16:9 */
                    background: #000;
                }
                .wrap iframe { 
                    position: absolute; 
                    inset: 0; 
                    width: 100%; 
                    height: 100%; 
                    border: 0; 
                    border-radius: 0; 
                    background: #000; 
                }
            </style>
        </head>
        <body>
            <div class=\"wrap\">
                <iframe
                    src=\"\(iframeSrc)\"
                    title=\"YouTube video\"
                    allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\"
                    allowfullscreen
                ></iframe>
            </div>
        </body>
        </html>
        """
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, WKNavigationDelegate {
        var currentVideoID: String
        @Binding var isLoading: Bool
        
        init(currentVideoID: String, isLoading: Binding<Bool>) {
            self.currentVideoID = currentVideoID
            self._isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Mark loading as complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
            }
            
            // Keep track of what we've loaded to avoid unnecessary reloads in updateUIView
            if let url = webView.url, let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                if comps.path.contains("/embed/") {
                    if let id = comps.path.split(separator: "/").last {
                        currentVideoID = String(id)
                        return
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        InlineYouTubeWebView(videoID: "dQw4w9WgXcQ")
            .aspectRatio(16/9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding()
    }
}
