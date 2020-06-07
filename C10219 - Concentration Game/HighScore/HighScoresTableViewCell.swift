//
//  HighScoresTableViewCell.swift
//  C10219 - Concentration Game
//
//  Created by user167774 on 07/06/2020.
//  Copyright © 2020 com.Tomco.iOs. All rights reserved.
//

import UIKit

class HighScoresTableViewCell: UITableViewCell {

    @IBOutlet weak var highScores_LBL_rank: UILabel!
    @IBOutlet weak var highScores_LBL_name: UILabel!
    @IBOutlet weak var highScores_LBL_elapsedTime: UILabel!
    @IBOutlet weak var highScores_LBL_location: UILabel!
    @IBOutlet weak var highScores_LBL_date: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

