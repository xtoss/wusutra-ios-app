import SwiftUI

struct AdminAuditView: View {
    @ObservedObject var recordingManager: RecordingManager
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var selectedFilter: AuditFilter = .pending
    @State private var showingAuditSheet = false
    @State private var selectedRecording: RecordingItem?
    @State private var currentUser = User.adminUser // In real app, get from auth
    
    enum AuditFilter: String, CaseIterable {
        case pending = "uploaded"
        case auditing = "auditing"
        case approved = "approved"
        case rejected = "rejected"
        
        var displayName: String {
            switch self {
            case .pending: return "待审核"
            case .auditing: return "审核中"
            case .approved: return "已通过"
            case .rejected: return "已拒绝"
            }
        }
        
        var status: UploadStatus {
            switch self {
            case .pending: return .uploaded
            case .auditing: return .auditing
            case .approved: return .approved
            case .rejected: return .rejected
            }
        }
    }
    
    private var filteredRecordings: [RecordingItem] {
        recordingManager.recordings.filter { $0.status == selectedFilter.status }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    private var auditStats: (pending: Int, approved: Int, rejected: Int) {
        let recordings = recordingManager.recordings
        return (
            pending: recordings.filter { $0.status == .uploaded || $0.status == .auditing }.count,
            approved: recordings.filter { $0.status == .approved }.count,
            rejected: recordings.filter { $0.status == .rejected }.count
        )
    }
    
    var body: some View {
        NavigationView {
            if !currentUser.isAdmin {
                // Non-admin view
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("访问被拒绝")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("您没有管理员权限，无法访问审核功能。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .navigationTitle("审核管理")
            } else {
                VStack(spacing: 0) {
                    // Admin header with stats
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.blue)
                            Text("录音审核管理")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("审核方言录音质量，确保数据准确性")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Stats cards
                        HStack(spacing: 12) {
                            StatCard(
                                title: "待审核",
                                count: auditStats.pending,
                                color: .orange,
                                icon: "clock.badge.exclamationmark"
                            )
                            
                            StatCard(
                                title: "已通过",
                                count: auditStats.approved,
                                color: .green,
                                icon: "checkmark.circle"
                            )
                            
                            StatCard(
                                title: "已拒绝",
                                count: auditStats.rejected,
                                color: .red,
                                icon: "xmark.circle"
                            )
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    
                    // Filter tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AuditFilter.allCases, id: \.rawValue) { filter in
                                Button(action: { selectedFilter = filter }) {
                                    HStack {
                                        Text(filter.displayName)
                                        
                                        let count = recordingManager.recordings.filter { $0.status == filter.status }.count
                                        if count > 0 {
                                            Text("\(count)")
                                                .font(.caption)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.white.opacity(0.3))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedFilter == filter ? .white : .primary)
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    
                    // Recordings list
                    if filteredRecordings.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: selectedFilter == .pending ? "tray" : "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text(selectedFilter == .pending ? "暂无待审核录音" : "暂无\(selectedFilter.displayName)录音")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredRecordings) { recording in
                                AuditRecordingRow(
                                    recording: recording,
                                    audioPlayer: audioPlayer,
                                    recordingManager: recordingManager,
                                    onAudit: {
                                        selectedRecording = recording
                                        showingAuditSheet = true
                                    }
                                )
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("审核管理")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showingAuditSheet) {
            if let recording = selectedRecording {
                AuditDetailSheet(
                    recording: recording,
                    recordingManager: recordingManager,
                    audioPlayer: audioPlayer,
                    isPresented: $showingAuditSheet
                )
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AuditRecordingRow: View {
    let recording: RecordingItem
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var recordingManager: RecordingManager
    let onAudit: () -> Void
    
    private var isCurrentlyPlaying: Bool {
        audioPlayer.currentlyPlayingID == recording.id && audioPlayer.isPlaying
    }
    
    private var isCurrentRecording: Bool {
        audioPlayer.currentlyPlayingID == recording.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with basic info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recording.filename)
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        Label(recording.formattedDuration, systemImage: "clock")
                            .font(.caption)
                        
                        Label(recording.formattedDate, systemImage: "calendar")
                            .font(.caption)
                        
                        if !recording.dialect.isEmpty {
                            Label(Dialect.allDialects.first(where: { $0.code == recording.dialect })?.name ?? recording.dialect,
                                  systemImage: "globe.asia.australia")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                AuditStatusPill(status: recording.status)
            }
            
            // Audio controls
            HStack(spacing: 12) {
                Button(action: {
                    let fileURL = recordingManager.getFileURL(for: recording)
                    if isCurrentlyPlaying {
                        audioPlayer.pause()
                    } else if isCurrentRecording {
                        audioPlayer.resume()
                    } else {
                        audioPlayer.playRecording(recording, fileURL: fileURL)
                    }
                }) {
                    Image(systemName: isCurrentlyPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(.blue))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if isCurrentRecording {
                        ProgressView(value: audioPlayer.currentTime, total: audioPlayer.duration)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(height: 3)
                        
                        HStack {
                            Text(formatTime(audioPlayer.currentTime))
                                .font(.caption2)
                            Spacer()
                            Text(formatTime(audioPlayer.duration))
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 2) {
                            ForEach(0..<15, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 2, height: CGFloat.random(in: 3...12))
                                    .cornerRadius(1)
                            }
                        }
                        
                        Text("0:00 / \(recording.formattedDuration)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Text content
            if !recording.text.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("文字内容：")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(recording.text)
                        .font(.subheadline)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Audit info
            if let auditedBy = recording.auditedBy, let auditDate = recording.auditDate {
                VStack(alignment: .leading, spacing: 4) {
                    Text("审核信息：")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("审核员: \(auditedBy)")
                        Spacer()
                        Text(DateFormatter.short.string(from: auditDate))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if let notes = recording.auditNotes, !notes.isEmpty {
                        Text("备注: \(notes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Action buttons
            if recording.status == .uploaded || recording.status == .auditing {
                HStack(spacing: 12) {
                    Button(action: onAudit) {
                        Label("开始审核", systemImage: "eye")
                            .font(.caption)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AuditStatusPill: View {
    let status: UploadStatus
    
    private var color: Color {
        switch status {
        case .uploaded: return .orange
        case .auditing: return .blue
        case .approved: return .green
        case .rejected: return .red
        default: return .gray
        }
    }
    
    private var displayText: String {
        switch status {
        case .uploaded: return "待审核"
        case .auditing: return "审核中"
        case .approved: return "已通过"
        case .rejected: return "已拒绝"
        default: return status.rawValue
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}

extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}