//
//  ProductDetailController.swift
//  homework9
//
//  Created by MyMac on 4/18/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import Toast_Swift

class ProductDetailController: UITabBarController {

    let backendUrlBase = "http://homework9-0c39c2008a3f3bba2.us-east-2.elasticbeanstalk.com/"
    let imageEmpty = UIImage(named: "wishListEmpty")
    let imageFilled = UIImage(named:"wishListFilled")
    let userDefaultId = "wish"
    var itemId : String = ""
    var productDetail:JSON = ""
    var searchResult:JSON = ""
    
    var searchResultController:SearchResultController?
    var wishResultController:SearchBoxController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageFacebook  = UIImage(named: "facebook")!
        var wishImage = imageEmpty
        if hasId(itemId: itemId){
            wishImage = imageFilled
        }
        let buttonWish = UIBarButtonItem(image: wishImage, style: .plain, target: self, action: Selector(("addWish")))
        
        let buttonFacebook = UIBarButtonItem(image: imageFacebook, style: .plain, target: self, action: Selector(("sendFacebook")))
        navigationItem.rightBarButtonItems = [buttonWish, buttonFacebook]
        

        let url = "\(backendUrlBase)item_facebook?itemId=\(itemId)"
        Alamofire.request(url).responseJSON { response in
            let json = JSON(response.result.value!)
            let isSuccess:Bool = json[0].bool!
            if isSuccess{
                self.productDetail = json[1]
            }
        }
    }
    
    @IBAction func addWish(){
        let wishListJSON = getDefaultJSON()
        let item = searchResult
        let itemTitle = item["title"].stringValue
        let itemId = item["itemId"].stringValue
        var jsonArray = wishListJSON.arrayValue
        let buttonImage = navigationItem.rightBarButtonItems![0].image
        
        if buttonImage == imageEmpty{
            self.view.window?.makeToast("\(itemTitle) was added to the wishList")
            jsonArray.append(item)
            navigationItem.rightBarButtonItems![0].image = imageFilled
        } else{
            self.view.window?.makeToast("\(itemTitle) was removed from wishList")
            for (index,wishItem) in wishListJSON{
                if wishItem["itemId"].stringValue == itemId{
                    jsonArray.remove(at: Int(index)!)
                }
            }
            navigationItem.rightBarButtonItems![0].image = imageEmpty
        }
        let jsonString:String =  JSON(jsonArray).rawString()!
        UserDefaults.standard.set(jsonString, forKey: userDefaultId)
        searchResultController?.searchResultTableView.reloadRows(at: [IndexPath(row: item["index"].intValue-1, section: 0)], with: .none)
        searchResultController?.searchResultTableView.selectRow(at: IndexPath(row: item["index"].intValue-1, section: 0), animated: false, scrollPosition: .none)
        wishResultController?.initWishList()
    }
    
    @IBAction func sendFacebook(){
        let link:String = productDetail["facebookShareUrl"].stringValue
        let url = URL(string: link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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



    func getDefaultJSON() -> JSON {
        let wishListStr:String = UserDefaults.standard.string(forKey: userDefaultId) ?? "[]"
        let wishListData = wishListStr.data(using: .utf8)!
        guard let wishListJSON:JSON = try? JSON.init(data: wishListData) else{
            print("error return []")
            return []
        }
        return wishListJSON
    }

    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination)
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
 

}
