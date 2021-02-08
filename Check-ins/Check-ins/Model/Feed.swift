//
//  Feed.swift
//  Check-ins
//
//  Created by Dimitar on 27.1.21.
//

import UIKit
import Foundation

struct Feed: Codable {
    var id: String?
    var imageUrl: String?
    var creatorId: String?
    var createdAt: TimeInterval?
    var location: String?
    var latitude: String?
    var longitude: String?
}
