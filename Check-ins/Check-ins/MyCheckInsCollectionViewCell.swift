//
//  MyCheckInsCollectionViewCell.swift
//  CheckIn
//
//  Created by Deniz Adil on 25.1.21.
//

import UIKit
import Kingfisher
import CoreLocation
import Firebase

class MyCheckInsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    
    
    var feedItem: Feed?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userPhoto.layer.cornerRadius = 20
        userPhoto.layer.masksToBounds = true
    }
    
    func setupCell(feedItem: Feed, user: User) {
        self.feedItem = feedItem
        guard let imageUrl = feedItem.imageUrl else {return}
        image.kf.setImage(with: URL(string: imageUrl))
        setDate(feedItem: feedItem)
        fetchCreatorDetails(feedItem: feedItem)
    }
    
    func fetchCreatorDetails(feedItem: Feed) {
        guard let creatorId = feedItem.creatorId else { return }
        DataStore.shared.getUser(uid: creatorId) { (user, error) in
            if let user = user {
                self.userName.text = user.name
                if let imageUrl = user.image {
                    self.userPhoto.kf.setImage(with: URL(string: imageUrl))
                } else {
                    self.userPhoto.image = UIImage(named: "user")
                }
                self.country.text = feedItem.location
                self.latitude.text = "latt: \(feedItem.latitude ?? "0.0")"
                self.longitude.text = "long: \(feedItem.longitude ?? "0.0")"
            }
        }
    }
    
    func setDate(feedItem: Feed) {
        let date = Date(with: feedItem.createdAt!)
        time.text = date?.timeAgoDisplay()
    }
}


