//
//  DashboardViewModel.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import Foundation
import Combine // <-- 1. ADD THIS IMPORT
import SwiftUI // <-- 2. ADD THIS IMPORT

class DashboardViewModel: ObservableObject {
    @Published var metrics: DashboardMetrics?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDashboardMetrics() {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.request(endpoint: "/api/dashboard-metrics", method: "GET")
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { (metrics: DashboardMetrics) in
                self.metrics = metrics
            })
            .store(in: &cancellables)
    }
}
