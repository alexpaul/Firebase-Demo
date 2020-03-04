//
//  ItemCell.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

  @IBOutlet weak var itemImageView: UIImageView!
  @IBOutlet weak var itemNameLabel: UILabel!
  @IBOutlet weak var sellerNameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  
  public func configureCell(for item: Item) {
    // TODO: setup image, import Kingfisher, install Kingfisher via pods
    itemNameLabel.text = item.itemName
    sellerNameLabel.text = "@\(item.sellerName)"
    dateLabel.text = item.listedDate.description
    let price = String(format: "%.2f", item.price)
    priceLabel.text = "$\(price)"
  }
}
