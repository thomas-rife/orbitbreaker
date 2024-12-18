//
//  EnemyTypes.swift
//  Orbit Breaker
//
//  Created by August Wetterau on 10/25/24.
//

import SpriteKit

enum EnemyType {
    case a
    case b
    case c
    case d
    
    static var size: CGSize {
        return CGSize(width: 24, height: 16)
    }
    
    static var name: String {
        return "enemy"
    }
    
    // Get sprite name based on health and boss type
    static func spriteForHealth(_ health: Int, bossType: BossType) -> String {
        let prefix = bossType == .anger ? "Angry" :
                    bossType == .disgust ? "Breathe" :
                    bossType == .sadness ? "Sad" :
                    "Love"
        
        switch health {
        case 31...40: return "\(prefix) Face UFO (Base)"    // Full health
        case 21...30: return "\(prefix) Face UFO (Damaged 1)" // First damage state
        case 11...20: return "\(prefix) Face UFO (Damaged 2)" // Second damage state
        default: return "\(prefix) Face UFO (Damaged 3)"      // Final damage state
        }
    }
    
    var initialHealth: Int {
        return 40  // All enemies start with 40 health
    }
}
