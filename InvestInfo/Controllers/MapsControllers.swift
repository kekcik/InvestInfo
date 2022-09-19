//
//  MapsControllers.swift
//  InvestInfo
//
//  Created by Владимир Микищенко on 19.09.2022.
//

import UIKit
import MapKit

final class MapsController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    private let plusButton = UIButton()
    private let currentPositionButton = UIButton()
    private let minusButton = UIButton()
    private let buttonsStack = UIStackView()
    
    private var locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        setupLocation()
        setupMapView()
        setupButtons()
        registerAnnotationViewClasses()
    }
    
    deinit {
        stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension MapsController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
        currentCoordinate = latestLocation.coordinate
        manager.stopUpdatingLocation()
        mapView.showsUserLocation = true
        guard let currentCoordinate = currentCoordinate else { return }
        zoomTo(currentCoordinate)
    }
}

// MARK: - MKMapViewDelegate
extension MapsController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapsItem else { return nil }
        return MapsItemView(annotation: annotation)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        obtainMapsItems(for: mapView.centerCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let mapsItem = (view as? MapsItemViewProtocol)?.mapsItem else {
            /// если нажали на кластер, пробуем показать содержимое
            guard let cluster = view.annotation as? MKClusterAnnotation else { return }
            mapView.showAnnotations(cluster.memberAnnotations, animated: true)
            mapView.deselectAnnotation(cluster, animated: true)
            return
        }
        showDetails(mapsItem, view.annotation)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        hideItemDetails()
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        hideItemDetails()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        showClusterContent()
    }
}


// MARK: - Helper
private extension MapsController {
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func setupMapView() {
        mapView.delegate = self
        mapView.showsCompass = true
        obtainMapsItems(for: mapView.centerCoordinate)
    }
    
    func setupButtons() {
        
        plusButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        plusButton.addTarget(self, action: #selector(zoomIn), for: .touchUpInside)
        currentPositionButton.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        currentPositionButton.addTarget(self, action: #selector(goToCurrentPosition), for: .touchUpInside)
        minusButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        minusButton.addTarget(self, action: #selector(zoomOut), for: .touchUpInside)
        [ plusButton, currentPositionButton, minusButton ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 30).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            buttonsStack.addArrangedSubview($0)
        }
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 8
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(buttonsStack)
        buttonsStack.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        buttonsStack.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16).isActive = true
        
    }
    
    func registerAnnotationViewClasses() {
        mapView.register(MapsItemView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    // MARK: - Zooming
    @objc func zoomIn() {
        var region = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }
    
    @objc func zoomOut() {
        var region = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func goToCurrentPosition() {
        guard let currentCoordinate = currentCoordinate else { return }
        zoomTo(currentCoordinate)
    }
    
    func zoomTo(_ coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    //MARK: - AddItems
    func obtainMapsItems(for coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async { [weak self] in
            let mapsItems = MapsDataSource.markers.compactMap { MapsItem($0) }
            self?.mapView.addAnnotations(mapsItems)
        }
    }
    
    func showDetails(_ mapsItem: MapsItem, _ annotation: MKAnnotation?) {
        let vc = UIAlertController(title: "Отделение банка", message: "Меняем шило на мыло. Не забудь паспорт", preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Проложить маршрут", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let routeInfo = RouteInfo(startPoint: self.currentCoordinate, endPoint: mapsItem.position)
            self.showMenu(routeInfo, annotation)
        }))
        vc.addAction(UIAlertAction(title: "Не поеду никуда", style: .default, handler: { [weak self] _ in
            self?.mapView.deselectAnnotation(annotation, animated: true)
        }))
        present(vc, animated: true)
    }
    
    func showMenu(_ routeInfo: RouteInfo, _ annotation: MKAnnotation?) {
        let alertVC = UIAlertController(title: "Проложить маршрут",
                                        message: "используя сторонние приложения или браузер:",
                                        preferredStyle: .actionSheet)
        RouteInfo.RouteKey.allCases.forEach {
            let info = routeInfo.getInfo($0)
            alertVC.addAction(UIAlertAction(title: info.title, style: .default) { [weak self] _ in
                self?.open(info.appURL, info.webURL)
                self?.mapView.deselectAnnotation(annotation, animated: true)
            })
        }
        alertVC.addAction(UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.mapView.deselectAnnotation(annotation, animated: true)
        })
        present(alertVC, animated: true)
    }
    
    func open(_ appURL: String, _ webURL: String) {
        if let url = URL(string: appURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else if let url = URL(string: webURL) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

// MARK: - MapsItem
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

// MARK: - RouteInfo
struct RouteInfo {
    let startPoint, endPoint: CLLocationCoordinate2D?
    
    enum RouteKey: String, CaseIterable {
        case yandexMaps, appleMaps, googleMaps, doubleGis
    }
    
    struct MapsRouteInfo {
        let title, name, appURL, webURL: String
    }
    
    func getInfo(_ key: RouteKey) -> MapsRouteInfo {
        let start = joinText(getText(from: startPoint?.latitude), getText(from: startPoint?.longitude))
        let end =   joinText(getText(from: endPoint?.latitude), getText(from: endPoint?.longitude))
        let start2Gis = joinText(getText(from: startPoint?.longitude), getText(from: startPoint?.latitude))
        let end2Gis =   joinText(getText(from: endPoint?.longitude), getText(from: endPoint?.latitude))
        
        switch key {
        case .yandexMaps:
            let suffix = start.isEmpty ?
            ["~", end].joined() : [start, end].joined(separator: "~")
            let appURL = ["yandexmaps://maps.yandex.ru/?rtext=", suffix].joined()
            let webURL = ["https://yandex.ru/maps/?rtext=", suffix].joined()
            return MapsRouteInfo(title: "Яндекс.Карты", name: "ЯндексКарты", appURL: appURL, webURL: webURL)
        case .appleMaps:
            let suffix = start.isEmpty ?
            ["daddr=", end].joined() : ["saddr=", start, "&daddr=", end].joined()
            let appURL = ["maps://?", suffix].joined()
            let webURL = ["https://maps.apple.com/?", suffix].joined()
            return MapsRouteInfo(title: "Карты", name: "AppleMaps", appURL: appURL, webURL: webURL)
        case .googleMaps:
            let appSuffix = start.isEmpty ?
            ["daddr=", end].joined() : ["saddr=", start, "&daddr=", end].joined()
            let webSuffix = start.isEmpty ?
            ["/", end].joined() : [start, end].joined(separator: "/")
            let appURL = ["comgooglemaps://?", appSuffix].joined()
            let webURL = ["https://google.com/maps/dir/", webSuffix].joined()
            return MapsRouteInfo(title: "Google Maps", name: "GoogleMaps", appURL: appURL, webURL: webURL)
        case .doubleGis:
            let suffix = start2Gis.isEmpty ?
            ["2gis.ru/routeSearch/rsType/car/to/", end2Gis].joined() :
            ["2gis.ru/routeSearch/rsType/car/from/", start2Gis, "/to/", end2Gis].joined()
            let appURL = ["dgis://", suffix].joined()
            let webURL = ["https://", suffix].joined()
            return MapsRouteInfo(title: "2ГИС", name: "2ГИС", appURL: appURL, webURL: webURL)
        }
    }
}

private extension RouteInfo {
    func getText(from: Double?) -> String? {
        guard let from = from else { return nil }
        return String(describing: from)
    }
    
    func joinText(_ text1: String?, _ text2: String?) -> String {
        guard let text1 = text1, let text2 = text2 else { return "" }
        return [text1, text2].joined(separator: ",")
    }
}
