//
//  CategoryCell.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/2/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
  @IBOutlet weak var categoryImageView: UIImageView!
  @IBOutlet weak var categoyNameLabel: UILabel!
  
  public func configureCell(for category: Category) {
    let colorImage = category.image.withTintColor(UIColor.generateRandomColor(), renderingMode: .alwaysOriginal)
    categoryImageView.image = colorImage
    categoyNameLabel.text = category.name
  }
}

extension UIColor {
  static func generateRandomColor() -> UIColor {
      let redValue = CGFloat.random(in: 0...1)
      let greenValue = CGFloat.random(in: 0...1)
      let blueValue = CGFloat.random(in: 0...1)
      let randomColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
      return randomColor
  }
}
