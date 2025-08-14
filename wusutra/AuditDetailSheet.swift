import SwiftUI

struct AuditDetailSheet: View {
    let recording: RecordingItem
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var audioPlayer: AudioPlayer
    @Binding var isPresented: Bool
    
    @State private var auditNotes = ""
    @State private var playbackSpeed: Float = 1.0
    @State private var isAnalyzing = false
    @State private var showingApprovalConfirmation = false
    @State private var showingRejectionConfirmation = false
    
    private var isCurrentlyPlaying: Bool {
        audioPlayer.currentlyPlayingID == recording.id && audioPlayer.isPlaying
    }
    
    private var isCurrentRecording: Bool {
        audioPlayer.currentlyPlayingID == recording.id
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Recording info card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("录音信息")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            InfoRow(label: "文件名", value: recording.filename)
                            InfoRow(label: "时长", value: recording.formattedDuration)
                            InfoRow(label: "创建时间", value: recording.formattedDate)
                            InfoRow(label: "方言", value: Dialect.allDialects.first(where: { $0.code == recording.dialect })?.name ?? recording.dialect)
                            InfoRow(label: "用户", value: recording.userId)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Audio player section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("音频播放")
                            .font(.headline)
                        
                        // Waveform and controls
                        VStack(spacing: 12) {
                            // Play button and progress
                            HStack(spacing: 16) {
                                Button(action: togglePlayback) {
                                    Image(systemName: isCurrentlyPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    if isCurrentRecording {
                                        ProgressView(value: audioPlayer.currentTime, total: audioPlayer.duration)
                                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                        
                                        HStack {
                                            Text(formatTime(audioPlayer.currentTime))
                                            Spacer()
                                            Text(formatTime(audioPlayer.duration))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    } else {
                                        // Static waveform
                                        HStack(spacing: 3) {
                                            ForEach(0..<30, id: \.self) { _ in
                                                Rectangle()
                                                    .fill(Color.blue.opacity(0.3))
                                                    .frame(width: 4, height: CGFloat.random(in: 8...24))
                                                    .cornerRadius(2)
                                            }
                                        }
                                        
                                        Text("点击播放")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Playback speed control
                            VStack(alignment: .leading, spacing: 4) {
                                Text("播放速度: \(String(format: "%.1fx", playbackSpeed))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Button("0.5x") { setPlaybackSpeed(0.5) }
                                    Button("1.0x") { setPlaybackSpeed(1.0) }
                                    Button("1.5x") { setPlaybackSpeed(1.5) }
                                    Button("2.0x") { setPlaybackSpeed(2.0) }
                                }
                                .buttonStyle(.bordered)
                                .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Text content analysis
                    VStack(alignment: .leading, spacing: 12) {
                        Text("文字内容分析")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("用户输入的文字：")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(recording.text.isEmpty ? "（无文字内容）" : recording.text)
                                .font(.body)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        // Quality check items
                        VStack(alignment: .leading, spacing: 8) {
                            Text("质量检查项：")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ChecklistItem(text: "音频清晰，无明显噪音", isChecked: .constant(false))
                            ChecklistItem(text: "方言发音准确", isChecked: .constant(false))
                            ChecklistItem(text: "文字与音频内容匹配", isChecked: .constant(false))
                            ChecklistItem(text: "无敏感或不当内容", isChecked: .constant(false))
                            ChecklistItem(text: "符合数据质量标准", isChecked: .constant(false))
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Audit notes
                    VStack(alignment: .leading, spacing: 12) {
                        Text("审核备注")
                            .font(.headline)
                        
                        TextEditor(text: $auditNotes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text("请记录审核过程中发现的问题或需要注意的事项")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: { showingRejectionConfirmation = true }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("拒绝")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showingApprovalConfirmation = true }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("通过")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("审核详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        audioPlayer.stop()
                        isPresented = false
                    }
                }
            }
        }
        .alert("确认通过", isPresented: $showingApprovalConfirmation) {
            Button("取消", role: .cancel) {}
            Button("确认通过") {
                approveRecording()
            }
        } message: {
            Text("确认通过此录音？通过后将可用于模型训练。")
        }
        .alert("确认拒绝", isPresented: $showingRejectionConfirmation) {
            Button("取消", role: .cancel) {}
            Button("确认拒绝", role: .destructive) {
                rejectRecording()
            }
        } message: {
            Text("确认拒绝此录音？拒绝后将不会用于模型训练。")
        }
        .onAppear {
            // Auto-play the recording when sheet appears
            let fileURL = recordingManager.getFileURL(for: recording)
            audioPlayer.playRecording(recording, fileURL: fileURL)
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
    
    private func togglePlayback() {
        let fileURL = recordingManager.getFileURL(for: recording)
        if isCurrentlyPlaying {
            audioPlayer.pause()
        } else if isCurrentRecording {
            audioPlayer.resume()
        } else {
            audioPlayer.playRecording(recording, fileURL: fileURL)
        }
    }
    
    private func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        // In a real implementation, you would set the audio player's rate
    }
    
    private func approveRecording() {
        var updatedRecording = recording
        updatedRecording.status = .approved
        updatedRecording.auditedBy = "管理员"
        updatedRecording.auditDate = Date()
        updatedRecording.auditNotes = auditNotes.isEmpty ? nil : auditNotes
        
        recordingManager.updateRecording(updatedRecording)
        audioPlayer.stop()
        isPresented = false
    }
    
    private func rejectRecording() {
        var updatedRecording = recording
        updatedRecording.status = .rejected
        updatedRecording.auditedBy = "管理员"
        updatedRecording.auditDate = Date()
        updatedRecording.auditNotes = auditNotes.isEmpty ? "质量不符合要求" : auditNotes
        
        recordingManager.updateRecording(updatedRecording)
        audioPlayer.stop()
        isPresented = false
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.caption)
            
            Spacer()
        }
    }
}

struct ChecklistItem: View {
    let text: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { isChecked.toggle() }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(isChecked ? .green : .gray)
            }
            
            Text(text)
                .font(.caption)
                .strikethrough(isChecked)
                .foregroundColor(isChecked ? .secondary : .primary)
            
            Spacer()
        }
    }
}