//
//  SearchResultController.swift
//  homework9
//
//  Created by MyMac on 4/15/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit
import SwiftSpinner
import Alamofire
import SwiftyJSON
import Toast_Swift

class SearchResultController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchResultTableView: UITableView!
    let backendUrlBase = "http://homework9-0c39c2008a3f3bba2.us-east-2.elasticbeanstalk.com/"
    let userDefaultId = "wish"
    let imageEmpty = UIImage(named: "wishListEmpty")
    let imageFilled = UIImage(named:"wishListFilled")
    var formData : Parameters  = [:]
    var searchResult:JSON = ""

    override func viewDidLoad() {
        
        super.viewDidLoad()
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute:{
//            SwiftSpinner.show("Searching...")
//        })
        SwiftSpinner.show("Searching...")
        let url = "\(backendUrlBase)search_list"
        Alamofire.request(url, method: .get, parameters: formData).responseJSON { response in
            let json = JSON(response.result.value!)
            let isSuccess:Bool = json[0].bool!
            if isSuccess{
                self.searchResult = json[1]
//                print(self.searchResult)
//                print(json[2])
                self.searchResultTableView.reloadData()
                SwiftSpinner.hide()
            } else {
                
                let errorResult = UIAlertController(title: "No Results!", message: json[1].string, preferredStyle: .alert)
                let returnButton = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
//                    self.dismiss(animated: true, completion: nil)
                })
                errorResult.addAction(returnButton)
                self.present(errorResult, animated: true, completion: {
                    SwiftSpinner.hide()
                })
            }
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! SearchResultCell
        let cellInformation = self.searchResult[indexPath.row]
        
        cell.productTitle.text = cellInformation["title"].stringValue
        cell.productPrice.text = cellInformation["value"].stringValue
        cell.productShipping.text = cellInformation["shippingCost"].stringValue
        cell.productZip.text = cellInformation["postalCode"].stringValue
        cell.productCondition.text = cellInformation["condition_ios"].stringValue
        let itemId = cellInformation["itemId"].stringValue
        if hasId(itemId: itemId){
            cell.productWishButton.setImage(imageFilled, for: .normal)
        }else{
            cell.productWishButton.setImage(imageEmpty, for: .normal)
        }
        cell.productWishButton.tag = indexPath.row
        let url = URL(string: cellInformation["galleryURL"].stringValue)

        guard let data = try? Data(contentsOf: url!) else{
            return cell
        }
        cell.productImage.image = UIImage(data: data)
        return cell
    }
    
    func hasId(itemId:String)->Bool{
        let wishListJSON = getDefaultJSON()
        var hasId = false
        for (_,wishItem) in wishListJSON{
            
            if wishItem["itemId"].stringValue == itemId{
                hasId = true
                break
            }
        }
        return hasId
    }
    
    @IBAction func changeWish(_ sender: UIButton) {
        //set button
        
        let wishListJSON = getDefaultJSON()
        let item = searchResult[sender.tag]
        let itemTitle = item["title"].stringValue
        let itemId = item["itemId"].stringValue
        var jsonArray = wishListJSON.arrayValue
        if sender.currentImage == imageEmpty{
            self.view.window?.makeToast("\(itemTitle) was added to the wishList")
            jsonArray.append(item)
            sender.setImage(imageFilled, for: .normal)
        } else{
            self.view.window?.makeToast("\(itemTitle) was removed from wishList")
            for (index,wishItem) in wishListJSON{
                if wishItem["itemId"].stringValue == itemId{
                    jsonArray.remove(at: Int(index)!)
                }
            }
            sender.setImage(imageEmpty, for: .normal)
        }
        let jsonString:String =  JSON(jsonArray).rawString()!
        UserDefaults.standard.set(jsonString, forKey: userDefaultId)
    }
    
    func getDefaultJSON() -> JSON {
        let wishListStr:String = UserDefaults.standard.string(forKey: userDefaultId) ?? "[]"
        let wishListData = wishListStr.data(using: .utf8)!
        guard let wishListJSON:JSON = try? JSON.init(data: wishListData) else{
            print("error return []")
            return []
        }
        return wishListJSON
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let cellInformation = self.searchResult[self.searchResultTableView.indexPathForSelectedRow!.row]

        let dest = segue.destination as! ProductDetailController
        let infoController = dest.viewControllers![0] as! InfoTabController
        let shippingController = dest.viewControllers![1] as! ShippingTabController
        let googleController = dest.viewControllers![2] as! GoogleTabController
        let similarController = dest.viewControllers![3] as! SimilarTabController
        dest.searchResultController = self
        dest.searchResult = cellInformation
        let itemID:String = cellInformation["itemId"].stringValue
        dest.itemId = itemID
        infoController.itemId = itemID
        shippingController.itemId = itemID
        googleController.itemTitle = cellInformation["title"].stringValue
        similarController.itemId = itemID
    }
 

}
