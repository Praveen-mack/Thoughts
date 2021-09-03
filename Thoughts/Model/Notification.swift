//
//  Notification.swift
//  Thoughts
//
//  Created by praveen mack on 25/08/21.
//

import UIKit

enum NotificationType: Int {
    case follow
    case like
    case reply
}

struct Notification {
    var thoughtID: String?
    var timestamp: Date!
    var user: User
    var thought: Thought?
    var type: NotificationType!
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        
        if let thoughtID = dictionary["thoughtID"] as? String {
            self.thoughtID = thoughtID
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
