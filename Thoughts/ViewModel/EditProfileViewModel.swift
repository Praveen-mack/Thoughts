//
//  EditProfileViewModel.swift
//  Thoughts
//
//  Created by praveen mack on 29/08/21.
//

import UIKit

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case bio
    
    var description: String {
        switch self {
        case .fullname:
            return "Username"
        case .username:
            return "Name"
        case .bio:
            return "Bio"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }

    var optionValue: String? {
        switch option {
        case .fullname:
            return user.username
        case .username:
            return user.fullname
        case .bio:
            return user.bio
        }
    }

    var shouldHideTextField: Bool {
        return option == .bio
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}


