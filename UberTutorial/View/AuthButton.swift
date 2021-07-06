//
//  AuthButton.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 05/01/21.
//

import UIKit

class AuthButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(UIColor(white: 1, alpha: 1), for: .normal)
        backgroundColor = .black
        layer.cornerRadius = 15.0
        heightAnchor.constraint(equalToConstant: 58).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
