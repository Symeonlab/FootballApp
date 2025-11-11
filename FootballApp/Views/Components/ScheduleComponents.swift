//
//  ScheduleComponents.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.theme.primary : Color.theme.surface)
                .cornerRadius(16)
        }
    }
}

// MARK: - Calendar View
// (This view is fine, no API models needed)
struct CalendarView: View {
    @Binding var selectedDate: Date
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            HStack {
                Text(selectedDate.formatted(.dateTime.month().year()))
                    .font(.title3.bold())
                Spacer()
            }
            
            HStack(spacing: 10) {
                ForEach(getWeekDays(), id: \.self) { date in
                    DayView(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
    }
    
    private func getWeekDays() -> [Date] {
        // ... (This function is fine as-is)
        guard let week = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [] }
        var days = [Date]()
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: week.start) {
                days.append(date)
            }
        }
        return days
    }
    
    private struct DayView: View {
        let date: Date
        let isSelected: Bool
        private let calendar = Calendar.current
        
        var body: some View {
            VStack {
                Text(date.formatted(.dateTime.weekday(.narrow)))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                Text(date.formatted(.dateTime.day()))
                    .font(.headline.bold())
                    .foregroundColor(isSelected ? .white : Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isSelected {
                        Color.theme.primary.cornerRadius(10)
                    } else {
                        Color.theme.surface.cornerRadius(10)
                    }
                }
            )
        }
    }
}


// MARK: - Workout Schedule Card
struct WorkoutScheduleCard: View {
    // --- THIS IS THE FIX ---
    // Use the 'WorkoutSession' model from 'APIModels.swift'
    let session: WorkoutSession
    // --- END OF FIX ---
    
    var isRestDay: Bool {
        session.theme == "Repos"
    }

    var body: some View {
        HStack {
            // Placeholder for instructor image
            Image(systemName: "person.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            VStack(alignment: .leading) {
                HStack {
                    if !isRestDay {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(Color.theme.primary)
                        Text(LocalizedStringKey(session.theme))
                            .font(.caption.bold())
                            .foregroundColor(Color.theme.primary)
                    }
                }
                
                Text(LocalizedStringKey(isRestDay ? "Rest Day" : session.theme))
                    .font(.headline.bold())
                
                Text(LocalizedStringKey(session.day))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !isRestDay {
                // TODO: You will need to create 'WorkoutDetailView'
                // NavigationLink(destination: WorkoutDetailView(session: session, user: nil)) {
                //     Text("common.view".localized)
                //         .font(.headline)
                //         .foregroundColor(.white)
                //         .padding(.horizontal, 24)
                //         .padding(.vertical, 8)
                //         .background(Color.theme.primary.cornerRadius(16))
                // }
            }
        }
        .padding()
        .background(Color.theme.surface)
        .cornerRadius(20)
    }
}
