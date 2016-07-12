//
//  CommentViewController.swift
//  Instagram
//
//  Created by 花井章宏 on 2016/07/10.
//  Copyright © 2016年 akihiro.hanai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD

class CommentViewController: UIViewController, UITextFieldDelegate {
    
    var postData: PostData!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var contentWrap: UIStackView!
    @IBOutlet weak var constraintVertically: NSLayoutConstraint!
    
    // action
    @IBAction func commentPostButton(sender: AnyObject) {
        if let text = textField.text{
            
            if text.isEmpty{
                SVProgressHUD.showErrorWithStatus("コメントを入力してください。")
                return
            } else {
                
                let postRef = FIRDatabase.database().reference().child(CommonConst.PostPATH)
                let comment = text
                let ud = NSUserDefaults.standardUserDefaults()
                let commentName = ud.objectForKey(CommonConst.DisplayNameKey) as! String
                
                let imageString = postData.imageString
                let name = postData.name
                let caption = postData.caption
                let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
                let likes = postData.likes
                
                let commentData = ["name" : "\(commentName)", "comment" : "\(comment)"]
                
                postData.commentData.append(commentData)
                
                // 辞書を作成してFirebaseに保存する
                let post = ["caption": caption!, "image": imageString!,"commentData": postData.commentData, "name": name!, "time" : time, "likes": likes]
                
                postRef.child(postData.id!).setValue(post)
                
                
                // HUDで投稿完了を表示する
                SVProgressHUD.showSuccessWithStatus("投稿しました")
                
                // 全てのモーダルを閉じる
                UIApplication.sharedApplication().keyWindow?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                
                
            }
        }

    }
    
    @IBAction func commentCancelButton(sender: AnyObject) {
        
        // キーボードが遅れて隠れるのを防ぐ
        textField.resignFirstResponder()
        // 画面を閉じる
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // textFiel の情報を受け取るための delegate を設定
        textField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillhide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // textFieldからカーソルが離れた時にキーボードを隠す
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillhide(notification: NSNotification){
        constraintVertically.constant = 0
    }
    
    func keyboardWillShow(notification: NSNotification){
        
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
        
        // 画面のサイズを取得
        let myBoundSize: CGSize = UIScreen.mainScreen().bounds.size
        
        //　ViewControllerを基準に要素の下辺までの距離を取得
        let txtLimit = contentWrap.frame.origin.y + contentWrap.frame.height + 35.0
        // ViewControllerの高さからキーボードの高さを引いた差分を取得
        let kbdLimit = myBoundSize.height - keyboardSize.height
        
        //要素の移動距離設定
        if txtLimit >= kbdLimit {
            constraintVertically.constant =   kbdLimit - txtLimit
        }
        
    }
    


}



