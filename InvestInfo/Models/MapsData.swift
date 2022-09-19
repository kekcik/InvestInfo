import Foundation

struct MapsData {
    let ownerId: Int
    let latitude: Double
    let longitude: Double
}

enum MapsDataSource {
    static let markers = [
        MapsData(ownerId: 545, latitude: 55.753098, longitude: 37.633937),
        MapsData(ownerId: 577, latitude: 55.753521, longitude: 37.634584),
        MapsData(ownerId: 630, latitude: 55.765238, longitude: 37.63867),
        MapsData(ownerId: 550, latitude: 55.752993, longitude: 37.591164),
        MapsData(ownerId: 615, latitude: 55.7713, longitude: 37.595887)
    ]
}
