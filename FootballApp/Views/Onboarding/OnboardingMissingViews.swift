#if DEBUG && false
import SwiftUI

struct OnboardingIntroView: View {
    @Binding var selection: Int
    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to your training!").font(.title)
            Text("Let's personalize your experience.")
            Button("Get Started") { withAnimation { selection += 1 } }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct GenderSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        VStack(spacing: 16) {
            Text("Select your gender").font(.headline)
            HStack {
                Button("Male") { viewModel.data.gender = "HOMME" }
                Button("Female") { viewModel.data.gender = "FEMME" }
            }
            Button("Next") { withAnimation { selection += 1 } }
                .disabled(viewModel.data.gender == nil)
        }
        .padding()
    }
}

struct HeightAndWeightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        VStack(spacing: 16) {
            Text("Height & Weight").font(.headline)
            Stepper("Height: \(Int(viewModel.data.height ?? 170)) cm", value: Binding(
                get: { Int(viewModel.data.height ?? 170) },
                set: { viewModel.data.height = Double($0) }
            ), in: 120...220)
            Stepper("Weight: \(Int(viewModel.data.weight ?? 70)) kg", value: Binding(
                get: { Int(viewModel.data.weight ?? 70) },
                set: { viewModel.data.weight = Double($0) }
            ), in: 30...200)
            Button("Next") { withAnimation { selection += 1 } }
        }
        .padding()
    }
}

struct FitnessLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        VStack(spacing: 16) {
            Text("Fitness Level").font(.headline)
            HStack {
                Button("Beginner") { viewModel.data.level = "BEGINNER" }
                Button("Advanced") { viewModel.data.level = "ADVANCED" }
            }
            Button("Next") { withAnimation { selection += 1 } }
                .disabled(viewModel.data.level == nil)
        }
        .padding()
    }
}

struct TrainingLocationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        VStack(spacing: 16) {
            Text("Training Location").font(.headline)
            HStack {
                Button("Gym") { viewModel.data.training_location = "GYM" }
                Button("Home") { viewModel.data.training_location = "HOME" }
            }
            Button("Next") { withAnimation { selection += 1 } }
                .disabled(viewModel.data.training_location == nil)
        }
        .padding()
    }
}

struct TrainingDaysSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    private let days = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    var body: some View {
        VStack(spacing: 16) {
            Text("Training Days").font(.headline)
            WrapHStack(items: days) { day in
                Button(day) {
                    var set = Set(viewModel.data.training_days ?? [])
                    if set.contains(day) { set.remove(day) } else { set.insert(day) }
                    viewModel.data.training_days = Array(set)
                }
            }
            Button("Next") { withAnimation { selection += 1 } }
                .disabled((viewModel.data.training_days ?? []).isEmpty)
        }
        .padding()
    }
}

struct TrainingPreferencesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        VStack(spacing: 16) {
            Text("Preferences").font(.headline)
            Toggle("Cardio", isOn: Binding(
                get: { (viewModel.data.cardio_preferences ?? []).contains("CARDIO") },
                set: { newValue in
                    var prefs = Set(viewModel.data.cardio_preferences ?? [])
                    if newValue { prefs.insert("CARDIO") } else { prefs.remove("CARDIO") }
                    viewModel.data.cardio_preferences = Array(prefs)
                }
            ))
            Button("Next") { withAnimation { selection += 1 } }
        }
        .padding()
    }
}

struct WrapHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }
    var body: some View {
        FlowLayout(items: items, content: content)
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    @State private var totalHeight: CGFloat = .zero
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .padding(6)
                    .background(Capsule().stroke())
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == items.last { width = 0 } else { width -= d.width }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last { height = 0 }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            DispatchQueue.main.async { binding.wrappedValue = geometry.size.height }
            return Color.clear
        }
    }
}
#endif
