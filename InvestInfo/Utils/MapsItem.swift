import UIKit
import MapKit

final class MapsItem: NSObject {
    var position: CLLocationCoordinate2D
    let ownerId: Int

    init(_ position: CLLocationCoordinate2D, _ ownerId: Int) {
        self.position = position
        self.ownerId = ownerId
    }
    
    init(_ mapsData: MapsData) {
        self.position = CLLocationCoordinate2D(latitude: mapsData.latitude, longitude: mapsData.longitude)
        self.ownerId = mapsData.ownerId
    }
}

extension MapsItem: MKAnnotation {
    @objc dynamic var coordinate: CLLocationCoordinate2D {
        get { return position }
        set { position = newValue }
    }
}

// MARK: - MapsItemViewProtocol
protocol MapsItemViewProtocol where Self: MKMarkerAnnotationView {
    var mapsItem: MapsItem? { get }
}

// MARK: - MapsItemView
final class MapsItemView: MKMarkerAnnotationView, MapsItemViewProtocol {
    static let reuseID = "mapsItem"
    private(set) var mapsItem: MapsItem?
    
    init(annotation: MKAnnotation?) {
        super.init(annotation: annotation, reuseIdentifier: MapsItemView.reuseID)
        clusteringIdentifier = MapsItemView.reuseID
        guard let mapsItem = annotation as? MapsItem else { return }
        self.mapsItem = mapsItem
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        displayPriority = .defaultHigh
        markerTintColor = .red
        glyphImage = UIImage(systemName: "repeat.circle")
    }
}
