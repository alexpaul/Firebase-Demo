//
//  ProfileViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var displayNameTextField: UITextField!
  @IBOutlet weak var emailLabel: UILabel!
  
  private lazy var imagePickerController: UIImagePickerController = {
    let ip = UIImagePickerController()
    ip.delegate = self
    return ip
  }()
  
  private var selectedImage: UIImage? {
    didSet {
      profileImageView.image = selectedImage
    }
  }
  
  private let storageService = StorageService()
  private let databaseService = DatabaseService()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    displayNameTextField.delegate = self
    updateUI()
  }
  
  private func updateUI() {
    guard let user = Auth.auth().currentUser else {
      return
    }
    emailLabel.text = user.email
    displayNameTextField.text = user.displayName
    profileImageView.kf.setImage(with: user.photoURL)
    //user.displayName
    //user.email
    //user.phoneNumber
    //user.photoURL
  }
  
  @IBAction func updateProfileButtonPressed(_ sender: UIButton) {
    // change the user's display name
    guard let displayName = displayNameTextField.text,
      !displayName.isEmpty,
      let selectedImage = selectedImage else {
        print("missing fields")
        return
    }
    
    guard let user = Auth.auth().currentUser else { return }
    
    // resize image before uploading to Firebase
    let resizedImage = UIImage.resizeImage(originalImage: selectedImage, rect: profileImageView.bounds)
    
    print("original image size: \(selectedImage.size)")
    print("resized image size: \(resizedImage)")
    
    // call storageService.upload
    storageService.uploadPhoto(userId: user.uid, image: resizedImage) { [weak self] (result) in
      // code here to add the photoURL to the user's photoURL property then commit changes
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(title: "Error uploading photo", message: "\(error.localizedDescription)")
        }
      case .success(let url):
        
        self?.updateDatabaseUser(displayName: displayName, photoURL: url.absoluteString)
        
        // TODO: refactor into its own function
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = displayName
        request?.photoURL = url
        request?.commitChanges(completion: { [unowned self] (error) in
          if let error = error {
            DispatchQueue.main.async {
              self?.showAlert(title: "Error updating profile", message: "Error changing profile: \(error.localizedDescription).")
            }
          } else {
            DispatchQueue.main.async {
              self?.showAlert(title: "Profile Update", message: "Profile successfully updated 🥳.")
            }
          }
        })
      }
    }
  }
  
  private func updateDatabaseUser(displayName: String, photoURL: String) {
    databaseService.updateDatabaseUser(displayName: displayName, photoURL: photoURL) { (result) in
      switch result {
      case .failure(let error):
        print("failed to update db user: \(error.localizedDescription)")
      case .success:
        print("successfully updated db user")
      }
    }
  }
  
  @IBAction func editProfilePhotoButtonPressed(_ sender: UIButton) {
    let alertController = UIAlertController(title: "Choose Photo Option", message: nil, preferredStyle: .actionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: .default) { alertAction in
      self.imagePickerController.sourceType = .camera
      self.present(self.imagePickerController, animated: true)
    }
    let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { alertAction in
      self.imagePickerController.sourceType = .photoLibrary
      self.present(self.imagePickerController, animated: true)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      alertController.addAction(cameraAction)
    }
    alertController.addAction(photoLibraryAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
  @IBAction func signOutButtonPressed(_ sender: UIButton) {
    do {
      try Auth.auth().signOut()
      UIViewController.showViewController(storyBoardName: "LoginView", viewControllerId: "LoginViewController")
    } catch {
      DispatchQueue.main.async {
        self.showAlert(title: "Error signing out", message: "\(error.localizedDescription)")
      }
    }
  }
  
  
}

extension ProfileViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      return
    }
    selectedImage = image
    dismiss(animated: true)
  }
}
