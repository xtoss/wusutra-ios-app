import SwiftUI

struct PhoneticSheet: View {
    let recording: RecordingItem
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @Binding var isPresented: Bool
    
    @State private var phoneticText = ""
    @State private var characterCount = 0
    @FocusState private var isTextFieldFocused: Bool
    
    // Sample phonetic transcriptions from the provided list
    private let sampleTranscriptions = [
        "来孛/别相 → 来玩",
        "蛮(/mae/)好个 → 挺好的、好",
        "覅来烦 → 不要烦",
        "明朝会 → 明天见",
        "啥个物事？ → 什么东西？",
        "搞七捻三 → 瞎搞",
        "怄比实欠 → 胡说八道",
        "昏煞过去 → 傻眼了",
        "晚后点 → 下午三点左右",
        "瞎七搭八 → 不着边际",
        "瞎三话四 → 瞎说八道",
        "乱(loe)七八糟 → 很乱"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("录音详情")
                        .font(.headline)
                    
                    HStack {
                        Label(recording.filename, systemImage: "waveform")
                            .font(.caption)
                        
                        Spacer()
                        
                        Label(recording.formattedDuration, systemImage: "clock")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    if !recording.dialect.isEmpty {
                        HStack {
                            Image(systemName: "globe.asia.australia")
                                .font(.caption)
                            Text("方言: \(Dialect.allDialects.first(where: { $0.code == recording.dialect })?.name ?? recording.dialect)")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                    
                    if !recording.text.isEmpty {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.caption)
                            Text("文字: \(recording.text)")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("添加音译 (选填)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(characterCount) 字符")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Sample transcriptions
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb")
                                .foregroundColor(.orange)
                            Text("音译示例")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(sampleTranscriptions.prefix(4), id: \.self) { sample in
                                Button(action: {
                                    phoneticText = sample
                                    characterCount = sample.count
                                    isTextFieldFocused = true
                                }) {
                                    Text(sample)
                                        .font(.caption)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                    
                    TextEditor(text: $phoneticText)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 120)
                        .focused($isTextFieldFocused)
                        .onChange(of: phoneticText) { newValue in
                            characterCount = newValue.count
                        }
                    
                    Text("请输入方言音译，格式如：来孛/别相 → 来玩")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        // Skip phonetic transcription and upload
                        var updatedRecording = recording
                        updatedRecording.phoneticTranscription = ""
                        recordingManager.updateRecording(updatedRecording)
                        
                        let fileURL = recordingManager.getFileURL(for: updatedRecording)
                        uploadManager.uploadRecording(updatedRecording, fileURL: fileURL, recordingManager: recordingManager)
                        
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.circle")
                            Text("跳过并上传")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        var updatedRecording = recording
                        updatedRecording.phoneticTranscription = phoneticText.trimmingCharacters(in: .whitespacesAndNewlines)
                        recordingManager.updateRecording(updatedRecording)
                        
                        let fileURL = recordingManager.getFileURL(for: updatedRecording)
                        uploadManager.uploadRecording(updatedRecording, fileURL: fileURL, recordingManager: recordingManager)
                        
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                            Text("添加并上传")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("第4步：音译 (选填)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            phoneticText = recording.phoneticTranscription
            characterCount = phoneticText.count
            isTextFieldFocused = true
        }
    }
}