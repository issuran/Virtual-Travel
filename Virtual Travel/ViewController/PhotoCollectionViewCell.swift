//
//  PhotoCollectionViewCell.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 28/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
}
