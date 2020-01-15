//
//  Note.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 08. 13..
//  Copyright © 2018. Daniel. All rights reserved.
//

class Note {
    let creationDate: Int
    private(set) var comment = ""
    
    init(creationDate: Int, comment: String) {
        self.creationDate = creationDate
        self.comment = comment
    }
    
    func setComment(to comment: String) {
        self.comment = comment
    }
}
