//
//  LoadingViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 6/24/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import Foundation
import Firebase
import NVActivityIndicatorView
class LoadingViewController: UIViewController {
    
    
    override func viewDidLoad() {
        animateView()
        delay(0.5) {
            if FIRAuth.auth()?.currentUser != nil {
                print("user exists")
                
            } else {
                self.animatableView.stopAnimating()
                self.goTo(storyboardName: "Auth", viewControllerName: "mLoginVC", animated: false)
            }
        }
        
        
    }
    
    @IBOutlet weak var animatableView: NVActivityIndicatorView!
    
    func animateView() {
        animatableView.color = UIColor.lavoLightGray
        animatableView.type = .ballClipRotateMultiple
        animatableView.startAnimating()
    }
    
    func changeWindow() {
        
        if let window = UIApplication.shared.keyWindow {
        //    self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Auth", bundle: nil)
          //  let initVC = storyboard.instantiateInitialViewController()
            let initialViewController = storyboard.instantiateInitialViewController()
            window.rootViewController = initialViewController
            window.makeKeyAndVisible()
        } else {
            print("No Window")
        }
    }
    
}

extension CGRect {
    
    mutating func dilate(x: Float) {
        
        self.origin = CGPoint(x: self.origin.x+CGFloat(x), y: self.origin.y)
        
    }
    
    mutating func dilate(y: Float) {
        
        self.origin = CGPoint(x: self.origin.x, y: self.origin.y+CGFloat(y))
    }
    
    mutating func centerHorizontally(){
        
        let centerX = (UIScreen.main.bounds.width)/2
        
        self.origin = CGPoint(x: centerX-(self.width/2), y: self.minY)
        
    }
    
    mutating func centerVertically(){
        
        let centerY = (UIScreen.main.bounds.height)/2
        
        self.origin = CGPoint(x: self.minX, y: centerY-(self.height/2))
        
    }

}

extension UIFont {

    class func customFontAttibutes(with fontStyle: String?, size: CGFloat, color: UIColor, weight: CGFloat) -> [NSObject: AnyObject]? {
        var retAttributes: [NSObject : AnyObject]?
        if let style = fontStyle {
            
            if let font = UIFont(name: style, size: size) {
                
                let attributes : [NSObject : AnyObject] = [NSForegroundColorAttributeName as NSObject : color, NSFontAttributeName as NSObject: font]
                retAttributes = attributes
            } else {
                let attributes : [NSObject : AnyObject] = [NSForegroundColorAttributeName as NSObject : color, NSFontAttributeName as NSObject: UIFont.systemFont(ofSize: size, weight: weight)]
                retAttributes = attributes
            }
            
        } else {
            let attributes : [NSObject : AnyObject] = [NSForegroundColorAttributeName as NSObject : color, NSFontAttributeName as NSObject: UIFont.systemFont(ofSize: size, weight: weight)]
            retAttributes = attributes
        }
        
        
        return retAttributes
        
    }
    

}

extension CGFloat {
    
    static var fontBold : CGFloat {
        return UIFontWeightBold
    }
    
    static var fontVeryBold : CGFloat {
        return UIFontWeightHeavy
    }
    
}

extension UIViewController {
    
    func delay(_ by: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + by) {
            completion()
        }
    }
    
}

extension UIApplicationDelegate {
    
    func delay(_ by: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + by) {
            completion()
        }
    }
    
}
