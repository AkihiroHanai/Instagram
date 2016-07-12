//
//  CommentTableViewCell.swift
//  Instagram
//
//  Created by 花井章宏 on 2016/07/10.
//  Copyright © 2016年 akihiro.hanai. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    var postData: PostData!
    var indexNumber : Int!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    // 表示されるときに呼ばれるメソッドをオーバーライドしてデータをUIに反映する
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userNameLabel.text = postData.commentData[indexNumber]["name"]
        commentLabel.text = postData.commentData[indexNumber]["comment"]
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
