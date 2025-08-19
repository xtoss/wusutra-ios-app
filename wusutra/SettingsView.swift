import SwiftUI

struct SettingsView: View {
    @AppStorage("API_BASE_URL") private var apiBaseURL = "https://9848be0d46d7.ngrok-free.app"
    @Environment(\.dismiss) private var dismiss
    @State private var tempURL = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Base URL")
                            .font(.headline)
                        
                        TextField("https://9848be0d46d7.ngrok-free.app", text: $tempURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.URL)
                        
                        Text("The base URL for uploading recordings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Server Configuration")
                }
                
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        apiBaseURL = tempURL
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempURL = apiBaseURL
        }
    }
}