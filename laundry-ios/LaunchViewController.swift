//
//  LoadingViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 6/24/17.
//  Copyright © 2017 Lavo Logistics. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
class LaunchViewController: UIViewController {
    
    
    override func viewDidLoad() {
        animateView()
    }
    
    @IBOutlet weak var animatableView: NVActivityIndicatorView!
    
    func animateView() {
        animatableView.color = UIColor.lavoLightGray
        animatableView.type = .ballClipRotateMultiple
        animatableView.startAnimating()
    }
    
}
