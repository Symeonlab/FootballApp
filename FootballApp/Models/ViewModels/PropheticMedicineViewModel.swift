//
//  PropheticMedicineViewModel.swift
//  FootballApp
//
//  ViewModel for managing prophetic medicine conditions and remedies
//

import Foundation
import Combine
import os

@MainActor
class PropheticMedicineViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "PropheticMedicineViewModel")

    // MARK: - Published Properties
    @Published var conditions: [PropheticCondition] = []
    @Published var remedies: [PropheticRemedy] = []
    @Published var selectedCondition: PropheticCondition?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties
    private let apiService = APIService.shared

    // MARK: - Fetch Methods

    func fetchConditions() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: GenericAPIResponse<[PropheticCondition]> = try await apiService.request(endpoint: APIEndpoints.propheticMedicine)
            self.conditions = response.data
            logger.info("Fetched \(self.conditions.count) prophetic conditions")
        } catch {
            logger.error("Failed to fetch prophetic conditions: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchRemedies(for conditionKey: String) async {
        isLoading = true
        do {
            let endpoint = "\(APIEndpoints.propheticMedicine)/\(conditionKey)"
            let response: GenericAPIResponse<[PropheticRemedy]> = try await apiService.request(endpoint: endpoint)
            self.remedies = response.data
            logger.info("Fetched \(self.remedies.count) remedies for \(conditionKey)")
        } catch {
            logger.error("Failed to fetch remedies for \(conditionKey): \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
