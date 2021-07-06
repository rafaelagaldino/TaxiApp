//
//  InputLocationActivationView.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 08/01/21.
//

import UIKit

protocol LocationInputActivationViewDelegate: class {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    // MARK: - Properties
    var delegate: LocationInputActivationViewDelegate?
    
    let indicatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 7/2
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Para onde?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addShadow()
        
        addSubview(indicatorView)
        indicatorView.anchor(centerY: (centerYAnchor, 0),
                             leading: (leadingAnchor, 20),
                             width: 7,
                             height: 7)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(centerY: (centerYAnchor, 0),
                                leading: (indicatorView.trailingAnchor, 12))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func presentLocationInputView() {
        delegate?.presentLocationInputView()
    }
}
