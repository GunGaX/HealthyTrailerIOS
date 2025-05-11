//
//  ListeningWidgetBundle.swift
//  ListeningWidget
//
//  Created by Dmytro Savka on 12.05.2025.
//

import WidgetKit
import SwiftUI

@main
struct ListeningWidgetBundle: WidgetBundle {
    var body: some Widget {
        ListeningWidget()
        ListeningWidgetControl()
        ListeningWidgetLiveActivity()
    }
}
