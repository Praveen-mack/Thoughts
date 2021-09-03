//
//  ThoughtController.swift
//  Thoughts
//
//  Created by praveen mack on 23/08/21.
//

import UIKit

private let reuseIdentifier = "ThoughtCell"
private let headerIdentifier = "ThoughtHeader"

class ThoughtController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var thought: Thought
    private var actionSheetLauncher: ActionSheetLauncher!
    private var replies = [Thought]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    init(thought: Thought) {
        self.thought = thought
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        configureCollectionView()
        fetchReplies()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - API
    
    func fetchReplies() {
        ThoughtService.shared.fetchReplies(forThought: thought) { replies in
            self.replies = replies
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        
        collectionView.register(ThoughtCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ThoughtHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    fileprivate func ShowActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: thought.user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
}

// MARK: - UICollectionViewDataSource

extension ThoughtController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThoughtCell
        cell.thought = replies[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ThoughtController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ThoughtHeader
        header.thought = thought
        header.delegate = self
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ThoughtController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let viewModel = ThoughtViewModel(thought: thought)
        let captionHeight = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: captionHeight + 260)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - ThoughtHeaderDelegate

extension ThoughtController: ThoughtHeaderDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            print("DEBUG: User is \(user.username)")
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func showActionSheet() {
        if thought.user.isCurrentUser {
            ShowActionSheet(forUser: thought.user)
        } else {
            UserService.shared.checkIfUserIsFollowed(uid: thought.user.uid) { isFollowed in
                var user = self.thought.user
                user.isFollowed = isFollowed
                self.ShowActionSheet(forUser: user)
            }
        }
    }
}

// MARK: - ActionSheetLauncherDelegate

extension ThoughtController: ActionSheetLauncherDelegate {
    func didSelect(option: ActionSheetOptions) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { err, ref in
                print("DEBUG: Did  follow user \(user.username)")
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { err, ref in
                print("DEBUG: Did  unfollow user \(user.username)")
            }
            print("DEBUG: Unfollow \(user.username)")
        case .report:
            print("DEBUG: Report thought")
        case .delete:
            print("DEBUG: Delete thought")
        }
    }
}
