//
//  Enumerations.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 16..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

enum Severity: String {
    case urgent = "Sürgős"
    case actual = "Aktuális"
    case soon = "Hamar"
    case ok = "Rendben"
    case undefined = "Nem meghatározott"
    
    var color: UIColor {
        get {
            var R, G, B: CGFloat
            
            switch self {
            case .ok: R = 0.55; G = 0.76; B = 0.29
            case .soon: R = 1.0; G = 0.95; B = 0.46
            case .actual: R = 1.0; G = 0.72; B = 0.30
            case .urgent: R = 0.96; G = 0.26; B = 0.21
            case .undefined: R = 0.93; G = 0.93; B = 0.93
            }
            
            return UIColor(red: R, green: G, blue: B, alpha: 1.0)
        }
    }
    
    var description: String {
        get {
            var descriptionString = ""
            
            switch self {
            case .ok: descriptionString = "Nem igényel karbantartást."
            case .soon: descriptionString = "Az üzemidő meghaladta a karbantartási periódus 80%-át."
            case .actual: descriptionString = "Az üzemidő meghaladta a karbantartási periódus 90%-át."
            case .urgent: descriptionString = "Az üzemidő meghaladta a karbantartási periódus 100%-át."
            case .undefined: break
            }
            
            return descriptionString
        }
    }
}
