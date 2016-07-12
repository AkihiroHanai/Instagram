//
//  HomeViewController.swift
//  Instagram
//
//  Created by 花井章宏 on 2016/07/10.
//  Copyright © 2016年 akihiro.hanai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    var postArray: [PostData] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // xibのインスタンスを作成
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        let commentNib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        
        // tableviewにxibのインスタンスを登録
        tableView.registerNib(nib, forCellReuseIdentifier: "Cell")
        tableView.registerNib(commentNib, forCellReuseIdentifier: "CommentCell")
        
        tableView.separatorInset = UIEdgeInsets()
        tableView.layoutMargins = UIEdgeInsets()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        // 要素が追加されたらpostArrayに追加してTableViewを再表示する
        FIRDatabase.database().reference().child(CommonConst.PostPATH).observeEventType(.ChildAdded, withBlock: { snapshot in
            
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                self.postArray.insert(postData, atIndex: 0)
                
                // TableViewを再表示する
                self.tableView.reloadData()
            }
        })
        
        
        // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
        FIRDatabase.database().reference().child(CommonConst.PostPATH).observeEventType(.ChildChanged, withBlock: { snapshot in
            
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                
                // PostDataクラスを生成して受け取ったデータを設定する
                let postData = PostData(snapshot: snapshot, myId: uid)
                
                // 保持している配列からidが同じものを探す
                var index: Int = 0
                for post in self.postArray {
                    if post.id == postData.id {
                        index = self.postArray.indexOf(post)!
                        break
                    }
                }

                // 差し替えるため一度削除する
                self.postArray.removeAtIndex(index)
                
                // 削除したところに更新済みのでデータを追加する
                self.postArray.insert(postData, atIndex: index)
                self.tableView.reloadData()
                
            }
        })
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 投稿記事の数だけセクションを作る。
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        // print("投稿記事の数\(postArray.count)")
        return postArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // sectionの値が添え字となるような配列を作って、コメント数を拾いたい   return 配列[section]
        
        // 投稿記事数とコメント数を全て拾う
        var number = 0

        number += 1    // 記事を1と数える
        number += postArray[section].commentData.count  //コメント数を足す

        return number
        
    }
    
    // ボーダー
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsets()
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 { // 最初のrowの時
            
            //一番目のrowは記事のため、PostTableViewCell.xibを読み込む
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
            
            cell.postData = postArray[indexPath.section]
            
            // セル内のボタンのアクションをソースコードで設定する
            cell.likeButton.addTarget(self, action:#selector(HomeViewController.handleButton(_:event:)), forControlEvents:  UIControlEvents.TouchUpInside)
            
            cell.commentButton.addTarget(self, action:#selector(HomeViewController.commentButtonPressed(_:event:)), forControlEvents:  UIControlEvents.TouchUpInside)
            
            // UILabelの行数が変わっている可能性があるので再描画させる
            cell.layoutIfNeeded()
            
            
            return cell

        } else {
            
            // 一番目以外はコメントのため、CommentTableviewCell.xibを読み込む
            
            let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentTableViewCell
            
            commentCell.postData = postArray[indexPath.section] // 該当記事のデータを渡す
            commentCell.indexNumber = indexPath.row - 1 // コメントの番号を渡す（rowは記事も含めているので-1をする）
            
            return commentCell
            
        }

    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルをタップされたら何もせずに選択状態を解除する
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    func handleButton(sender: UIButton, event:UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.section]
        
        // Firebaseに保存するデータの準備
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.indexOf(likeId)!
                        break
                    }
                }
                postData.likes.removeAtIndex(index)
            } else {
                postData.likes.append(uid)
            }
            
            let imageString = postData.imageString
            let name = postData.name
            let caption = postData.caption
            let time = (postData.date?.timeIntervalSinceReferenceDate)! as NSTimeInterval
            let likes = postData.likes
            let commentData = postData.commentData
            
            // 辞書を作成してFirebaseに保存する
            let post = ["caption": caption!, "image": imageString!,"commentData": commentData, "name": name!, "time" : time, "likes": likes]
            let postRef = FIRDatabase.database().reference().child(CommonConst.PostPATH)
            postRef.child(postData.id!).setValue(post)
        }
    }
    
    // コメントボタンが押された時の挙動
    func commentButtonPressed(sender: UIButton, event: UIEvent){
        
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches()?.first
        let point = touch!.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.section]
        
        // コメント投稿画面を開く
        let commentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Comment") as! CommentViewController
        
        commentViewController.postData = postData
        
        self.presentViewController(commentViewController, animated: true, completion: nil)
        
        
    }
    


}
