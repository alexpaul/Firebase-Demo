//
//  StorageService.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/4/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageService {
  
  // in our app we will be uploading a photo to Storage in two places: 1. ProfileViewController and 2. CreateItemViewController
  
  // we will be creating two different buckets of folders 1. UserProfilePhotos/user.uid 2. ItemsPhotos/itemId
  
  // let's create a reference to the Firebase storage
  private let storageRef = Storage.storage().reference()
  
  private init() {}
  static let shared = StorageService()
  
  // default parameters in Swift e.g userId: String? = nil
  public func uploadPhoto(userId: String? = nil, itemId: String? = nil, image: UIImage, completion: @escaping (Result<URL, Error>) -> ()) {
    
    // 1. convert UIImage to Data because this is the object we are posting to Firebase Storage
    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
      return
    }
    
    // we need to establish which bucket or collection or folder we will be saving the photo to
    var photoReference: StorageReference! // nil
    
    if let userId = userId { // coming from ProfileViewController
      photoReference = storageRef.child("UserProfilePhotos/\(userId).jpg")
    } else if let itemId = itemId { // coming from CreateItemViewController
      photoReference = storageRef.child("ItemsPhotos/\(itemId).jpg")
    }
    
    // configure metatdata for the object being uploaded
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpg" // MIME type
    
    let _ = photoReference.putData(imageData, metadata: metadata) { (metadata, error) in
      if let error = error {
        completion(.failure(error))
      } else if let _ = metadata {
        photoReference.downloadURL { (url, error) in
          if let error = error {
            completion(.failure(error))
          } else if let url = url {
            completion(.success(url))
          }
        }
      }
    }
    
  }
}
