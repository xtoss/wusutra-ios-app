import Foundation

struct Constants {
    // In debug builds, use local configuration; in release builds, use empty string
    static let defaultAPIBaseURL: String = {
        #if DEBUG
        return LocalConstants.apiBaseURL
        #else
        return ""  // Must be configured in Settings before use
        #endif
    }()
    
    static let defaultInferenceURL: String = {
        #if DEBUG
        return LocalConstants.inferenceURL
        #else
        return "http://localhost:8000"
        #endif
    }()
}
