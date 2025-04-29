//
//  PublisherModel.swift
//  ROS2iOS
//
//  Created by Chiawen Liao on 4/29/25.
//

import Foundation

import ros2msg
import ROS2FastRTPSMessages
import SwiftROS2
import OSLog


fileprivate let logger = Logger(subsystem: "ROS2iOS", category: "PublisherModel")
public class PublisherModel: ObservableObject {
    private weak var centralNode: CentralNode?
    
    private let rosOwner: String
    private var pubTopicPrefix: String // ROS 话题前缀。
    
    private var publisher: Publisher<DDSString>? // 用于发布速度命令。
    
    private(set) public var initialized: Bool
    
    init() {
        self.rosOwner = "iPhone"
        self.pubTopicPrefix = "/std_msg/string"
        self.publisher = nil
        self.initialized = false
        logger.info("Init.")
    }
    
    public func initialize(centralNode: CentralNode) async {
        if self.initialized {
            return
        }
        
        self.centralNode = centralNode
        
        // 初始化 `/cmd_vel` 发布器。
        self.publisher = await self.centralNode!.createPublisher(
            owner: self.rosOwner,
            topic: self.pubTopicPrefix,
            willWriteToFile: false,
            writeDestination: .light
        )
        
        if self.publisher == nil {
            logger.error("Failed to create publisher for topic: \(self.pubTopicPrefix)")
        } else {
            logger.info("Publisher created successfully for topic: \(self.pubTopicPrefix)")
        }
        
        self.initialized = true
        logger.info("Publisher initialized.")
    }
    
    public func sendString() {
        guard let publisher = self.publisher else {
            logger.error("Publisher is not initialized.")
            return
        }
        
        let ros2str = ROS2String()
        ros2str.data = "Hello World!"
        
        let ddsMsg = DDSString(val: ros2str)
        
        Task {
            await publisher.publish(ddsMsg)
            logger.info("Published \(ros2str.data)")
        }
    }
    
    public func destroy() async {
        if !self.initialized {
            logger.error("Publisher Model Already destroyed.")
            return
        }
        
        self.centralNode = nil
        self.initialized = false
    }
}
