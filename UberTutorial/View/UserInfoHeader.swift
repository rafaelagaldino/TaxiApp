//
//  UserInfoHeader.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 08/06/21.
//

import UIKit

class UserInfoHeader: UIView {
    private var user: User
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        
        imageView.addSubview(initialLabel)
        initialLabel.anchor(centerX: (imageView.centerXAnchor, 0),
                            centerY: (imageView.centerYAnchor, 0))
        return imageView
    }()
    
    private lazy var initialLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 42)
        label.textColor = .white
        label.text = "Rafaela Galdino"
        label.text = user.firstInitial
        return label
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()
    
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)

        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(centerY: (centerYAnchor, 0),
                                leading: (leadingAnchor, 16),
                                width: 64, height: 64)
        profileImageView.layer.cornerRadius = 64/2
        
        let stack = UIStackView(arrangedSubviews: [fullNameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        
        addSubview(stack)
        stack.anchor(centerY: (profileImageView.centerYAnchor, 0),
                     leading: (profileImageView.trailingAnchor, 12))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
