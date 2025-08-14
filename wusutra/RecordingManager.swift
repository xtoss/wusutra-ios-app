import AVFoundation
import SwiftUI

@MainActor
class RecordingManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var recordings: [RecordingItem] = []
    @Published var hasPermission = false
    @Published var permissionDenied = false
    @Published var selectedDialect = ""
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let metadataFileName = "recordings_metadata.json"
    
    override init() {
        super.init()
        checkPermission()
        loadRecordings()
    }
    
    func checkPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            hasPermission = true
        case .denied:
            hasPermission = false
            permissionDenied = true
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.hasPermission = granted
                    self?.permissionDenied = !granted
                }
            }
        @unknown default:
            hasPermission = false
        }
    }
    
    func startRecording() {
        guard hasPermission else { return }
        
        let fileName = generateFileName()
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            startTimer()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording(completion: @escaping (RecordingItem?) -> Void) {
        guard let recorder = audioRecorder else {
            completion(nil)
            return
        }
        
        let url = recorder.url
        let duration = recorder.currentTime
        recorder.stop()
        
        audioRecorder = nil
        isRecording = false
        stopTimer()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate session: \(error)")
        }
        
        let recording = RecordingItem(
            id: UUID().uuidString,
            filename: url.lastPathComponent,
            duration: duration,
            createdAt: Date(),
            text: "",
            dialect: selectedDialect,
            status: .pending,
            userId: getUserId()
        )
        
        recordings.insert(recording, at: 0)
        saveRecordings()
        completion(recording)
    }
    
    func updateRecording(_ recording: RecordingItem) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
            saveRecordings()
        }
    }
    
    func deleteRecording(_ recording: RecordingItem) {
        let fileURL = documentsPath.appendingPathComponent(recording.filename)
        try? FileManager.default.removeItem(at: fileURL)
        
        recordings.removeAll { $0.id == recording.id }
        saveRecordings()
    }
    
    func getFileURL(for recording: RecordingItem) -> URL {
        return documentsPath.appendingPathComponent(recording.filename)
    }
    
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "\(formatter.string(from: Date())).m4a"
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.recordingTime += 0.1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingTime = 0
    }
    
    private func loadRecordings() {
        let metadataURL = documentsPath.appendingPathComponent(metadataFileName)
        guard let data = try? Data(contentsOf: metadataURL),
              let decoded = try? JSONDecoder().decode([RecordingItem].self, from: data) else {
            return
        }
        recordings = decoded
    }
    
    private func saveRecordings() {
        let metadataURL = documentsPath.appendingPathComponent(metadataFileName)
        guard let encoded = try? JSONEncoder().encode(recordings) else { return }
        try? encoded.write(to: metadataURL)
    }
    
    private func getUserId() -> String {
        // Check if we have a stored user ID
        if let storedId = UserDefaults.standard.string(forKey: "wusutra_user_id") {
            return storedId
        }
        
        // Generate a new user ID if none exists
        let newId = "user_\(UUID().uuidString.prefix(8))"
        UserDefaults.standard.set(newId, forKey: "wusutra_user_id")
        return newId
    }
}