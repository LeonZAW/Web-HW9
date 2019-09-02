//
//  GoogleTabController.swift
//  homework9
//
//  Created by MyMac on 4/21/19.
//  Copyright © 2019 Snowflake. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire

class GoogleTabController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var googleScrollView: UIScrollView!
    @IBOutlet weak var errorPrompt: UILabel!
    
    let backendUrlBase = "http://homework9-0c39c2008a3f3bba2.us-east-2.elasticbeanstalk.com/"
    var itemTitle:String = ""
    var googlePhotos:JSON = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Google Images...")
        let url = "\(backendUrlBase)item_picture"
        let param : Parameters = ["key":itemTitle]
        Alamofire.request(url, method: .get, parameters: param).responseJSON { response in
            let json = JSON(response.result.value!)
            let isSuccess:Bool = json[0].bool!
            if isSuccess{
                self.googlePhotos = json[1]
//                print(self.googlePhotos)
                let imageUrls:[String] = self.googlePhotos.arrayObject as! [String]
                let imageWidth = self.googleScrollView.frame.size.width
                var startY = CGFloat(0)
                var successNumber = 0
                for imageUrl in imageUrls{
                    let imgurl = URL(string: imageUrl)
                    guard let data = try? Data(contentsOf: imgurl!) else{
                        print(imageUrl)
                        continue
                    }
                    let image = UIImage(data: data)
                    let imageSize:CGSize = image!.size
                    let imageView = UIImageView(image: image)
                    let imageHeight = imageSize.height/imageSize.width*imageWidth
                    
                    imageView.frame = CGRect(origin: CGPoint(x: 0, y: startY), size: CGSize(width: imageWidth, height: imageHeight))
                    startY = startY + imageHeight

                    self.googleScrollView.addSubview(imageView)
                    successNumber = successNumber + 1
                }

                if successNumber != 0{
                    self.googleScrollView.contentSize = CGSize(width: imageWidth,height:startY)
                }else{
                    self.googleScrollView.isHidden = true
                    self.errorPrompt.isHidden = false
                }
                SwiftSpinner.hide()
            } else {
                self.googleScrollView.isHidden = true
                self.errorPrompt.isHidden = false
                SwiftSpinner.hide()
            }
        }
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
