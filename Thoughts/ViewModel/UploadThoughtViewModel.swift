//
//  UploadThoughtViewModel.swift
//  Thoughts
//
//  Created by praveen mack on 23/08/21.
//

import UIKit

enum UploadThoughtConfiguration {
    case thought
    case reply(Thought)
}

struct UploadThoughtViewModel {
    let actionButtonTitle: String
    let placeholderText: String
    let shouldShowReplyLabel: Bool
    var replyText: String?
    
    init(config: UploadThoughtConfiguration) {
        switch config {
        case .thought:
            actionButtonTitle = "Send"
            placeholderText = "What's happening?"
            shouldShowReplyLabel = false
        case .reply(let thought):
            actionButtonTitle = "Reply"
            placeholderText = "Thought your reply"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(thought.user.username)"
        }
    }
}
