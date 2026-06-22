//
//  Item.swift
//  RevenueShot
//
//  Created by fenglei on 2026/6/22.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
