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
  static let usersCollection = "users"
  static let commentsCollection = "comments" // sub-collection on an item document
  static let favoritesCollection = "favorites" // sub-collection on a user docment
  
  // review - firebase firestore hierarchy
  // top level
  // collection -> document -> collection -> document ->......
  
  // let's get a reference to the Firebase Firestore database
  
  private let db = Firestore.firestore()
  
  private init() {}
  static let shared = DatabaseService()
  
  public func createItem(itemName: String, price: Double,
                         category: Category,
                         displayName: String,
                         completion: @escaping (Result<String, Error>) -> ()) {
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
    db.collection(DatabaseService.itemsCollection)
      .document(documentRef.documentID)
      .setData(["itemName":itemName,"price": price,
                "itemId":documentRef.documentID,
                "listedDate": Timestamp(date: Date()),
                "sellerName": displayName,"sellerId": user.uid,
                "categoryName": category.name]) { (error) in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(documentRef.documentID))
      }
    }
    
  }
  
  public func createDatabaseUser(authDataResult: AuthDataResult,
                                 completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let email = authDataResult.user.email else {
      return
    }
    db.collection(DatabaseService.usersCollection)
      .document(authDataResult.user.uid)
      .setData(["email" : email,
                "createdDate": Timestamp(date: Date()),
                "userId": authDataResult.user.uid]) { (error) in
      
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
  }
  
  func updateDatabaseUser(displayName: String,
                          photoURL: String,
                          completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let user = Auth.auth().currentUser else { return }
    db.collection(DatabaseService.usersCollection)
      .document(user.uid).updateData(["photoURL" : photoURL,
                                      "displayName" : displayName]) { (error) in
            if let error = error {
              completion(.failure(error))
            } else {
              completion(.success(true))
      }
    }
  }
  
  public func delete(item: Item,
                     completion: @escaping (Result<Bool, Error>) -> ()) {
    db.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
  }
  
  public func postComment(item: Item, comment: String,
                          completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let user = Auth.auth().currentUser,
      let displayName = user.displayName else {
        print("missing user data")
        return
    }
    
    // getting a new document
    let docRef = db.collection(DatabaseService.itemsCollection)
      .document(item.itemId)
      .collection(DatabaseService.commentsCollection).document()
   
   // using the new document from above to write its contents to firebase
    db.collection(DatabaseService.itemsCollection)
      .document(item.itemId)
      .collection(DatabaseService.commentsCollection)
      .document(docRef.documentID).setData(["text" : comment,
                                            "commentDate": Timestamp(date: Date()),
                                            "itemName": item.itemName,
                                            "itemId": item.itemId,
                                            "sellerName": item.sellerName,
                                            "commentedBy": displayName]) { (error) in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
  }
  
  public func addToFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
    
    guard let user = Auth.auth().currentUser else { return }
  db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.itemId).setData(["itemName" : item.itemName, "price": item.price, "imageURL": item.imageURL, "favoritedDate": Timestamp(date: Date()), "itemId": item.itemId, "sellerName": item.sellerName, "sellerId": item.sellerId]) { (error) in
      
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
  }
  
  public func removeFromFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let user = Auth.auth().currentUser else { return }
    db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).document(item.itemId).delete { (error) in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
  }
  
  public func isItemInFavorites(item: Item, completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let user = Auth.auth().currentUser else { return }
    
    // in firebase we use the "where" keyword to query (search) a collection
    
    // addSnapshotListener - continues to listen for modifications to a collection
    // getDocuments - fetches documents ONLY once
    db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).whereField("itemId", isEqualTo: item.itemId).getDocuments { (snapshot, error) in
      if let error = error {
        completion(.failure(error))
      } else if let snapshot = snapshot {
        let count = snapshot.documents.count // check if we have documents
        if count > 0 {
          completion(.success(true))
        } else {
          completion(.success(false))
        }
      }
    }
  }
  
  public func fetchUserItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
    db.collection(DatabaseService.itemsCollection).whereField(Constants.sellerId, isEqualTo: userId).getDocuments { (snapshot, error) in
      if let error = error {
        completion(.failure(error))
      } else if let snapshot = snapshot {
        let items = snapshot.documents.map { Item($0.data()) }
        completion(.success(items.sorted{$0.listedDate.seconds > $1.listedDate.seconds}))
      }
    }
  }
  
  public func fetchFavorites(completion: @escaping (Result<[Favorite], Error>) -> ()) {
    // access users collection -> userid (document) -> favorites collection
    guard let user = Auth.auth().currentUser else { return }
    db.collection(DatabaseService.usersCollection).document(user.uid).collection(DatabaseService.favoritesCollection).getDocuments { (snapshot, error) in
      if let error = error {
        completion(.failure(error))
      } else if let snapshot = snapshot {
        // compact map removes nil values from an array
        // [4, nil, 12, -9, nil] => [4, 12, -9]
        // init?() => Favorite?
        let favorites = snapshot.documents.compactMap { Favorite($0.data()) }
        completion(.success(favorites.sorted{$0.favoritedDate.seconds > $1.favoritedDate.seconds}))
      }
    }
  }
  
}

