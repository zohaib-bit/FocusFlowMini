//
//  SuggestionService.swift
//  FlowFocusMini
//
//  Created by o9tech on 05/12/2025.
//

import Foundation

final class SuggestionService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateSuggestions(from interests: [String]) async throws -> [SuggestedTask] {
        let interestsText = interests.joined(separator: ", ")
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let systemPrompt = """
        Generate 5 practical daily tasks based on these interests: \(interestsText)
        
        Return ONLY this exact JSON format (no extra text or markdown):
        [
            {"title": "Task 1", "category": "Work", "description": "Do this task"},
            {"title": "Task 2", "category": "Health", "description": "Do this task"},
            {"title": "Task 3", "category": "Personal", "description": "Do this task"},
            {"title": "Task 4", "category": "Finance", "description": "Do this task"},
            {"title": "Task 5", "category": "Other", "description": "Do this task"}
        ]
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": "Generate 5 tasks"]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        let requestData = try JSONSerialization.data(withJSONObject: body, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(domain: "SuggestionService", code: http.statusCode)
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAISuggestionResponse.self, from: data)
        guard let content = openAIResponse.choices.first?.message.content else {
            throw NSError(domain: "SuggestionService", code: 0)
        }
        
        // Extract JSON array from content
        guard let jsonData = extractJSONArray(from: content) else {
            throw NSError(domain: "SuggestionService", code: 0)
        }
        
        let suggestions = try JSONDecoder().decode([SuggestedTask].self, from: jsonData)
        return Array(suggestions.prefix(5))
    }
    
    private func extractJSONArray(from text: String) -> Data? {
        guard let startIndex = text.firstIndex(of: "[") else { return nil }
        var depth = 0
        var endIndexOpt: String.Index?
        
        var idx = startIndex
        while idx < text.endIndex {
            let ch = text[idx]
            if ch == "[" {
                depth += 1
            } else if ch == "]" {
                depth -= 1
                if depth == 0 {
                    endIndexOpt = idx
                    break
                }
            }
            idx = text.index(after: idx)
        }
        
        if let endIndex = endIndexOpt {
            let jsonRange = startIndex...endIndex
            let jsonString = String(text[jsonRange])
            return jsonString.data(using: .utf8)
        }
        return nil
    }
}

// MARK: - Response Models (specific to suggestions, doesn't conflict with AIService)
private struct OpenAISuggestionResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: - Suggested Task Model
struct SuggestedTask: Codable, Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case title, category, description
    }
}
