//
//  SellerItemsController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseFirestore

class SellerItemsController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  private var item: Item
  
  private var items = [Item]() {
    didSet {
      DispatchQueue.main.async {
        self.tableView.reloadData()
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
    configureTableView()
    fetchItems()
    fetchUserPhoto()
    navigationItem.title = "@" + item.sellerName
  }
  
  private func fetchItems() {    
    DatabaseService.shared.fetchUserItems(userId: item.sellerId) { [weak self] (result) in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(title: "Failed fetching", message: error.localizedDescription)
        }
      case .success(let items):
        self?.items = items
      }
    }
  }
  
  private func fetchUserPhoto() {
    Firestore.firestore().collection(DatabaseService.usersCollection).document(item.sellerId).getDocument { [weak self] (snapshot, error) in
      if let error = error {
        DispatchQueue.main.async {
          self?.showAlert(title: "Error fetching user", message: error.localizedDescription)
        }
      } else if let snapshot = snapshot {
        // TODO: could be refactored to a User model
        if let photoURL = snapshot.data()?["photoURL"] as? String {
          DispatchQueue.main.async {
            self?.tableView.tableHeaderView = HeaderView(imageURL: photoURL)
          }
          
        }
      }
    }
  }
  
  private func configureTableView() {
    // add a header view to the table view
       tableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "itemCell")
       tableView.dataSource = self
       tableView.delegate = self
  }
}

extension SellerItemsController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemCell else {
      // developer error that's why we intentionally crash to fix the error
      fatalError("could not downcast to ItemCell")
    }
    let item = items[indexPath.row]
    cell.configureCell(for: item)
    return cell
  }
}

extension SellerItemsController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // TODO: in a constants file e.g Row.height
    return 140
  }
}
