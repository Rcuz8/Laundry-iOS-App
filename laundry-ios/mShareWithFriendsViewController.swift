//
//  mShareWithFriendsViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
protocol AddContactViewControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}


class mShareWithFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CheckToggledDelegate, MFMessageComposeViewControllerDelegate {

    var contacts = [CNContact]()
    
    var contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavController()
        self.menuButton.tintColor = UIColor.lavoLightGray
        
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])

        do {
            try self.contactStore.enumerateContacts(with: fetchRequest) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                self.contacts.append(contact)
                self.tableView.reloadData()
                let name = "\(contact.givenName) \(contact.familyName)"
                let phone = (contact.phoneNumbers[0].value as! CNPhoneNumber).value(forKey: "digits") as! String
                self.phoneList.append(phone)
                self.nameList.append(name)
                print("Added New Contact: { ")
                print("   Name: \(name)")
                print("   Phone: \(phone)")
                print("}")
                self.tableView.reloadData()
            }
        }
        catch {
            print("unable to fetch contacts")
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.reloadData()
    }
    
    var nameList = [String]()
    var phoneList = [String]()
    
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
    
    var checkedCells = [Int]()
    func checkToggled(cell: CheckBoxCell) {
        let indexPath = self.tableView.indexPathForRow(at: cell.center)!
        checkedCells.append(indexPath.row)
        print("appended \(indexPath.row)")
    }
    
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }
    
    
    @IBAction func markAll(_ sender: Any) {
        for cell in tableView.visibleCells {
            if let checkCell = cell as? CheckBoxCell {
                if checkCell.checkMark.alpha == 0 { // unchecked 
                    checkCell.toggleCheck()
                } }
        }
    }
    
    
    func didFetchContacts(contacts: [CNContact]) {
        for contact in contacts {
            self.contacts.append(contact)
        }
        
        tableView.reloadData()
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkBoxCell") as! CheckBoxCell
        print(nameList)
        print(phoneList)
        let currentContact = contacts[indexPath.row]
        
        cell.title.text = nameList[indexPath.row]
        cell.delegate = self
        
        
        
        return cell
    }
    
    @IBAction func sendSmsClick(_ sender: AnyObject) {
        if phoneList.count > 0 {
            if !MFMessageComposeViewController.canSendText() {
                print("SMS services are not available")
            } else {
                print("SMS services are available!")
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Get Lavo!! Link: GetLavo.com";
        messageVC.recipients = phoneList
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
            } }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }

}

