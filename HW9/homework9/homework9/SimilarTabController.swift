//
//  SimilarTabController.swift
//  homework9
//
//  Created by MyMac on 4/21/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class SimilarTabController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var sortingView: UIStackView!
    @IBOutlet weak var sortBySegmentedControl: UISegmentedControl!
    @IBOutlet weak var orderBySegmentedControl: UISegmentedControl!
    @IBOutlet weak var similarCollectionView: UICollectionView!
    @IBOutlet weak var errorPrompt: UILabel!
    
    let borderColor = UIColor(red: CGFloat(203.0/255), green: CGFloat(203.0/255), blue: CGFloat(203.0/255), alpha: 1)
    let backendUrlBase = "http://homework9-0c39c2008a3f3bba2.us-east-2.elasticbeanstalk.com/"
    var itemId:String = ""
    var similarItems:JSON = ""
    var sortedItems:[JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        orderBySegmentedControl.isUserInteractionEnabled = false
        SwiftSpinner.show("Fetching Similar Items...")
        let url = "\(backendUrlBase)similar_item?itemId=\(itemId)"
        Alamofire.request(url).responseJSON { response in
            let json = JSON(response.result.value!)
            let isSuccess:Bool = json[0].bool!

            if isSuccess{
                self.similarItems = json[1]
//                print(self.similarItems)
                self.resortItems()
                self.similarCollectionView.reloadData()
                SwiftSpinner.hide()
            } else {
                self.sortingView.isHidden = true
                self.similarCollectionView.isHidden = true
                self.errorPrompt.isHidden = false
                SwiftSpinner.hide()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return similarItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "similarCell", for: indexPath) as! SimilarCollectionCell
        let cellData = sortedItems[indexPath.item]
        
        cell.similarTitle.text = cellData["title"].stringValue
        cell.similarShipFee.text = cellData["shipStr"].stringValue
        cell.similarLeftDay.text = cellData["timeStr"].stringValue
        cell.similarPrice.text = cellData["valueStr"].stringValue
        cell.itemURL = cellData["viewItemURL"].stringValue
        cell.layer.borderColor = borderColor.cgColor
        let url = cellData["imageURL"].stringValue
        let imgurl = URL(string: url)

        guard let data = try? Data(contentsOf: imgurl!) else{
            return cell
        }
        cell.similarImageView.image = UIImage(data: data)
        return cell
    }
    
    func resortItems(){
        switch sortBySegmentedControl.selectedSegmentIndex {
        case 1:
            sortedItems = similarItems.arrayValue.sorted(by: {
                $0["title"].stringValue<$1["title"].stringValue
            })
            if orderBySegmentedControl.selectedSegmentIndex==1 {
                sortedItems = sortedItems.reversed()
            }
        case 2:
            sortedItems = similarItems.arrayValue.sorted(by: {
                $0["value"].floatValue<$1["value"].floatValue
            })
            if orderBySegmentedControl.selectedSegmentIndex==1 {
                sortedItems = sortedItems.reversed()
            }
        case 3:
            sortedItems = similarItems.arrayValue.sorted(by: {
                $0["time"].intValue<$1["time"].intValue
            })
            if orderBySegmentedControl.selectedSegmentIndex==1 {
                sortedItems = sortedItems.reversed()
            }
        case 4:
            sortedItems = similarItems.arrayValue.sorted(by: {
                $0["ship"].floatValue<$1["ship"].floatValue
            })
            if orderBySegmentedControl.selectedSegmentIndex==1 {
                sortedItems = sortedItems.reversed()
            }
        default:
            sortedItems = similarItems.arrayValue
        }
        print(sortedItems)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SimilarCollectionCell
        let link:String = cell.itemURL
        let url = URL(string: link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func sortBy(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            orderBySegmentedControl.selectedSegmentIndex=0
            orderBySegmentedControl.isUserInteractionEnabled = false
        }else{
            orderBySegmentedControl.isUserInteractionEnabled = true
        }
        resortItems()
        similarCollectionView.reloadData()
    }
    
    @IBAction func orderBy(_ sender: UISegmentedControl) {
        resortItems()
        similarCollectionView.reloadData()
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
