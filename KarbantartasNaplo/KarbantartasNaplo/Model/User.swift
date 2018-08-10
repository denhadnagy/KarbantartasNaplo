//
//  User.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 08..
//  Copyright © 2018. Daniel. All rights reserved.
//

class User: Codable {
    private(set) var id = 0
    private(set) var creationDate = 0
    private(set) var deleted = false
    private(set) var email = ""
    private(set) var name: String?
}
