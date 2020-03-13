//
//  ViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 2/28/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import FirebaseAuth

enum AccountState {
  case existingUser
  case newUser
}

class LoginViewController: UIViewController {
  
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var accountStateMessageLabel: UILabel!
  @IBOutlet weak var accountStateButton: UIButton!
  
  private var accountState: AccountState = .existingUser
  
  override func viewDidLoad() {
    super.viewDidLoad()
    clearErrorLabel()
  }
  
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard let email = emailTextField.text,
      !email.isEmpty,
      let password = passwordTextField.text,
      !password.isEmpty else {
        print("missing fields")
        return
    }
    continueLoginFlow(email: email, password: password)
  }
  
  private func continueLoginFlow(email: String, password: String) {
    if accountState == .existingUser {
      AuthenticationSession.shared.signExistingUser(email: email, password: password) { [weak self] (result) in
        switch result {
        case .failure(let error):
          DispatchQueue.main.async {
            self?.errorLabel.text = "\(error.localizedDescription)"
            self?.errorLabel.textColor = .systemRed
          }
        case .success:
          DispatchQueue.main.async {
            self?.navigateToMainView()
          }
        }
      }
    } else {
      AuthenticationSession.shared.createNewUser(email: email, password: password) { [weak self] (result) in
        switch result {
        case .failure(let error):
          DispatchQueue.main.async {
            self?.errorLabel.text = "\(error.localizedDescription)"
            self?.errorLabel.textColor = .systemRed
          }
        case .success(let authDataResult):
          // create a database user only from a new authenticated account
          self?.createDatabaseUser(authDataResult: authDataResult)
        }
      }
    }
  }
  
  private func createDatabaseUser(authDataResult: AuthDataResult) {
    DatabaseService.shared.createDatabaseUser(authDataResult: authDataResult) { [weak self] (result) in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self?.showAlert(title: "Account error", message: error.localizedDescription)
        }
      case .success:
        DispatchQueue.main.async {
          self?.navigateToMainView()
        }
      }
    }
  }
  
  private func navigateToMainView() {
    UIViewController.showViewController(storyBoardName: "MainView", viewControllerId: "MainTabBarController")
  }
  
  private func clearErrorLabel() {
    errorLabel.text = ""
  }
  
  @IBAction func toggleAccountState(_ sender: UIButton) {
    // change the account login state
    accountState = accountState == .existingUser ? .newUser : .existingUser
    
    // animation duration
    let duration: TimeInterval = 1.0
    
    if accountState == .existingUser {
      UIView.transition(with: containerView, duration: duration, options: [.transitionFlipFromRight], animations: {
        self.loginButton.setTitle("Login", for: .normal)
        self.accountStateMessageLabel.text = "Don't have an account ? Click"
        self.accountStateButton.setTitle("SIGNUP", for: .normal)
      }, completion: nil)
    } else {
      UIView.transition(with: containerView, duration: duration, options: [.transitionFlipFromLeft], animations: {
        self.loginButton.setTitle("Sign Up", for: .normal)
        self.accountStateMessageLabel.text = "Already have an account ?"
        self.accountStateButton.setTitle("LOGIN", for: .normal)
      }, completion: nil)
    }
  }

}

