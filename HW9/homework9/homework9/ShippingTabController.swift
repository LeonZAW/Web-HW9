//
//  ShippingTabController.swift
//  homework9
//
//  Created by MyMac on 4/20/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class ShippingTabController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var shipTableView: UITableView!
    
    
    

    let sectionRowHeight = CGFloat(25.0)
    let borderHeight = CGFloat(3.0)
    let sectionTitles = ["Seller","Shipping Info","Return Policy"]
    let borderColor = UIColor(red: CGFloat(214.0/255), green: CGFloat(214.0/255), blue: CGFloat(214.0/255), alpha: 1)
    let linkColor = UIColor(red: 9.0/255, green: 79.0/255, blue: 209.0/255, alpha: 1)
    let starBorderImage = UIImage(named: "starBorder")
    let starImage = UIImage(named: "star")
    let colorList:[UIColor] = [
        UIColor.yellow,
        UIColor.blue,
        UIColor(red: CGFloat(0.0/255), green: CGFloat(253.0/255), blue: CGFloat(255.0/255), alpha: 1),
        UIColor.purple,
        UIColor.red,
        UIColor.green,
        UIColor(red: CGFloat(214.0/255), green: CGFloat(214.0/255), blue: CGFloat(214.0/255), alpha: 1)
    ]
    let backendUrlBase = "http://homework9-0c39c2008a3f3bba2.us-east-2.elasticbeanstalk.com/"
    var itemId:String = ""
    var shippingData:JSON = ""
    var storeLink:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        shipTableView.separatorColor = UIColor.clear
        shipTableView.allowsSelection = false
        
        SwiftSpinner.show("Fetching Shipping Data...")
        let url = "\(backendUrlBase)item_shipping?itemId=\(itemId)"
        Alamofire.request(url).responseJSON { response in
            let json = JSON(response.result.value!)
            let isSuccess:Bool = json[0].bool!
            if isSuccess{
                self.shippingData = json[1]
//                print(self.shippingData)
                self.shipTableView.reloadData()
                SwiftSpinner.hide()
            } else {
                let errorResult = UIAlertController(title: "No Results!", message: json[1].string, preferredStyle: .alert)
                let returnButton = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                    // self.dismiss(animated: true, completion: nil)
                })
                errorResult.addAction(returnButton)
                self.present(errorResult, animated: true, completion: {
                    SwiftSpinner.hide()
                })
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shippingData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shippingData[section].count
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: sectionRowHeight+borderHeight*2))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: borderHeight, width: sectionRowHeight, height: sectionRowHeight))
        imageView.image = UIImage(named: sectionTitles[section])
        
        let title = UILabel(frame: CGRect(x: sectionRowHeight+5, y: borderHeight, width: tableView.frame.width-sectionRowHeight-5, height: sectionRowHeight))
        title.text = sectionTitles[section]
        title.font = UIFont.boldSystemFont(ofSize: 18.0)

        sectionView.addSubview(imageView)
        sectionView.addSubview(title)
        sectionView.backgroundColor = UIColor.white
        
        let borderTop = CALayer()
        let borderBottom = CALayer()
        borderTop.borderColor = borderColor.cgColor
        borderBottom.borderColor = borderColor.cgColor
        borderTop.borderWidth = 1
        borderBottom.borderWidth = 1
        borderTop.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1)
        borderBottom.frame = CGRect(x: 0, y: sectionRowHeight+borderHeight*2-1, width: tableView.frame.width, height: 1)
        
        sectionView.layer.addSublayer(borderTop)
        sectionView.layer.addSublayer(borderBottom)
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shippingTableCell", for: indexPath) as! ShippingTableCell
        let titleText = shippingData[indexPath.section][indexPath.row]["title"].stringValue
        cell.labelTitle.text = titleText
        
        if titleText=="Store Name" {
            let valueText = shippingData[indexPath.section][indexPath.row]["value"]["name"].stringValue
            storeLink = shippingData[indexPath.section][indexPath.row]["value"]["url"].stringValue
            cell.labelValue.textColor = linkColor
            cell.labelValue.attributedText = NSAttributedString(string: valueText, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
            cell.labelValue.isUserInteractionEnabled = true
            let showStore = UITapGestureRecognizer(target: self, action: Selector(("showStore")))
            cell.labelValue.addGestureRecognizer(showStore)
        }else if titleText=="Feedback Star" {
            cell.labelValue.isHidden = true
            cell.labelImage.isHidden = false
            cell.labelImage.image = shippingData[indexPath.section][indexPath.row]["value"]["small"].boolValue ? starBorderImage : starImage
            let colorIndex = shippingData[indexPath.section][indexPath.row]["value"]["colorIndex"].intValue
            cell.labelImage.tintColor = colorList[colorIndex]
        }else{
            cell.labelValue.text = shippingData[indexPath.section][indexPath.row]["value"].stringValue
        }
        return cell
    }
    
    @IBAction func showStore() {
        let url = URL(string: storeLink)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
