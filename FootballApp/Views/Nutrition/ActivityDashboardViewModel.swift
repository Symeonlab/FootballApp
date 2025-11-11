import Foundation
import Combine

final class ActivityDashboardViewModel: ObservableObject {
    @Published var healthData = HealthData()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchHealthData() {
        // TODO: Hook up to HealthKit or API. Provide placeholder values for now.
        healthData.steps = 5234
        healthData.activeCalories = 320
        healthData.exerciseMinutes = 18
        healthData.distance = 3.7
        healthData.heartRate = 72
    }
}
