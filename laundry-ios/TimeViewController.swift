//
//  TimeViewController.swift
//  laundry-ios
//
//  Created by Anagh Telluri on 5/26/17.
//  Copyright © 2017 Lavo Logistics Inc. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var button = UIButton()
    var dropDownList = [String]()
    var tableViews = UITableView()
    var flag = 1
    
    override func viewDidLoad() {
        
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.lightGray
    
    
    button.layer.borderWidth = 1;
    
    
    button.frame = CGRect(x: 20,y: (self.view.viewWithTag(2)?.frame.origin.y)!+(self.view.viewWithTag(2)?.frame.height)!+1, width:  self.view.frame.width-40, height: 40)
    
    
    button.layer.cornerRadius = 10
    
    button.tag = 1
    
    
    button.addTarget(self, action: #selector(PressDrop), for: .touchUpInside)
    
    
    
    view.addSubview(button)
    
    tableViews.frame = CGRect(x: self.button.frame.origin.x, y:(self.view.viewWithTag(1)?.frame.origin.y)!+(self.view.viewWithTag(1)?.frame.height)!+1 , width: self.button.frame.width , height: 200)
    tableViews.delegate = self
    
    tableViews.dataSource = self
    
    tableViews.layer.cornerRadius = 10
    
    
    tableViews.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    //hide tableview
    
    tableViews.isHidden = true
    
    view.addSubview(tableViews)
    
    
    
    // Do any additional setup after loading the view.
    }
    
    
    func PressDrop(){
    
    if flag == 0
    {
    
    UIView.animate(withDuration: 0.5)
    {
    self.tableViews.frame = CGRect(x: self.self.button.frame.origin.x, y:self.self.button.frame.origin.y+self.self.button.frame.height  , width: self.self.button.frame.width , height: 0)
    self.tableViews.isHidden = true
    
    self.tableViews.tableHeaderView = nil
    
    
    
    
    
    
    self.flag = 1
    }
    }
    else
    {
    UIView.animate(withDuration: 0.5){
    
    self.tableViews.frame = CGRect(x: self.button.frame.origin.x, y:(self.view.viewWithTag(1)?.frame.origin.y)!+(self.view.viewWithTag(1)?.frame.height)!+1 , width: self.button.frame.width , height: self.view.frame.height-(self.tableViews.frame.origin.y)-17)
    self.tableViews.isHidden = false
    
    self.flag = 0
    }
    }
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    return dropDownList.count
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    return cell
    }
    
    override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
