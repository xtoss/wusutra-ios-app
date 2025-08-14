import Foundation
import SwiftUI

@MainActor
class UploadManager: ObservableObject {
    @Published var uploadQueue: [String] = []
    @Published var isUploading = false
    var apiBaseURL = "https://example.com"
    
    private let maxRetries = 3
    private var baseDelay = 1.0
    
    func uploadRecording(_ recording: RecordingItem, fileURL: URL, recordingManager: RecordingManager) {
        guard !recording.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Cannot upload recording without text: \(recording.filename)")
            return
        }
        
        print("🚀 Starting upload for: \(recording.filename)")
        print("   API Base URL: \(apiBaseURL)")
        
        var updatedRecording = recording
        updatedRecording.status = .uploading
        recordingManager.updateRecording(updatedRecording)
        
        uploadQueue.append(recording.id)
        isUploading = true
        
        performUpload(recording: updatedRecording, fileURL: fileURL, recordingManager: recordingManager, attempt: 1)
    }
    
    private func performUpload(recording: RecordingItem, fileURL: URL, recordingManager: RecordingManager, attempt: Int) {
        NetworkingClient.shared.uploadRecording(
            fileURL: fileURL,
            recording: recording,
            apiBaseURL: apiBaseURL
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    var updatedRecording = recording
                    updatedRecording.status = .uploaded
                    updatedRecording.lastError = nil
                    recordingManager.updateRecording(updatedRecording)
                    self?.removeFromQueue(recording.id)
                    
                case .failure(let error):
                    print("❌ Upload failed for \(recording.filename): \(error.localizedDescription)")
                    print("❌ No retry - debugging mode")
                    
                    var updatedRecording = recording
                    updatedRecording.status = .failed
                    updatedRecording.uploadAttempts = attempt
                    updatedRecording.lastError = error.localizedDescription
                    recordingManager.updateRecording(updatedRecording)
                    self?.removeFromQueue(recording.id)
                }
            }
        }
    }
    
    func retryUpload(_ recording: RecordingItem, recordingManager: RecordingManager) {
        let fileURL = recordingManager.getFileURL(for: recording)
        var updatedRecording = recording
        updatedRecording.uploadAttempts = 0
        updatedRecording.lastError = nil
        uploadRecording(updatedRecording, fileURL: fileURL, recordingManager: recordingManager)
    }
    
    private func removeFromQueue(_ id: String) {
        uploadQueue.removeAll { $0 == id }
        if uploadQueue.isEmpty {
            isUploading = false
        }
    }
}