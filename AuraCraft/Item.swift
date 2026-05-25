//
//  Item.swift
//  MyValo
//
//  Created by MNyberg on 20/05/2026.
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
