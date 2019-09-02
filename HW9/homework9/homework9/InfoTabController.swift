//
//  InfoTabController.swift
//  homework9
//
//  Created by MyMac on 4/18/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftyJSON
import Alamofire

class InfoTabController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    
    

    @IBOutlet weak var imagePages: UIScrollView!
    @IBOutlet weak var imagePageControl: UIPageControl!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailPrice: UILabel!
    @IBOutlet weak var errorPrompt: UILabel!
    @IBOutlet weak var descriptionTableView: UITableView!
    
    let backendUrlBase = "http://homework9-0c39c2008a3f3bba2.us-east-2.elasticbeanstalk.com/"
    var itemId:String = ""
    var productDetail:JSON = ""
    var imageSize:CGSize = CGSize(width: 0,height: 0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Product Details...")
        let url = "\(backendUrlBase)item_info?itemId=\(itemId)"
        Alamofire.request(url).responseJSON { response in
            let json = JSON(response.result.value!)
            let isSuccess:Bool = json[0].bool!
            if isSuccess{
                self.productDetail = json[1]
//                print(self.productDetail)
                let imageUrls:[String] = self.productDetail["picture"].arrayObject as! [String]
                let imageNumber = imageUrls.count
                self.imagePageControl.numberOfPages = imageNumber
                self.imageSize = self.imagePages.frame.size
                for index in 0..<imageNumber{
                    let originPoint = CGPoint(x: self.imageSize.width * CGFloat(index), y: 0)
                    let imageview = UIImageView(frame: CGRect(origin: originPoint, size: self.imageSize))
                    let imageUrl = imageUrls[index]
                    let url = URL(string: imageUrl)

                    guard let data = try? Data(contentsOf: url!) else{
                        self.imagePages.addSubview(imageview)
                        continue
                    }
                    imageview.image = UIImage(data: data)
                    self.imagePages.addSubview(imageview)
                }
                self.imagePages.contentSize = CGSize(width: self.imageSize.width * CGFloat(imageNumber),height:self.imageSize.height)
                self.detailTitle.text = self.productDetail["title"].string
                self.detailPrice.text = self.productDetail["price"].string
//                let testJSON:JSON = []
//                print(self.productDetail)
//                self.productDetail["sp"] = testJSON
//                print(self.productDetail)
                if self.productDetail["sp"].count != 0{
                    self.descriptionTableView.reloadData()
                }else{
                    self.errorPrompt.isHidden = false
                }
                
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == imagePages{
            let pageNumber = imagePages.contentOffset.x / imageSize.width
            self.imagePageControl.currentPage = Int(pageNumber)
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productDetail["sp"].arrayValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoTabCell", for: indexPath) as! InfoTabDescriptionCell
        let cellData = self.productDetail["sp"][indexPath.row]
        cell.tableTitle.text = cellData["name"].stringValue
        cell.tableValue.text = cellData["value"].stringValue
        return cell
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
