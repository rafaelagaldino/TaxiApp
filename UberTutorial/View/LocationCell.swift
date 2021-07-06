//
//  LocationCell.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 10/01/21.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
    // MARK: - Properties
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    var type: LocationType? {
        didSet {
            titleLabel.text = type?.description
            addressLabel.text = type?.subtitle
        }
    }
    
    let pinImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "pin")
        return image
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
               
        addSubview(pinImage)
        pinImage.anchor(centerY: (centerYAnchor, 0),
                        leading: (leadingAnchor, 12),
                        width: 30, height: 30)

        addressLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 4
        addSubview(stack)
        stack.anchor(centerY: (centerYAnchor, 0),
                     leading: (pinImage.trailingAnchor, 12),
                     trailing: (trailingAnchor, 12))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

