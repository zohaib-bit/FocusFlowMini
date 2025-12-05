//
//  TaskSuggestionViewModel.swift
//  FlowFocusMini
//
//  Created by o9tech on 03/12/2025.
//



import SwiftUI
import Combine

@MainActor
class TaskSuggestionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var dailySuggestions: [ParsedTaskResponse] = []
    @Published var weeklySuggestions: [ParsedTaskResponse] = []
    @Published var isLoadingSuggestions: Bool = false
    @Published var suggestionError: String?
    
    // MARK: - Private Properties
    //    private let aiServiceManager = AIServiceManager.shared
    //    private let interestManager = InterestManager.shared
    //
    // MARK: - Generate Suggestions Based on User Interests
    //    func generateDailySuggestions() {
    //        guard let interests = interestManager.getSelectedInterests(),
    //              !interests.isEmpty else {
    //            suggestionError = "No interests selected"
    //            return
    //        }
    //
    //        isLoadingSuggestions = true
    //        suggestionError = nil
    //
    //        Task {
    //            do {
    //                let suggestions = try await aiServiceManager.getDailyTaskSuggestions(
    //                    for: interests,
    //                    taskCount: 3
    //                )
    //
    //                DispatchQueue.main.async {
    //                    self.dailySuggestions = suggestions
    //                    self.isLoadingSuggestions = false
    //                }
    //            } catch {
    //                DispatchQueue.main.async {
    //                    self.suggestionError = error.localizedDescription
    //                    self.isLoadingSuggestions = false
    //                }
    //            }
    //        }
    //    }
    //
    //    // MARK: - Generate Weekly Suggestions
    //    func generateWeeklySuggestions() {
    //        guard let interests = interestManager.getSelectedInterests(),
    //              !interests.isEmpty else {
    //            suggestionError = "No interests selected"
    //            return
    //        }
    //
    //        isLoadingSuggestions = true
    //        suggestionError = nil
    //
    //        Task {
    //            do {
    //                let suggestions = try await aiServiceManager.getWeeklyTaskSuggestions(
    //                    for: interests
    //                )
    //
    //                DispatchQueue.main.async {
    //                    self.weeklySuggestions = suggestions
    //                    self.isLoadingSuggestions = false
    //                }
    //            } catch {
    //                DispatchQueue.main.async {
    //                    self.suggestionError = error.localizedDescription
    //                    self.isLoadingSuggestions = false
    //                }
    //            }
    //        }
    //    }
    //
    //    // MARK: - Get Custom Task Suggestions
    //    func getTaskSuggestions(for interests: [String], count: Int = 5) {
    //        guard !interests.isEmpty else {
    //            suggestionError = "No interests provided"
    //            return
    //        }
    //
    //        isLoadingSuggestions = true
    //        suggestionError = nil
    //
    //        Task {
    //            do {
    //                let suggestions = try await aiServiceManager.getTaskSuggestionsFromInterests(
    //                    interests,
    //                    count: count
    //                )
    //
    //                DispatchQueue.main.async {
    //                    self.dailySuggestions = suggestions
    //                    self.isLoadingSuggestions = false
    //                }
    //            } catch {
    //                DispatchQueue.main.async {
    //                    self.suggestionError = error.localizedDescription
    //                    self.isLoadingSuggestions = false
    //                }
    //            }
    //        }
    //    }
    //}
}
