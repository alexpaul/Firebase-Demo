//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

// step 1. custom delegate protocol
protocol ItemCellDelegate: AnyObject {
  func didSelecteSellerName(_ itemCell: ItemCell, item: Item)
}

class ItemCell: UITableViewCell {
  
  // step 2: custom delegate protocol
  weak var delegate: ItemCellDelegate?

  @IBOutlet weak var itemImageView: UIImageView!
  @IBOutlet weak var itemNameLabel: UILabel!
  @IBOutlet weak var sellerNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  private var currentItem: Item!
  
  private lazy var tapGesture: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleTap(_:)))
    return gesture
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    sellerNameLabel.textColor = .systemOrange
    sellerNameLabel.addGestureRecognizer(tapGesture)
    sellerNameLabel.isUserInteractionEnabled = true
  }
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    // step 3 custom delegate protocol
    delegate?.didSelecteSellerName(self, item: currentItem)
  }
  
  public func configureCell(for item: Item) {
    currentItem = item
    updateUI(imageURL: item.imageURL, itemName: item.itemName, sellerName: item.sellerName, date: item.listedDate, price: item.price)
  }
  
  public func configureCell(for favorite: Favorite) {
    updateUI(imageURL: favorite.imageURL, itemName: favorite.itemName, sellerName: favorite.sellerName, date: favorite.favoritedDate, price: favorite.price)
  }
  
  private func updateUI(imageURL: String, itemName: String, sellerName: String, date: Timestamp, price: Double) {
    itemImageView.kf.setImage(with: URL(string: imageURL))
    itemNameLabel.text = itemName
    sellerNameLabel.text = "@\(sellerName)"
    dateLabel.text = date.dateValue().dateString()
    let price = String(format: "%.2f", price)
    priceLabel.text = "$\(price)"
  }
}
