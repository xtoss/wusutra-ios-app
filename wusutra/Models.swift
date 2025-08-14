import Foundation

enum UploadStatus: String, Codable {
    case pending = "Pending"
    case uploading = "Uploading"
    case uploaded = "Uploaded"
    case failed = "Failed"
    case auditing = "Auditing"
    case approved = "Approved"
    case rejected = "Rejected"
}

struct RecordingItem: Identifiable, Codable {
    let id: String
    let filename: String
    let duration: TimeInterval
    let createdAt: Date
    var text: String
    var dialect: String
    var phoneticTranscription: String = "" // 音译
    var status: UploadStatus
    var uploadAttempts: Int = 0
    var lastError: String?
    var userId: String = "anonymous"
    var auditedBy: String?
    var auditDate: Date?
    var auditNotes: String?
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

struct UploadResponse: Codable {
    let success: Bool
    let message: String?
    let recordingId: String?
}

struct Dialect {
    let code: String
    let name: String
    
    static let allDialects = [
        Dialect(code: "jiangyin", name: "江阴话"),
        Dialect(code: "mandarin", name: "普通话")
    ]
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let userId: String
    let username: String
    let avatar: String?
    let totalRecordings: Int
    let totalDuration: TimeInterval
    let dialectCounts: [String: Int]
    let rank: Int
}

struct User: Codable {
    let id: String
    var username: String
    var isAdmin: Bool = false
    var totalContributions: Int = 0
    var joinDate: Date = Date()
    
    static let currentUser = User(id: "user123", username: "用户123", isAdmin: false)
    static let adminUser = User(id: "admin", username: "管理员", isAdmin: true)
}