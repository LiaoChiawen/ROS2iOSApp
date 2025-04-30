//
//  ContentView.swift
//  ROS2iOSApp
//
//  Created by Chiawen Liao on 4/16/25.
//

import SwiftUI
import SwiftROS2
import ROS2FastRTPSMessages   
import ros2msg
import OSLog


fileprivate let logger = Logger(subsystem: "", category: "string")

struct ContentView: View {
    @EnvironmentObject var observableCentralNode: ObservableCentralNode
    @EnvironmentObject var publisherModel: PublisherModel
    
    @State private var configViewIP: String = getWiFiIPv4Address() ?? "127.0.0.1"

    
    func initialize(){
        
        Task{
            configViewIP = getWiFiIPv4Address() ?? "127.0.0.1"
            observableCentralNode.centralNode = CentralNode(
                domainID: 0,
                ipAddress: configViewIP
            )
            
            guard let cn = self.observableCentralNode.centralNode else {
                logger.error("Central Node is not ready/available. Cannot initialize.")
                return
            }
            
            await cn.initialize()
            
            await self.publisherModel.initialize(centralNode: cn)
            
        }
        
    }
    

    func destroyNode() {
        Task {
            await observableCentralNode.centralNode?.destroy()
            observableCentralNode.centralNode = nil
            await publisherModel.destroy()
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Initialize") {
                initialize()
            }
            .font(.headline)
            .fontWeight(.semibold)
            .frame(width: 140, height: 44)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Publish Message") {
                publisherModel.sendString()
            }
            .font(.headline)
            .fontWeight(.semibold)
            .frame(width: 140, height: 44)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Destroy Node") {
                destroyNode()
            }
            .font(.headline)
            .fontWeight(.semibold)
            .frame(width: 140, height: 44)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ObservableCentralNode())
    }
}
