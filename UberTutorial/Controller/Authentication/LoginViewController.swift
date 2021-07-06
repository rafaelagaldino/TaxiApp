//
//  ViewController.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 04/01/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    // MARK: - Properties
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
    
    /// Lazy - indica que ele é configurado apenas quando existe a necessidade, ou seja, ele é configurado apenas quanto é chamado
    private lazy var emailContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return view
    }()
    
    public let emailTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Email", isSecureTextEntry: false)
    }()
    
    public let passwordView: UIView = {
        return UILabel().label(title: "Password".uppercased())
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 45).isActive = true
        return view
    }()
    
    private let passwordTextField: UITextField = {
        return UITextField().textField(withPlaceholder: "Password", isSecureTextEntry: true)
    }()
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Dont'have an account?", attributes:
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: " Sing Up", attributes:
            [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16),
             NSAttributedString.Key.foregroundColor : UIColor.black]))
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    private let eyeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "eye-hide"), for: .normal)
        button.addTarget(self, action: #selector(eyeIconAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to log user in with erro \(error.localizedDescription)")
                return
            }
            print("DEBUG: Succesfully logged user in")
  
//            DispatchQueue.main.async {
//            guard let keyWindow = self.view.window?.rootViewController as? HomeViewController else { return }

//            guard let keyWindow = UIApplication.shared.windows.first?.rootViewController as? HomeViewController else { return }
//            keyWindow.configure()
//
            self.navigationController?.popViewController(animated: true)
//            }
        }
    }
    
    @objc func handleShowSignUp() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    // MARK: - Helper Functions
    private func configureUI() {
        ///Deixa a barra de navegação invisivel
        configureNavigationBar()
//        view.backgroundColor = .backgroundColor
        view.backgroundColor = .white

        view.addSubview(titleLabel)
        titleLabel.anchor(centerX: (view.centerXAnchor, 0),
                          top: (view.safeAreaLayoutGuide.topAnchor, 40))

        passwordTextField.rightViewMode = .always
        passwordTextField.rightView = eyeButton
        
        let stack = UIStackView(arrangedSubviews: [emailView,
                                                   emailContainerView,
                                                   passwordView,
                                                   passwordContainerView])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 5
        view.addSubview(stack)
        stack.anchor(top: (titleLabel.bottomAnchor, 40),
                     leading: (view.leadingAnchor, 36),
                     trailing: (view.trailingAnchor, 36))
        
        view.addSubview(loginButton)
        loginButton.anchor(top: (stack.bottomAnchor, 48),
                           leading: (view.leadingAnchor, 36),
                           trailing: (view.trailingAnchor, 36))
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(centerX: (loginButton.centerXAnchor, 0),
                                     top: (loginButton.bottomAnchor, 10))
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    @objc func eyeIconAction() {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        if passwordTextField.isSecureTextEntry {
            eyeButton.setImage(UIImage(named: "eye-hide"), for: .normal)
        } else {
            eyeButton.setImage(UIImage(named: "eye"), for: .normal)
        }
    }
}

extension UIViewController {
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first,
                let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            print("**** ", windowScene)
            print("**** ", window)
                   return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }
}
