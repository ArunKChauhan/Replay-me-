//
//  TextFieldPadding.swift
//  ReplayMe
//
//  Created by Core Techies on 25/02/20.
//  Copyright © 2020 Core Techies. All rights reserved.
//

import UIKit
class PaddedTextField: UITextField {

    @IBInspectable var padding: CGFloat = 0

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + padding, y: bounds.origin.y, width: bounds.width - padding * 2, height: bounds.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + padding, y: bounds.origin.y, width: bounds.width - padding * 2, height: bounds.height)
    }
}
