//
//  HomeViewController.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 06/01/21.
//

import UIKit
import Firebase
import MapKit
import MapKitGoogleStyler

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

// Casos de destino e coleta
private enum AnnotationType: String {
    case pickup
    case destination
}

protocol HomeControllerDelegate: AnyObject {
    func handleMenuToggle()
}

class HomeViewController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var savedLocations = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 220
    private final let rideActionViewHeight: CGFloat = 300
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    weak var delegate: HomeControllerDelegate?
    
    var user: User? {
        didSet {
            self.locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
                configureSavedUserLocations()
            } else {
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet {
            print("DEBUG: Show pickup passenger controller..")
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
                let controller = PickupViewController(trip: trip)
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                present(controller, animated: true, completion: nil)
            } else {
                print("DEBUG: Show ride action view for accepted trip...")
            }
        }
    }

    private let viewButton: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.addShadow()
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOpacity = 0.10
//        view.layer.shadowOffset = CGSize(width: 5.5, height: 5.5)
//        view.layer.masksToBounds = false
        return view
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
//        mapView.overrideUserInterfaceStyle = .dark
        addOverlay()
        enableLocationService()
        configureUI()
        configureSavedUserLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return }
        print("DEBUG: Trip is state \(trip.state)")
    }
    
    private func addOverlay() {
        guard let overlayFileURLString = Bundle.main.path(forResource: "Overlay", ofType: "json") else { return }
                
        let overlayFileURL = URL(fileURLWithPath: overlayFileURLString)
                
        guard let tileOverlay = try? MapKitGoogleStyler.buildOverlay(with: overlayFileURL) else { return }
                
        mapView.addOverlay(tileOverlay)
    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    func configureSavedUserLocations() {
        guard let user = user else { return }
        savedLocations.removeAll()
        
        if let homeLocation = user.homeLocation {
            geocodeAddressString(address: homeLocation)
        }
        
        if let workLocation = user.workLocation {
            geocodeAddressString(address: workLocation)
        }
    }
    
    func geocodeAddressString(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let clPlacemark = placemarks?.first else { return }
            let placemark = MKPlacemark(placemark: clPlacemark)
            self.savedLocations.append(placemark)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Selectors
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            delegate?.handleMenuToggle()
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            self.mapView.showAnnotations(mapView.annotations, animated: true)

            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
        }
    }
    
    // MARK: - API
    func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            self.trip = trip
            guard let state = trip.state else { return }
            guard let driverUid = trip.driverUid else { return }

            switch state {
            case .requested:
                break
            case .denied:
                self.shouldPresentLoadingView(false)
                self.presentAlertController(withTitle: "Oops", message: "It looks like we couldnt find you a driver. Please try again..")
                PassengerService.shared.cancelTrip { error, ref in
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.removeAnnotationsAndOverlays()
                }
            case .accepted:
                print("DEBUG: Trip was accepted")
                self.shouldPresentLoadingView(false)
                self.removeAnnotationsAndOverlays()
                self.zoomForActiveTrip(withDriverUid: driverUid)
                Service.shared.fetchUserData(uid: driverUid) { driver in
                    self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: driver)
                }
            case .driverArrived:
                self.rideActionView.config = .driverArrived
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                self.animateRideActionView(shouldShow: false)
                self.centerMapOnUserLocation()
                self.configureActionButton(config: .showMenu)
                self.inputActivationView.alpha = 1
                self.presentAlertController(withTitle: "Trip Completed", message: "We hope you enjoyed your trip")
            }
        }
    }
    func startTrip() {
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .inProgress) { (error, ref) in
            self.rideActionView.config = .tripInProgress
            self.removeAnnotationsAndOverlays()
            self.mapView.addAnnotationAndSelect(forCoordinate: trip.destinationCoordinates)
            
            let placemark = MKPlacemark(coordinate: trip.destinationCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            
            self.setCustomRegion(withType: .destination, withCoordinates: trip.destinationCoordinates)
            self.generatePolyline(toDestination: mapItem)
            
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
        }
    }
    
    func fetchDrivers() {
        guard user?.accountType == .passenger else {
            print("DEBUG: User accounttype is: \(String(describing: user?.accountType))")
            return
        }
        guard let location = locationManager?.location else { return }
        PassengerService.shared.fetchDrivers(location: location) { driver in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            print("&&&&& ", coordinate)
            var driversIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false }
                    if driverAnno.uid == driver.uid {
                        print("**** ", coordinate)
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveTrip(withDriverUid: driver.uid)
                        return true
                    }
                    return false
                })
            }

            if !driversIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    // MARK: - Drivers API
    func observeTrips() {
        DriverService.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    func observeCancelledTrip(trip: Trip) {
        DriverService.shared.observeTripsCancelled(trip: trip) {
            self.removeAnnotationsAndOverlays()
            self.animateRideActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withTitle: "Oops!", message: "The passenger has decided to cancel this trip. Press Ok to continue.")
        }
    }

    // MARK: - Helper Functions
    func configure() {
        configureUI()
    }
    
    func configureUI() {
        configureMapView()
        configureRideActionView()
        
        view.addSubview(viewButton)
        viewButton.anchor(top: (view.safeAreaLayoutGuide.topAnchor, 16),
                          leading: (view.leadingAnchor, 16),
                          width: 40,
                          height: 40)
        
        viewButton.addSubview(actionButton)
        actionButton.anchor(centerX: (viewButton.centerXAnchor, 0),
                            centerY: (viewButton.centerYAnchor, 0),
                            width: 26,
                            height: 26)
        configureTableView()
    }
    
    func configureLocationInputActivationView() {
        inputActivationView.layer.cornerRadius = 26.0

        view.addSubview(inputActivationView)
        inputActivationView.anchor(centerX: (view.centerXAnchor, 0),
                                   top: (actionButton.bottomAnchor, 32),
                                   leading: (view.leadingAnchor, 30),
                                   trailing: (view.trailingAnchor, 30),
                                   height: 50)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top: (view.topAnchor, 0),
                                 leading: (view.leadingAnchor, 0),
                                 trailing: (view.trailingAnchor, 0),
                                 height: locationInputViewHeight)
        locationInputView.alpha = 0
        locationInputView.delegate = self
        
        UIView.animate(withDuration: 0.5) {
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }

    }
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
        rideActionView.delegate = self
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }
    
    func dismissLocationView(_ completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pick up region \(region)")
        }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring destination region \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DEBUG: Driver did enter passenger region")
        guard let trip = self.trip else { return }
        
        if region.identifier == AnnotationType.pickup.rawValue {
            print("DEBUG: Did start monitoring pick up region \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .driverArrived) { (error, ref) in
                self.rideActionView.config = .pickupPassenger
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("DEBUG: Did start monitoring destination region \(region)")
            DriverService.shared.updateTripState(trip: trip, state: .arrivedAtDestination) { (error, ref) in
                self.rideActionView.config = .endTrip
            }
        }
    }
    
    func enableLocationService() {
        locationManager?.delegate = self
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Authorized always..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Authorized in use..")
            locationManager?.requestAlwaysAuthorization()
        default:
            break
        }
    }
}

