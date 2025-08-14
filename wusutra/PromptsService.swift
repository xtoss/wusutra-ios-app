import Foundation

struct Prompt: Codable, Identifiable {
    let id: String
    let text: String
    let dialect: String
    let category: String?
    let difficulty: String?
}

struct PromptsResponse: Codable {
    let prompts: [Prompt]
    let total: Int
}

@MainActor
class PromptsService: ObservableObject {
    static let shared = PromptsService()
    private init() {}
    
    @Published var prompts: [Prompt] = []
    @Published var isLoading = false
    private var hasLoaded = false
    
    func loadPromptsOnce(apiBaseURL: String) {
        guard !hasLoaded && !isLoading else { return }
        
        isLoading = true
        fetchPrompts(apiBaseURL: apiBaseURL) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                self?.hasLoaded = true
                switch result {
                case .success(let prompts):
                    self?.prompts = prompts
                case .failure(let error):
                    print("Failed to load prompts: \(error.localizedDescription)")
                    self?.prompts = []
                }
            }
        }
    }
    
    private func fetchPrompts(
        apiBaseURL: String,
        completion: @escaping (Result<[Prompt], Error>) -> Void
    ) {
        let urlString = "\(apiBaseURL)/v1/prompts"
        print("🔍 Fetching prompts from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid prompts URL: \(urlString)")
            completion(.failure(PromptsError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        print("📋 Prompts request headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("   \(key): \(value)")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("📥 Prompts response received")
            
            if let error = error {
                print("❌ Prompts network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid prompts response type")
                completion(.failure(PromptsError.invalidResponse))
                return
            }
            
            print("📊 Prompts status code: \(httpResponse.statusCode)")
            
            if let data = data {
                print("📦 Prompts response body size: \(data.count) bytes")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Prompts response body: \(responseString)")
                }
            }
            
            guard httpResponse.statusCode == 200 else {
                print("❌ Prompts fetch failed with status code: \(httpResponse.statusCode)")
                completion(.failure(PromptsError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                print("❌ No prompts data received")
                completion(.failure(PromptsError.noData))
                return
            }
            
            do {
                // Try to decode as array first (backend returns [])
                if let prompts = try? JSONDecoder().decode([Prompt].self, from: data) {
                    print("✅ Prompts decoded successfully (array format): \(prompts.count) prompts")
                    completion(.success(prompts))
                } else {
                    // Fall back to object format
                    let response = try JSONDecoder().decode(PromptsResponse.self, from: data)
                    print("✅ Prompts decoded successfully (object format): \(response.prompts.count) prompts")
                    completion(.success(response.prompts))
                }
            } catch {
                print("❌ Prompts decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

enum PromptsError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid prompts URL"
        case .invalidResponse:
            return "Invalid prompts response"
        case .httpError(let statusCode):
            return "Prompts server error (code: \(statusCode))"
        case .noData:
            return "No prompts data received"
        }
    }
}