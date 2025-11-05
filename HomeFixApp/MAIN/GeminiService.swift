
import Foundation
import SwiftUI

class GeminiService {
    
    // ВСТАВЬ СВОЙ КЛЮЧ СЮДА
    private let geminiAPIKey = "AIzaSyA64dB7fiTRzuDi2bvQa2yhGlrR8svlZG8"
    
    private let modelName = "gemini-1.5-flash-latest"
    private var endpointURL: String {
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"
    }
    
    enum GeminiError: LocalizedError {
        case failedToConstructURL
        case networkRequestFailed(Error)
        case serverError(statusCode: Int, message: String?)
        case noData
        case jsonDecodingError(Error)
        case imageConversionFailed
        
        var errorDescription: String? {
            switch self {
            case .failedToConstructURL:
                return "Internal error: Could not create the request URL."
            case .networkRequestFailed:
                return "Network problem. Please check your internet connection and try again."
            case .serverError(let statusCode, let message):
                if let message = message, !message.isEmpty {
                    return "An API error occurred: \(message)"
                }
                return "The server responded with an error (Code: \(statusCode)). Please try again later."
            case .noData:
                return "The AI returned an empty response. Please try again with a clearer image."
            case .jsonDecodingError:
                return "Failed to process the AI's response. The format might be incorrect."
            case .imageConversionFailed:
                return "Failed to process the selected image. Please try a different one."
            }
        }
    }
    
    func analyse(image: UIImage) async throws -> RepairProjectDTO {
        guard let url = URL(string: "\(endpointURL)?key=\(geminiAPIKey)") else {
            throw GeminiError.failedToConstructURL
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw GeminiError.imageConversionFailed
        }
        let base64Image = imageData.base64EncodedString()
        
        let promptPart = Part(text: createSystemPrompt())
        let imagePart = Part(inlineData: InlineData(mimeType: "image/jpeg", data: base64Image))
        let content = Content(parts: [promptPart, imagePart])
        let requestBody = GeminiRequest(contents: [content])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw GeminiError.networkRequestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.serverError(statusCode: 0, message: "Invalid response from server.")
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data).error.message
            throw GeminiError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let apiResponse = try JSONDecoder().decode(GeminiAPIResponse.self, from: data)
        
        guard let textResponse = apiResponse.candidates.first?.content.parts.first?.text else {
            throw GeminiError.noData
        }
        
        let cleanedText = textResponse.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleanedText.data(using: .utf8) else {
            throw GeminiError.jsonDecodingError(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert cleaned text to data."]))
        }
        
        do {
            let projectDTO = try JSONDecoder().decode(RepairProjectDTO.self, from: jsonData)
            return projectDTO
        } catch {
            throw GeminiError.jsonDecodingError(error)
        }
    }
    
    private func createSystemPrompt() -> String {
        return """
        You are an expert home repair assistant named HomeFix AI.
        Your task is to analyze an image of a household problem and provide a structured repair plan.
        Respond ONLY with a valid JSON object. Do not include any introductory text, markdown formatting like ```json, or any explanations outside of the JSON structure.

        The JSON object must have the following structure:
        {
          "title": "A short, descriptive title of the problem (e.g., 'Crack in Drywall')",
          "category": "One of the following strings: 'Electrical', 'Plumbing', 'Walls & Paint', 'Furniture', 'Other'",
          "difficulty": "One of the following strings: 'Easy', 'Medium', 'Hard', 'Professional Required'",
          "safetyWarning": "A brief but critical safety warning if applicable (e.g., 'Turn off power at the circuit breaker before starting.'). Null if not applicable.",
          "recommendation": "A recommendation to call a professional if the difficulty is 'Professional Required'. Null otherwise.",
          "materials": [
            { "name": "Name of the material (e.g., 'Drywall patch kit')" }
          ],
          "tools": [
            { "name": "Name of the tool (e.g., 'Putty knife')" }
          ],
          "steps": [
            {
              "title": "A short title for the step (e.g., 'Prepare the Area')",
              "descriptionText": "A detailed description of what to do in this step."
            }
          ]
        }
        
        Analyze the image provided and generate the JSON object according to these rules.
        """
    }
}
