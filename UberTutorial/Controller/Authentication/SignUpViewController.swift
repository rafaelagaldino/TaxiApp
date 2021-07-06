//
//  SignUpViewController.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 05/01/21.
//

import UIKit
import Firebase
import GeoFire

class SignUpViewController: UIViewController {
    // MARK: - Properties
    private var location = LocationHandler.shared.locationManager?.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    public let emailView: UIView = {
        return UILabel().label(title: "Email".uppercased())
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    public let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    public let fullNameView: UIView = {
        return UILabel().label(title: "Name".uppercased())
    }()
    
    private lazy var fullNameContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let fullNameTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Full Name", isSecureTextEntry: false)
    }()
    
    public let passwordView: UIView = {
        return UILabel().label(title: "Password".uppercased())
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()

    private lazy var accountTypeContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_account_box_white_2x"), segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let accountTypeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Rider", "Driver"])
        segmentedControl.backgroundColor = .backgroundColor
        segmentedControl.tintColor = UIColor(white: 1, alpha: 0.87)
        segmentedControl.selectedSegmentIndex = 0
//        button.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return segmentedControl
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    private let alrealdyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?", attributes:
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: " Sing In", attributes:
            [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor : UIColor.black]))
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        print("DEBUG: Location is \(location)")
    }
    
    // MARK: - Selectors
    @objc func handleSignUp() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let fullName = fullNameTextField.text else { return }
        
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] result, error in
            if let error = error {
                print("DEBUG: Failed to register user with error \(error.localizedDescription)")
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email" : email,
                          "fullname" : fullName,
                          "accounttype" : accountTypeIndex] as [String : Any]

            if accountTypeIndex == 1 {
                guard let location = location else { return }
                let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
                
                geofire.setLocation(location, forKey: uid) { error in
                    self.uploadUserDataAndDShowHomeViewController(uid: uid, values: values)
                }
            }
            self.uploadUserDataAndDShowHomeViewController(uid: uid, values: values)
        }
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    func uploadUserDataAndDShowHomeViewController(uid: String, values: [String:Any]) {
        REF_USERS.child(uid).updateChildValues(values) { error, ref in
            print("DEBUG: Successfully registered user and saved data...")
            guard let homeViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? ContainerViewController else { return }
            homeViewController.configure()
            self.navigationController?.popViewControllers(viewsToPop: 2, animated: true)
        }
    }
    
    private func configureUI() {
        ///Deixa a barra de navegação invisivel
        configureNavigationBar()
        view.backgroundColor = .white

        view.addSubview(titleLabel)
        titleLabel.anchor(centerX: (view.centerXAnchor, 0),
                          top: (view.safeAreaLayoutGuide.topAnchor, 40))

        let stack = UIStackView(arrangedSubviews: [emailView,
                                                   emailContainerView,
                                                   fullNameView,
                                                   fullNameContainerView,
                                                   passwordView,
                                                   passwordContainerView])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 5
        view.addSubview(stack)
        stack.anchor(top: (titleLabel.bottomAnchor, 40),
                     leading: (view.leadingAnchor, 36),
                     trailing: (view.trailingAnchor, 36))
        
        view.addSubview(accountTypeSegmentedControl)
        accountTypeSegmentedControl.anchor(top: (stack.bottomAnchor, 28),
                                           leading: (view.leadingAnchor, 36),
                                           trailing: (view.trailingAnchor, 36))
        
        view.addSubview(signUpButton)
        signUpButton.anchor(top: (accountTypeSegmentedControl.bottomAnchor, 48),
                            leading: (view.leadingAnchor, 36),
                            trailing: (view.trailingAnchor, 36))
        
        view.addSubview(alrealdyHaveAccountButton)
        alrealdyHaveAccountButton.anchor(centerX: (signUpButton.centerXAnchor, 0),
                                         top: (signUpButton.bottomAnchor, 8))
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
