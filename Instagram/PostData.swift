//
//  PostData.swift
//  Instagram
//
//  Created by 花井章宏 on 2016/07/10.
//  Copyright © 2016年 akihiro.hanai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostData: NSObject {
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: NSDate?
    var likes: [String] = []
    var isLiked: Bool = false
    var commentData: Array<[String:String]> = [] // 提出用追加
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        id = snapshot.key
        
        
        // valueDictionary["name"]などで値を取り出せるように
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        imageString = valueDictionary["image"] as? String
        image = UIImage(data: NSData(base64EncodedString: imageString!, options: .IgnoreUnknownCharacters)!)
        
        name = valueDictionary["name"] as? String
        
        caption = valueDictionary["caption"] as? String
        
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        
        for likeId in likes {
            if likeId == myId {
                isLiked = true
                break
            }
        }
        
        self.date = NSDate(timeIntervalSinceReferenceDate: valueDictionary["time"] as! NSTimeInterval)
        
        if let comment = valueDictionary["commentData"] as? Array<[String:String]> {  // 提出用追加
            self.commentData = comment
        }
    }
}