extension HomeViewController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
}

extension HomeViewController: LocationInputViewDelegate {
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { results in
            self.searchResults = results
            self.tableView.reloadData()
        }

    }
    
    func dismissLocationInputView() {
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.5) {
                self.inputActivationView.alpha = 1
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved Locations" : "Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView()
        returnedView.backgroundColor = UIColor.white
        
        let label = UILabel(frame: CGRect(x: 10, y: 7, width: view.frame.size.width, height: 30))
        label.text = section == 0 ? "Saved Locations".uppercased() : "Results".uppercased()
        label.textColor = .lightGray
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedLocations.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: LocationCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? LocationCell else { return UITableViewCell() }
        if indexPath.section == 0 {
            cell.placemark = savedLocations[indexPath.row]
        }
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let seletedPlacemark = indexPath.section == 0 ? savedLocations[indexPath.row] : searchResults[indexPath.row]
        var annotations = [MKAnnotation]()

        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: seletedPlacemark)
        generatePolyline(toDestination: destination)
        addOverlay()
        
        dismissLocationView { _ in
            self.mapView.addAnnotationAndSelect(forCoordinate: seletedPlacemark.coordinate)

            let annotations = self.mapView.annotations.filter { !$0.isKind(of: DriverAnnotation.self) }
//            self.mapView.showAnnotations(annotations, animated: true)
            self.mapView.zoomToFit(annotations: annotations)
            self.animateRideActionView(shouldShow: true, destination: seletedPlacemark, config: .requestRide)
        }
    }
    
    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil, config: RideActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { return }
            
            if let destination = destination {
                rideActionView.destination = destination
            }
            
            if let user = user {
                rideActionView.user = user
            }
            
            rideActionView.config = config
        }
    }
}

