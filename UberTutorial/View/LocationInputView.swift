//
//  LocationInputView.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 10/01/21.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {
    // MARK: - Properties
    var user: User? {
        didSet { titleLabel.text = user?.fullname }
    }
    
    weak var delegate: LocationInputViewDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20.0
        view.addShadow()
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 5
        return stack
    }()
    
    private lazy var startingLocationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Current Location"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.isEnabled = false
        textField.anchor(height: 35.0)
        
//        let paddingView = UIView()
//        paddingView.anchor(width: 8, height: 30)
//        textField.leftView = paddingView
//        textField.leftViewMode = .always
//
        return textField
    }()
    
    private let line: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.anchor(height: 1)
        return view
    }()
    
    private lazy var destinationLocationTextField: UITextField = {
        let textField = UITextField()
//        textField.placeholder = "Enter a destination.."
        textField.returnKeyType = .search
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.delegate = self
        textField.anchor(height: 35.0)

//        let paddingView = UIView()
//        paddingView.anchor(width: 8, height: 30)
//        textField.leftView = paddingView
//        textField.leftViewMode = .always
        
        return textField
    }()
    
    // MARK: - Lifecycle
    override init (frame: CGRect) {
        super.init(frame: frame)
        addShadow()
        backgroundColor = .white
        
        addSubview(backButton)
        backButton.anchor(top: (topAnchor, 44),
                          leading: (leadingAnchor, 14),
                          width: 24,
                          height: 25)
        
        addSubview(titleLabel)
        titleLabel.anchor(centerX: (centerXAnchor, 0),
                          centerY: (backButton.centerYAnchor, 0))
        
        addSubview(containerView)
        containerView.anchor(top: (titleLabel.bottomAnchor, 20),
                             leading: (leadingAnchor, 30),
                             trailing: (trailingAnchor, 30),
                             width: 50,
                             height: 110)
        
        stackView.addArrangedSubview(startingLocationTextField)
        stackView.addArrangedSubview(line)
        stackView.addArrangedSubview(destinationLocationTextField)
        addSubview(stackView)
        stackView.anchor(centerY: (containerView.centerYAnchor, 0),
                         leading: (containerView.leadingAnchor, 40),
                         trailing: (containerView.trailingAnchor, 0))
        
//        containerView.addSubview(startingLocationTextField)
//        startingLocationTextField.anchor(top: (containerView.topAnchor, 20),
//                                         leading: (containerView.leadingAnchor, 40),
//                                         trailing: (containerView.trailingAnchor, 40),
//                                         height: 30)
//
//        containerView.addSubview(destinationLocationTextField)
//        destinationLocationTextField.anchor(top: (startingLocationTextField.bottomAnchor, 10),
//                                            leading: (containerView.leadingAnchor, 40),
//                                            trailing: (containerView.trailingAnchor, 40),
//                                            height: 30)
//
        containerView.addSubview(startLocationIndicatorView)
        startLocationIndicatorView.anchor(centerY: (startingLocationTextField.centerYAnchor, 0),
                                          leading: (containerView.leadingAnchor, 20),
                                          width: 6,
                                          height: 6)
        startLocationIndicatorView.layer.cornerRadius = 6 / 2
        
        containerView.addSubview(destinationIndicatorView)
        destinationIndicatorView.anchor(centerY: (destinationLocationTextField.centerYAnchor, 0),
                                        leading: (containerView.leadingAnchor, 20),
                                        width: 6,
                                        height: 6)
        destinationIndicatorView.layer.cornerRadius = 6 / 2
        
        addSubview(linkingView)
        linkingView.anchor(centerX: (startLocationIndicatorView.centerXAnchor, 0),
                           top: (startLocationIndicatorView.bottomAnchor, 4),
                           bottom: (destinationIndicatorView.topAnchor, 4),
                           width: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
}

// MARK: - UITextFieldDelegate
extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        delegate?.executeSearch(query: query)
        return true
    }
}
