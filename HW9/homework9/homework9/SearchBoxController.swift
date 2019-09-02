//
//  SearchBoxController.swift
//  homework9
//
//  Created by MyMac on 4/13/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit
import McPicker
import SwiftSpinner
import Alamofire
import SwiftyJSON
import Toast_Swift

class SearchBoxController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var boxStackView: UIStackView!
    @IBOutlet weak var boxSearchButton: UIButton!
    @IBOutlet weak var boxClearButton: UIButton!
    
    
    @IBOutlet weak var textFieldKeyword: UITextField!
    @IBOutlet weak var mcPickerField: McTextField!
    @IBOutlet weak var buttonConditionNew: UIButton!
    @IBOutlet weak var buttonConditionUsed: UIButton!
    @IBOutlet weak var buttonConditionUnsp: UIButton!
    @IBOutlet weak var buttonShippingPick: UIButton!
    @IBOutlet weak var buttonShippingFree: UIButton!
    @IBOutlet weak var textFieldMile: UITextField!
    @IBOutlet weak var switchLocation: UISwitch!
    @IBOutlet weak var textFieldZip: UITextField!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    @IBOutlet weak var errorPrompt: UILabel!
    
    @IBOutlet weak var wishTotalStackView: UIStackView!
    @IBOutlet weak var wishTableView: UITableView!
    @IBOutlet weak var wishTotalNum: UILabel!
    @IBOutlet weak var wishTotalPrice: UILabel!
    
    var wishResult:JSON = []
    
    
    let pickerData:[[String]] = [["All","Art","Baby","Books","Clothing,Shoes & Accesories","Computers/Tablets & Networking","Health & Beauty","Music","VideoGames & Consoles"]]
    let pickerDataId:[Int] = [0,550,2984,267,11450,58058,26395,11233,1249]
    let imagechecked = UIImage(named: "checked")
    let imageunchecked = UIImage(named: "unchecked")
    let backendUrlBase = "http://homework9-0c39c2008a3f3bba2.us-east-2.elasticbeanstalk.com/"
    let userDefaultId = "wish"
    var zipcodes:[String] = []
    var localIp = ""
    var autoCompleteIndex:Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLocalIp()
        self.initPickerField()
        self.initLocation()
        self.autoCompleteTableView.layer.borderColor = UIColor.black.cgColor
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if wishTableView.indexPathForSelectedRow != nil{
//            wishTableView.deselectRow(at: wishTableView.indexPathForSelectedRow!, animated: true)
//        }
//    }
    
    
    func getLocalIp(){
        let url = "http://ip-api.com/json"
        Alamofire.request(url).responseJSON { response in
            let json = JSON(response.result.value!)
            self.localIp = json["zip"].string!
        }
    }
    
    func initPickerField(){
        let mcInputView = McPicker(data: pickerData)
        mcInputView.backgroundColor = .gray
        mcInputView.backgroundColorAlpha = 0.25
        mcPickerField.inputViewMcPicker = mcInputView
        mcPickerField?.text = pickerData[0][0]
        mcPickerField.doneHandler = { [weak mcPickerField] (selections) in
            mcPickerField?.text = selections[0]!

        }
    }
    
    func initLocation(){
        switchLocation.isOn = false
        textFieldZip.isHidden = true
        autoCompleteTableView.isHidden = true
    }
    
    func initWishList(){
        loadWishData()
        wishTableView.reloadData()
    }
    
    func loadWishData(){
        wishResult = getDefaultJSON()
        if wishResult.count == 0{
            errorPrompt.isHidden = false
            wishTotalStackView.isHidden = true
            wishTableView.isHidden = true
        }else{
            errorPrompt.isHidden = true
            wishTotalStackView.isHidden = false
            wishTableView.isHidden = false
        }
        var plural = "items"
        if wishResult.count == 1{
            plural = "item"
        }
        let totalNumStr:String = "WishList Total(\(wishResult.count) \(plural))"
        wishTotalNum.text = totalNumStr
        let totalPrice = countTotalPrice()
        wishTotalPrice.text = String(format: "$%.2f", totalPrice)
    }
    
    func countTotalPrice() -> Float{
        var total:Float = 0
        for item in wishResult.arrayValue{
            let priceStr:String = item["totalValue"].stringValue
            let priceFloat:Float = Float(priceStr)!
            total = total + priceFloat
        }
        return total
    }
    
    func deleteDefaultItem(itemId:String){
        var jsonArray = wishResult.arrayValue
        for (index,wishItem) in wishResult{
            if wishItem["itemId"].stringValue == itemId{
                jsonArray.remove(at: Int(index)!)
            }
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
    
    @IBAction func checkBoxOnclick(_ sender: UIButton) {
        let crtImage = sender.currentImage
        if crtImage==self.imageunchecked {
            sender.setImage(self.imagechecked,for: .normal)
        }else{
            sender.setImage(self.imageunchecked,for: .normal)
        }
        sender.alpha = 0.0
        UIView.transition(with: sender, duration: 0.5, options: .curveEaseInOut, animations: {
            sender.alpha = 1.0
        }, completion: nil)
        
    }
    
    @IBAction func locationChange(_ sender: UISwitch) {
        if sender.isOn {
            textFieldZip.isHidden = false
            textFieldZip.text = ""
        }else{
            textFieldZip.text = ""
            textFieldZip.isHidden = true
            autoCompleteTableView.isHidden = true
        }
    }
    
    @IBAction func autoCompleteSearch(_ sender: UITextField) {
        autoCompleteIndex += 1
        let currentCompleteIndex = autoCompleteIndex
        let textContent = sender.text!
        let url = "\(backendUrlBase)auto_complete?start=\(textContent)"
        Alamofire.request(url).responseJSON { response in
            if self.autoCompleteIndex == currentCompleteIndex{
                let json = JSON(response.result.value!)
                self.zipcodes = json.arrayObject as! [String]
                self.autoCompleteTableView.reloadData()
                let textLength = sender.text!.count
                if textLength>0 && textLength<6{
                    self.autoCompleteTableView.isHidden = false
                }else{
                    self.autoCompleteTableView.isHidden = true
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == autoCompleteTableView{
            return []
        }
        let actionDelete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let itemTitle = self.wishResult[indexPath.row]["title"].stringValue
            self.view.window?.makeToast("\(itemTitle) was removed from wishList")
            self.deleteDefaultItem(itemId: self.wishResult[indexPath.row]["itemId"].stringValue)
            self.loadWishData()
            self.wishTableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [actionDelete]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autoCompleteTableView{
            return zipcodes.count
        }else{
            return wishResult.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == autoCompleteTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "autoCell", for: indexPath)
            cell.textLabel?.text = zipcodes[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "wishCell", for: indexPath) as! SearchResultCell
            let cellInformation = self.wishResult[indexPath.row]

            cell.productTitle.text = cellInformation["title"].stringValue
            cell.productPrice.text = cellInformation["value"].stringValue
            cell.productShipping.text = cellInformation["shippingCost"].stringValue
            cell.productZip.text = cellInformation["postalCode"].stringValue
            cell.productCondition.text = cellInformation["condition_ios"].stringValue
            let url = URL(string: cellInformation["galleryURL"].stringValue)

            guard let data = try? Data(contentsOf: url!) else{
                return cell
            }
            cell.productImage.image = UIImage(data: data)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == autoCompleteTableView{
            self.autoCompleteTableView.setContentOffset(.zero, animated: false)
            self.autoCompleteTableView.isHidden = true
            self.textFieldZip.text = zipcodes[indexPath.row]
        }
    }
    
    @IBAction func clearBox(_ sender: UIButton) {
        textFieldKeyword.text = ""
        mcPickerField?.text = pickerData[0][0]
        buttonConditionNew.setImage(self.imageunchecked,for: .normal)
        buttonConditionUsed.setImage(self.imageunchecked,for: .normal)
        buttonConditionUnsp.setImage(self.imageunchecked,for: .normal)
        buttonShippingPick.setImage(self.imageunchecked,for: .normal)
        buttonShippingFree.setImage(self.imageunchecked,for: .normal)
        textFieldMile.text = ""
        textFieldZip.text = ""
        switchLocation.isOn = false
        textFieldZip.isHidden = true
        autoCompleteTableView.isHidden = true
    }
    
    @IBAction func changeList(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex==1){
            setBoxHidden(value: true)
            setWishHidden(value: false)
            initWishList()
        }else{
            setBoxHidden(value: false)
            setWishHidden(value: true)
        }
    }
    
    func setBoxHidden(value:Bool){
        boxStackView.isHidden = value
        boxSearchButton.isHidden = value
        boxClearButton.isHidden = value
        if switchLocation.isOn {
            textFieldZip.isHidden = false
        }else{
            textFieldZip.text = ""
            textFieldZip.isHidden = true
            autoCompleteTableView.isHidden = true
        }
    }
    
    func setWishHidden(value:Bool){
        wishTotalStackView.isHidden = value
        wishTableView.isHidden = value
        errorPrompt.isHidden = value
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="searchSegue"{
            let keyword:String = self.textFieldKeyword.text!
            let index:Int = self.pickerData[0].firstIndex(of:mcPickerField!.text!)!
            let category = self.pickerDataId[index]
            let checkboxNew:String = (self.buttonConditionNew.currentImage==self.imagechecked) ? "true" : "false"
            let checkboxUsed:String = (self.buttonConditionUsed.currentImage==self.imagechecked) ? "true" : "false"
            let checkboxUnsp:String = (self.buttonConditionUnsp.currentImage==self.imagechecked) ? "true" : "false"
            let checkboxLocal:String = (self.buttonShippingPick.currentImage==self.imagechecked) ? "true" : "false"
            let checkboxFree:String = (self.buttonShippingFree.currentImage==self.imagechecked) ? "true" : "false"
            let mile:String = self.textFieldMile.text=="" ? "10" : self.textFieldMile.text!
            let location:String = self.switchLocation.isOn ? "local" : "here"
            let zip:String = self.textFieldZip.text!
            // Get the new view controller using segue.destination.
            let dest = segue.destination as! SearchResultController
            dest.formData = [
                "keyword":keyword,
                "category":category,
                "checkbox_new":checkboxNew,
                "checkbox_used":checkboxUsed,
                "checkbox_unsp":checkboxUnsp,
                "checkbox_local":checkboxLocal,
                "checkbox_free":checkboxFree,
                "mile":mile,
                "location":location,
                "zip":zip,
                "local_ip":localIp
            ]
        }else{
            let cellInformation = self.wishResult[self.wishTableView.indexPathForSelectedRow!.row]
            
            let dest = segue.destination as! ProductDetailController
            let infoController = dest.viewControllers![0] as! InfoTabController
            let shippingController = dest.viewControllers![1] as! ShippingTabController
            let googleController = dest.viewControllers![2] as! GoogleTabController
            let similarController = dest.viewControllers![3] as! SimilarTabController
            dest.wishResultController = self
            dest.searchResult = cellInformation
            let itemID:String = cellInformation["itemId"].stringValue
            dest.itemId = itemID
            infoController.itemId = itemID
            shippingController.itemId = itemID
            googleController.itemTitle = cellInformation["title"].stringValue
            similarController.itemId = itemID
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier=="wishSegue"{
            return true
        }else{
            let keyword:String = self.textFieldKeyword.text!
            let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedKeyword==""{
                self.view.window?.makeToast("Keyword is Mandatory")
                return false
            }
            
            let mile:String = self.textFieldMile.text=="" ? "10" : self.textFieldMile.text!
            let testMile = mile.range(of: #"^[1-9]\d*$"#,options: .regularExpression) == nil
            if testMile{
                self.view.window?.makeToast("Mile must be a Positive Integer")
                return false
            }
            
            let location = self.switchLocation.isOn
            let zip:String = self.textFieldZip.text!
            let trimmedZip = zip.trimmingCharacters(in: .whitespacesAndNewlines)
            if location && trimmedZip==""{
                self.view.window?.makeToast("Zipcode is Mandatory")
                return false
            }
            if location && (zip.range(of: #"^\d{5}$"#,options: .regularExpression) == nil){
                self.view.window?.makeToast("Zipcode Must Contain 5 digits")
                return false
            }
            
            
            let testLocalIp = localIp.range(of: #"^\d{5}$"#,options: .regularExpression) == nil
            if testLocalIp{
                self.view.window?.makeToast("Retriving local address, please wait")
                return false
            }
            return true
        }
    }
    

}
