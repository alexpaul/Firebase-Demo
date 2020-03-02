//
//  CreateItemViewController.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CreateItemViewController: UIViewController {
  
  @IBOutlet weak var itemNameTextField: UITextField!
  @IBOutlet weak var itemPriceTextField: UITextField!
  
  private var category: Category
  
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
  }
  
  @IBAction func sellButtonPressed(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }
}
