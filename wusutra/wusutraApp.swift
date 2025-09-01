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
    @StateObject private var promptsService = PromptsService.shared
    @AppStorage("API_BASE_URL") private var apiBaseURL = Constants.defaultAPIBaseURL
    
    var body: some View {
        TabView {
            RecordView(recordingManager: recordingManager, uploadManager: uploadManager)
                .tabItem {
                    Label("录音", systemImage: "mic.circle.fill")
                }
            
            LibraryView(recordingManager: recordingManager, uploadManager: uploadManager)
                .tabItem {
                    Label("录音库", systemImage: "folder.fill")
                }
            
            LeaderboardView(recordingManager: recordingManager)
                .tabItem {
                    Label("排行榜", systemImage: "trophy.fill")
                }
            
            TrainingView()
                .tabItem {
                    Label("训练中心", systemImage: "cpu")
                }
            
            DialectMapView(recordingManager: recordingManager)
                .tabItem {
                    Label("方言地图", systemImage: "map.fill")
                }
            
            AdminAuditView(recordingManager: recordingManager)
                .tabItem {
                    Label("审核", systemImage: "checkmark.shield.fill")
                }
        }
        .onAppear {
            uploadManager.apiBaseURL = apiBaseURL
            promptsService.loadPromptsOnce(apiBaseURL: apiBaseURL)
        }
        .onChange(of: apiBaseURL) { newValue in
            uploadManager.apiBaseURL = newValue
        }
    }
}
