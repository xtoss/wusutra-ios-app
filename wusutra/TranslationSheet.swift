import SwiftUI
import Combine

struct TranslationSheet: View {
    let recording: RecordingItem
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @Binding var isPresented: Bool
    
    @State private var text = ""
    @State private var phoneticText = ""
    @State private var characterCount = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var isLoadingTranscription = false
    @State private var transcriptionError: String?
    @State private var hasTranscribed = false
    @State private var modelVersion: String?
    
    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
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
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("输入正确文字")
                            .font(.headline)
                        
                        if hasTranscribed {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("AI转写")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        if isLoadingTranscription {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("\(characterCount) 字符")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    TextEditor(text: $text)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 120)
                        .focused($isTextFieldFocused)
                        .onChange(of: text) { newValue in
                            characterCount = newValue.count
                        }
                    
                    HStack {
                        Text("请输入您刚才用方言说的标准文字内容")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            getTranscription()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "mic.fill")
                                    .font(.caption)
                                Text("AI转写")
                                    .font(.caption.bold())
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        }
                        .disabled(isLoadingTranscription)
                    }
                    
                    if let error = transcriptionError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                // Phonetic transcription input
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "textformat.abc")
                            .foregroundColor(.blue)
                        Text("音译 (选填)")
                            .font(.headline)
                        Spacer()
                    }
                    
                    TextEditor(text: $phoneticText)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .frame(minHeight: 80)
                    
                    Text("请输入方言的音译，如：来孛/别相")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Submit button - always visible at bottom
                Button(action: {
                    var updatedRecording = recording
                    updatedRecording.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    updatedRecording.phoneticTranscription = phoneticText.trimmingCharacters(in: .whitespacesAndNewlines)
                    recordingManager.updateRecording(updatedRecording)
                    
                    let fileURL = recordingManager.getFileURL(for: updatedRecording)
                    uploadManager.uploadRecording(updatedRecording, fileURL: fileURL, recordingManager: recordingManager)
                    
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("上传")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!isValid)
                .padding(.horizontal)
                .padding(.bottom, 30) // Extra bottom padding for keyboard
                }
                .padding(.bottom) // Extra padding for ScrollView
            }
            .navigationTitle("第3步：输入正确文字")
            .navigationBarTitleDisplayMode(.inline)
            .keyboardAdaptive()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            text = recording.text
            phoneticText = recording.phoneticTranscription
            characterCount = text.count
            isTextFieldFocused = true
            
            // AUTO-TRANSCRIPTION DISABLED - users will input text manually
            // if text.isEmpty {
            //     getTranscription()
            // }
        }
    }
    
    private func getTranscription() {
        isLoadingTranscription = true
        transcriptionError = nil
        hasTranscribed = false
        
        let fileURL = recordingManager.getFileURL(for: recording)
        let apiBaseURL = UserDefaults.standard.string(forKey: "API_BASE_URL") ?? Constants.defaultAPIBaseURL
        
        guard !apiBaseURL.isEmpty else {
            transcriptionError = "请先设置API服务器地址"
            isLoadingTranscription = false
            return
        }
        
        // Create transcription request
        guard let url = URL(string: "\(apiBaseURL)/v1/transcribe") else {
            transcriptionError = "无效的API地址"
            isLoadingTranscription = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add audio file
        if let audioData = try? Data(contentsOf: fileURL) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"audio_file\"; filename=\"\(recording.filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
            body.append(audioData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoadingTranscription = false
                
                if let error = error {
                    transcriptionError = "网络错误: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data,
                      let response = try? JSONDecoder().decode(TranscriptionResponse.self, from: data) else {
                    transcriptionError = "无法解析服务器响应"
                    return
                }
                
                // Set the transcription if we got one
                if !response.transcription.isEmpty {
                    text = response.transcription
                    characterCount = text.count
                    hasTranscribed = true
                    modelVersion = response.model_version
                }
            }
        }.resume()
    }
}

struct TranscriptionResponse: Codable {
    let transcription: String
    let model_version: String
}

// Keyboard adaptive modifier
extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                self.keyboardHeight = keyboardHeight
            }
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { notification in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}