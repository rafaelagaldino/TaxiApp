//
//  RideActionView.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 28/02/21.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(_ view: RideActionView)
    func cancelTrip()
    func pickupPassenger()
    func dropOffPassenger()
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case driverArrived
    case pickupPassenger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

enum ButtonAction: CustomDebugStringConvertible {
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var debugDescription: String {
        switch self {
            case .requestRide: return "CONFIRM UBERX"
            case .cancel: return "CANCEL RIDE"
            case .getDirections: return "GET DIRECTIONS"
            case .pickup: return "PICKUP PASSENGER"
            case .dropOff: return "DROP OFF PASSANGER"
        }
    }
    
    init() {
        self = .requestRide
    }
}

class RideActionView: UIView {

    // MARK: - Properties
    var currentLocation: MKPlacemark? {
        didSet {
            titleDestinationLabel.text =  currentLocation?.name
            addressDestinationLabel.text = currentLocation?.address
        }
    }
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    var config = RideActionViewConfiguration() {
        didSet {
            configureUI(withConfig: config)
        }
    }
    
    var buttonAction = ButtonAction()
    
    weak var delegate: RideActionViewDelegate?
    var user: User?
    
    private let view: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 8/2
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Teste"
        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Teste Teste Teste Teste Teste"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let titleDestinationLabel: UILabel = {
        let label = UILabel()
        label.text = "Teste"
        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let addressDestinationLabel: UILabel = {
        let label = UILabel()
        label.text = "Teste Teste Teste Teste Teste"
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
//        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let infoViewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()
    
    private let uberInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER X"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBER", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 25.0
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        layer.cornerRadius = 40.0
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: (topAnchor, 30),
                     leading: (leadingAnchor, 70),
                     trailing: (trailingAnchor, 20))
        
        addSubview(view)
        view.anchor(centerY: (stack.centerYAnchor, 0),
                    trailing: (stack.leadingAnchor, 20),
                    width: 8.0,
                    height: 8.0)
        
//        addSubview(infoView)
//        infoView.anchor(centerX: (centerXAnchor, 0),
//                        top: (stack.bottomAnchor, 16),
//                        width: 60, height: 60)
//        infoView.layer.cornerRadius = 60 / 2
     
//        addSubview(uberInfoLabel)
//        uberInfoLabel.anchor(centerX: (centerXAnchor, 0),
//                          top: (infoView.bottomAnchor, 8))
        
//        let separatorView = UIView()
//        separatorView.backgroundColor = .lightGray
//        addSubview(separatorView)
//        separatorView.anchor(top: (uberInfoLabel.bottomAnchor, 4),
//                             leading: (leadingAnchor, 0),
//                             trailing: (trailingAnchor, 0),
//                             height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(leading: (leadingAnchor, 15),
                            trailing: (trailingAnchor, 15),
                            bottom: (safeAreaLayoutGuide.bottomAnchor, 15),
                            height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func actionButtonPressed() {
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelTrip()
        case .getDirections:
            break
        case .pickup:
            delegate?.pickupPassenger()
        case .dropOff:
            delegate?.dropOffPassenger()
        }
    }
    
    // MARK: - Helper Functions
    private func configureUI(withConfig config: RideActionViewConfiguration) {
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.debugDescription, for: .normal)
        case .tripAccepted:
            guard let user = user else { return }
            
            if user.accountType == .passenger {
                titleLabel.text = "In Route to passenger"
                buttonAction = .getDirections
            } else {
                titleLabel.text = "Driver En route"
                buttonAction = .cancel
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberInfoLabel.text = user.fullname
            actionButton.setTitle(buttonAction.debugDescription, for: .normal)
            
        case .driverArrived:
            guard let user = user else { return }

            if user.accountType == .driver {
                titleLabel.text = "Driver Has Arrived"
                addressLabel.text = "Please meet driver at pickup location"
            }
            
        case .pickupPassenger:
            titleLabel.text = "Arrived At Passanger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.debugDescription, for: .normal)
            
        case .tripInProgress:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
                actionButton.setTitle(buttonAction.debugDescription, for: .normal)
            } else {
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.debugDescription, for: .normal)
            }
            
            titleLabel.text = "En Route To Destination"
        case .endTrip:
            guard let user = user else { return }
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.debugDescription, for: .normal)
            }
            
            titleLabel.text = "Arrived at Destination"
        }
    }
}
