//
//  HeaderView.swift
//  Firebase-Demo
//
//  Created by Alex Paul on 3/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Kingfisher

class HeaderView: UIView {
  
  private lazy var imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    iv.image = UIImage(systemName: "mic")
    return iv
  }()
  
  init(imageURL: String) {
    super.init(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
    commonInit()
    imageView.kf.setImage(with: URL(string: imageURL))
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  private func commonInit() {
    setupImageViewConstraints()
  }
  
  private func setupImageViewConstraints() {
    addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}
