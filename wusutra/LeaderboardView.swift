import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var recordingManager: RecordingManager
    @State private var selectedDialect: String = "all"
    @State private var selectedScope: LeaderboardScope = .all
    
    enum LeaderboardScope: String, CaseIterable {
        case all = "all"
        case week = "week"
        case month = "month"
        
        var displayName: String {
            switch self {
            case .all: return "全部时间"
            case .week: return "本周"
            case .month: return "本月"
            }
        }
    }
    
    private var approvedRecordings: [RecordingItem] {
        recordingManager.recordings.filter { $0.status == .approved }
    }
    
    private var filteredRecordings: [RecordingItem] {
        let recordings = approvedRecordings
        
        // Filter by time scope
        let filtered = recordings.filter { recording in
            switch selectedScope {
            case .all:
                return true
            case .week:
                return Calendar.current.isDate(recording.createdAt, equalTo: Date(), toGranularity: .weekOfYear)
            case .month:
                return Calendar.current.isDate(recording.createdAt, equalTo: Date(), toGranularity: .month)
            }
        }
        
        // Filter by dialect
        if selectedDialect == "all" {
            return filtered
        } else {
            return filtered.filter { $0.dialect == selectedDialect }
        }
    }
    
    private var leaderboardEntries: [LeaderboardEntry] {
        let userStats = Dictionary(grouping: filteredRecordings, by: { $0.userId })
            .mapValues { recordings in
                let totalDuration = recordings.reduce(0) { $0 + $1.duration }
                let dialectCounts = Dictionary(grouping: recordings, by: { $0.dialect })
                    .mapValues { $0.count }
                return (count: recordings.count, duration: totalDuration, dialects: dialectCounts)
            }
        
        return userStats.enumerated().sorted { $0.element.value.count > $1.element.value.count }
            .map { index, element in
                LeaderboardEntry(
                    userId: element.key,
                    username: getUserDisplayName(element.key),
                    avatar: nil,
                    totalRecordings: element.value.count,
                    totalDuration: element.value.duration,
                    dialectCounts: element.value.dialects,
                    rank: index + 1
                )
            }
    }
    
    private var dialectOptions: [(String, String)] {
        var options = [("all", "全部方言")]
        for dialect in Dialect.allDialects {
            let count = approvedRecordings.filter { $0.dialect == dialect.code }.count
            if count > 0 {
                options.append((dialect.code, "\(dialect.name) (\(count))"))
            }
        }
        return options
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with filters
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.orange)
                        Text("贡献排行榜")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("展示各地区方言贡献者的排名")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Filter controls
                    HStack(spacing: 12) {
                        // Time scope picker
                        Menu {
                            ForEach(LeaderboardScope.allCases, id: \.rawValue) { scope in
                                Button(scope.displayName) {
                                    selectedScope = scope
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedScope.displayName)
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Dialect picker
                        Menu {
                            ForEach(dialectOptions, id: \.0) { code, name in
                                Button(name) {
                                    selectedDialect = code
                                }
                            }
                        } label: {
                            HStack {
                                Text(dialectOptions.first { $0.0 == selectedDialect }?.1 ?? "全部方言")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.05))
                
                // Leaderboard list
                if leaderboardEntries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("暂无排行数据")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("等待更多已审核的录音贡献")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(leaderboardEntries) { entry in
                            LeaderboardRowView(entry: entry)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("排行榜")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func getUserDisplayName(_ userId: String) -> String {
        if userId == "admin" {
            return "管理员"
        } else if userId == "user123" {
            return "用户123"
        } else {
            return "用户\(userId.suffix(3))"
        }
    }
}

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    
    private var rankColor: Color {
        switch entry.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    private var rankIcon: String {
        switch entry.rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "\(entry.rank).circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank badge
            ZStack {
                if entry.rank <= 3 {
                    Image(systemName: rankIcon)
                        .font(.title2)
                        .foregroundColor(rankColor)
                } else {
                    Text("\(entry.rank)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(rankColor))
                }
            }
            .frame(width: 40)
            
            // User avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(entry.username.prefix(1)))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.username)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    Label("\(entry.totalRecordings)", systemImage: "waveform")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(formatDuration(entry.totalDuration), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Dialect badges (top 3)
                if !entry.dialectCounts.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(entry.dialectCounts.sorted { $0.value > $1.value }.prefix(3)), id: \.key) { dialectCode, count in
                            if let dialect = Dialect.allDialects.first(where: { $0.code == dialectCode }) {
                                Text("\(dialect.name)(\(count))")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Points or score
            VStack(alignment: .trailing) {
                Text("\(entry.totalRecordings * 10)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("积分")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(entry.rank <= 3 ? rankColor.opacity(0.05) : Color.clear)
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}