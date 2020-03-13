//
//  Item.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import Firebase

struct Item {
  let itemName: String
  let price: Double
  let itemId: String // documentId
  let listedDate: Timestamp
  let sellerName: String
  let sellerId: String
  let categoryName: String
  let imageURL: String
}

extension Item {
  init(_ dictionary: [String: Any]) {
    self.itemName = dictionary["itemName"] as? String ?? "no item name"
    self.price = dictionary["price"] as? Double ?? 0.0
    self.itemId = dictionary["itemId"] as? String ?? "no item id"
    self.listedDate = dictionary["listedDate"] as? Timestamp ?? Timestamp(date: Date())
    self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
    self.sellerId = dictionary["sellerId"] as? String ?? "no seller id"
    self.categoryName = dictionary["categoryName"] as? String ?? "no category name"
    self.imageURL = dictionary["imageURL"] as? String ?? "no image url"
  }
}
