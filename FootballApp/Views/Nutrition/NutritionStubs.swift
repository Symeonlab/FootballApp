#if false
import SwiftUI
import Combine

// Minimal NutritionPlan stub to satisfy compiler. Replace with your real model.
struct NutritionPlan: Identifiable {
    let id = UUID()
    var daily_calorie_intake: Double = 2000
    var protein_per_day: Double = 120
    var carbs_per_day: Double = 220
    var fat_per_day: Double = 70
    var advice: [String]? = ["Stay hydrated", "Balance macros"]
}

// Minimal ViewModel stub if missing elsewhere; comment out if you already have one.
final class NutritionViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var nutritionPlan: NutritionPlan? = NutritionPlan()
    func fetchNutritionPlan() { /* hook up real fetching */ }
}

// Minimal reels wrapper placeholder to satisfy fullScreenCover
struct NutritionReelsViewWrapper: View {
    let plan: NutritionPlan
    @Binding var isPresented: Bool
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Nutrition Reels")
                    .font(.title.bold())
                Text("Tips & Recipes for your plan")
                    .foregroundColor(.secondary)
                Button("Close") { isPresented = false }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Reels")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#endif
