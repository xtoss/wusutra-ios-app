import SwiftUI

struct LibraryView: View {
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var showingDeleteConfirmation = false
    @State private var recordingToDelete: RecordingItem?
    @State private var editingRecording: RecordingItem?
    
    var body: some View {
        NavigationView {
            List {
                if recordingManager.recordings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("还没有录音")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("您的录音将在这里显示")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(recordingManager.recordings) { recording in
                        RecordingRow(
                            recording: recording,
                            recordingManager: recordingManager,
                            uploadManager: uploadManager,
                            audioPlayer: audioPlayer,
                            onEdit: { editingRecording = $0 },
                            onDelete: {
                                recordingToDelete = recording
                                showingDeleteConfirmation = true
                            }
                        )
                    }
                }
            }
            .navigationTitle("录音库")
            .listStyle(InsetGroupedListStyle())
        }
        .alert("删除录音？", isPresented: $showingDeleteConfirmation) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let recording = recordingToDelete {
                    recordingManager.deleteRecording(recording)
                }
            }
        } message: {
            Text("这将永久删除录音文件和对应的文字内容。")
        }
        .sheet(item: $editingRecording) { recording in
            EditTextSheet(
                recording: recording,
                recordingManager: recordingManager,
                uploadManager: uploadManager
            )
        }
    }
}

struct RecordingRow: View {
    let recording: RecordingItem
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @ObservedObject var audioPlayer: AudioPlayer
    let onEdit: (RecordingItem) -> Void
    let onDelete: () -> Void
    
    private var isCurrentlyPlaying: Bool {
        audioPlayer.currentlyPlayingID == recording.id && audioPlayer.isPlaying
    }
    
    private var isCurrentRecording: Bool {
        audioPlayer.currentlyPlayingID == recording.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                
                StatusPill(status: recording.status)
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
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.blue))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Progress bar
                    if isCurrentRecording {
                        ProgressView(value: audioPlayer.currentTime, total: audioPlayer.duration)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(height: 4)
                        
                        HStack {
                            Text(formatTime(audioPlayer.currentTime))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formatTime(audioPlayer.duration))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        // Static waveform representation
                        HStack(spacing: 2) {
                            ForEach(0..<20, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 3, height: CGFloat.random(in: 4...16))
                                    .cornerRadius(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("0:00 / \(recording.formattedDuration)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
            
            if !recording.text.isEmpty {
                Text(recording.text)
                    .font(.subheadline)
                    .lineLimit(2)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if let error = recording.lastError {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                if recording.status == .pending || recording.status == .failed {
                    if recording.text.isEmpty {
                        Button(action: { onEdit(recording) }) {
                            Label("添加文字", systemImage: "text.badge.plus")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button(action: {
                            let fileURL = recordingManager.getFileURL(for: recording)
                            uploadManager.retryUpload(recording, recordingManager: recordingManager)
                        }) {
                            Label("上传", systemImage: "arrow.up.circle")
                                .font(.caption)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(action: { onEdit(recording) }) {
                            Label("编辑", systemImage: "pencil")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Label("删除", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
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

struct StatusPill: View {
    let status: UploadStatus
    
    var color: Color {
        switch status {
        case .pending: return .orange
        case .uploading: return .blue
        case .uploaded: return .green
        case .failed: return .red
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}