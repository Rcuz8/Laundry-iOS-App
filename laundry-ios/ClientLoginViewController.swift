//
//  ClientLoginViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 7/29/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit

class ClientLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var background: UIImageView!
    
    var lavoLogo: UIImageView!
    
    var standardSignInView: UIView!
    
    var standardSignInDivLine: UIView!
    
    var emailField: UITextField!
    
    var passField: UITextField!
    
    var standardSignInButton: UIButton!
    
    // BEGIN Element
    
    func addBackground() {
        let cgr = CGRect(x: 0, y: 0, width: partOfScreenWidth_d(percentage: 100), height: partOfScreenHeight_d(percentage: 100))
        background = UIImageView(frame: cgr)
        background.image = UIImage(named: "background1")
        self.view.addSubview(background)
    }
    
    func addUIelementLavoLogo() {
        let cgr = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 20), width: Double(partOfScreenWidth_d(percentage: 60)), height: Double(partOfScreenHeight_d(percentage: 10)))
        lavoLogo = UIImageView(frame: cgr)
        lavoLogo.image = UIImage(named: "lavoLogo")
        lavoLogo.frame.centerHorizontally()
        lavoLogo.center.x = self.view.center.x
        self.view.addSubview(lavoLogo)
        
    }

    func addStandardSignIn() {
        
        // Create Encapsulating View for Email and Password
        let cgr = CGRect(x: 0, y: 0, width: partOfScreenWidth_d(percentage: 70), height: Double(partOfScreenHeight_d(percentage: 19)))
        standardSignInView = UIView(frame: cgr)
        standardSignInView.layer.cornerRadius = 6
        standardSignInView.layer.borderColor = UIColor.white.cgColor
        standardSignInView.layer.borderWidth = 1
        standardSignInView.blur(style: .regular)
        standardSignInView.frame.centerVertically()
        standardSignInView.frame.centerHorizontally()
        self.view.addSubview(standardSignInView)
        // End
        
        // NEXT: Create 2 textfields, create division between them, put in pictures, indent textfields to account for pictures
        let divLineCGR = CGRect(x: 0, y: 0, width: Double(partOfScreenWidth_d(percentage: 70)), height: 1)
        standardSignInDivLine = UIView(frame: divLineCGR)
        standardSignInDivLine.frame.centerHorizontally()
        standardSignInDivLine.frame.centerVertically()
        standardSignInDivLine.backgroundColor =  UIColor.white
        self.view.addSubview(standardSignInDivLine)
        //
        
        emailField = UITextField()
        
        emailField.initializeRectWith(image: "RC-profilePic3", width: Double(partOfScreenWidth_d(percentage: 70)))
        emailField.center = standardSignInView.center
        print();print()
        print(emailField.center)
        print(standardSignInView.center)
        emailField.textColor = UIColor.white
        emailField.frame.centerHorizontally()
        emailField.frame.dilate(y: -partOfScreenHeight_f(percentage: 5))
        emailField.placeholder = "Enter your email"
        self.view.addSubview(emailField)
        
        passField = UITextField()
        passField.initializeRectWith(image: "RC-lock", width: Double(partOfScreenWidth_d(percentage: 70)))
        passField.center = standardSignInView.center
        passField.placeholder = "Enter your password"
        passField.frame.centerHorizontally()
        passField.textColor = UIColor.white
        
        passField.frame.dilate(y: partOfScreenHeight_f(percentage: 5))
        self.view.addSubview(passField)
        //
        
        
        // Create Sign In Button
        let ssbCGR = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 65), width: partOfScreenWidth_d(percentage: 70), height: partOfScreenHeight_d(percentage: 7))
        standardSignInButton = UIButton(frame: ssbCGR)
        standardSignInButton.setTitle("Sign in", for: .normal)
        standardSignInButton.setTitleColor(.white, for: .normal)
        standardSignInButton.backgroundColor = UIColor.veryLightGray
  //      standardSignInButton.addTarget(self, action: #selector(standardSignIn), for: .touchUpInside)
        standardSignInButton.layer.cornerRadius = 6
        standardSignInButton.frame.centerHorizontally()
        self.view.addSubview(standardSignInButton)
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
