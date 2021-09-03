//
//  FeedController.swift
//  Thoughts
//
//  Created by praveen mack on 20/08/21.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "ThoughtCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            print("DEBUG: Did set user in feed controller..")
            configureLeftBarButton()
        }
    }
    
    private var thoughts = [Thought]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        fetchThoughts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh() {
        fetchThoughts()
    }
    
    @objc func handleProjectImageTap() {
        guard let user = user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
        print("DEBUG: Show user profile..")
    }
    
    // MARK: - API
    
    func fetchThoughts() {
        collectionView.refreshControl?.beginRefreshing()
        
        ThoughtService.shared.fetchThoughts { thoughts in
            print("DEBUG: thoughts are \(thoughts)")
            self.thoughts = thoughts.sorted(by: { $0.timestamp > $1.timestamp })
            self.checkIfUserLikedThoughts()
            
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Helper function
    
    func checkIfUserLikedThoughts() {
        self.thoughts.forEach { thought in
            ThoughtService.shared.checkIfUserLikedThought(thought) { didLike in
                guard didLike == true else { return }
                
                if let index = self.thoughts.firstIndex(where: { $0.thoughtID == thought.thoughtID }) {
                    self.thoughts[index].didLike = true
                }
            }
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        collectionView.register(ThoughtCell.self, forCellWithReuseIdentifier: reuseIdentifier )
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "thoughts"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 80, height: 80)
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .lightGray
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProjectImageTap))
        profileImageView.addGestureRecognizer(tap)
        
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
   
}

// MARK: - UICollectionViewDelegate/DataSource

extension FeedController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thoughts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThoughtCell
        cell.delegate = self
        cell.thought = thoughts[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = ThoughtController(thought: thoughts[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let thought = thoughts[indexPath.row]
        let viewModel = ThoughtViewModel(thought: thought)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 72)
    }
}

// MARK: - ThoughtCellDelegate

extension FeedController: ThoughtCellDelegate {
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            print("DEBUG: User is \(user.username)")
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func handleLikeTapped(_ cell: ThoughtCell) {
        guard let thought = cell.thought else { return }
        
        ThoughtService.shared.likeThought(thought: thought) { err, ref in
            cell.thought?.didLike.toggle()
            let likes = thought.didLike ? thought.likes - 1 : thought.likes + 1
            cell.thought?.likes = likes
            
            guard !thought.didLike else { return }
            NotificationService.shared.uploadNotification(type: .like, thought: thought)
        }
    }
    
    func handleReplyTapped(_ cell: ThoughtCell) {
        guard let thought = cell.thought else { return }
        let controller = UploadThoughtController(user: thought.user, config: .reply(thought))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: ThoughtCell) {
        guard let user = cell.thought?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
