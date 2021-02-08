//
//  CreateAccountViewController.swift
//  Check-ins
//
//  Created by Dimitar on 27.1.21.
//

import UIKit
import FirebaseAuth
import Firebase
import SVProgressHUD

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setKeyboardOpservers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeKeyboardObservers()
    }
    
    
    func setKeyboardOpservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) != nil else {
            return
        }
    }
    func createLocalUser() -> User? {
        guard let user = FirebaseAuth.Auth.auth().currentUser else {
            return nil
        }
        let localUser = User(id: user.uid)
        return localUser
    }
    @IBAction func onContinue(_ sender: Any) {
        guard let email = txtEmail.text, email != "" else {
            showErrorWith(title: "Error", msg: "Please enter your e-mail")
            return
        }
        guard email.isValidEmail() else {
            showErrorWith(title: "Error", msg: "Please enter a valid e-mail")
            return
        }
        guard let password = txtPassword.text, password != "" else {
            showErrorWith(title: "Error", msg: "Please enter your password")
            return
        }
        guard password.count >= 5 else {
            showErrorWith(title: "Error", msg: "Password must contain at least 6 characters")
            return
        }
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                let specificError = error as NSError
                if specificError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.showErrorWith(title: "Error", msg: "Email already in use!")
                    return
                }
                if specificError.code == AuthErrorCode.weakPassword.rawValue {
                    self.showErrorWith(title: "Error", msg: "Your password is too weak")
                    return
                }
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let authResult = authResult {
                self.saveUser(uid: authResult.user.uid)
            }
        }
//        guard let localUser = user else {return}
//        DataStore.shared.setUserData(user: localUser) { (success, error) in
//            if let error = error {
//                self.showErrorWith(title: "Error", msg: error.localizedDescription)
//                return
//            }
//            if success {
//                DataStore.shared.localUser = localUser
//            }
//        }
//        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
//            SVProgressHUD.dismiss()
//            if let error = error {
//                let specificError = error as NSError
//
//                if specificError.code == AuthErrorCode.invalidEmail.rawValue && specificError.code == AuthErrorCode.wrongPassword.rawValue {
//                    self.showErrorWith(title: "Error", msg: "Incorect email or password")
//                    return
//                }
//                if specificError.code == AuthErrorCode.userDisabled.rawValue {
//                    self.showErrorWith(title: "Error", msg: "You account was disabled")
//                    return
//                }
//                self.showErrorWith(title: "Error", msg: error.localizedDescription)
//                return
//            }
//            if let authResult = authResult {
//                self.getLocalUserData(uid: authResult.user.uid)
//            }
//        }
    }
    func getLocalUserData(uid: String) {
        SVProgressHUD.show()
        DataStore.shared.getUser(uid: uid) { (user, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let user = user {
                DataStore.shared.localUser = user
                return
            }
        }
    }

    
    func saveUser(uid: String) {
        var user = User(id: uid)
        user.email = txtEmail.text
        SVProgressHUD.show()
        DataStore.shared.setUserData(user: user) { [self] (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if success {
                DataStore.shared.localUser = user
                self.continueToHome()
            }
        }
    }
    func continueToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "Home")
        present(controller, animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: false)
    }
}
extension CreateAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
     }
   }
