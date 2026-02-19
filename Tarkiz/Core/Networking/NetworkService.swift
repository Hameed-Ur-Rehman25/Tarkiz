import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// Placeholder for APIEndpoint protocol until defined
protocol APIEndpoint {
    var url: URL { get }
    func urlRequest() throws -> URLRequest
}

protocol NetworkService {
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod,
        body: Encodable?
    ) async throws -> T
}

final class NetworkServiceImpl: NetworkService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init(),
        encoder: JSONEncoder = .init()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        body: Encodable? = nil
    ) async throws -> T {
        var request = try endpoint.urlRequest()
        request.httpMethod = method.rawValue
        
        // Add auth token if available (placeholder logic)
        // In a real app, inject KeychainService or TokenManager here
        // if let token = try? keychainService.get(key: .accessToken) {
        //     request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        // }
        
        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: String(data: data, encoding: .utf8)
            )
        }
        
        return try decoder.decode(T.self, from: data)
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case unauthorized
    case networkFailure(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "")
        case .noData:
            return NSLocalizedString("No data received", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response from server", comment: "")
        case .decodingError(let error):
            return NSLocalizedString("Failed to decode: \(error.localizedDescription)", comment: "")
        case .serverError(let code, let message):
            return message ?? NSLocalizedString("Server error: \(code)", comment: "")
        case .unauthorized:
            return NSLocalizedString("Unauthorized. Please log in again.", comment: "")
        case .networkFailure(let error):
            return error.localizedDescription
        }
    }
}
