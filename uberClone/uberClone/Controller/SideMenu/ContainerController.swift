//
//  ContainerController.swift
//  uberClone
//
//  Created by Михаил Щербаков on 23.08.2022.
//

import UIKit
import Firebase

class ContainerController: UIViewController {
    
    //MARK: Properties
    
    private let homeController = HomeViewController()
    private var menuController: MenuController!
    private var isExpanded = false
    private let blackView = UIView()
    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIsUserLoggedIn()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpanded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //MARK: Selectors
    
    @objc func dismissMenu() {
        isExpanded = false
        animateMenu(shouldExpand: isExpanded)
    }
    
    //MARK: API
    
    func checkIsUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configure()
        }
    }
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { user in
            self.user = user
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated: true, completion: nil)
            }
        } catch {
            print("Error signing Out!")
        }
    }
    
    //MARK: Helpers
    
    func configure() {
        view.backgroundColor = .backgroundColor
        configureController()
        fetchUserData()
    }
    
    func configureController() {
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
    }
    
    func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
        menuController.delegate = self
        configureBlackView()
    }
    
    func configureBlackView() {
        self.blackView.frame = CGRect(x: self.view.frame.width - 80,
                                      y: 0,
                                      width: 80,
                                      height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        
        if shouldExpand {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80
                self.blackView.alpha = 1
            }, completion: nil)
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity:  0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}

//MARK: HomeControllerDelegate

extension ContainerController: HomeControllerDelegate {
    func hamdleMenuToggle() {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded)
    }
}

//MARK: MenuControllerDelegate

extension ContainerController: MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpanded.toggle()
        animateMenu(shouldExpand: isExpanded) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                break
            case .logout:
                let alert = UIAlertController(title: nil,
                                              message: "Вы действительно хотите выйти?",
                                              preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in
                    self.signOut()
                }))
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
