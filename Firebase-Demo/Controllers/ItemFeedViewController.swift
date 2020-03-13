//
//  ItemFeedViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ItemFeedViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  private var listener: ListenerRegistration?
  
  private var items = [Item]() {
    didSet {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    configureTableView()
    configureNavBar()
  }
  
  private func configureTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    
    // register our custom .xib ItemCell class
    tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
  }
  
  private func configureNavBar() {
    navigationItem.title = "Marketplace"
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    listener = Firestore.firestore().collection(DatabaseService.itemsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
      if let error = error {
        DispatchQueue.main.async {
          self?.showAlert(title: "Try again later", message: "\(error.localizedDescription)")
        }
      } else if let snapshot = snapshot {
        let items = snapshot.documents.map { Item($0.data()) }
        self?.items = items.sorted{ $0.listedDate.seconds > $1.listedDate.seconds }
      }
    })
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    listener?.remove() // no longer are we listening for changes from Firebase
  }
}

extension ItemFeedViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
      fatalError("could not downcast to ItemCell")
    }
    let item = items[indexPath.row]
    cell.configureCell(for: item)
    
    // step 1 - delegating object
    cell.delegate = self
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // perform deletion on item
      let item = items[indexPath.row]
      DatabaseService.shared.delete(item: item) { [weak self] (result) in
        switch result {
        case .failure(let error):
          DispatchQueue.main.async {
            self?.showAlert(title: "Deletion error", message: error.localizedDescription)
          }
        case .success:
          print("deleted successfully")
        }
      }
    }
  }
  
  // on the client side meaning the app we will ensure that swipe to delete only works for the user who created the item
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    let item = items[indexPath.row]
    guard let user = Auth.auth().currentUser else { return false }
    
    if item.sellerId != user.uid {
      return false // cannot swipe on row to delete
    }
    return true // able to swipe to delete item
  }
  
  // TODO: that's not enough to only prevent accidental deletion on the client, we need to protect the database as well, we will do so using Firebase "Security Rules"
}

extension ItemFeedViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    let storyboard = UIStoryboard(name: "MainView", bundle: nil)
    let detailVC = storyboard.instantiateViewController(identifier: "ItemDetailController") { (coder) in
      return ItemDetailController(coder: coder, item: item)
    }
    navigationController?.pushViewController(detailVC, animated: true)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 140
  }
}

// step 2 - delegating object
extension ItemFeedViewController: ItemCellDelegate {
  func didSelecteSellerName(_ itemCell: ItemCell, item: Item) {
    let storyboard = UIStoryboard(name: "MainView", bundle: nil)
    let sellerItemsController = storyboard.instantiateViewController(identifier: "SellerItemsController") { (coder) in
      return SellerItemsController(coder: coder, item: item)
    }
    navigationController?.pushViewController(sellerItemsController, animated: true)
  }
}
