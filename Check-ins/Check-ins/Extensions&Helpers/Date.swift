//
//  Date.swift
//  CheckIn
//
//  Created by Dimitar on 15.1.21.
//
import Foundation

extension Date {
   
    public init?(with miliseconds: TimeInterval) {
        self = Date(timeIntervalSince1970: miliseconds / 1000.0)
    }
    func toMiliseconds() -> TimeInterval {
        return self.timeIntervalSince1970 * 1000.0
    }
    func timeAgoDisplay() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
}

//import Foundation
//
//extension Date {
//    public init?(with miliseconds: TimeInterval) {
//        self = Date(timeIntervalSince1970: miliseconds / 1000.0)
//    }
//
//    func toMiliseconds() -> TimeInterval {
//        return (self.timeIntervalSince1970 * 1000.0)
//    }
//
//    @available(iOS 13.0, *)
//    func timeAgoDisplay() -> String {
//          let formatter = RelativeDateTimeFormatter()
//          formatter.unitsStyle = .full
//          formatter.dateTimeStyle = .numeric
//          let dateString = formatter.localizedString(for: self, relativeTo: Date())
//          if dateString.contains("second") {
//              return "just now"
//          }
//          return dateString
//      }
//}
