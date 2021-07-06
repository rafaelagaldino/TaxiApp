//
//  PickupViewController.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 18/03/21.
//
import UIKit
import MapKit

protocol PickupControllerDelegate: AnyObject {
    func didAcceptTrip(_ trip: Trip)
}

class PickupViewController: UIViewController {
   // MARK: - Properties
    weak var delegate: PickupControllerDelegate?
    private let mapView = MKMapView()
    let trip: Trip
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.anchor(centerX: (cp.centerXAnchor, 0),
                       centerY: (cp.centerYAnchor, 32),
                       width: 268, height: 268)
        mapView.layer.cornerRadius = 268 / 2
        
        return cp
    }()
    
    private let cancelbutton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissed), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this passenger"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        button.backgroundColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("ACCEPT TRIP", for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.modalPresentationStyle = .fullScreen
//        navigationController?.navigationBar.barStyle = .black // atualiza a cor da tabbar para branco
        print("DEBUG: Trip passenger uid is \(trip.passengerUid)")
        configureUI()
        configureMapView()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
     
    // MARK: - Selectors
    @objc func handleAcceptTrip() {
        DriverService.shared.acceptTrip(trip: trip) { error, ref in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    @objc func handleDismissed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 5, value: 0) {
            DriverService.shared.updateTripState(trip: self.trip, state: .denied) { error, ref in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    // MARK: - API
    
    // MARK: - Helper functions
    func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)

        mapView.addAnnotationAndSelect(forCoordinate: trip.pickupCoordinates)
    }
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(cancelbutton)
        cancelbutton.anchor(top: (view.safeAreaLayoutGuide.topAnchor, 0),
                            leading: (view.leadingAnchor, 16))
        
        view.addSubview(circularProgressView)
        circularProgressView.anchor(centerX: (view.centerXAnchor, 0),
                                    top: (view.safeAreaLayoutGuide.topAnchor, 32),
                                    width: 360, height: 360)
        
        view.addSubview(pickupLabel)
        pickupLabel.anchor(centerX: (view.centerXAnchor, 0),
                           top: (circularProgressView.bottomAnchor, 32))
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(centerX: (view.centerXAnchor, 0),
                                top: (pickupLabel.bottomAnchor, 16),
                                leading: (view.leadingAnchor, 32),
                                trailing: (view.trailingAnchor, 32),
                                height: 50)
    }
}

extension UINavigationController { // Método usado para esconder a tabbar
    open override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? true
    }
}
