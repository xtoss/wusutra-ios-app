import SwiftUI

struct EditTextSheet: View {
    let recording: RecordingItem
    @ObservedObject var recordingManager: RecordingManager
    @ObservedObject var uploadManager: UploadManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
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
                        Text("Text/Translation")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(characterCount) characters")
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
                    
                    Text("Edit the text or translation for this audio recording")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        var updatedRecording = recording
                        updatedRecording.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        recordingManager.updateRecording(updatedRecording)
                        dismiss()
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isValid)
                    
                    Button(action: {
                        var updatedRecording = recording
                        updatedRecording.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        recordingManager.updateRecording(updatedRecording)
                        
                        let fileURL = recordingManager.getFileURL(for: updatedRecording)
                        uploadManager.uploadRecording(updatedRecording, fileURL: fileURL, recordingManager: recordingManager)
                        
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                            Text("Save & Upload")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.green : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!isValid)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Edit Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            text = recording.text
            characterCount = recording.text.count
            isTextFieldFocused = true
        }
    }
}