import SwiftUI

struct TrainingDaysSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    @State private var days: [String] = []
    @State private var matchDay: String = "AUCUN"
    
    private var allDays: [String] = ["LUNDI", "MARDI", "MERCREDI", "JEUDI", "VENDREDI", "SAMEDI", "DIMANCHE"]

    private func localizedDayName(for day: String) -> String {
        switch day {
        case "LUNDI":    return "common.days.monday".localizedString
        case "MARDI":    return "common.days.tuesday".localizedString
        case "MERCREDI": return "common.days.wednesday".localizedString
        case "JEUDI":    return "common.days.thursday".localizedString
        case "VENDREDI": return "common.days.friday".localizedString
        case "SAMEDI":   return "common.days.saturday".localizedString
        case "DIMANCHE": return "common.days.sunday".localizedString
        default:         return day
        }
    }
    
    init(viewModel: OnboardingViewModel, selection: Binding<Int>) {
        self.viewModel = viewModel
        self._selection = selection
    }

    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.training_days.title",
            subtitleKey: "onboarding.training_days.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: !days.isEmpty,
            action: {
                viewModel.data.trainingDays = days
                viewModel.data.matchDay = matchDay
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "onboarding.training_days.select"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(allDays, id: \.self) { day in
                        MultiSelectionButton(
                            title: localizedDayName(for: day),
                            isSelected: days.contains(day),
                            action: {
                                if days.contains(day) {
                                    days.removeAll { $0 == day }
                                } else {
                                    days.append(day)
                                }
                            }
                        )
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "onboarding.match_day.title"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Picker("onboarding.match_day".localized, selection: $matchDay) {
                        Text("common.none".localizedString).tag("AUCUN")
                        ForEach(allDays, id: \.self) { day in
                            Text(localizedDayName(for: day)).tag(day)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color.theme.surface)
                    .cornerRadius(12)
                }
            }
        }
        .onAppear {
            self.days = viewModel.data.trainingDays ?? []
            self.matchDay = viewModel.data.matchDay ?? "AUCUN"
        }
    }
}


