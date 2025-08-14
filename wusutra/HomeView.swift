import SwiftUI

struct HomeView: View {
    @ObservedObject var recordingManager: RecordingManager
    @StateObject private var audioPlayer = AudioPlayer()
    
    private var todayProgress: (uploaded: Int, target: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        let todayRecordings = recordingManager.recordings.filter { recording in
            Calendar.current.isDate(recording.createdAt, inSameDayAs: today) &&
            (recording.status == .uploaded || recording.status == .approved)
        }
        return (uploaded: todayRecordings.count, target: 3)
    }
    
    private var totalStats: (recordings: Int, points: Int) {
        let approvedCount = recordingManager.recordings.filter { $0.status == .approved }.count
        return (recordings: approvedCount, points: approvedCount * 10)
    }
    
    private var recentRecordings: [RecordingItem] {
        recordingManager.recordings
            .filter { $0.status == .uploaded || $0.status == .approved }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(10)
            .map { $0 }
    }
    
    private var dialectStats: [(String, Int)] {
        let stats = Dictionary(grouping: recordingManager.recordings.filter { $0.status == .approved }, by: { $0.dialect })
            .mapValues { $0.count }
        
        return stats.sorted { $0.value > $1.value }
            .compactMap { dialectCode, count in
                guard let dialect = Dialect.allDialects.first(where: { $0.code == dialectCode }) else { return nil }
                return (dialect.name, count)
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Daily Progress Card
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "target")
                            Text("今日进度")
                                .font(.headline)
                            Spacer()
                            Text("0/\(todayProgress.target)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(12)
                        }
                        .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("完成度")
                                    .font(.caption)
                                Spacer()
                                Text("0%")
                                    .font(.caption)
                            }
                            .foregroundColor(.white.opacity(0.8))
                            
                            ProgressView(value: Double(todayProgress.uploaded), total: Double(todayProgress.target))
                                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(4)
                        }
                        
                        HStack(spacing: 20) {
                            VStack {
                                HStack {
                                    Image(systemName: "arrow.up.circle")
                                    Text("连续天数")
                                }
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(todayProgress.uploaded)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack {
                                HStack {
                                    Image(systemName: "star")
                                    Text("总积分")
                                }
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(totalStats.points)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("还需录制 \(max(0, todayProgress.target - todayProgress.uploaded)) 条语音完成今日目标")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.orange.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    
                    HStack(spacing: 12) {
                        // Recent Recordings
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.orange)
                                Text("最近录音")
                                    .font(.headline)
                                Spacer()
                                Text("管理视图")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            if recentRecordings.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "mic.slash")
                                        .font(.title2)
                                        .foregroundColor(.gray)
                                    Text("暂无录音")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            } else {
                                LazyVStack(spacing: 8) {
                                    ForEach(recentRecordings.prefix(6)) { recording in
                                        RecentRecordingRow(
                                            recording: recording,
                                            audioPlayer: audioPlayer,
                                            recordingManager: recordingManager
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        
                        // Right sidebar
                        VStack(spacing: 12) {
                            // Badge System
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "rosette")
                                        .foregroundColor(.orange)
                                    Text("成就徽章 (9)")
                                        .font(.headline)
                                }
                                
                                LazyVStack(spacing: 8) {
                                    BadgeRow(title: "初次尝试", subtitle: "完成第一次录音", status: .earned)
                                    BadgeRow(title: "积极贡献者", subtitle: "完成10次录音", status: .earned)
                                    BadgeRow(title: "百尺竿头", subtitle: "完成13次录音", status: .earned)
                                    BadgeRow(title: "更进一步", subtitle: "完成15次录音", status: .earned)
                                    BadgeRow(title: "坚持不懈", subtitle: "完成17次录音", status: .earned)
                                    BadgeRow(title: "中坚力量", subtitle: "完成20次录音", status: .earned)
                                    BadgeRow(title: "方言专家", subtitle: "完成50次录音", status: .progress(current: 6, total: 50))
                                    BadgeRow(title: "社区领袖", subtitle: "完成100次录音", status: .progress(current: 6, total: 100))
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            
                            // Dialect Statistics
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "chart.bar")
                                        .foregroundColor(.blue)
                                    Text("方言统计")
                                        .font(.headline)
                                }
                                
                                if dialectStats.isEmpty {
                                    Text("暂无数据")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    LazyVStack(spacing: 8) {
                                        ForEach(dialectStats, id: \.0) { dialectName, count in
                                            HomeDialectStatRow(name: dialectName, count: count, total: totalStats.recordings)
                                        }
                                        
                                        HStack {
                                            Text("总计录音")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text("\(totalStats.recordings) 条")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .frame(width: 280)
                    }
                }
                .padding()
            }
            .background(Color.gray.opacity(0.05))
            .navigationTitle("主页")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RecentRecordingRow: View {
    let recording: RecordingItem
    @ObservedObject var audioPlayer: AudioPlayer
    @ObservedObject var recordingManager: RecordingManager
    
    private var isCurrentlyPlaying: Bool {
        audioPlayer.currentlyPlayingID == recording.id && audioPlayer.isPlaying
    }
    
    private var isCurrentRecording: Bool {
        audioPlayer.currentlyPlayingID == recording.id
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(recording.text.isEmpty ? "（无文字）" : recording.text)
                    .font(.subheadline)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(Dialect.allDialects.first(where: { $0.code == recording.dialect })?.name ?? "未知")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text(recording.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatRelativeTime(recording.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                if recording.status == .approved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
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
                    Image(systemName: isCurrentlyPlaying ? "pause.circle" : "play.circle")
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(String(format: "%02d", minutes / 60)):\(String(format: "%02d", minutes % 60))"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
            return String(format: "%02d/%02d %02d:%02d", Calendar.current.component(.month, from: date), Calendar.current.component(.day, from: date), hours, minutes)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd HH:mm"
            return formatter.string(from: date)
        }
    }
}

struct BadgeRow: View {
    let title: String
    let subtitle: String
    let status: BadgeStatus
    
    enum BadgeStatus {
        case earned
        case progress(current: Int, total: Int)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            switch status {
            case .earned:
                Text("已解锁")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(4)
            case .progress(let current, let total):
                Text("\(current)/\(total)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.secondary)
                    .cornerRadius(4)
            }
        }
    }
}

struct HomeDialectStatRow: View {
    let name: String
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        HStack {
            Text(name)
                .font(.caption)
            
            Spacer()
            
            Text("\(count) 条")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.orange)
        }
        
        ProgressView(value: percentage)
            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
            .frame(height: 4)
    }
}