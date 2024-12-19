//
//  UIHelpers.swift
//  Why-Cook_In (외쿸인)
//
//  Created by Joowon Jang on 12/12/24.
//

import UIKit

func presentLanguageSelection(from viewController: UIViewController) {
    let manager = LanguageManager.shared
    let alert = UIAlertController(title: manager.string(forKey: "language_info_title"),
                                  message: nil,
                                  preferredStyle: .actionSheet)
    
    for lang in manager.availableLanguages() {
        alert.addAction(UIAlertAction(title: lang.displayName, style: .default, handler: { _ in
            manager.setLanguage(lang)
        }))
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    // For iPad support if using actionSheet
    if let popover = alert.popoverPresentationController {
        popover.sourceView = viewController.view
        popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                    y: viewController.view.bounds.midY,
                                    width: 0,
                                    height: 0)
        popover.permittedArrowDirections = []
    }
    
    viewController.present(alert, animated: true)
}
