//
//  Thought.swift
//  Thoughts
//
//  Created by praveen mack on 21/08/21.
//

import UIKit
import Firebase

struct Thought {
    let caption: String
    let thoughtID: String
    var likes: Int
    var timestamp: Date!
    var user: User
    var didLike = false
    var replyingTo: String?
    
    var isReply: Bool { return replyingTo != nil }
    
    init(user: User, thoughtID: String, dictionary: [String: Any]) {
        self.thoughtID = thoughtID
        self.user = user
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}

