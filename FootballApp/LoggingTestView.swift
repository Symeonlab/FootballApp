//
//  LoggingTestView.swift
//  FootballApp
//
//  A simple view to test that logging is working correctly
//

import SwiftUI
import os.log

struct LoggingTestView: View {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "LoggingTest")
    
    @State private var testCount = 0
    @State private var logMessages: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Logging Test")
                            .font(.title.bold())
                        
                        Text("Check Xcode Debug Console (Cmd+Shift+Y)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Test Buttons
                    VStack(spacing: 16) {
                        TestButton(
                            title: "Test Info Log",
                            icon: "info.circle.fill",
                            color: .blue
                        ) {
                            testCount += 1
                            let message = "ℹ️ Info log test #\(testCount)"
                            logger.info("ℹ️ Info log test #\(testCount)")
                            print("🔵 PRINT: Info log test #\(testCount)")
                            logMessages.append(message)
                        }
                        
                        TestButton(
                            title: "Test Debug Log",
                            icon: "ant.circle.fill",
                            color: .green
                        ) {
                            testCount += 1
                            let message = "🐛 Debug log test #\(testCount)"
                            logger.debug("🐛 Debug log test #\(testCount)")
                            print("🟢 PRINT: Debug log test #\(testCount)")
                            logMessages.append(message)
                        }
                        
                        TestButton(
                            title: "Test Warning Log",
                            icon: "exclamationmark.triangle.fill",
                            color: .orange
                        ) {
                            testCount += 1
                            let message = "⚠️ Warning log test #\(testCount)"
                            logger.warning("⚠️ Warning log test #\(testCount)")
                            print("🟠 PRINT: Warning log test #\(testCount)")
                            logMessages.append(message)
                        }
                        
                        TestButton(
                            title: "Test Error Log",
                            icon: "xmark.circle.fill",
                            color: .red
                        ) {
                            testCount += 1
                            let message = "❌ Error log test #\(testCount)"
                            logger.error("❌ Error log test #\(testCount)")
                            print("🔴 PRINT: Error log test #\(testCount)")
                            logMessages.append(message)
                        }
                        
                        TestButton(
                            title: "Test Success Log",
                            icon: "checkmark.circle.fill",
                            color: .green
                        ) {
                            testCount += 1
                            let message = "✅ Success log test #\(testCount)"
                            logger.info("✅ Success log test #\(testCount)")
                            print("🟢 PRINT: Success log test #\(testCount)")
                            logMessages.append(message)
                        }
                        
                        TestButton(
                            title: "Test API Log",
                            icon: "network",
                            color: .purple
                        ) {
                            testCount += 1
                            let message = "🚀 [GET] /api/test - Test API call #\(testCount)"
                            logger.info("🚀 [GET] /api/test - Test API call #\(testCount)")
                            print("🟣 PRINT: API call test #\(testCount)")
                            logMessages.append(message)
                        }
                        
                        TestButton(
                            title: "Test Data Fetch Log",
                            icon: "arrow.down.circle.fill",
                            color: .cyan
                        ) {
                            testCount += 1
                            let message = "📥 Fetching data... Test #\(testCount)"
                            logger.info("📥 Fetching data... Test #\(testCount)")
                            print("🔵 PRINT: Data fetch test #\(testCount)")
                            logMessages.append(message)
                            
                            // Simulate success after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                let successMessage = "✅ Data loaded successfully! Test #\(testCount)"
                                logger.info("✅ Data loaded successfully! Test #\(testCount)")
                                print("🟢 PRINT: Data loaded successfully! Test #\(testCount)")
                                logMessages.append(successMessage)
                            }
                        }
                        
                        // Clear button
                        Button(action: {
                            logMessages.removeAll()
                            testCount = 0
                            logger.info("🧹 Logs cleared")
                            print("🔵 PRINT: Logs cleared")
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Clear Logs")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions:")
                            .font(.headline)
                        
                        InstructionRow(
                            number: "1",
                            text: "Open Debug Console (Cmd+Shift+Y)"
                        )
                        
                        InstructionRow(
                            number: "2",
                            text: "Tap any button above"
                        )
                        
                        InstructionRow(
                            number: "3",
                            text: "Look for colored emoji logs in console"
                        )
                        
                        InstructionRow(
                            number: "4",
                            text: "Search for emojis: 🚀 ✅ ❌ 📥"
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    )
                    .padding(.horizontal)
                    
                    // Log History
                    if !logMessages.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Logs (\(logMessages.count)):")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                ForEach(logMessages.reversed().prefix(10), id: \.self) { message in
                                    HStack {
                                        Text(message)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray6))
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle("Logging Test")
            .onAppear {
                logger.info("👁️ LoggingTestView appeared")
                print("🔵 PRINT: LoggingTestView appeared")
                logMessages.append("👁️ View appeared")
            }
        }
    }
}

// MARK: - Supporting Views

private struct TestButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(color)
            .cornerRadius(12)
        }
    }
}

private struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 24, height: 24)
                
                Text(number)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    LoggingTestView()
}

// MARK: - How to Use This Test View

/*
 
 To test logging in your app:
 
 1. Add this view to your navigation (temporarily):
 
    In MainTabView.swift or any navigation:
    
    NavigationLink("Test Logging") {
        LoggingTestView()
    }
 
 2. Or create a test preview:
 
    #Preview {
        LoggingTestView()
    }
 
 3. Run the app on simulator (Cmd+R)
 
 4. Open Debug Console (Cmd+Shift+Y)
 
 5. Tap the test buttons and watch logs appear!
 
 Expected output in console:
 
 🔵 PRINT: LoggingTestView appeared
 ℹ️ Info log test #1
 🔵 PRINT: Info log test #1
 ✅ Success log test #2
 🟢 PRINT: Success log test #2
 ❌ Error log test #3
 🔴 PRINT: Error log test #3
 
 If you see the PRINT messages but not the logger messages:
 - Check Console.app instead of Xcode console
 - Make sure you imported os.log
 - Verify bundle identifier is correct
 
 */
