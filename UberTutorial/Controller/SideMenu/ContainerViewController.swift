//
//  ContainerViewController.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 03/04/21.
//

import UIKit
import Firebase

class ContainerViewController: UIViewController {
    
    private let homeViewController = HomeViewController()
    private var menuViewController:  MenuViewController!
    private var isExpended = false
    private let blackView = UIView()
    private lazy var xOrigin = view.frame.width - 80

    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeViewController.user = user
//            menuViewController.user = user
            menuViewController = MenuViewController(user: user)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpended
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - Selectors
    @objc func dismissMenu() {
        isExpended = false
        animateMenu(shouldExpand: isExpended)
    }
    
    // MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User not logged in...")
            configure()
            navigationController?.pushViewController(LoginViewController(), animated: true)
        } else {
            print("DEBUG: User is logged in...")
            configure()
        }
    }
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
            self.configureMenuController()
            print("DEBUG: User logged in: \(String(describing: self.user))")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            navigationController?.pushViewController(LoginViewController(), animated: true)
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    // MARK: - Helper Functions
    
    func configure() {
        view.backgroundColor = .backgroundColor
        configureHomeController()
        fetchUserData()
    }
    
    func configureHomeController() {
        addChild(homeViewController)
        homeViewController.didMove(toParent: self)
        view.addSubview(homeViewController.view)
        homeViewController.delegate = self
    }
    
    func configureMenuController() {
        addChild(menuViewController)
        menuViewController.didMove(toParent: self)
        view.insertSubview(menuViewController.view, at: 0)
        menuViewController.view.frame = CGRect(x: 0, y: 50, width: self.view.frame.width, height: view.frame.height)
        menuViewController.delegate = self
        menuViewController.tableView.contentInsetAdjustmentBehavior = .never // não deixa a scroll da tableview rolar para baixo
        configureBlackView()
    }
    
    func configureBlackView() {
        self.blackView.frame = CGRect(x: xOrigin, y: 0, width: 80, height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil ) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.homeViewController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.homeViewController.view.frame.origin.x = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.setNeedsStatusBarAppearanceUpdate()
        }

    }
}

// MARK: - SettingsControllerDelegate

extension ContainerViewController: SettingsControllerDelegate {
    func updateUser(_ controller: SettingsViewController) {
        self.user = controller.user
    }
}

// MARK: - HomeControllerDelegate

extension ContainerViewController: HomeControllerDelegate {
    func handleMenuToggle() {
        isExpended.toggle()
        animateMenu(shouldExpand: isExpended)
    }
}

// MARK: - MenuControllerDelegate

extension ContainerViewController: MenuControllerDelegate {
    func didSelect(options: MenuOptions) {
        isExpended.toggle()
        animateMenu(shouldExpand: isExpended) { _ in
            switch options {
            case .yourTrips:
                break
            case .settings:
                guard let user = self.user else { return }
                let settingsController = SettingsViewController(user: user)
                settingsController.delegate = self
                let navigationController = UINavigationController(rootViewController: settingsController)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            case .logout:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to log out", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
