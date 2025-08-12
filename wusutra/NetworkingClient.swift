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
        guard let audioData = try? Data(contentsOf: fileURL) else {
            completion(.failure(NetworkError.fileReadError))
            return
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(apiBaseURL)/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(recording.filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add text field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"text\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(recording.text)\r\n".data(using: .utf8)!)
        
        // Add dialect field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"dialect\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(recording.dialect)\r\n".data(using: .utf8)!)
        
        // Add other fields
        let fields = [
            "filename": recording.filename,
            "duration_sec": String(recording.duration),
            "sample_rate": "16000",
            "format": "m4a",
            "app": "wusutra"
        ]
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data,
                   let uploadResponse = try? JSONDecoder().decode(UploadResponse.self, from: data) {
                    completion(.success(uploadResponse))
                } else {
                    // If we can't decode the response but got 200, consider it successful
                    completion(.success(UploadResponse(success: true, message: nil, recordingId: nil)))
                }
            } else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
}

enum NetworkError: LocalizedError {
    case fileReadError
    case invalidResponse
    case httpError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .fileReadError:
            return "Failed to read audio file"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "Server error (code: \(statusCode))"
        }
    }
}