//
//  PLTabBarItem.swift
//  Pals
//
//  Created by Vitaliy Delidov on 11/8/16.
//  Copyright © 2016 citirex. All rights reserved.
//

import Foundation


extension UITabBarItem {
    
    func setBadge(badge: PLBadge) {
        if badge.count > 0 {
            badgeValue = String(badge.count)
        }
    }
    
    func plusBadge() {
        let value = Int(badgeValue ?? "0") ?? 0
        badgeValue = String(value + 1)
    }
    
}