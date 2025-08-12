import SwiftUI

@main
struct wusutraApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @StateObject private var recordingManager = RecordingManager()
    @StateObject private var uploadManager = UploadManager()
    @AppStorage("API_BASE_URL") private var apiBaseURL = "https://example.com"
    
    var body: some View {
        TabView {
            RecordView(recordingManager: recordingManager, uploadManager: uploadManager)
                .tabItem {
                    Label("Record", systemImage: "mic.circle.fill")
                }
            
            LibraryView(recordingManager: recordingManager, uploadManager: uploadManager)
                .tabItem {
                    Label("Library", systemImage: "folder.fill")
                }
        }
        .onAppear {
            uploadManager.apiBaseURL = apiBaseURL
        }
        .onChange(of: apiBaseURL) { newValue in
            uploadManager.apiBaseURL = newValue
        }
    }
}