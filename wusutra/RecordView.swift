import SwiftUI

struct RecordView: View {
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @State private var showingTranslationSheet = false
    @State private var currentRecording: RecordingItem?
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var selectedDialect = "wu"
    @State private var currentStep = 1
    @StateObject private var promptsService = PromptsService.shared
    
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
                    // Task description header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)
                            Text("您的任务：帮助训练方言AI模型")
                                .font(.headline)
                        }
                        
                        Text("主流AI无法识别您家乡的独特方言。您的贡献将从零开始，为您的家乡建立独一无二的语音数据库。")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("1. 先选择方言 → 告诉我们您要录制哪种方言", systemImage: "1.circle.fill")
                                .font(.caption)
                                .foregroundColor(currentStep == 1 ? .blue : .secondary)
                            
                            Label("2. 录制语音 → 用方言朗读文字（AI会尝试识别，通常会失败😊）", systemImage: "2.circle.fill")
                                .font(.caption)
                                .foregroundColor(currentStep == 2 ? .blue : .secondary)
                            
                            Label("3. 输入正确文字 → 告诉我们您刚才说的标准文字是什么", systemImage: "3.circle.fill")
                                .font(.caption)
                                .foregroundColor(currentStep == 3 ? .blue : .secondary)
                        }
                        
                        Text("💡 重点：您的数据将用于训练更好的方言识别AI！")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Step 1: Dialect Selection
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("1")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(currentStep >= 1 ? Color.orange : Color.gray))
                                    
                                    Text("选择方言")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("您要录制哪种方言？")
                                        .font(.subheadline)
                                    
                                    Menu {
                                        ForEach(Dialect.allDialects, id: \.code) { dialect in
                                            Button(dialect.name) {
                                                selectedDialect = dialect.code
                                                recordingManager.selectedDialect = dialect.code
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedDialect.isEmpty ? "请选择方言" : 
                                                 Dialect.allDialects.first(where: { $0.code == selectedDialect })?.name ?? "请选择方言")
                                                .foregroundColor(selectedDialect.isEmpty ? .gray : .primary)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                    
                                    if !selectedDialect.isEmpty {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                            Text("已选择：\(Dialect.allDialects.first(where: { $0.code == selectedDialect })?.name ?? "")")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            
                            // Prompts section (shown after dialect selection)
                            if !selectedDialect.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                        Text("录音建议")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    
                                    if promptsService.isLoading {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("加载录音建议...")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.vertical)
                                    } else if !promptsService.prompts.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("选择一个句子开始录音：")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            LazyVGrid(columns: [
                                                GridItem(.flexible()),
                                                GridItem(.flexible())
                                            ], spacing: 12) {
                                                ForEach(promptsService.prompts.prefix(6)) { prompt in
                                                    Button(action: {
                                                        // Scroll to recording section and highlight it
                                                        withAnimation(.easeInOut(duration: 0.5)) {
                                                            currentStep = 2
                                                        }
                                                    }) {
                                                        Text(prompt.text)
                                                            .font(.subheadline)
                                                            .multilineTextAlignment(.leading)
                                                            .lineLimit(3)
                                                            .padding()
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .background(Color.blue.opacity(0.1))
                                                            .foregroundColor(.blue)
                                                            .cornerRadius(10)
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        Text("暂无录音建议，请直接开始录音")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding(.vertical)
                                    }
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.05))
                                .cornerRadius(12)
                                .shadow(radius: 1)
                            }
                            
                            // Step 2: Recording
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("2")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(Color.orange))
                                    
                                    Text("录制语音")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(spacing: 20) {
                                    if recordingManager.isRecording {
                                        VStack(spacing: 12) {
                                            Text(formatTime(recordingManager.recordingTime))
                                                .font(.system(size: 36, weight: .medium, design: .monospaced))
                                                .foregroundColor(.red)
                                            
                                            Text("点击停止录音")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Button(action: {
                                        if recordingManager.isRecording {
                                            recordingManager.stopRecording { recording in
                                                if let recording = recording {
                                                    currentRecording = recording
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
                                                .frame(width: 100, height: 100)
                                            
                                            Image(systemName: recordingManager.isRecording ? "stop.fill" : "mic.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .disabled(!recordingManager.hasPermission)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            
                            // Step 3: Text Input (shown as placeholder)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("3")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(Color.gray))
                                    
                                    Text("输入正确文字")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("请先完成录音")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .opacity(0.6)
                        }
                        .padding()
                    }
                }
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
        .onAppear {
            recordingManager.selectedDialect = selectedDialect
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let tenths = Int((time * 10).truncatingRemainder(dividingBy: 10))
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }
    
}