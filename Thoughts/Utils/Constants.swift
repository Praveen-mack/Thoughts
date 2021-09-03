//
//  Constants.swift
//  Thoughts
//
//  Created by praveen mack on 21/08/21.
//

import UIKit
import Firebase

let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_THOUGHTS = DB_REF.child("thoughts")
let REF_USER_THOUGHTS = DB_REF.child("user-thoughts")
let REF_USER_FOLLOWERS = DB_REF.child("user-followers")
let REF_USER_FOLLOWING = DB_REF.child("user-following")
let REF_THOUGHT_REPLIES = DB_REF.child("thought-replies")
let REF_USER_LIKES = DB_REF.child("user-likes")
let REF_THOUGHT_LIKES = DB_REF.child("thought-likes")
let REF_NOTIFICATIONS = DB_REF.child("notifications")
let REF_USER_REPLIES = DB_REF.child("user-replies")
let REF_USER_USERNAMES = DB_REF.child("user-usernames")
