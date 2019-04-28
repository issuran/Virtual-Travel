//
//  BaseViewController.swift
//  Virtual Travel
//
//  Created by Tiago Oliveira on 28/04/19.
//  Copyright © 2019 Tiago Oliveira. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    func alert(message: String, title: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(OKAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
