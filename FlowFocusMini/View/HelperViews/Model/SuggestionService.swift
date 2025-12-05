////
////  SuggestionService.swift
////  FlowFocusMini
////
////  Created by o9tech on 05/12/2025.
////
//
//import Foundation
//
//// MARK: - Suggested Task Model
//struct SuggestedTask: Identifiable, Codable {
//    let id: String
//    let title: String
//    let description: String
//    let category: String
//    let estimatedDuration: String
//    let basedOnInterest: String
//    
//    init(id: String = UUID().uuidString, title: String, description: String, category: String, estimatedDuration: String, basedOnInterest: String) {
//        self.id = id
//        self.title = title
//        self.description = description
//        self.category = category
//        self.estimatedDuration = estimatedDuration
//        self.basedOnInterest = basedOnInterest
//    }
//}
//
//// MARK: - OpenAI Response Structure
//private struct SuggestionResponse: Codable {
//    struct Suggestion: Codable {
//        let title: String
//        let description: String
//        let category: String
//        let estimated_duration: String
//        let based_on_interest: String
//    }
//    let suggestions: [Suggestion]
//}
//
//private struct OpenAISuggestionResponse: Codable {
//    struct Choice: Codable {
//        struct Message: Codable {
//            let content: String
//        }
//        let message: Message
//    }
//    let choices: [Choice]
//}
//
//// MARK: - Suggestion Service
//final class SuggestionService {
//    private let apiKey: String
//    
//    init(apiKey: String) {
//        self.apiKey = apiKey
//    }
//    
//    /// Generate 5 task suggestions based on user interests
//    func generateSuggestions(from interests: [String]) async throws -> [SuggestedTask] {
//        guard !interests.isEmpty else {
//            throw NSError(
//                domain: "SuggestionService",
//                code: 1,
//                userInfo: [NSLocalizedDescriptionKey: "No interests provided"]
//            )
//        }
//        
//        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
//        
//        // Create a focused interest list (max 5 to keep prompt concise)
//        let focusedInterests = Array(interests.prefix(5))
//        let interestsString = focusedInterests.joined(separator: ", ")
//        
//        let systemPrompt = """
//        You are a helpful task suggestion assistant. Based on the user's interests, generate 5 practical, actionable daily tasks.
//        
//        User's interests: \(interestsString)
//        
//        Requirements:
//        - Generate exactly 5 diverse task suggestions
//        - Each task should be based on ONE of the user's interests
//        - Tasks should be achievable in one day
//        - Make tasks specific and actionable
//        - Categorize each task as: "Work", "Personal", "Health", "Finance", or "Other"
//        - Estimate realistic duration (e.g., "30 min", "1 hour", "2 hours")
//        
//        Return ONLY valid JSON in this exact format (no markdown, no code blocks):
//        {
//            "suggestions": [
//                {
//                    "title": "Short task title (3-5 words)",
//                    "description": "Brief description of what to do",
//                    "category": "Work|Personal|Health|Finance|Other",
//                    "estimated_duration": "duration string",
//                    "based_on_interest": "which interest this relates to"
//                }
//            ]
//        }
//        """
//        
//        let body: [String: Any] = [
//            "model": "gpt-4o-mini",
//            "messages": [
//                ["role": "system", "content": systemPrompt],
//                ["role": "user", "content": "Generate 5 task suggestions based on my interests: \(interestsString)"]
//            ],
//            "temperature": 0.7,
//            "max_tokens": 800
//        ]
//        
//        let requestData = try JSONSerialization.data(withJSONObject: body)
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = requestData
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        // Handle HTTP errors
//        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
//            let bodyText = String(data: data, encoding: .utf8) ?? "<no body>"
//            throw NSError(
//                domain: "SuggestionService",
//                code: http.statusCode,
//                userInfo: [NSLocalizedDescriptionKey: "API error: \(http.statusCode) - \(bodyText)"]
//            )
//        }
//        
//        // Decode OpenAI response
//        let openAI = try JSONDecoder().decode(OpenAISuggestionResponse.self, from: data)
//        guard let content = openAI.choices.first?.message.content else {
//            throw NSError(
//                domain: "SuggestionService",
//                code: 0,
//                userInfo: [NSLocalizedDescriptionKey: "No content in response"]
//            )
//        }
//        
//        // Extract and parse JSON
//        guard let jsonData = extractJSON(from: content) else {
//            throw NSError(
//                domain: "SuggestionService",
//                code: 0,
//                userInfo: [NSLocalizedDescriptionKey: "Failed to extract JSON from response"]
//            )
//        }
//        
//        let suggestionResponse = try JSONDecoder().decode(SuggestionResponse.self, from: jsonData)
//        
//        // Convert to SuggestedTask array
//        let tasks = suggestionResponse.suggestions.map { suggestion in
//            SuggestedTask(
//                title: suggestion.title,
//                description: suggestion.description,
//                category: suggestion.category,
//                estimatedDuration: suggestion.estimated_duration,
//                basedOnInterest: suggestion.based_on_interest
//            )
//        }
//        
//        return tasks
//    }
//    
//    // Extract JSON from response (handles markdown formatting)
//    private func extractJSON(from text: String) -> Data? {
//        guard let startIndex = text.firstIndex(of: "{") else { return nil }
//        var depth = 0
//        var endIndexOpt: String.Index?
//        
//        var idx = startIndex
//        while idx < text.endIndex {
//            let ch = text[idx]
//            if ch == "{" {
//                depth += 1
//            } else if ch == "}" {
//                depth -= 1
//                if depth == 0 {
//                    endIndexOpt = idx
//                    break
//                }
//            }
//            idx = text.index(after: idx)
//        }
//        
//        if let endIndex = endIndexOpt {
//            let jsonRange = startIndex...endIndex
//            let jsonString = String(text[jsonRange])
//            return jsonString.data(using: .utf8)
//        }
//        
//        return nil
//    }
//}
//
//// MARK: - Updated SimpleSuggestionsSection with AI Integration
//struct SimpleSuggestionsSection: View {
//    @EnvironmentObject private var interestVM: InterestViewModel
//    @EnvironmentObject private var authVM: AuthViewModel
//    
//    @State private var suggestions: [SuggestedTask] = []
//    @State private var isLoading = false
//    @State private var errorMessage = ""
//    
//    private let suggestionService: SuggestionService
//    
//    init() {
//        self.suggestionService = SuggestionService(apiKey: Config.openaiAPIKey)
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Section Header
//            HStack {
//                HStack(spacing: 8) {
//                    Image(systemName: "sparkles")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.appPrimary)
//                    
//                    Text("Suggested Tasks")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.black)
//                }
//                
//                Spacer()
//                
//                if !isLoading && !suggestions.isEmpty {
//                    Button(action: loadSuggestions) {
//                        Image(systemName: "arrow.clockwise")
//                            .font(.system(size: 16))
//                            .foregroundColor(.appPrimary)
//                    }
//                }
//            }
//            
//            // Content
//            Group {
//                if isLoading {
//                    loadingView
//                } else if !errorMessage.isEmpty {
//                    errorView
//                } else if !suggestions.isEmpty {
//                    suggestionsScrollView
//                } else {
//                    emptyStateView
//                }
//            }
//        }
//        .onAppear {
//            if suggestions.isEmpty && !isLoading {
//                loadSuggestions()
//            }
//        }
//    }
//    
//    // MARK: - Subviews
//    
//    private var loadingView: some View {
//        HStack {
//            Spacer()
//            VStack(spacing: 12) {
//                ProgressView()
//                    .tint(.appPrimary)
//                Text("Generating suggestions...")
//                    .font(.system(size: 13))
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//        }
//        .frame(height: 130)
//    }
//    
//    private var errorView: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "exclamationmark.triangle")
//                .font(.system(size: 28))
//                .foregroundColor(.orange)
//            
//            Text("Couldn't load suggestions")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.primary)
//            
//            Text(errorMessage)
//                .font(.system(size: 12))
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
//                .padding(.horizontal, 20)
//            
//            Button(action: loadSuggestions) {
//                HStack(spacing: 6) {
//                    Image(systemName: "arrow.clockwise")
//                    Text("Retry")
//                }
//                .font(.system(size: 13, weight: .medium))
//                .foregroundColor(.appPrimary)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(Color.appPrimary.opacity(0.1))
//                .cornerRadius(8)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 130)
//        .background(Color.gray.opacity(0.05))
//        .cornerRadius(14)
//    }
//    
//    private var suggestionsScrollView: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                ForEach(suggestions) { suggestion in
//                    SimpleSuggestionCard(suggestion: suggestion)
//                }
//            }
//        }
//    }
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "lightbulb.slash")
//                .font(.system(size: 28))
//                .foregroundColor(.gray.opacity(0.6))
//            
//            Text("No suggestions available")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.secondary)
//            
//            Text("Add interests in your profile to get personalized task suggestions")
//                .font(.system(size: 12))
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
//                .padding(.horizontal, 20)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 130)
//        .background(Color.gray.opacity(0.05))
//        .cornerRadius(14)
//    }
//    
//    // MARK: - Methods
//    
//    private func loadSuggestions() {
//        guard let userId = authVM.user?.uid else {
//            errorMessage = "Please sign in to get suggestions"
//            return
//        }
//        
//        let userInterests = interestVM.getInterestsArray(userId: userId)
//        
//        guard !userInterests.isEmpty else {
//            errorMessage = "Add interests to get personalized suggestions"
//            return
//        }
//        
//        isLoading = true
//        errorMessage = ""
//        
//        Task {
//            do {
//                let generated = try await suggestionService.generateSuggestions(from: userInterests)
//                await MainActor.run {
//                    self.suggestions = generated
//                    self.isLoading = false
//                }
//            } catch {
//                await MainActor.run {
//                    self.errorMessage = error.localizedDescription
//                    self.isLoading = false
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Suggestion Card Component
//struct SimpleSuggestionCard: View {
//    let suggestion: SuggestedTask
//    
//    var cardColor: Color {
//        switch suggestion.category.lowercased() {
//        case "work":
//            return Color(red: 0.85, green: 0.92, blue: 1.0)
//        case "personal":
//            return Color(red: 1.0, green: 0.95, blue: 0.85)
//        case "health":
//            return Color(red: 0.85, green: 1.0, blue: 0.90)
//        case "finance":
//            return Color(red: 1.0, green: 0.90, blue: 0.95)
//        default:
//            return Color(red: 0.95, green: 0.95, blue: 0.95)
//        }
//    }
//    
//    var icon: String {
//        switch suggestion.category.lowercased() {
//        case "work": return "briefcase.fill"
//        case "personal": return "person.fill"
//        case "health": return "heart.fill"
//        case "finance": return "dollarsign.circle.fill"
//        default: return "folder.fill"
//        }
//    }
//    
//    var iconColor: Color {
//        switch suggestion.category.lowercased() {
//        case "work": return .blue
//        case "personal": return .purple
//        case "health": return .green
//        case "finance": return .orange
//        default: return .gray
//        }
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            // Header with category and duration
//            HStack {
//                HStack(spacing: 6) {
//                    Image(systemName: icon)
//                        .font(.system(size: 12))
//                        .foregroundColor(iconColor)
//                    
//                    Text(suggestion.category)
//                        .font(.system(size: 10, weight: .semibold))
//                        .foregroundColor(.gray)
//                        .textCase(.uppercase)
//                }
//                
//                Spacer()
//                
//                HStack(spacing: 4) {
//                    Image(systemName: "clock")
//                        .font(.system(size: 10))
//                    Text(suggestion.estimatedDuration)
//                        .font(.system(size: 10))
//                }
//                .foregroundColor(.gray.opacity(0.8))
//            }
//            
//            // Title
//            Text(suggestion.title)
//                .font(.system(size: 14, weight: .bold))
//                .foregroundColor(.black)
//                .lineLimit(2)
//                .fixedSize(horizontal: false, vertical: true)
//            
//            // Description
//            Text(suggestion.description)
//                .font(.system(size: 11))
//                .foregroundColor(.gray)
//                .lineLimit(2)
//                .fixedSize(horizontal: false, vertical: true)
//            
//            Spacer(minLength: 0)
//            
//            // Based on interest badge
//            HStack(spacing: 4) {
//                Image(systemName: "star.fill")
//                    .font(.system(size: 8))
//                Text(suggestion.basedOnInterest)
//                    .font(.system(size: 9, weight: .medium))
//                    .lineLimit(1)
//            }
//            .foregroundColor(iconColor.opacity(0.8))
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(iconColor.opacity(0.15))
//            .cornerRadius(6)
//        }
//        .padding(14)
//        .frame(width: 180, height: 160)
//        .background(cardColor)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
//    }
//}
