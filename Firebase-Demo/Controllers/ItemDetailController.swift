//
//  ItemDetailController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ItemDetailController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var containerBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var commentTextField: UITextField!

  private var item: Item
  private var originalValueForConstraint: CGFloat = 0
  
  private lazy var tapGesture: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(dismissKeyboard))
    return gesture
  }()
  
  private var listener: ListenerRegistration?
  
  private var comments = [Comment]() {
    didSet { // property observer
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
  private var isFavorite = false {
    didSet {
      if isFavorite {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart.fill")
      } else {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "heart")
      }
    }
  }
  
  init?(coder: NSCoder, item: Item) {
    self.item = item
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    originalValueForConstraint = containerBottomConstraint.constant
    
    tableView.tableHeaderView = HeaderView(imageURL: item.imageURL)
    tableView.dataSource = self
    
    commentTextField.delegate = self
    view.addGestureRecognizer(tapGesture)
    navigationItem.title = item.itemName
    navigationItem.largeTitleDisplayMode = .never
    
    // TODO: refactor code (helper functions) in viewDidLoad, we should always strive for less code in our viewDidLoad
    updateUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    registerKeyboardNotifications()
    
    listener = Firestore.firestore().collection(DatabaseService.itemsCollection)
      .document(item.itemId)
      .collection(DatabaseService.commentsCollection)
      .addSnapshotListener({ [weak self] (snapshot, error) in
      if let error = error {
        DispatchQueue.main.async {
          self?.showAlert(title: "Try Again", message: error.localizedDescription)
        }
      } else if let snapshot = snapshot {
        // create comments using dictionary initializer from the Comment model
        let comments = snapshot.documents.map { Comment($0.data()) }
        // sort by date
        self?.comments = comments.sorted { $0.commentDate.dateValue() > $1.commentDate.dateValue() }
      }
    })
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    unregisterKeyboardNotifications()
    listener?.remove()
  }
  
  private func updateUI() {
    // check if item is a favorite and update heart icon accordingly
    DatabaseService.shared.isItemInFavorites(item: item) { [weak self] (result) in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(title: "Try again", message: error.localizedDescription)
        }
      case .success(let success):
        if success { // true
          self?.isFavorite = true
        } else {
          self?.isFavorite = false
        }
      }
    }
  }
  
  @IBAction func sendButtonPressed(_ sender: UIButton) {
    dismissKeyboard()
    
    // getting comment ready to post to firebase
    guard let commentText = commentTextField.text,
      !commentText.isEmpty else {
        showAlert(title: "Missing Fields", message: "A comment is required.")
        return
    }
    postComment(text: commentText)
  }
  
  private func postComment(text: String) {
    DatabaseService.shared.postComment(item: item, comment: text) { [weak self] (result) in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(title: "Try again", message: error.localizedDescription)
        }
      case .success:
        DispatchQueue.main.async {
          self?.showAlert(title: "Comment posted 🥳", message: nil)
        }
      }
    }
  }
  
  private func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(_:)),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide(_:)),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)
  }
  
  private func unregisterKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self,
                                              name: UIResponder.keyboardWillShowNotification,
                                              object: nil)
    NotificationCenter.default.removeObserver(self,
                                              name: UIResponder.keyboardWillHideNotification,
                                              object: nil)
  }
  
  @objc private func keyboardWillShow(_ notification: Notification) {
    print(notification.userInfo ?? "missing userInfo") // info keys from the userInfo
    guard let keyboardFrame = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect else {
      return
    }
    // adjust the container bottom constraint
    containerBottomConstraint.constant = -(keyboardFrame.height - view.safeAreaInsets.bottom)
  }
  
  @objc private func keyboardWillHide(_ notification: Notification) {
    dismissKeyboard()
  }
  
  @objc private func dismissKeyboard() {
    containerBottomConstraint.constant = originalValueForConstraint
    commentTextField.resignFirstResponder()
  }
  
  @IBAction func favoriteButtonPressed(_ sender: UIBarButtonItem) {
    
    if isFavorite { // remove from favorites
      DatabaseService.shared.removeFromFavorites(item: item) { [weak self] (result) in
        switch result {
        case .failure(let error):
          DispatchQueue.main.async {
            self?.showAlert(title: "Failed to remove favorite", message: error.localizedDescription)
          }
        case .success:
          DispatchQueue.main.async {
            self?.showAlert(title: "Item removed", message: nil)
            self?.isFavorite = false
          }
        }
      }
    } else { // add to favorites
      DatabaseService.shared.addToFavorites(item: item) { [weak self] (result) in
         switch result {
         case .failure(let error):
           DispatchQueue.main.async {
             self?.showAlert(title: "Favoriting error", message: error.localizedDescription)
           }
         case .success:
           DispatchQueue.main.async {
             self?.showAlert(title: "Item favorited", message: nil)
            self?.isFavorite = true
           }
         }
       }
    }
    
    
  }
  
}

extension ItemDetailController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
    let comment = comments[indexPath.row]
    let dateString = comment.commentDate.dateValue().dateString()
    cell.textLabel?.text = comment.text
    cell.detailTextLabel?.text = "@" + comment.commentedBy + " " + dateString
    return cell
  }
}

extension ItemDetailController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    dismissKeyboard()
    return true
  }
}
