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
        switch self {
        case .ok: return #colorLiteral(red: 0.55, green: 0.76, blue: 0.29, alpha: 1)
        case .soon: return #colorLiteral(red: 1, green: 0.95, blue: 0.46, alpha: 1)
        case .actual: return #colorLiteral(red: 1, green: 0.72, blue: 0.3, alpha: 1)
        case .urgent: return #colorLiteral(red: 0.96, green: 0.26, blue: 0.21, alpha: 1)
        case .undefined: return #colorLiteral(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        }
    }
    
    var description: String {
        switch self {
        case .ok: return "Nem igényel karbantartást."
        case .soon: return "Az üzemidő meghaladta a karbantartási periódus 80%-át."
        case .actual: return "Az üzemidő meghaladta a karbantartási periódus 90%-át."
        case .urgent: return "Az üzemidő meghaladta a karbantartási periódus 100%-át."
        case .undefined: return ""
        }
    }
}

enum User {
    case nobody
    case boss
    case admin
}
