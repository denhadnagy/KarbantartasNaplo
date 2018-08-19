//
//  NotesTableViewCell.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 08. 14..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet private weak var commentLabel: UILabel!
    //okFilterButton.setImage(UIImage(named: "icons8-chart"), for: UIControlState.normal)
    //okFilterButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    //okFilterButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
    var note: Note! {
        didSet {
            let creationDate = Date(timeIntervalSince1970: TimeInterval(note.creationDate))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd   HH:mm"
            
            creationDateLabel.text = dateFormatter.string(from: creationDate)
            commentLabel.text = "Bejegyzés: \(note.comment)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
