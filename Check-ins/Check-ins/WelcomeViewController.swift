//
//  WelcomeViewController.swift
//  Check-ins
//
//  Created by Dimitar on 27.1.21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            DataStore.shared.getUser(uid: Auth.auth().currentUser!.uid) { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                DataStore.shared.localUser = user
                self.performSegue(withIdentifier: "Home", sender: nil)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func onFacebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login error", message: error.localizedDescription, preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                } else {
                    guard let currentUser = user?.user else {return}
                    var cUser = User(id: currentUser.uid)
                    cUser.name = currentUser.displayName
                    cUser.email = currentUser.email
                    guard let photo = currentUser.photoURL?.absoluteString else {return}
                    cUser.image = photo
                    DataStore.shared.setUserData(user: cUser) { (success, error) in
                        if let error = error {
                            self.showErrorWith(title: nil, msg: error.localizedDescription)
                            return
                        }
                        if success {
                            DataStore.shared.localUser = cUser
                            self.performSegue(withIdentifier: "Home", sender: nil)
                        }
                    }
                }
//                    if Auth.auth().currentUser != nil {
//                        self.performSegue(withIdentifier: "Home", sender: nil)
//                    }
            }
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }
    
    
    @IBAction func onCreateAccount(_ sender: Any) {
        performSegue(withIdentifier: "createAccount", sender: nil)
    }
}
