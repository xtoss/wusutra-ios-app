import AVFoundation
import SwiftUI

@MainActor
class AudioPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var currentlyPlayingID: String?
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    func playRecording(_ recording: RecordingItem, fileURL: URL) {
        // Stop current playback if any
        stop()
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = AudioPlayerDelegate(player: self)
            audioPlayer?.prepareToPlay()
            
            duration = audioPlayer?.duration ?? 0
            currentTime = 0
            currentlyPlayingID = recording.id
            
            audioPlayer?.play()
            isPlaying = true
            startTimer()
            
        } catch {
            print("Failed to play recording: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        currentlyPlayingID = nil
        stopTimer()
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate session: \(error)")
        }
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateCurrentTime()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCurrentTime() {
        currentTime = audioPlayer?.currentTime ?? 0
    }
    
    func audioDidFinishPlaying() {
        isPlaying = false
        currentTime = 0
        currentlyPlayingID = nil
        stopTimer()
    }
}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    weak var player: AudioPlayer?
    
    init(player: AudioPlayer) {
        self.player = player
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.player?.audioDidFinishPlaying()
        }
    }
}