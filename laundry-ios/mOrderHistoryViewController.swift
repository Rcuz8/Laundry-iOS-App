//
//  mOrderHistoryViewController.swift
//  laundry-ios
//
//  Created by Ryan Cocuzzo on 8/3/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class mOrderHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, OrderHistoryDelegate , ClientOrderChecking {

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavController()
        self.menuButton.tintColor = UIColor.lavoDarkBlue
        fillTable()
        
        
    }
    
    func fillTable() {
        self.tableView.isHidden = true
        if let user = FIRAuth.auth()?.currentUser { let client = Client(id: user.uid);
            client.dbFill {
                print(client.printableJSON)
                print(client.orders)
                if let co = client.orders { if co.count > 0 {
                    self.orders = client.orders!
                    self.tableView.isHidden = false
                } else {
                    self.tableView.isHidden = true
                    let noOrdersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.partOfScreenWidth_d(percentage: 100), height: self.partOfScreenHeight_d(percentage: 20)))
                    noOrdersLabel.frame.centerVertically()
                    noOrdersLabel.text = "No Orders have been made!"
                    noOrdersLabel.textColor = UIColor.lavoDarkBlue
                    noOrdersLabel.textAlignment = .center
                    noOrdersLabel.font = UIFont().bangla(size: 25)
                    self.view.addSubview(noOrdersLabel)
                    }
                } else {
                    self.tableView.isHidden = true
                    let noOrdersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.partOfScreenWidth_d(percentage: 100), height: self.partOfScreenHeight_d(percentage: 20)))
                    noOrdersLabel.frame.centerVertically()
                    noOrdersLabel.text = "No Orders have been made!"
                    noOrdersLabel.textColor = UIColor.lavoDarkBlue
                    noOrdersLabel.textAlignment = .center
                    noOrdersLabel.font = UIFont().bangla(size: 25)
                    self.view.addSubview(noOrdersLabel)
                }
                
            }
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func update(with order: Order) {
        print("updated order!!")
        self.orders.append(order)
        self.tableView.reloadData()
        self.tableView.isHidden = false
    }
    
    
    
    func infoRequested(cell: OrderHistoryCell) {
        if let row = cell.indexPath?.row {
            let order = orders[row]
            SCLAlertView().showInfo("Your Order", subTitle: "\(order.orderDescription())")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderHistoryCell") as! OrderHistoryCell
        let order = orders[indexPath.row]
        if let review = order.review {
            cell.shade(stars: (review.overallRating))
            cell.statusLabel.text = order.status?.simpleDescription()
        }
        
        return cell
    }
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var orders = [Order]()
    
    
    
    @IBAction func toggle(_ sender: Any) {
        if self.revealViewController() != nil {
            self.revealViewController().rearViewRevealWidth = 200
            self.revealViewController().revealToggle(animated: true)
        }
    }

}

extension UITableViewCell {
    
    var indexPath: IndexPath? {
        return (superview as? UITableView)?.indexPath(for: self)
    }
}
