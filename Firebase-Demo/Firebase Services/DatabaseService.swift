//
//  DatabaseService.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
  
  static let itemsCollection = "items" // collection
  
  // let's get a reference to the Firebase Firestore database
  
  private let db = Firestore.firestore()
  
  public func createItem(itemName: String, price: Double, category: Category, displayName: String, completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let user = Auth.auth().currentUser else { return }
    
    // generate a document for the "items" collection
    let documentRef = db.collection(DatabaseService.itemsCollection).document()
    
    
    // create a document in our "items" collection
    
    /*
     let itemName: String
     let price: Double
     let itemId: String // documentId
     let listedDate: Date
     let sellerName: String
     let sellerId: String
     let categoryName: String
     */
    db.collection(DatabaseService.itemsCollection).document(documentRef.documentID).setData(["itemName":itemName,"price": price, "itemId":documentRef.documentID, "listedDate": Timestamp(date: Date()), "sellerName": displayName,"sellerId": user.uid, "categoryName": category.name]) { (error) in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
    
  }
  
}

