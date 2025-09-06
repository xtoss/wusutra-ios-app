import SwiftUI

struct RecordView: View {
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @State private var showingTranslationSheet = false
    @State private var currentRecording: RecordingItem?
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var selectedDialect = "jiangyin"
    @State private var currentStep = 1
    @StateObject private var promptsService = PromptsService.shared
    @State private var showingPhoneticSheet = false
    @State private var selectedPromptText = ""
    @State private var selectedPromptPhonetic = ""
    
    var body: some View {
        NavigationView {
            if recordingManager.permissionDenied {
                VStack(spacing: 20) {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("Microphone Access Required")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Please enable microphone access in Settings to record audio.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    // Task description header - dark theme
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                            Text("您的任务：帮助训练方言AI模型")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 8) {
                            Label("1. 选择方言", systemImage: "1.circle.fill")
                                .font(.caption2)
                                .foregroundColor(currentStep == 1 ? .blue : .gray)
                            
                            Label("2. 录制语音", systemImage: "2.circle.fill")
                                .font(.caption2)
                                .foregroundColor(currentStep == 2 ? .blue : .gray)
                            
                            Label("3. 输入文字", systemImage: "3.circle.fill")
                                .font(.caption2)
                                .foregroundColor(currentStep == 3 ? .blue : .gray)
                            
                            Label("4. 音译(选填)", systemImage: "4.circle")
                                .font(.caption2)
                                .foregroundColor(currentStep == 4 ? .blue : .gray)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.8))
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Step 1: Dialect Selection
                            dialectSelectionView
                            
                            // Prompts section
                            if !selectedDialect.isEmpty {
                                promptsView
                            }
                            
                            // Step 2: Recording
                            recordingView
                            
                            // Step 3: Text Input
                            step3View
                            
                            // Step 4: Phonetic Transcription
                            step4View
                        }
                        .padding()
                    }
                }
                .background(Color.black)
                .navigationTitle("方言数据贡献")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { showingSettings = true }) {
                                Label("Settings", systemImage: "gear")
                            }
                            Button(action: { showingAbout = true }) {
                                Label("About", systemImage: "info.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingTranslationSheet) {
            if let recording = currentRecording {
                TranslationSheet(
                    recording: recording,
                    recordingManager: recordingManager,
                    uploadManager: uploadManager,
                    isPresented: $showingTranslationSheet
                )
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingPhoneticSheet) {
            if let recording = currentRecording {
                PhoneticSheet(
                    recording: recording,
                    recordingManager: recordingManager,
                    uploadManager: uploadManager,
                    isPresented: $showingPhoneticSheet
                )
            }
        }
        .onAppear {
            recordingManager.selectedDialect = selectedDialect
        }
    }
    
    @ViewBuilder
    private var dialectSelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("1")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.orange))
                
                Text("选择方言")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            HStack {
                Menu {
                    ForEach(Dialect.allDialects, id: \.code) { dialect in
                        Button(dialect.name) {
                            selectedDialect = dialect.code
                            recordingManager.selectedDialect = dialect.code
                        }
                    }
                } label: {
                    HStack {
                        Text(Dialect.allDialects.first(where: { $0.code == selectedDialect })?.name ?? "请选择方言")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                }
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var promptsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("录音建议")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            let jiangYinPrompts = [
                ("啥个物事", "什么东西"),
                ("明朝会", "明天见"),
                ("啥辰光", "什么时候"),
                ("嘎来", "回来"),
                ("老官", "老公"),
                ("毕结骨", "十分寒冷")
            ]
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(Array(jiangYinPrompts.enumerated()), id: \.offset) { index, prompt in
                    Button(action: {
                        // Toggle selection - if already selected, clear it
                        if selectedPromptPhonetic == prompt.0 {
                            selectedPromptPhonetic = ""
                            selectedPromptText = ""
                        } else {
                            selectedPromptPhonetic = prompt.0
                            selectedPromptText = prompt.1
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prompt.0)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                            Text("——\(prompt.1)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selectedPromptPhonetic == prompt.0 ? Color.blue.opacity(0.5) : Color.blue.opacity(0.25))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .overlay(
                            selectedPromptPhonetic == prompt.0 ? 
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.blue, lineWidth: 2) : nil
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var recordingView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("2")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.orange))
                
                Text("录制语音")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if recordingManager.isRecording {
                    Text(formatTime(recordingManager.recordingTime))
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    if recordingManager.isRecording {
                        recordingManager.stopRecording { recording in
                            if let recording = recording {
                                var updatedRecording = recording
                                if !selectedPromptText.isEmpty {
                                    updatedRecording.text = selectedPromptText
                                }
                                if !selectedPromptPhonetic.isEmpty {
                                    updatedRecording.phoneticTranscription = selectedPromptPhonetic
                                }
                                currentRecording = updatedRecording
                                currentStep = 3
                                showingTranslationSheet = true
                            }
                        }
                    } else {
                        recordingManager.startRecording()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(recordingManager.isRecording ? Color.red : Color.orange)
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: recordingManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .disabled(!recordingManager.hasPermission)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var step3View: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("3")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(!selectedPromptText.isEmpty ? Color.green : Color.gray))
                
                Text("输入正确文字")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if !selectedPromptText.isEmpty {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Image(systemName: "doc.text")
                    .font(.system(size: 24))
                    .foregroundColor(!selectedPromptText.isEmpty ? .green : .gray)
                
                if !selectedPromptText.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("已预填文字")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Text(selectedPromptText)
                            .font(.caption)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                } else {
                    Text("请先完成录音")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .opacity(!selectedPromptText.isEmpty ? 1.0 : 0.6)
    }
    
    @ViewBuilder
    private var step4View: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("4")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(!selectedPromptPhonetic.isEmpty ? Color.green : Color.blue.opacity(0.6)))
                
                Text("音译 (选填)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !selectedPromptPhonetic.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Text("选填")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            HStack {
                Image(systemName: "textformat.abc")
                    .font(.system(size: 24))
                    .foregroundColor(!selectedPromptPhonetic.isEmpty ? .green : .blue.opacity(0.6))
                
                if !selectedPromptPhonetic.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("已预填音译")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Text(selectedPromptPhonetic)
                            .font(.caption)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("添加方言音译")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("如：来孛/别相 → 来玩")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .opacity(!selectedPromptPhonetic.isEmpty ? 1.0 : (currentRecording == nil ? 0.6 : 1.0))
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let tenths = Int((time * 10).truncatingRemainder(dividingBy: 10))
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }
}
