//
//  AuraCraftWidgetBundle.swift
//  AuraCraftWidget
//
//  Created by MNyberg on 22/05/2026.
//

import WidgetKit
import SwiftUI

@main
struct AuraCraftWidgetBundle: WidgetBundle {
    var body: some Widget {
        AuraCraftWidget()
        AuraCraftWidgetControl()
        AuraCraftWidgetLiveActivity()
    }
}
