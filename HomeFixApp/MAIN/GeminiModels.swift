import Foundation
import SwiftUI

// MARK: - Request Structures (Encodable)
struct GeminiRequest: Encodable {
    let contents: [Content]
}

struct Content: Encodable {
    let parts: [Part]
}

struct Part: Encodable {
    let text: String?
    let inlineData: InlineData?
    
    init(text: String) {
        self.text = text
        self.inlineData = nil
    }
    
    init(inlineData: InlineData) {
        self.text = nil
        self.inlineData = inlineData
    }
}

struct InlineData: Encodable {
    let mimeType: String
    let data: String
}

// MARK: - Response Structures (Decodable)
struct GeminiAPIResponse: Decodable {
    let candidates: [Candidate]
}

struct Candidate: Decodable {
    let content: ContentResponse
}

struct ContentResponse: Decodable {
    let parts: [PartResponse]
}

struct PartResponse: Decodable {
    let text: String
}

// MARK: - Data Transfer Object (DTO) for Parsed Response
struct RepairProjectDTO: Decodable {
    let title: String
    let category: String
    let difficulty: String
    let safetyWarning: String?
    let recommendation: String?
    let materials: [ChecklistItemDTO]
    let tools: [ChecklistItemDTO]
    let steps: [InstructionStepDTO]
}

struct ChecklistItemDTO: Decodable {
    let name: String
}

struct InstructionStepDTO: Decodable {
    let title: String
    let descriptionText: String
}

// MARK: - Error Response Structure
struct GeminiErrorResponse: Decodable {
    let error: GeminiErrorDetail
}

struct GeminiErrorDetail: Decodable {
    let message: String
}
