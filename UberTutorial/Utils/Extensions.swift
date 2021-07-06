//
//  Extensions.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 04/01/21.
//

import UIKit
import MapKit

extension UINavigationController {
    func popViewControllers(viewsToPop: Int, animated: Bool) {
        let viewControllersArray = self.viewControllers
        if viewsToPop < viewControllersArray.count {
            let vc = viewControllersArray[(viewControllersArray.count - 1) - viewsToPop]
            self.popToViewController(vc, animated: animated)
        } else {
            self.popViewController(animated: animated)
        }
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainOrangeTint = UIColor.rgb(red: 255, green: 140, blue: 0)
    static let pink = UIColor.rgb(red: 19, green: 81, blue: 253)
    static let outlineStrokeColor = UIColor.rgb(red: 234, green: 46, blue: 111)
    static let trackStrokeColor = UIColor.rgb(red: 56, green: 25, blue: 49)
    static let pulsatingFillColor = UIColor.rgb(red: 86, green: 30, blue: 63)
}

extension UIFont {
    static let font = UIFont(name: "HelveticaNeue-Bold", size: 14)
}

extension UIView {
    func anchor(centerX: (anchor: NSLayoutXAxisAnchor, constant: CGFloat)? = nil,
                centerY: (anchor: NSLayoutYAxisAnchor, constant: CGFloat)? = nil,
                top: (anchor: NSLayoutYAxisAnchor, constant: CGFloat)? = nil,
                leading: (anchor: NSLayoutXAxisAnchor, constant: CGFloat)? = nil,
                trailing: (anchor: NSLayoutXAxisAnchor, constant: CGFloat)? = nil,
                bottom: (anchor: NSLayoutYAxisAnchor, constant: CGFloat)? = nil,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
            
        if let centerX = centerX {
            centerXAnchor.constraint(equalTo: centerX.anchor, constant: centerX.constant).isActive = true
        }
            
        if let centerY = centerY {
            centerYAnchor.constraint(equalTo: centerY.anchor, constant: centerY.constant).isActive = true
        }
            
        if let top = top {
            topAnchor.constraint(equalTo: top.anchor, constant: top.constant).isActive = true
        }
            
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading.anchor, constant: leading.constant).isActive = true
        }
            
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing.anchor, constant: -trailing.constant).isActive = true
        }
            
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom.anchor, constant: -bottom.constant).isActive = true
        }
            
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
            
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func inputContainerView(image: UIImage, textField: UITextField? = nil, segmentedControl: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9803921569, alpha: 1)
        view.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 15.0
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
//        view.addSubview(imageView)

        if let textField = textField {
//            imageView.anchor(centerY: (view.centerYAnchor, 0),
//                             leading: (view.leadingAnchor, 0),
//                             width: 24,
//                             height: 24)
            
            view.addSubview(textField)
//            textField.anchor(centerY: (imageView.centerYAnchor, 0),
//                             leading: (imageView.trailingAnchor, 8),
//                             trailing: (view.trailingAnchor, 0))
            
            textField.anchor(centerY: (view.centerYAnchor, 0),
                             leading: (view.leadingAnchor, 8),
                             trailing: (view.trailingAnchor, 20),
                             height: 24)

        }
        
        if let segmentedControl = segmentedControl {
//            imageView.anchor(top: (view.topAnchor, 8),
//                             leading: (view.leadingAnchor, 0),
//                             width: 24,
//                             height: 24)
            
            view.addSubview(segmentedControl)
            segmentedControl.anchor(centerY: (view.centerYAnchor, 8),
                                    leading: (view.leadingAnchor, 0),
                                    trailing: (view.trailingAnchor, 0))
        }
        
//        let line = UIView()
//        line.backgroundColor = .lightGray
//        view.addSubview(line)
//        line.anchor(leading: (view.leadingAnchor, 0),
//                    trailing: (view.trailingAnchor, 0),
//                    bottom: (view.bottomAnchor, 0),
//                    height: 0.75)
        
        return view
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        layer.masksToBounds = false
    }
}

extension UITextField {
    func textField(withPlaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.textColor = .darkGray
        textField.keyboardAppearance = .dark
        textField.isSecureTextEntry = isSecureTextEntry
//        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        return textField
    }
}

extension UILabel {
    func label(title: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let label = UILabel()
        label.text = title
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        label.textColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
        
        view.addSubview(label)
        label.anchor(leading: (view.leadingAnchor, 3),
                     bottom: (view.bottomAnchor, 0))
        
        return view
    }
}

extension MKPlacemark {
    var address: String? {
        get {
            guard let subThoroughfare = subThoroughfare else { return nil }
            guard let thoroughfare = thoroughfare else { return nil }
            guard let locality = locality else { return nil }
            guard let adminArea = administrativeArea else { return nil }
            return "\(subThoroughfare) \(thoroughfare) \(locality) \(adminArea)"
        }
    }
}

extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.02)
            zoomRect = zoomRect.union(pointRect)
        }
        let insets = UIEdgeInsets(top: 300, left: 150, bottom: 300, right: 150)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    func addAnnotationAndSelect(forCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        addAnnotation(annotation)
        selectAnnotation(annotation, animated: true)
    }
}

extension UIViewController {
    func presentAlertController(withTitle title: String, message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func shouldPresentLoadingView(_ present: Bool, _ message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1

            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 24)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            label.anchor(centerX: (view.centerXAnchor, 0),
                         top: (indicator.bottomAnchor, 32))
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }

                }
            }
           
        }
    }
}
