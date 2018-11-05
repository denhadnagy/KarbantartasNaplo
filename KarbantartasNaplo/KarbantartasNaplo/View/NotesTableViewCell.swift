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
