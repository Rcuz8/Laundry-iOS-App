//
//  DB.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 1/11/18.
//  Copyright © 2018 Lavo Logistics. All rights reserved.
//

import Foundation

struct DB {
    func getLocations(forUserWithId id: String, finished: @escaping (_ success: Bool,_ picture: UIImage?) -> ()) {
        if let userId = id {
            
            print("Client: getClientPicture: ✅ FIRUser found!")
            
            //         firebase.child("Users").child(userId).child("images").observeSingleEvent(of: .value, with: { (snap: FIRDataSnapshot) in
            //             print("Client: getClientPicture: User Info Database snapshot found. Testing as [String:AnyObject] . . .")
            
            // Image
            let userPhotoLocation = self.firebaseImages.child("Users").child(userId).child("profilePicture.jpg")
            
            userPhotoLocation.downloadURL { url, error in
                print("Client: getClientPicture:  downloadURL callback . . .")
                if let error = error {
                    // Handle any errors
                    finished(false, nil)
                } else {
                    
                    let downloadString = "\(url!)"
                    self.ryanSimpleDownloadGetImage(withURLstring: downloadString, finished: { (success, image) in
                        if success {
                            print("getClientPicture: successful downlaod!!!")
                        } else {
                            print("getClientPicture: UNsuccessful downlaod!!!")
                        }
                        finished(success, image)
                        
                    })
                    
                }}
            
            //         })
        } else {
            print("Exit 1")
            finished(false, nil)
        }
    }
}
