//
//  User.swift
//  Check-ins
//
//  Created by Dimitar on 27.1.21.
//

import Foundation

typealias UserSaveCompletion = (_ success: Bool,_ error: Error?)-> Void

struct User: Codable {
    var id: String?
    var name: String?
    var password: String?
    var image: String?
    var email: String?
    var createdAt: String?
    var location: String?
    
    init(id: String) {
        self.id = id
    }
    func save(completion: UserSaveCompletion?) {
           DataStore.shared.setUserData(user: self) { (sucess, error) in
               completion?(sucess, error)
           }
    }

}
