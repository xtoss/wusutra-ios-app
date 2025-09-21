import SwiftUI

struct TrainingView: View {
    @StateObject private var trainingViewModel = TrainingViewModel()
    @AppStorage("API_BASE_URL") private var apiBaseURL = Constants.defaultAPIBaseURL
    
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
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("训练模式", systemImage: "info.circle.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                            
                            Text("当前训练模式：从基础 Whisper 模型开始训练")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("注意：手动训练只会使用未处理的新录音")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                            }
                            .padding(.top, 4)
                            
                            Text("系统会记录已训练的文件，下次训练只包含新增的录音文件。")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
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
                            
                            Spacer()
                            
                            // Manual training button
                            Button(action: {
                                trainingViewModel.showTrainingModeSelection = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.circle.fill")
                                    Text("手动训练")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                            }
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
                                
                                // Model info
                                HStack {
                                    Image(systemName: "cpu.fill")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Text("当前模型: \(progress.currentModel)")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                    Spacer()
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh model info when app comes to foreground
            trainingViewModel.fetchCurrentModel()
        }
        .alert("训练结果", isPresented: $trainingViewModel.showTrainingAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(trainingViewModel.trainingMessage ?? "未知结果")
        }
        .actionSheet(isPresented: $trainingViewModel.showTrainingModeSelection) {
            ActionSheet(
                title: Text("选择训练模式"),
                message: Text("请选择您想要的训练方式"),
                buttons: [
                    .default(Text("增量训练 (推荐)")) {
                        trainingViewModel.selectedTrainingMode = .incremental
                        trainingViewModel.showManualTrainingAlert = true
                    },
                    .default(Text("完整训练")) {
                        trainingViewModel.selectedTrainingMode = .full
                        trainingViewModel.showManualTrainingAlert = true
                    },
                    .default(Text("LoRA 训练 (推荐)")) {
                        trainingViewModel.selectedTrainingMode = .lora
                        trainingViewModel.showManualTrainingAlert = true
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
        .alert(trainingViewModel.getTrainingModeTitle(), 
               isPresented: $trainingViewModel.showManualTrainingAlert) {
            Button("取消", role: .cancel) { }
            Button("开始训练", role: .destructive) {
                Task {
                    await trainingViewModel.triggerManualTraining()
                }
            }
        } message: {
            Text(trainingViewModel.getTrainingModeDescription())
        }
    }
}

// Training Mode
enum TrainingMode {
    case incremental
    case full
    case lora
}

// Training Response Model
struct TrainingResponse: Codable {
    let status: String
    let message: String
    let mode: String?
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case mode
        case note
    }
}

// View Model for Training Status
class TrainingViewModel: ObservableObject {
    @Published var isTrainingScheduled = true
    @Published var autoTrainingEnabled = true
    @Published var dialectProgress: [DialectProgress] = []
    @Published var countdownTime: TimeInterval = 0
    @Published var nextTrainingDate: Date?
    @Published var trainingMessage: String?
    @Published var showTrainingAlert = false
    @Published var showManualTrainingAlert = false
    @Published var pendingNewFiles = 0
    @Published var totalFiles = 0
    @Published var showTrainingModeSelection = false
    @Published var selectedTrainingMode: TrainingMode?
    
    var apiBaseURL = ""
    private var timer: Timer?
    
    // Training base URL - can be configured via Settings
    private var trainingBaseURL: String {
        return apiBaseURL.isEmpty ? "http://localhost:8000" : apiBaseURL
    }
    
    init() {
        // Initialize with default values - will be updated from API
        dialectProgress = [
            DialectProgress(dialectName: "江阴话", count: 0, currentModel: "加载中..."),
            DialectProgress(dialectName: "南京话", count: 0, currentModel: "加载中..."),
            DialectProgress(dialectName: "合肥话", count: 0, currentModel: "加载中..."),
            DialectProgress(dialectName: "上海话", count: 0, currentModel: "加载中..."),
            DialectProgress(dialectName: "苏州话", count: 0, currentModel: "加载中...")
        ]
        
        // Set next training date (mock - 2 days from now)
        nextTrainingDate = Date().addingTimeInterval(2 * 24 * 60 * 60)
        startCountdownTimer()
        
        // Will be fetched from API
        pendingNewFiles = 0
        totalFiles = 0
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
        // Fetch both training status and current model
        fetchCurrentModel()
        
        let url = URL(string: "\(trainingBaseURL)/v1/training/status")!
        var request = URLRequest(url: url)
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
                        
                        // Parse pending files for manual training
                        if let pendingFiles = json["pending_files"] as? Int {
                            self.pendingNewFiles = pendingFiles
                        }
                    }
                }
            } catch {
                print("Error parsing training status: \(error)")
            }
        }.resume()
    }
    
    func fetchCurrentModel() {
        let url = URL(string: "\(trainingBaseURL)/v1/training/current-model")!
        var request = URLRequest(url: url)
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching current model: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let currentModel = json["current_model"] as? String {
                    DispatchQueue.main.async {
                        // Update all dialect progress with the current model
                        self.dialectProgress = self.dialectProgress.map { progress in
                            DialectProgress(
                                dialectName: progress.dialectName,
                                count: progress.count,
                                currentModel: currentModel
                            )
                        }
                    }
                }
            } catch {
                print("Error parsing current model: \(error)")
            }
        }.resume()
    }
    
    func requestTraining(for dialectName: String) {
        var request = URLRequest(url: URL(string: "\(trainingBaseURL)/v1/training/request")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "ngrok-skip-browser-warning")
        
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
    
    func getTrainingModeTitle() -> String {
        switch selectedTrainingMode {
        case .incremental:
            return "增量训练说明"
        case .full:
            return "完整训练说明"
        case .lora:
            return "LoRA 训练说明"
        case .none:
            return "训练说明"
        }
    }
    
    func getTrainingModeDescription() -> String {
        switch selectedTrainingMode {
        case .incremental:
            return """
            🔄 增量训练模式
            
            • 只训练新增的音频文件
            • 基于最新模型继续训练
            • 训练时间较短，适合日常更新
            • 保留之前的学习成果
            
            确定要继续吗？
            """
        case .full:
            return """
            🔨 完整训练模式
            
            • 训练所有音频文件
            • 从基础 Whisper 模型开始训练
            • 训练时间较长，但效果最佳
            • 适合大量新数据或定期重训
            
            确定要继续吗？
            """
        case .lora:
            return """
            🧩 LoRA 训练模式 (推荐)
            
            • 使用低秩适配器技术
            • 模型体积小 (~10MB)
            • 训练速度快，内存占用低
            • 适合快速实验和迭代
            • 性能可能略低于完整训练
            
            确定要继续吗？
            """
        case .none:
            return "请选择训练模式"
        }
    }
    
    func triggerManualTraining() async {
        let mode: String
        switch selectedTrainingMode {
        case .full:
            mode = "full"
        case .lora:
            mode = "lora"
        default:
            mode = "incremental"
        }
        let url = URL(string: "\(trainingBaseURL)/v1/training/trigger?mode=\(mode)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ngrok-skip-browser-warning", forHTTPHeaderField: "ngrok-skip-browser-warning")
        request.timeoutInterval = 10  // Quick timeout since we're not waiting for training completion
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 202 {
                // Training accepted (202) or old success response (200)
                if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let message = responseData["message"] as? String ?? "训练已启动"
                    let note = responseData["note"] as? String
                    
                    await MainActor.run {
                        let fullMessage = note != nil ? "\(message)\n\n\(note!)" : message
                        self.trainingMessage = fullMessage
                        self.showTrainingAlert = true
                        // Refresh training status to update UI
                        self.fetchTrainingStatus()
                    }
                } else {
                    await MainActor.run {
                        self.trainingMessage = "训练已在后台启动，请查看日志了解进度"
                        self.showTrainingAlert = true
                        self.fetchTrainingStatus()
                    }
                }
            } else if httpResponse.statusCode == 400 {
                // No new files to train or other validation errors
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let detail = errorData["detail"] as? String {
                    await MainActor.run {
                        self.trainingMessage = detail
                        self.showTrainingAlert = true
                    }
                } else {
                    await MainActor.run {
                        self.trainingMessage = "无法启动训练：请求参数错误"
                        self.showTrainingAlert = true
                    }
                }
            } else {
                // Other server errors
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let detail = errorData["detail"] as? String {
                    await MainActor.run {
                        self.trainingMessage = "训练启动失败：\(detail)"
                        self.showTrainingAlert = true
                    }
                } else {
                    await MainActor.run {
                        self.trainingMessage = "服务器错误：HTTP \(httpResponse.statusCode)"
                        self.showTrainingAlert = true
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.trainingMessage = "无法连接到服务器：\(error.localizedDescription)"
                self.showTrainingAlert = true
            }
        }
    }
}

struct DialectProgress: Identifiable {
    let id = UUID()
    let dialectName: String
    let count: Int
    let currentModel: String
    
    init(dialectName: String, count: Int, currentModel: String? = nil) {
        self.dialectName = dialectName
        self.count = count
        self.currentModel = currentModel ?? "whisper-small-base"
    }
    
    var canTriggerTraining: Bool {
        return count < 500
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
    }
}
