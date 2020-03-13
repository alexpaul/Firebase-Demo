//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth // authentication
import FirebaseFirestore // database (firestore)

class CreateItemViewController: UIViewController {
  
  @IBOutlet weak var itemNameTextField: UITextField!
  @IBOutlet weak var itemPriceTextField: UITextField!
  @IBOutlet weak var itemImageView: UIImageView!
  
  private var category: Category
    
  private lazy var imagePickerController: UIImagePickerController = {
    let picker = UIImagePickerController()
    picker.delegate = self // confomrm to UIImagePickerContorllerDelegate and UINavigationControllerDelegate
    return picker
  }()
  
  private lazy var longPressGesture: UILongPressGestureRecognizer = {
    let gesture = UILongPressGestureRecognizer()
    gesture.addTarget(self, action: #selector(showPhotoOptions))
    return gesture
  }()
  
  private var selectedImage: UIImage? {
    didSet {
      itemImageView.image = selectedImage
    }
  }
  
  init?(coder: NSCoder, category: Category) {
    self.category = category
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = category.name
    
    // add long press gesture to itemImageView
    itemImageView.isUserInteractionEnabled = true
    itemImageView.addGestureRecognizer(longPressGesture)
  }
  
  @objc private func showPhotoOptions() {
    let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
      self.imagePickerController.sourceType = .camera
      self.present(self.imagePickerController, animated: true)
    }
    let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { alertAction in
      self.imagePickerController.sourceType = .photoLibrary
      self.present(self.imagePickerController, animated: true)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      alertController.addAction(cameraAction)
    }
    alertController.addAction(photoLibrary)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
  @IBAction func sellButtonPressed(_ sender: UIBarButtonItem) {
    sender.isEnabled = false
    guard let itemName = itemNameTextField.text,
      !itemName.isEmpty,
      let priceText = itemPriceTextField.text,
      !priceText.isEmpty,
      let price = Double(priceText),
      let selectedImage = selectedImage else {
        showAlert(title: "Missing Fields", message: "All fields are required along with a photo.")
        sender.isEnabled = true
        return
    }
    
    guard let displayName = Auth.auth().currentUser?.displayName else {
      showAlert(title: "Incomplete Profile", message: "Please complete your Profile.")
      sender.isEnabled = true
      return
    }
    
    // resize image before uploading to Storage
    let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: itemImageView.bounds)
    
    DatabaseService.shared.createItem(itemName: itemName, price: price, category: category, displayName: displayName) { [weak self, weak sender] (result) in
      switch result {
      case.failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(title: "Error creating item", message: "Sorry something went wrong: \(error.localizedDescription)")
          sender?.isEnabled = true
        }
      case .success(let documentId):
        self?.uploadPhoto(photo: resizedImage, documentId: documentId)
        sender?.isEnabled = true
      }
    }
  }
  
  private func uploadPhoto(photo: UIImage, documentId: String) {
    StorageService.shared.uploadPhoto(itemId: documentId, image: photo) { [weak self] (result) in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
        }
      case .success(let url):
        self?.updateItemImageURL(url, documentId: documentId)
      }
    }
  }
  
  private func updateItemImageURL(_ url: URL, documentId: String) {
    // update an existing document on Firebase
    Firestore.firestore().collection(DatabaseService.itemsCollection).document(documentId).updateData(["imageURL" : url.absoluteString]) { [weak self] (error) in
      if let error = error {
        DispatchQueue.main.async {
          self?.showAlert(title: "Fail to update item", message: "\(error.localizedDescription)")
        }
      } else {
        // everything went ok
        print("all went well with the update")
        DispatchQueue.main.async {
          self?.dismiss(animated: true)
        }
      }
    }
  }
}



extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      fatalError("could not attain original image")
    }
    selectedImage = image
    dismiss(animated: true)
  }
}
