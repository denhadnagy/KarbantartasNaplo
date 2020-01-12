//
//  Extensions.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 08. 19..
//  Copyright © 2018. Daniel. All rights reserved.
//

extension Int {
    var digits: [Int] {
        String(self).compactMap { Int(String($0)) }
    }
}
