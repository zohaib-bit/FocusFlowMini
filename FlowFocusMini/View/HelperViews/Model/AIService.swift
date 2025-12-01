import Foundation

/// Model that matches the JSON we ask the AI to return.
struct ParsedTaskResponse: Codable {
    let task_group: String
    let project_name: String
    let description: String
    let start_date: String
    let end_date: String
}

/// Minimal representation of the OpenAI chat-completion response we need.
private struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

/// Responsible for calling the OpenAI API and returning a ParsedTaskResponse.
final class AIService {
    private let apiKey: String

    /// Initialize with the API key so we don't hardcode inside the class.
    init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Parse a user natural-language text into a ParsedTaskResponse using OpenAI.
    /// Throws if network or parsing fails.
    func parseTask(from text: String) async throws -> ParsedTaskResponse {
        // OpenAI chat completions endpoint
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        // Get current date and time for context
        let now = Date()
        let formatter = ISO8601DateFormatter()
        let currentDateTime = formatter.string(from: now)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let tomorrowString = formatter.string(from: tomorrow)

        // System prompt instructs the model to return only JSON with exact keys.
        let systemPrompt = """
        You are a task parser. Today's date is \(currentDateTime).
        
        Convert the user's input into ONLY valid JSON matching this schema:
        {
            "task_group": "Work" | "Personal" | "Health" | "Finance" | "Other",
            "project_name": "short project name (1-3 words)",
            "description": "task description",
            "start_date": "ISO8601 datetime (e.g. 2025-11-22T15:00:00Z)",
            "end_date": "ISO8601 datetime"
        }

        IMPORTANT DATE RULES:
        - Today is: \(currentDateTime)
        - Tomorrow is: \(tomorrowString)
        - Parse relative dates like "tomorrow", "today", "next week", "in 2 days", etc.
        - If user says "tomorrow at 2pm", use tomorrow's date at 14:00:00Z
        - If user says "today at 5pm", use today's date at 17:00:00Z
        - If no time is specified, assume 09:00:00Z (9 AM)
        - If no date is provided, set start_date = today at 09:00:00Z and end_date = today + 2 hours
        - If only one date/time is provided, treat as start_date and set end_date = start_date + 2 hours
        - Always return dates in ISO8601 format with Z timezone (UTC)
        - Output ONLY valid JSON (no explanatory text, no markdown, no code blocks)
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.0,
            "max_tokens": 400
        ]

        let requestData = try JSONSerialization.data(withJSONObject: body, options: [])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        // Basic HTTP error handling
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let bodyText = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NSError(domain: "AIService", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "OpenAI API error: \(http.statusCode) - \(bodyText)"])
        }

        // Decode the outer response to get the model output string
        let openAI = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = openAI.choices.first?.message.content else {
            throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "OpenAI returned no content"])
        }

        // Extract JSON substring in case model added backticks or trailing text
        guard let jsonSubstring = AIService.extractJSON(from: content) else {
            // If extraction fails, attempt direct decode (may still fail)
            guard let directData = content.data(using: .utf8) else {
                throw NSError(domain: "AIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to interpret model output"])
            }
            return try JSONDecoder().decode(ParsedTaskResponse.self, from: directData)
        }

        // Decode extracted JSON into ParsedTaskResponse
        let parsed = try JSONDecoder().decode(ParsedTaskResponse.self, from: jsonSubstring)
        return parsed
    }

    /// Helper: find the first JSON object substring in `text` and return its Data.
    /// This tolerates cases where the model wraps JSON in backticks or extra text.
    private static func extractJSON(from text: String) -> Data? {
        // Find the first '{' and the matching '}' that closes the top-level object.
        guard let startIndex = text.firstIndex(of: "{") else { return nil }
        var depth = 0
        var endIndexOpt: String.Index?

        var idx = startIndex
        while idx < text.endIndex {
            let ch = text[idx]
            if ch == "{" {
                depth += 1
            } else if ch == "}" {
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
        } else {
            return nil
        }
    }
}
