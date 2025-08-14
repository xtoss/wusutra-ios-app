import Foundation

class NetworkingClient {
    static let shared = NetworkingClient()
    private init() {}
    
    func uploadRecording(
        fileURL: URL,
        recording: RecordingItem,
        apiBaseURL: String,
        completion: @escaping (Result<UploadResponse, Error>) -> Void
    ) {
        print("📤 Starting upload for recording: \(recording.filename)")
        print("   Dialect: \(recording.dialect)")
        print("   Text: \(recording.text)")
        print("   User ID: \(recording.userId)")
        print("   Duration: \(recording.duration)s")
        
        guard let audioData = try? Data(contentsOf: fileURL) else {
            print("❌ Failed to read audio file at: \(fileURL)")
            completion(.failure(NetworkError.fileReadError))
            return
        }
        
        print("✅ Audio file loaded, size: \(audioData.count) bytes")
        
        let boundary = UUID().uuidString
        let urlString = "\(apiBaseURL)/v1/records"
        print("📡 URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        print("📋 Request headers:")
        request.allHTTPHeaderFields?.forEach { key, value in
            print("   \(key): \(value)")
        }
        
        var body = Data()
        
        print("🔧 Building multipart form data with boundary: \(boundary)")
        
        // Add file data
        print("  📎 Adding file: \(recording.filename)")
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(recording.filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add text field
        print("  📝 Adding text: \(recording.text)")
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"text\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(recording.text)\r\n".data(using: .utf8)!)
        
        // Add dialect field
        print("  🗣️ Adding dialect: \(recording.dialect)")
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"dialect\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(recording.dialect)\r\n".data(using: .utf8)!)
        
        // Add user_id field (required)
        print("  👤 Adding user_id: \(recording.userId)")
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(recording.userId)\r\n".data(using: .utf8)!)
        
        // Add other fields
        let fields = [
            "duration_sec": String(recording.duration),
            "quality_score": "5" // Default to 5 for now
        ]
        
        for (key, value) in fields {
            print("  ➕ Adding \(key): \(value)")
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        print("📦 Request body size: \(body.count) bytes")
        print("📨 Sending request...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("📥 Response received")
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("📊 Status code: \(httpResponse.statusCode)")
            print("📋 Response headers:")
            httpResponse.allHeaderFields.forEach { key, value in
                print("   \(key): \(value)")
            }
            
            if let data = data {
                print("📦 Response body size: \(data.count) bytes")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response body: \(responseString)")
                }
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                print("✅ Upload successful!")
                if let data = data,
                   let uploadResponse = try? JSONDecoder().decode(UploadResponse.self, from: data) {
                    completion(.success(uploadResponse))
                } else {
                    // If we can't decode the response but got 200/201, consider it successful
                    completion(.success(UploadResponse(success: true, message: nil, recordingId: nil)))
                }
            } else {
                print("❌ Upload failed with status code: \(httpResponse.statusCode)")
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error details: \(errorString)")
                }
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
}

enum NetworkError: LocalizedError {
    case fileReadError
    case invalidResponse
    case invalidURL
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .fileReadError:
            return "Failed to read audio file"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidURL:
            return "Invalid URL"
        case .httpError(let statusCode):
            return "Server error (code: \(statusCode))"
        }
    }
}