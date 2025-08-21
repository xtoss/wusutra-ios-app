import SwiftUI

struct TrainingView: View {
    @StateObject private var trainingViewModel = TrainingViewModel()
    @AppStorage("API_BASE_URL") private var apiBaseURL = "https://9848be0d46d7.ngrok-free.app"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                    // Robot Icon
                    Image(systemName: "cpu")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    // Title
                    Text("无言引擎训练中心")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Subtitle
                    Text("您的每一次录音，都在塑造更智能的方言之声。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    // Info Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("为什么您的贡献如此重要？")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("主流AI能听懂普通话、粤语，但很少能识别您家乡独特的方言。您的每一次录音，都在为创建一个全新的、属于您家乡的语言模型添砖加瓦。这是从0到1的创造，每一条都至关重要。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineSpacing(5)
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    
                    // Countdown Section
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "hourglass")
                                .font(.title2)
                            Text("全局周期训练倒计时")
                                .font(.headline)
                        }
                        .foregroundColor(.primary)
                        
                        if trainingViewModel.isTrainingScheduled && trainingViewModel.countdownTime > 0 {
                            Text(trainingViewModel.formattedCountdown)
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(.green)
                            
                            if trainingViewModel.autoTrainingEnabled {
                                Text("下次自动训练时间")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                        } else if trainingViewModel.countdownTime <= 0 && trainingViewModel.isTrainingScheduled {
                            Text("训练进行中...")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        } else {
                            Text("暂未安排训练")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(25)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    
                    // Progress Section
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                            Text("各方言数据累积进度")
                                .font(.headline)
                        }
                        .foregroundColor(.primary)
                        
                        Text("每个方言累积500条新录音即可触发一次专门训练。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Progress bars for different dialects
                        ForEach(trainingViewModel.dialectProgress) { progress in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(progress.dialectName)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(progress.count) / 500 条新录音")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 8)
                                            .cornerRadius(4)
                                        
                                        Rectangle()
                                            .fill(Color.blue)
                                            .frame(width: geometry.size.width * CGFloat(progress.count) / 500.0, height: 8)
                                            .cornerRadius(4)
                                    }
                                }
                                .frame(height: 8)
                                
                                if progress.canTriggerTraining {
                                    Text("还需要 \(500 - progress.count) 条录音即可启动训练")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal, 20)
                    
                    }
                    .padding(.bottom, 20) // Small padding at bottom
                }
                .padding(.bottom, 50) // Additional padding to avoid tab bar
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            trainingViewModel.apiBaseURL = apiBaseURL
            trainingViewModel.fetchTrainingStatus()
        }
    }
}

// View Model for Training Status
class TrainingViewModel: ObservableObject {
    @Published var isTrainingScheduled = true
    @Published var autoTrainingEnabled = true
    @Published var dialectProgress: [DialectProgress] = []
    @Published var countdownTime: TimeInterval = 0
    @Published var nextTrainingDate: Date?
    
    var apiBaseURL = ""
    private var timer: Timer?
    
    init() {
        // Mock data for now
        dialectProgress = [
            DialectProgress(dialectName: "江阴话", count: 24),
            DialectProgress(dialectName: "南京话", count: 156),
            DialectProgress(dialectName: "合肥话", count: 89),
            DialectProgress(dialectName: "上海话", count: 342),
            DialectProgress(dialectName: "苏州话", count: 476)
        ]
        
        // Set next training date (mock - 2 days from now)
        nextTrainingDate = Date().addingTimeInterval(2 * 24 * 60 * 60)
        startCountdownTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startCountdownTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let nextDate = self.nextTrainingDate {
                self.countdownTime = nextDate.timeIntervalSinceNow
                if self.countdownTime <= 0 {
                    self.countdownTime = 0
                    self.timer?.invalidate()
                    self.isTrainingScheduled = false
                }
            }
        }
    }
    
    func fetchTrainingStatus() {
        guard !apiBaseURL.isEmpty else { return }
        
        let url = URL(string: "\(apiBaseURL)/api/training/status")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching training status: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        // Parse training schedule
                        if let nextTraining = json["next_training_date"] as? String {
                            let formatter = ISO8601DateFormatter()
                            self.nextTrainingDate = formatter.date(from: nextTraining)
                            self.isTrainingScheduled = true
                            self.startCountdownTimer()
                        }
                        
                        // Parse auto-training setting
                        if let autoTrain = json["auto_training_enabled"] as? Bool {
                            self.autoTrainingEnabled = autoTrain
                        }
                        
                        // Parse dialect progress
                        if let dialectData = json["dialect_progress"] as? [[String: Any]] {
                            self.dialectProgress = dialectData.compactMap { dict in
                                guard let name = dict["dialect_name"] as? String,
                                      let count = dict["new_recordings_count"] as? Int else { return nil }
                                return DialectProgress(dialectName: name, count: count)
                            }
                        }
                    }
                }
            } catch {
                print("Error parsing training status: \(error)")
            }
        }.resume()
    }
    
    func requestTraining(for dialectName: String) {
        guard !apiBaseURL.isEmpty else { return }
        
        var request = URLRequest(url: URL(string: "\(apiBaseURL)/api/training/request")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["dialect_name": dialectName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error requesting training: \(error)")
                return
            }
            
            DispatchQueue.main.async {
                // Refresh training status after request
                self.fetchTrainingStatus()
            }
        }.resume()
    }
    
    var formattedCountdown: String {
        let hours = Int(countdownTime) / 3600
        let minutes = Int(countdownTime) % 3600 / 60
        let seconds = Int(countdownTime) % 60
        
        if hours > 24 {
            let days = hours / 24
            let remainingHours = hours % 24
            return "\(days)天 \(remainingHours)小时 \(minutes)分钟"
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
}

struct DialectProgress: Identifiable {
    let id = UUID()
    let dialectName: String
    let count: Int
    
    var canTriggerTraining: Bool {
        return count < 500
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
    }
}