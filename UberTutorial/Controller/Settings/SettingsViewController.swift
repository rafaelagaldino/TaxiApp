//
//  SettingsViewController.swift
//  UberTutorial
//
//  Created by Rafaela Torres Alves Ribeiro Galdino on 07/06/21.
//

import UIKit

private let reuseIdentifier = "LocationCell"

protocol SettingsControllerDelegate: class {
    func updateUser(_ controller: SettingsViewController)
}

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case home
    case work
    
    var description: String {
        switch self {
        case .home: return "Home"
        case .work: return "Work"
        }
    }
    
    var subtitle: String {
        switch self {
        case .home: return "Add Home"
        case .work: return "Add Work"
        }
    }
}

class SettingsViewController: UITableViewController {

    var user: User
    private let locationManager = LocationHandler.shared.locationManager
    weak var delegate: SettingsControllerDelegate?
    var userInfoUpdate = false
    
    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        return view
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"

        configureNavigationBar()
        configureTableView()
    }
    
    // MARK: - Helper Functions
    func locationText(forType type: LocationType) -> String {
        switch type {
        case .home:
            return user.homeLocation ?? type.subtitle
        case .work:
            return user.workLocation ?? type.subtitle
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeader
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark // altera status bar par barStyle = .black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundColor
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    
    @objc func handleDismiss() {
        if userInfoUpdate {
            delegate?.updateUser(self)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .black
        
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .white
        title.text = "Favorites"
        view.addSubview(title)
        title.anchor(centerY: (view.centerYAnchor, 0),
                     leading: (view.leadingAnchor, 16))
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(forType: type)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row), let location = locationManager?.location else { return }
        let controller = AddLocationController(type: type, location: location)
        controller.delegate = self
        let navigationController = UINavigationController(rootViewController: controller)
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - AddLocationControllerDelegate
extension SettingsViewController: AddLocationControllerProtocol {
    func updateLocation(locationString: String, type: LocationType) {
        PassengerService.shared.saveLocation(locationString: locationString, type: type) { error, ref in
            self.dismiss(animated: true, completion: nil)
            self.userInfoUpdate = true
            
            switch type {
            case .home:
                self.user.homeLocation = locationString
            case .work:
                self.user.workLocation = locationString
            }
            
            self.tableView.reloadData()
        }
    }
}
