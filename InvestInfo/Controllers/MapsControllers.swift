//
//  MapsControllers.swift
//  InvestInfo
//
//  Created by Владимир Микищенко on 19.09.2022.
//

import UIKit
import MapKit

final class MapsController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    private let plusButton = UIButton()
    private let currentPositionButton = UIButton()
    private let minusButton = UIButton()
    private let buttonsStack = UIStackView()
    
    private var locationManager = CLLocationManager()
    private let defaultCoordinate = CLLocationCoordinate2D(latitude: 55.755786, longitude: 37.617633)
    private var currentCoordinate: CLLocationCoordinate2D? {
        didSet { currentPositionButton.isHidden = currentCoordinate == nil }
    }

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
        moveTo(currentCoordinate)
    }
}

// MARK: - MKMapViewDelegate
extension MapsController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapsItem else { return nil }
        return MapsItemView(annotation: annotation)
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
}

// MARK: - Helper
private extension MapsController {
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        guard
            CLLocationManager.locationServicesEnabled(),
            [.authorizedAlways, .authorizedWhenInUse, .notDetermined].contains(locationManager.authorizationStatus)
        else {
            currentCoordinate = nil
            moveTo(defaultCoordinate)
            return
        }
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
        let allButtons = [ plusButton, currentPositionButton, minusButton ]
        let allImages = [ "plus.circle", "person.crop.circle", "minus.circle" ]
        let allActions = [ #selector(zoomIn), #selector(goToCurrentPosition), #selector(zoomOut) ]
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 40))
        zip(allButtons, allImages).forEach { $0.setImage(UIImage(systemName: $1, withConfiguration: config), for: .normal) }
        zip(allButtons, allActions).forEach { $0.addTarget(self, action: $1, for: .touchUpInside) }
        currentPositionButton.isHidden = currentCoordinate == nil
        allButtons.forEach {
            $0.tintColor = .gray
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            buttonsStack.addArrangedSubview($0)
        }
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 8
        buttonsStack.distribution = .fillEqually
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(buttonsStack)
        buttonsStack.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
        buttonsStack.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -8).isActive = true
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
        moveTo(currentCoordinate)
    }
    
    func moveTo(_ coordinate: CLLocationCoordinate2D, _ meters: Double = 500.0) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: meters, longitudinalMeters: meters)
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
        let vc = UIAlertController(title: "Обменный пункт".uppercased(),
                                   message: "Меняем шило на мыло. Не забудь паспорт",
                                   preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Проложить маршрут", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let routeInfo = RouteInfo(startPoint: self.currentCoordinate, endPoint: mapsItem.position)
            self.showMenu(routeInfo, annotation)
        }))
        vc.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { [weak self] _ in
            self?.mapView.deselectAnnotation(annotation, animated: true)
        }))
        present(vc, animated: true)
    }
    
    func showMenu(_ routeInfo: RouteInfo, _ annotation: MKAnnotation?) {
        let alertVC = UIAlertController(title: "Проложить маршрут".uppercased(),
                                        message: "Используй сторонние приложения или браузер",
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
