//
//  ThoughtService.swift
//  Thoughts
//
//  Created by praveen mack on 21/08/21.
//

import Firebase

struct ThoughtService {
    static let shared = ThoughtService()
    
    func uploadThought(caption: String, type: UploadThoughtConfiguration,completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "likes": 0, "caption": caption] as [String: Any]
        
        switch type {
        case .thought:
            REF_THOUGHTS.childByAutoId().updateChildValues(values) { err, ref in
                guard let thoughtID = ref.key else { return }
                REF_USER_THOUGHTS.child(uid).updateChildValues([thoughtID: 1], withCompletionBlock: completion)
            }
        case .reply(let thought):
            values["replyingTo"] = thought.user.username
            
            REF_THOUGHT_REPLIES.child(thought.thoughtID).childByAutoId().updateChildValues(values) { err, ref in
                guard let replyKey = ref.key else { return }
                REF_USER_REPLIES.child(uid).updateChildValues([thought.thoughtID: replyKey], withCompletionBlock: completion)
            }
        }
    }
    
    func fetchThoughts(completion: @escaping([Thought]) -> Void) {
        var thoughts = [Thought]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
            let followingUid = snapshot.key
            
            REF_USER_THOUGHTS.child(followingUid).observe(.childAdded) { snapshot in
                let thoughtID = snapshot.key
                
                self.fetchThought(wihThoughtID: thoughtID) { thought in
                    thoughts.append(thought)
                    completion(thoughts)
                }
            }
        }
        
        REF_USER_THOUGHTS.child(currentUid).observe(.childAdded) { snapshot in
            let thoughtID = snapshot.key
            
            self.fetchThought(wihThoughtID: thoughtID) { thought in
                thoughts.append(thought)
                completion(thoughts)
            }
        }
    }
    
    func fetchThoughts(forUser user: User, completion: @escaping([Thought]) -> Void) {
        var thoughts = [Thought]()
        
        REF_USER_THOUGHTS.child(user.uid).observe(.childAdded) { snapshot in
            print(snapshot)
            
            let thoughtID = snapshot.key
            
            REF_THOUGHTS.child(thoughtID).observeSingleEvent(of: .value) { snapshot in
                print(snapshot)
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let thought = Thought(user: user, thoughtID: thoughtID, dictionary: dictionary)
                    thoughts.append(thought)
                    completion(thoughts)
                }
            }
        }
    }
    
    func fetchThought(wihThoughtID thoughtID: String, completion: @escaping(Thought) -> Void) {
        REF_THOUGHTS.child(thoughtID).observeSingleEvent(of: .value) { snapshot in
            print(snapshot)
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let thought = Thought(user: user, thoughtID: thoughtID, dictionary: dictionary)
                completion(thought)
            }
        }
    }
    
    func fetchReplies(forUser user: User, completion: @escaping([Thought]) -> Void) {
        var replies = [Thought]()
        
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
            let thoughtKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            
            print("DEBUG: Thought key is \(thoughtKey)")
            print("DEBUG: Reply key is \(replyKey)")
            
            REF_THOUGHT_REPLIES.child(thoughtKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                let replyID = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = Thought(user: user, thoughtID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    func fetchReplies(forThought thought: Thought, completion: @escaping([Thought]) -> Void) {
        var thoughts = [Thought]()
        
        REF_THOUGHT_REPLIES.child(thought.thoughtID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let thoughtID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let thought = Thought(user: user, thoughtID: thoughtID, dictionary: dictionary)
                thoughts.append(thought)
                completion(thoughts)
            }
        }
    }
    
    func fetchLikes(forUser user: User, completion: @escaping([Thought]) -> Void) {
        var thoughts = [Thought]()
        
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            let thoughtID = snapshot.key
            self.fetchThought(wihThoughtID: thoughtID) { likedThought in
                var thought = likedThought
                thought.didLike = true
                
                thoughts.append(thought)
                completion(thoughts)
            }
        }
    }
    
    func likeThought(thought: Thought, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = thought.didLike ? thought.likes - 1 : thought.likes + 1
        REF_THOUGHTS.child(thought.thoughtID).child("likes").setValue(likes)
        
        if thought.didLike {
            REF_USER_LIKES.child(uid).child(thought.thoughtID).removeValue { err, ref in
                REF_THOUGHT_LIKES.child(thought.thoughtID).removeValue(completionBlock: completion)
            }
        } else {
            REF_USER_LIKES.child(uid).updateChildValues([thought.thoughtID: 1]) { err, ref in
                REF_THOUGHT_LIKES.child(thought.thoughtID).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikedThought(_ thought: Thought, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_LIKES.child(uid).child(thought.thoughtID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
}
