//
//  ProfileTableViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 5/28/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import FirebaseStorage
import QuartzCore


class UserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenus()
        addLabels()
        addBackgroundPhoto()
        setupImagePicker()
        addDismissalFeature()
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var nameLabel: UILabel!
    
    var emailLabel: UILabel!
    
    var phoneLabel: UILabel!
    
    var profilePicture: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    func downloadClientProfilePicture() {
        if let userId = FIRAuth.auth()?.currentUser?.uid {
        // Image
        let firebaseImages = FIRStorage.storage().reference().child("Images")
        let userPhotoLocation = firebaseImages.child("Users").child(userId).child("profilePicture.jpg")
        print("--> ClientInfo: getInfoFromDatabase:  Attempting to download profile picture")
        userPhotoLocation.downloadURL { url, error in
            print("ClientInfo: getInfoFromDatabase:  downloadURL callback . . .")
            if let error = error {
                // Handle any errors
                print("ClientInfo: getInfoFromDatabase:  ❌ errors downloading.")
            } else {
                print("ClientInfo: getInfoFromDatabase:  ✅ download successful. trying to properly handle URL. . .")
                // Get the download URL
                self.downloadProfilePicture(url: url!)
            }
        }
        }
    }
    
    func addBackgroundPhoto () {
        
        self.profilePicture = UIImageView()
        self.profilePicture.frame = CGRect(x: 0, y: self.partOfScreenHeight_d(percentage: 15), width: self.partOfScreenHeight_d(percentage: 20), height: self.partOfScreenHeight_d(percentage: 20))
        self.profilePicture.backgroundColor = UIColor.veryLightGray
        self.profilePicture.setRounded()
        self.profilePicture.layer.borderColor = UIColor.black.cgColor
        self.profilePicture.layer.borderWidth = 1
        self.profilePicture.clipsToBounds = true
        self.profilePicture.frame.centerHorizontally()
        
//        let client = Client()
//        client.info?.getInfoFromDatabase {
//            if let info = client.info {
//                
//                
//                
//                
//                
//                info.getClientPicture(finished: { (success, image) in
//                    if success {
//                        self.profilePicture.image = image
//                        print("Ayyy")
//                    } else {
//                        print("Poopie")
//                    }
//                })
//                
//                
//                
//                /////////// --------------------->>>>>>>>>>
//                
//                
//                
//                
//                
//                
//                        print("UserProfileVC: addBackgroundPhoto: Client information found. . .")
//                if let image = info.profilePicture {
//                        print("UserProfileVC: addBackgroundPhoto: ✅ Client profile picture found and initialized to. Now handling. . .")
//                    self.profilePicture = UIImageView(image: image)
//                    self.profilePicture.frame = CGRect(x: 0, y: self.partOfScreenHeight_d(percentage: 10), width: self.partOfScreenWidth_d(percentage: 40), height: self.partOfScreenHeight_d(percentage: 20))
//                    self.profilePicture.frame.centerHorizontally()
//                } else {
//                    print("UserProfileVC: addBackgroundPhoto: ❌ Client profile picture could not be initialized to.")
//                }
//            } else {
//                // Alert
//                
//            }
//            
//        }
        
        // Add User Interaction
        profilePicture.isUserInteractionEnabled = true
        let changePictureTap = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profilePicture.addGestureRecognizer(changePictureTap)
        
        
        // add to view
        self.view.addSubview(profilePicture)
    }
    
    func setupImagePicker() {
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.contentMode = .scaleAspectFit
            profilePicture.image = pickedImage
            let client = Client()
//            client.info?.getInfoFromDatabase {
//                client.info?.profilePicture = pickedImage
//                let saved = client.saveInfo()
//                if saved == "Saved!" {
//                    SCLAlertView().showSuccess("Done", subTitle: "Your profile picture has been changed!")
//                } else {
//                    SCLAlertView().showSuccess("Oops", subTitle: "There seems to have been a problem with chaging your picture! Please try again!")
//                }
//                
//            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.contentMode = .scaleAspectFit
            profilePicture.image = pickedImage
            let client = Client()
//            client.info?.getInfoFromDatabase {
//                client.info?.profilePicture = pickedImage
//                let saved = client.saveInfo()
//                if saved == "Saved!" {
//                    SCLAlertView().showSuccess("Done", subTitle: "Your profile picture has been changed!")
//                } else {
//                    SCLAlertView().showSuccess("Oops", subTitle: "There seems to have been a problem with chaging your picture! Please try again!")
//                }
//                
//            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func changeProfilePicture() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func addLabels() {
        
        // setup frames
        var nameCGR = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 40), width: partOfScreenWidth_d(percentage: 100), height: partOfScreenHeight_d(percentage: 10))
        var firstNameCGR = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 40), width: partOfScreenWidth_d(percentage: 50), height: partOfScreenHeight_d(percentage: 10))
        var lastNameCGR = CGRect(x: partOfScreenWidth_d(percentage: 50), y: partOfScreenHeight_d(percentage: 40), width: partOfScreenWidth_d(percentage: 50), height: partOfScreenHeight_d(percentage: 10))
        var emailCGR = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 50), width: partOfScreenWidth_d(percentage: 100), height: partOfScreenHeight_d(percentage: 10))
        var phoneCGR = CGRect(x: 0, y: partOfScreenHeight_d(percentage: 60), width: partOfScreenWidth_d(percentage: 100), height: partOfScreenHeight_d(percentage: 10))
        
        // init labels
        nameLabel = UILabel(frame: nameCGR)
        emailLabel = UILabel(frame: emailCGR)
        phoneLabel = UILabel(frame: phoneCGR)
        
        // init textfields
        nameTextField = UITextField(frame: firstNameCGR)
        lastNameTextField = UITextField(frame: lastNameCGR)
        emailTextField = UITextField(frame: emailCGR)
        phoneTextField = UITextField(frame: phoneCGR)
        nameTextField.indent()
        lastNameTextField.indent()
        emailTextField.indent()
        phoneTextField.indent()
        
        
        // hide texfields
        nameTextField.isHidden = true
        emailTextField.isHidden = true
        phoneTextField.isHidden = true
        lastNameTextField.isHidden = true
        
        //
        nameLabel.textAlignment = .center
        emailLabel.textAlignment = .center
        phoneLabel.textAlignment = .center
        
        // set fonts
        phoneLabel.font = UIFont().bangla(size: fontSizeWithScreen())
        phoneLabel.textColor = UIColor.black
        emailLabel.font = UIFont().bangla(size: fontSizeWithScreen())
        emailLabel.textColor = UIColor.black
        nameLabel.font = UIFont().bangla(size: fontSizeWithScreen())
        nameLabel.textColor = UIColor.black
        
        // fill data
        let client = Client()
