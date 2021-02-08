//
//  Extension.swift
//  CheckIn
//
//  Created by Deniz Adil on 14.1.21.
//

import Foundation
import UIKit


extension UIViewController {
    func showErrorWith(title: String?, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
}

