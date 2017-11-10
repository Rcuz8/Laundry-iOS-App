//
//  mProfileViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import QuartzCore
import Hero
import Firebase
class mProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavController()
        initImageView()
        self.menuButton.tintColor = UIColor.lavoLightGray
        addBackgroundPhoto()
        setupImagePicker()
        orderPrefsB.roundCorners(.allCorners, radius: 7)
    }
    
    @IBOutlet weak var orderPrefsB: UIButton!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    func addBackgroundPhoto() {
        
        if let user = FIRAuth.auth()?.currentUser {
            let client = Client(id: user.uid)
            client.dbFill {
                if let firstName = client.firstName, let lastName = client.lastName { self.nameLabel.text = "\(firstName) \(lastName)" }
                if let email = client.email { self.emailLabel.text = "\(email)" }
                if let address = client.homeAddress {
                    if address.infoValid() {
                        self.addressLabel.text = "\(address.streetAddress), \(address.city) \(address.state)" } }
            }
            client.getClientPicture(finished: { (success, pic) in
                if success {
                    self.profilePicture.image = pic!
                } else {
                    // Cant find prof pic
                }
            })
        } else { print("Cannot find user") }
        
        profilePicture.isUserInteractionEnabled = true
        let changePictureTap = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profilePicture.addGestureRecognizer(changePictureTap)
    }
    
    func setupImagePicker() {
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print("pickedImage found")
            profilePicture.contentMode = .scaleAspectFit
            profilePicture.image = pickedImage
            if let user = FIRAuth.auth()?.currentUser {
                print("user good")
                let client = Client(id: user.uid)
                client.profilePicture = pickedImage
                client.storeProfilePic()
                
            }  else { print("Cannot find user") }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changeProfilePicture() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggle(_ sender: Any) {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = 200
            self.revealViewController().revealToggle(animated: true)
        }
    }
    
    func initImageView() {
        profilePicture.setRounded()
        profilePicture.layer.borderColor = UIColor.lavoLightGray.cgColor
        profilePicture.layer.borderWidth = 3
    }
    
//    @IBAction func toOrderPreferences(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let rootViewController = storyboard.instantiateViewController(withIdentifier:"mOrderingPreferencesVC");
//        let navController = UINavigationController(rootViewController: rootViewController)
//        navController.setViewControllers([rootViewController], animated: true)
//        self.revealViewController().setFront(navController, animated: true)
//        self.revealViewController().setFrontViewPosition(.left, animated: true)
//    }


     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "s1" {
            segue.destination.heroModalAnimationType = .push(direction: .left)
        }
        
     }
    
}

extension UIViewController {
    
    func heroPresent(storyboard: String, vc: String, withAnimation animation: HeroDefaultAnimationType) {
        let vc = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: vc)
        vc.heroModalAnimationType = animation
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func heroPresentWithSWReveal(storyboard: String, vc: String, withAnimation animation: HeroDefaultAnimationType) {
        let vc = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: vc)
        vc.heroModalAnimationType = animation
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    func hideNavController() {
        if let nav = self.navigationController {
            nav.isNavigationBarHidden = true
        }
    }
}
