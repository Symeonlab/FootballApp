//
//  PropheticMedicineView.swift
//  DiPODDI
//
//  Browse prophetic medicine conditions and natural remedies
//

import SwiftUI

struct PropheticMedicineView: View {
    @StateObject private var viewModel = PropheticMedicineViewModel()
    @State private var selectedCondition: PropheticCondition?

    var body: some View {
        NavigationStack {
            ZStack {
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.isLoading && viewModel.conditions.isEmpty {
                            ProgressView().tint(.white)
                                .padding(.top, 40)
                        } else if let selected = selectedCondition {
                            // Remedy detail
                            remedyDetailView(for: selected)
                        } else {
                            // Condition list
                            conditionListView
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("prophetic.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if selectedCondition != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation {
                                selectedCondition = nil
                                viewModel.remedies = []
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("prophetic.all_conditions".localized)
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .task {
                await viewModel.fetchConditions()
            }
        }
    }

    // MARK: - Condition List

    private var conditionListView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.conditions) { condition in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCondition = condition
                    }
                    Task {
                        await viewModel.fetchRemedies(for: condition.conditionKey)
                    }
                } label: {
                    Card {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(condition.conditionName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("\(condition.remedyCount) " + "prophetic.remedies".localizedString)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green.opacity(0.7))
                                .font(.title2)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Remedy Detail

    private func remedyDetailView(for condition: PropheticCondition) -> some View {
        VStack(spacing: 12) {
            // Header
            Card {
                HStack {
                    Image(systemName: "leaf.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text(condition.conditionName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("\(condition.remedyCount) " + "prophetic.natural_remedies".localizedString)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
            }

            if viewModel.isLoading {
                ProgressView().tint(.white).padding(.top, 20)
            } else {
                ForEach(viewModel.remedies) { remedy in
                    RemedyCard(remedy: remedy)
                }
            }
        }
    }
}

// MARK: - Remedy Card

struct RemedyCard: View {
    let remedy: PropheticRemedy
    @State private var isExpanded = false

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                        Text(remedy.elementName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(alignment: .leading, spacing: 12) {
                        // Mechanism
                        VStack(alignment: .leading, spacing: 4) {
                            Text("prophetic.mechanism".localized)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                            Text(remedy.mechanism)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Divider().background(Color.white.opacity(0.15))

                        // Recipe
                        VStack(alignment: .leading, spacing: 4) {
                            Text("prophetic.recipe".localized)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Text(remedy.recipe)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        if let notes = remedy.notes, !notes.isEmpty {
                            Divider().background(Color.white.opacity(0.15))
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .italic()
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
