//
//  LoadingSpinnerViewController.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/6/22.
//  Copyright © 2022 Hayden Kreuter. All rights reserved.
//

import Foundation
import UIKit

class LoadingSpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
        spinner.color = .gray
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
