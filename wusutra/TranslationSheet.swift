import SwiftUI

struct TranslationSheet: View {
    let recording: RecordingItem
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @Binding var isPresented: Bool
    
    @State private var text = ""
    @State private var phoneticText = ""
    @State private var characterCount = 0
    @FocusState private var isTextFieldFocused: Bool
    
    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("输入正确文字")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(characterCount) 字符")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    
                    Text("请输入您刚才用方言说的标准文字内容")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                
                Spacer()
                
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
                .padding(.bottom)
            }
            .navigationTitle("第3步：输入正确文字")
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
            text = recording.text
            phoneticText = recording.phoneticTranscription
            characterCount = text.count
            isTextFieldFocused = true
        }
    }
}