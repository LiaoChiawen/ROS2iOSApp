//
//  ROS2iOSApp.swift
//  ROS2iOSApp
//
//  Created by Chiawen Liao on 4/16/25.
//

import OSLog
import SwiftUI


import SwiftROS2

import UIKit

@main
struct ROS2iOSApp: App {
    
    var observableCentralNode = ObservableCentralNode()
    var publisherModel = PublisherModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(observableCentralNode)
                .environmentObject(publisherModel)
        }
    }
}