// MARK: - Map Helper Functions
private extension HomeViewController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            response.mapItems.forEach { item in
                results.append(item.placemark)
            }
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes.first
            
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { annotation in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withType type: AnnotationType, withCoordinates coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 20, identifier: type.rawValue)
        locationManager?.startMonitoring(for: region)
        print("DEBUG: Did set region \(region)")
    }
    
    func zoomForActiveTrip(withDriverUid uid: String) {
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? DriverAnnotation {
                if anno.uid == uid {
                    annotations.append(anno)
                }
            }
            
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        }
        print("DEBUG: Annotations array is \(annotations)")
        self.mapView.zoomToFit(annotations: annotations)
    }
}

// MARK: - MKMapViewDelegate
extension HomeViewController: MKMapViewDelegate {
    // Função chamada toda vez que a localição do usuário é atualizada
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("DEBUG: Did update user location..")
        guard let user = self.user, let location = userLocation.location else { return }
        guard user.accountType == .driver else { return }
        DriverService.shared.updateDriverLocation(location: location)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let tileOverlay = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay: tileOverlay)
        } else {
            if let route = self.route {
                let line = MKPolylineRenderer(overlay: route.polyline)
                line.strokeColor = .systemBlue
                line.lineWidth = 3
                return line
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
//        if let route = self.route {
//            let line = MKPolylineRenderer(overlay: route.polyline)
//            line.strokeColor = .systemBlue
//            line.lineWidth = 3
//            return line
//        }
//        return MKOverlayRenderer()
    }
}

// MARK: - RideActionViewDelegate
extension HomeViewController: RideActionViewDelegate {
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate, let destinationCoordinate = view.destination?.coordinate else { return }
        
        shouldPresentLoadingView(true, "Finding you a ride..")
        PassengerService.shared.uploadTrip(pickupCoordinates, destinationCoordinates: destinationCoordinate) { (error, ref) in
            if let error = error {
                print("DEBUG: Failed to upload trip with error: \(error.localizedDescription)")
                return
            }
            print("DEBUG: Did upload trip successfully")
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
    func cancelTrip() {
        print("DEBUG: Handle Cancel Trip...")
        PassengerService.shared.cancelTrip { error, ref in
            if let error = error {
                print("DEBUG: Error deleting trip \(error.localizedDescription)")
                return
            }

            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
            self.removeAnnotationsAndOverlays()

            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            
            self.inputActivationView.alpha = 1
        }
    }
    
    func pickupPassenger() {
        startTrip()
    }
    
    func dropOffPassenger() {
        guard let trip = self.trip else { return }
        DriverService.shared.updateTripState(trip: trip, state: .completed) { (error, ref) in
            self.removeAnnotationsAndOverlays()
            self.centerMapOnUserLocation()
            self.animateRideActionView(shouldShow: false)
        }
    }
}

// MARK: - PickupControllerDelegate
extension HomeViewController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip = trip

        self.mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
        
        setCustomRegion(withType: .pickup, withCoordinates: trip.pickupCoordinates)
        
        let placemark = MKPlacemark(coordinate: trip.pickupCoordinates)
        let mapItem = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: mapItem)

        observeCancelledTrip(trip: trip)
//        mapView.zoomToFit(annotations: mapView.annotations)
        dismiss(animated: true) {
            Service.shared.fetchUserData(uid: trip.passengerUid) { passenger in
                self.animateRideActionView(shouldShow: true, config: .tripAccepted, user: passenger)
            }
        }
    }
}
