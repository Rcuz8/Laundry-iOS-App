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
    
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var v3: UIView!
    @IBOutlet weak var saveB: UIButton!
    @IBOutlet weak var preferencesB: UIButton!
    let imagePicker = UIImagePickerController()
    
    let db = UserDB()
    
    var changedEmail = false
    var changedName = false
    var changedPhoneNumber = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggle(tf: nameTF)
        toggle(tf: phoneNumberTF)
        toggle(tf: emailTF)
        
        if let id = db.getUser()?.uid {
            fillBackgroundInfo(forClient: id)
        } else {
            showError(withMessage: "Cannot find your user information!")
        }
        
        
        // Profile Picture Setup
        initImageView()
        addBackgroundPhoto()
        setupImagePicker()
        
        // UI
        roundStuff()
        
    }
    
    func roundStuff() {
        saveB.round()
        v1.round()
        v2.round()
        v3.round()
        preferencesB.round()
    }
    
    func fillBackgroundInfo(forClient id: String) {
        
        let c = Client(id: id)
        c.dbFill {
            if let first = c.firstName, let last = c.lastName {
                let name = "\(first) \(last)"
                self.firstNameLabel.text = name
                self.nameTF.text = name
            }
            if let phone = c.phoneNumber {
                self.phoneNumberLabel.text = phone
                self.phoneNumberTF.text = phone
            }
            if let email = c.email {
                self.emailLabel.text = email
                self.emailTF.text = email
            }
        }
    }
    
    func toggle(tf: UITextField) {
        tf.isHidden = !tf.isHidden
    }
    func toggle(lbl: UILabel) {
        lbl.isHidden = !lbl.isHidden
    }
    
    
    
    @IBAction func editName(_ sender: Any) {
        toggle(tf: nameTF)
        toggle(lbl: firstNameLabel)
        changedName = true
    }
    
    @IBAction func editPhoneNumber(_ sender: Any) {
        toggle(tf: phoneNumberTF)
        toggle(lbl: phoneNumberLabel)
        changedPhoneNumber = true
    }
    
    @IBAction func editEmail(_ sender: Any) {
        toggle(tf: emailTF)
        toggle(lbl: emailLabel)
        changedEmail = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func emailIsGood() -> Bool {
        if let email = emailTF.text, emailTF.text! != "", emailTF.text!.contains("@"), emailTF.text!.characters.count > 4 {
            // good
            return true
        } else { return false }
    }
    
    @IBAction func toggle(_ sender: Any) {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = 200
            self.revealViewController().revealToggle(animated: true)
        }
    }
    
    
    @IBAction func save(_ sender: Any) {
        if let user = db.getUser() { let client = Client(id: user.uid)
            var emailFailed = false, nameFailed = false // prevent double error msgs
            if changedEmail, emailTF.text != nil, emailTF.text != emailLabel.text {
                if let email = emailTF.text, emailIsGood() {
                    // Update email
                    
                    db.postUserInformation(user: user, info: email, type: .email, completion: { (err) in
                        if err != nil {
                            self.showError(withMessage: "Could not update email info!")
                        } else {
                            self.emailLabel.text = email
                            self.toggle(tf: self.emailTF)
                            self.toggle(lbl: self.emailLabel)
                            self.showSuccess(withMessage: "Information updated!")
                        }
                    })
                    
                } else {
                    emailFailed = true
                    self.showError(withMessage: "Please enter in a valid email!")
                }
            }
            
            if changedName, !emailFailed, nameTF.text != nil, nameTF.text != firstNameLabel.text {
                if let name = nameTF.text, nameTF.text! != "" {
                    // Update email
                    db.postUserInformation(user: user, info: name, type: .name, completion: { (err) in
                        if err != nil {
                            print("ERROR Description: \(err)")
                            self.showError(withMessage: "Could not update name info!")
                        } else {
                            self.firstNameLabel.text = name
                            self.toggle(tf: self.nameTF)
                            self.toggle(lbl: self.firstNameLabel)
                            self.showSuccess(withMessage: "Information updated!")
                        }
                    })
                    
                    
                } else {
                    nameFailed = true
                    self.showError(withMessage: "Please enter in a valid name!")
                }
            } else { nameFailed = true }
            
            if changedPhoneNumber, !emailFailed, !nameFailed, phoneNumberTF.text != nil, phoneNumberTF.text != phoneNumberLabel.text {
                if let phoneNumber = emailTF.text, phoneNumberTF.text!.characters.count >= 10 {
                    // Update email
                    db.postUserInformation(user: user, info: phoneNumber, type: .phoneNumber, completion: { (err) in
                        if err != nil {
                            self.showError(withMessage: "Could not update phone number info!")
                        } else {
                            self.phoneNumberLabel.text = phoneNumber
                            self.toggle(tf: self.phoneNumberTF)
                            self.toggle(lbl: self.phoneNumberLabel)
                            self.showSuccess(withMessage: "Information updated!")
                        }
                    })
                    
                }  else {
                    self.showError(withMessage: "Please enter in a valid phone number!")
                }
                
            }
            
        } else {
            self.showError(withMessage: "Cannot find your user information!")
        }
        
    }
    
    
    // Profile Picture change code
    
    func initImageView() {
        profilePicture.layer.cornerRadius = 7
        profilePicture.layer.borderColor = UIColor.lavoLightBlue.cgColor
        profilePicture.layer.borderWidth = 3
    }
    
    func addBackgroundPhoto() {
        
        if let user = db.getUser() {
            
            db.getProfilePicture(forClient: user.uid, finished: { (success, image) in
                print("Callback for addBackgroundPhoto:")
                if success {    print("image successfully found!\n")
                    self.profilePicture.maskCircle(anyImage: image!)
                } else {
                    // Cant find prof pic
                    print("image could NOT be found!\n")
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
            print("User Selected an Image, saving . . .")
            //      profilePicture.contentMode = .scaleAspectFit
            profilePicture.maskCircle(anyImage: pickedImage)
            
            if let user = UserDB().getUser() {
                let client = Client(id: user.uid)
                client.profilePicture = pickedImage
                client.storeProfilePic()
                
            } else { print("Cannot find user") }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changeProfilePicture() {
        present(imagePicker, animated: true, completion: nil)
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

extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
        self.image = anyImage
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


import SCLAlertView

extension UIViewController {
    
    func showError(withMessage message: String) {
        SCLAlertView().showError("Error", subTitle: message)
    }
    
    func showSuccess(withMessage message: String) {
        SCLAlertView().showSuccess("Success!", subTitle: message)
    }
    
}

extension UIView {
    func round() {
        self.layer.cornerRadius = 5
    }
}
