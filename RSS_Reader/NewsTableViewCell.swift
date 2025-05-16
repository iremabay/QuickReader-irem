//
//  NewsTableViewCell.swift
//  RSS_Reader
//
//  Created by Trakya9 on 10.05.2025.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        newsImageView.layer.cornerRadius = 30 // Yarı çap, width/2 olduğu için yuvarlak yapar
        newsImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  

}