//        client.info?.getInfoFromDatabase {
//            if let info = client.info {
//                if info.infoValid() {
//                    print("UserProfileVC: addLabels: Retreived Data.. adding to screen")
//                    // get info
//                    let name = "\(info.firstName!) \(info.lastName!)"
//                    let email = info.email
//                    let phone = info.phoneNumber
//                    
//                    // send to UI
//                    self.nameLabel.text = name
//                    self.emailLabel.text = email!
//                    self.phoneLabel.text = phone!
//                    self.nameTextField.text = info.firstName!
//                    self.lastNameTextField.text = info.lastName!
//                    self.emailTextField.text = email!
//                    self.phoneTextField.text = phone!
//                }
//            } else {
//                // Alert
//                SCLAlertView().showError("One moment", subTitle: "There is something a bit slow on our end. Please give a moment and re-enter your profile")
//            }
//            
//        }
        
        // add to screen
        self.view.addSubview(nameLabel)
        self.view.addSubview(emailLabel)
        self.view.addSubview(phoneLabel)
        self.view.addSubview(phoneTextField)
        self.view.addSubview(emailTextField)
        self.view.addSubview(nameTextField)
        self.view.addSubview(lastNameTextField)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var nameTextField: UITextField!
    var lastNameTextField: UITextField!
    var emailTextField: UITextField!
    var phoneTextField: UITextField!
    
    
    
    var userEditingFields = false
    
    @IBAction func editFields(_ sender: Any) {
//        if userEditingFields {
//            let client = Client()
//            client.info?.getInfoFromDatabase {
//                
//                
//                
//                if let info = client.info {
//                    if info.infoValid() {
//                        
//                        // Attempt changing First Name
//                        if self.nameIsValid(textfield: self.nameTextField) {
//                        if let first = self.nameTextField.text {
//                        info.firstName = first
//                        self.nameLabel.text = "\(first) \(info.lastName!)"
//                            
//                            
//                            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
//                            changeRequest?.displayName = "\(first) \(info.lastName!)"
//                            changeRequest?.commitChanges { (error) in
//                                if error != nil {
//                                SCLAlertView().showError("Oops", subTitle: "It seems that we were not able to change your name at the moment, please try again in a little bit!")
//                                } else {
//                                    // Update all stuff
//                                    info.firstName = first
//                                    self.nameLabel.text = "\(first) \(info.lastName!)"
//                                    let saved = client.saveInfo()
//                                }
//                            }
//                        }
//                        }
//                        
//                        // Attempt changing Last Name
//                        if self.nameIsValid(textfield: self.lastNameTextField) {
//                        if let last = self.lastNameTextField.text {
//                            info.lastName = last
//                            self.nameLabel.text = "\(info.firstName!) \(last)"
//                            let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
//                            changeRequest?.displayName = "\(info.firstName!) \(last)"
//                            changeRequest?.commitChanges { (error) in
//                                if error != nil {
//                                SCLAlertView().showError("Oops", subTitle: "It seems that we were not able to change your name at the moment, please try again in a little bit!")
//                                } else {
//                                    // Update all stuff
//                                    info.lastName = last
//                                    self.nameLabel.text = "\(info.firstName!) \(last)"
//                                    let saved = client.saveInfo()
//                                }
//                            }
//                        }
//                        } else {
//                            print("UserProfileVC: editFields: ❌ Could not verify email input")
//                        }
//                        
//                        // Attempt changing Email
//                        if self.verifyEmailField(textfield: self.emailTextField) {
//                        if let email = self.emailTextField.text {
//                            
//                            
//                            FIRAuth.auth()?.currentUser?.updateEmail(email) { (error) in
//                                if error != nil {
//                                    SCLAlertView().showError("Oops", subTitle: "It seems that we were not able to change your email at the moment, please try again in a little bit!")
//                                } else {
//                                    // Update all stuff
//                                    info.email = email
//                                    self.emailLabel.text = email
//                                    let saved = client.saveInfo()
//                                }
//                            }
//                        }
//                        } else {
//                            print("UserProfileVC: editFields: ❌ Could not verify email input")
//                        }
//                        
//                        if self.verifyPhoneNumberField(textfield: self.phoneTextField) {
//                        // Attempt changing Phone Number
//                        if let phoneNumber = self.phoneTextField.text {
//                            
//                                    // Update all stuff
//                                    info.phoneNumber = phoneNumber
//                                    self.phoneLabel.text = phoneNumber
//                                    let saved = client.saveInfo()
//                            
//                        }
//                        } else {
//                            print("UserProfileVC: editFields: ❌ Could not verify phone number input")
//                        }
//                    }
//                }
//            }
//            toViewMode()
//        } else {
//            toEditMode()
//        }
//
//        userEditingFields = !userEditingFields
    }
    
    func nameIsValid(textfield: UITextField) -> Bool{
        if textfield.text != nil && textfield.text != "" {
            return true
        } else {
            return false
        }
    }
    
    
    // true means field is complete
    func verifyPhoneNumberField(textfield: UITextField) -> Bool {
        
        if let text = textfield.text {
            if text != "" {
                if text.characters.count == 10 { // NOTE: We assume 10-digit Phone Number
                    return true
                }
            }
        }
        
        return false
    }
    
    func verifyEmailField(textfield: UITextField) -> Bool {
        
        if let text = textfield.text {
            if text != "" {
                if text.contains("@") && text.contains("."){
                    if text.lastIndexOf(target: "@") != (text.length-1) {
                        if text.lastIndexOf(target: ".") != 0 {
                            if text.lastIndexOf(target: "@") != 0 {
                                print(text.lastIndexOf(target: "."))
                                print();print();print();print();print()
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    
    func verifyPassField(textfield: UITextField) -> Bool {
        
        
        if let text = textfield.text {
            if text != "" {
                if text.characters.count >= 6 {
                    return true
                }
            }
        }
        
        return false
    }
    
    func toEditMode() {
        editButton.title = "Done"
        nameTextField.isHidden = false
        lastNameTextField.isHidden = false
        emailTextField.isHidden = false
        phoneTextField.isHidden = false
        
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        phoneLabel.isHidden = true
        
    }
    
    func toViewMode() {
        editButton.title = "Edit"
        nameTextField.isHidden = true
        emailTextField.isHidden = true
        phoneTextField.isHidden = true
        lastNameTextField.isHidden = true
        
        nameLabel.isHidden = false
        emailLabel.isHidden = false
        phoneLabel.isHidden = false
        
    }
    
    func addDismissalFeature() {
        self.view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    }
    
    var keyboardIsPresented = false
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func createKeyboardObervers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            if !keyboardIsPresented {
                // . . .
            }
        }
        keyboardIsPresented = true
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            // . . .
        }
        keyboardIsPresented = false
    }
    
    
    func sideMenus(){
        
        
        if revealViewController() != nil {
            
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            revealViewController().rightViewRevealWidth = 160
  
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func ryanSimpleDownload(withURLstring string: String) {
        
        if let url = URL(string: string) {
            let data: Data = NSData(contentsOf: url) as! Data
            if let image = UIImage(data: data) {
                profilePicture.image = image
            } else {
                print("RyanSimpleDownload: can't create image")
            }
        } else {
            print("RyanSimpleDownload: can't create URL")
        }
        
    }
    
    func ryanSimpleDownload(withURLstring string: String, finished: @escaping (_ success: Bool) -> ()) {
        
        if let url = URL(string: string) {
            let data: Data = NSData(contentsOf: url) as! Data
            if let image = UIImage(data: data) {
                profilePicture.image = image
                finished(true)
            } else {
                print("RyanSimpleDownload: can't create image")
                finished(false)
            }
        } else {
            print("RyanSimpleDownload: can't create URL")
            finished(false)
        }
        
    }
    
    
    // BEGIN Picture Download
    
    func useDatabaseToDownloadPicture () {
         if let userId = FIRAuth.auth()?.currentUser?.uid {
            
        // Get a reference to the storage service using the default Firebase App
        let storage = FIRStorage.storage()
        
            let firebaseImages = FIRStorage.storage().reference().child("Images")
            let userPhotoLocation = firebaseImages.child("Users").child(userId).child("profilePicture.jpg")
            let myRef = FIRStorage.storage().reference()
            let firebaseProfilePicLocation = firebase.child("Users").child(userId).child("Images").child("profilePicture").child("downloadURL")
            
        firebaseProfilePicLocation.observe(.value, with: { (snapshot) in
            print("UserProfileVC: useDBtoDownloadPic: Profile Picture Databse Snapshot -> \n \(snapshot)")
            // Get download URL from snapshot
            if let downloadURL = snapshot.value as? String {
                 print("UserProfileVC: useDBtoDownloadPic: downloadURL converted to String")
                
            // Create a storage reference from the URL
            let storageRef = storage.reference(forURL: downloadURL)
            
            // Download the data, assuming a max size of 1MB (you can change this as necessary)
            storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                
                if error != nil {
                    print("ERROR -> ")
                    print(error)
                    print(error?.localizedDescription)
                }
                
                print("Downloading Data . . . Data String -> \(String(describing: data))")
                print("Downloading Data . . . Data Literal -> \(data)")
                // Create a UIImage, add it to profile picture
                if data != nil {
                print("Data is not nil!")
                    if let image = UIImage(data: data!) {
                        print("Image Created")
                    } else {
                        print("Image Could Not create!! check data...")
                        let url = URL(string: downloadURL)
                        let urlData = try? Data(contentsOf: url!)
                        if let img = UIImage(data: urlData!) {
                            print("Image  2 Created")
                        } else {
                            print("Image 2 Failed")
                        }
                    }
                let pic = UIImage(data: data!)
                self.profilePicture.image = pic
                } else {
                    print("UserProfileVC: useDBtoDownloadPic: ❌ Data is nil")
                }
            }
                
            
            
            } else if let downloadURL = snapshot.value as? URL {
                  print("UserProfileVC: useDBtoDownloadPic: downloadURL converted to URL!")
                    
                    // Create a storage reference from the URL
                    let storageRef = storage.reference(forURL: downloadURL.absoluteString)
                    
                    // Download the data, assuming a max size of 1MB (you can change this as necessary)
                    storageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                        
                        if error != nil {
                            print("ERROR -> ")
                            print(error)
                            print(error?.localizedDescription)
                        }
                        
                        // Create a UIImage, add it to profile picture
                        if data != nil {
                            let pic = UIImage(data: data!)
                            self.profilePicture.image = pic
                        } else {
                            print("UserProfileVC: useDBtoDownloadPic: ❌ Data is nil")
                        }
                    }
            } else {
                
                 print("UserProfileVC: useDBtoDownloadPic: downloadURL did not convert to String or URL.. attempting other ways to access URL string")
                
                if let val = snapshot.value as? FIRDataSnapshot {
                    let str = val.value
                    print("Option 1: \(str)")
                } else {
                    print("Option 1: FAIL")
                }
                
                if let val = snapshot.value as? [String: AnyObject] {
                    let str = val["downloadURL"]
                    print("Option 2: \(str)")
                } else {
                    print("Option 2:FAIL")
                }
                if let val = snapshot.value(forKey: "downloadURL"){
                    print("Option 3: \(val)")
                } else {
                    print("Option 3: FAIL")
                }
                print("Snapshot: -> \n \(snapshot)")
            }
            
        })
        }
    }
    
    // END Picture Download
    
    // Helper Method for downloadProfilePictuer
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    // Download from database
    func downloadProfilePicture(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                let image = UIImage(data: data)
                self.profilePicture.image = image
//                if let activeVC = UIApplication.topViewController() as? UserProfileViewController {
//                    print("UserProfileVC: downloadProfilePicture: initialized activeVC, should be changing picture")
//                    activeVC.profilePicture.image = UIImage(data: data)
//                    
//                } else {
//                    print("UserProfileVC: downloadProfilePicture: Could not initialize activeVC")
//                }
                
            }
        }
    }
    
}

extension UITableViewController {
    
    func registerTableView(reuseIdentifier: String) {
        self.tableView.register(GenericCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
}

extension UIFont {
    
    func bangla(size: CGFloat) -> UIFont {
        return UIFont(name: "Bangla Sangam MN", size: size)!
    }
    
}

extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}

extension UIViewController {
    /*
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    // Download from database
    func downloadImage(url: URL) -> UIImage? {
        print("Download Started")
        var image: UIImage?
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            
            DispatchQueue.main.async() { () -> Void in
                 image = UIImage(data: data)
            }
            
        }
        return image
    }
    */
}
