import SwiftUI
import MapKit

struct DialectMapView: View {
    @ObservedObject var recordingManager: RecordingManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.0, longitude: 105.0), // Center of China
        span: MKCoordinateSpan(latitudeDelta: 20.0, longitudeDelta: 20.0)
    )
    @State private var selectedDialect: String?
    
    private var dialectStats: [String: Int] {
        var stats: [String: Int] = [:]
        for recording in recordingManager.recordings {
            if !recording.dialect.isEmpty && recording.status == .uploaded {
                stats[recording.dialect, default: 0] += 1
            }
        }
        return stats
    }
    
    private var totalRecordings: Int {
        dialectStats.values.reduce(0, +)
    }
    
    private var dialectRegions: Int {
        dialectStats.count
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "map.fill")
                            .foregroundColor(.blue)
                        Text("方言地图")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("探索全国各地的方言分布和贡献热度")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(dialectRegions)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("个地区")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(totalRecordings)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("条录音")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                
                // Map Container
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "globe.asia.australia")
                            .foregroundColor(.orange)
                        Text("方言贡献地图")
                            .font(.headline)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Text("\(dialectRegions)个地区")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("\(totalRecordings)条录音")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Interactive Map
                    ZStack {
                        Map(coordinateRegion: $region, annotationItems: dialectAnnotations) { annotation in
                            MapAnnotation(coordinate: annotation.coordinate) {
                                DialectMapPin(
                                    dialect: annotation.dialect,
                                    count: annotation.count,
                                    isSelected: selectedDialect == annotation.dialect.code
                                )
                                .onTapGesture {
                                    selectedDialect = annotation.dialect.code
                                }
                            }
                        }
                        .frame(height: 300)
                        .cornerRadius(12)
                        
                        // Map controls
                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Button(action: { zoomIn() }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .medium))
                                            .frame(width: 32, height: 32)
                                            .background(Color.white)
                                            .cornerRadius(6)
                                            .shadow(radius: 2)
                                    }
                                    
                                    Button(action: { zoomOut() }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 16, weight: .medium))
                                            .frame(width: 32, height: 32)
                                            .background(Color.white)
                                            .cornerRadius(6)
                                            .shadow(radius: 2)
                                    }
                                }
                                .padding(.trailing, 12)
                            }
                            Spacer()
                        }
                        .padding(.top, 12)
                    }
                    
                    // Legend
                    HStack {
                        Text("图例:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("1-5条")
                                    .font(.caption2)
                            }
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 10, height: 10)
                                Text("6-20条")
                                    .font(.caption2)
                            }
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 12, height: 12)
                                Text("20+条")
                                    .font(.caption2)
                            }
                        }
                        .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding()
                
                // Statistics List
                if !dialectStats.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("方言统计")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(dialectStats.sorted(by: { $0.value > $1.value }), id: \.key) { dialectCode, count in
                                    if let dialect = Dialect.allDialects.first(where: { $0.code == dialectCode }) {
                                        DialectStatRow(
                                            dialect: dialect,
                                            count: count,
                                            percentage: Double(count) / Double(totalRecordings),
                                            isSelected: selectedDialect == dialectCode
                                        )
                                        .onTapGesture {
                                            selectedDialect = selectedDialect == dialectCode ? nil : dialectCode
                                            focusOnDialect(dialectCode)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("方言地图")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var dialectAnnotations: [DialectAnnotation] {
        dialectStats.compactMap { dialectCode, count in
            guard let dialect = Dialect.allDialects.first(where: { $0.code == dialectCode }),
                  let coordinate = dialectCoordinates[dialectCode] else {
                return nil
            }
            return DialectAnnotation(dialect: dialect, count: count, coordinate: coordinate)
        }
    }
    
    private func zoomIn() {
        region.span.latitudeDelta *= 0.7
        region.span.longitudeDelta *= 0.7
    }
    
    private func zoomOut() {
        region.span.latitudeDelta *= 1.3
        region.span.longitudeDelta *= 1.3
    }
    
    private func focusOnDialect(_ dialectCode: String) {
        if let coordinate = dialectCoordinates[dialectCode] {
            withAnimation(.easeInOut(duration: 1.0)) {
                region.center = coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
            }
        }
    }
}

struct DialectAnnotation: Identifiable {
    let id = UUID()
    let dialect: Dialect
    let count: Int
    let coordinate: CLLocationCoordinate2D
}

struct DialectMapPin: View {
    let dialect: Dialect
    let count: Int
    let isSelected: Bool
    
    private var pinColor: Color {
        if count >= 20 { return .red }
        else if count >= 6 { return .orange }
        else { return .green }
    }
    
    private var pinSize: CGFloat {
        if count >= 20 { return 24 }
        else if count >= 6 { return 20 }
        else { return 16 }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: pinSize, height: pinSize)
                
                if isSelected {
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: pinSize + 6, height: pinSize + 6)
                }
                
                Text("\(count)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            if isSelected {
                Text(dialect.name)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white)
                    .cornerRadius(4)
                    .shadow(radius: 1)
            }
        }
    }
}

struct DialectStatRow: View {
    let dialect: Dialect
    let count: Int
    let percentage: Double
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(dialect.name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Text("\(count)条录音")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(percentage * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * percentage, height: 4)
                    }
                }
                .frame(width: 60, height: 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

// Approximate coordinates for Chinese dialect regions
private let dialectCoordinates: [String: CLLocationCoordinate2D] = [
    "jianghuai": CLLocationCoordinate2D(latitude: 32.0, longitude: 118.8), // Nanjing area
    "wu": CLLocationCoordinate2D(latitude: 31.2, longitude: 121.5), // Shanghai area
    "cantonese": CLLocationCoordinate2D(latitude: 23.1, longitude: 113.3), // Guangzhou
    "minnan": CLLocationCoordinate2D(latitude: 24.5, longitude: 118.1), // Fujian
    "hakka": CLLocationCoordinate2D(latitude: 25.3, longitude: 115.0), // Ganzhou area
    "xiang": CLLocationCoordinate2D(latitude: 28.2, longitude: 112.9), // Changsha
    "gan": CLLocationCoordinate2D(latitude: 28.7, longitude: 115.9), // Nanchang
    "jin": CLLocationCoordinate2D(latitude: 37.9, longitude: 112.6), // Taiyuan
    "mandarin": CLLocationCoordinate2D(latitude: 39.9, longitude: 116.4), // Beijing
    "other": CLLocationCoordinate2D(latitude: 35.0, longitude: 105.0) // Central China
]