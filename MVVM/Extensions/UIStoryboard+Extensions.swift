//
//  UIStoryboard+Extensions.swift
//  MVVM
//
//  Created by  Gleb Tarasov on 09/08/2018.
//  Copyright © 2018 Gleb Tarasov. All rights reserved.
//

import UIKit

extension UIStoryboard {
    // swiftlint:disable force_cast
    func instantiate<T: UIViewController>(type: T.Type) -> T {
        return instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
    // swiftlint:enable force_cast
}
