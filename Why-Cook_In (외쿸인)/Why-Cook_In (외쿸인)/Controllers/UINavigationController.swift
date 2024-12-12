//
//  UINavigationController.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize navigation appearance if needed
        navigationBar.prefersLargeTitles = true
        navigationBar.tintColor = .systemBlue
    }
}
