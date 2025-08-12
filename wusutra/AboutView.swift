import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("wusutra")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Crowdsourcing dialect audio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                VStack(spacing: 20) {
                    Link(destination: URL(string: "https://Wusutra.com")!) {
                        HStack {
                            Image(systemName: "globe")
                            Text("Visit Wusutra.com")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Privacy Notice", systemImage: "lock.shield")
                            .font(.headline)
                        
                        Text("This app crowdsources dialect audio and corresponding text. Do not upload sensitive content.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}