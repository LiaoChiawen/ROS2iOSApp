//
//  ROS2Manager.swift
//  ROS2iOSApp
//
//  Created by Chiawen Liao on 4/16/25.
//

import Foundation
import SwiftROS2

class ROS2Manager: ObservableObject {
    private var node: CentralNode? // ROS2 节点
    private var publishers: [String: Any] = [:] // 存储多个发布者
    private var subscribers: [String: Any] = [:] // 存储多个订阅者
    
    init(nodeName: String = "ios_node") {
        initializeROS(nodeName: nodeName)
    }
    
    private func initializeROS(nodeName: String) {
        do {
            // 初始化 ROS2 节点
            node = CentralNode(name: nodeName)
            print("ROS2 Node '\(nodeName)' initialized successfully.")
        } catch {
            print("Failed to initialize ROS2 Node: \(error)")
        }
    }
    
    // 创建发布者
    func createPublisher<T: Codable>(topic: String, messageType: T.Type) {
        guard let node = node else {
            print("ROS2 Node is not initialized.")
            return
        }
        
        do {
            let publisher = try node.createPublisher(topic: topic, messageType: messageType)
            publishers[topic] = publisher
            print("Publisher created for topic '\(topic)'.")
        } catch {
            print("Failed to create publisher for topic '\(topic)': \(error)")
        }
    }
    
    // 发布消息
    func publishMessage<T: Codable>(topic: String, message: T) {
        guard let publisher = publishers[topic] as? Publisher<T> else {
            print("Publisher for topic '\(topic)' is not initialized.")
            return
        }
        
        do {
            try publisher.publish(message)
            print("Message published to topic '\(topic)': \(message)")
        } catch {
            print("Failed to publish message to topic '\(topic)': \(error)")
        }
    }
    
    // 创建订阅者
    func createSubscriber<T: Codable>(topic: String, messageType: T.Type, callback: @escaping (T) -> Void) {
        guard let node = node else {
            print("ROS2 Node is not initialized.")
            return
        }
        
        do {
            let subscriber = try node.createSubscriber(topic: topic, messageType: messageType, callback: callback)
            subscribers[topic] = subscriber
            print("Subscriber created for topic '\(topic)'.")
        } catch {
            print("Failed to create subscriber for topic '\(topic)': \(error)")
        }
    }
    
    // 销毁节点
    func destroyNode() {
        do {
            // 销毁所有发布者和订阅者
            for (_, publisher) in publishers {
                try (publisher as? AnyPublisher)?.destroy()
            }
            for (_, subscriber) in subscribers {
                try (subscriber as? AnySubscriber)?.destroy()
            }
            
            // 销毁节点
            try node?.destroy()
            
            publishers.removeAll()
            subscribers.removeAll()
            node = nil
            
            print("ROS2 Node and all resources destroyed successfully.")
        } catch {
            print("Failed to destroy ROS2 resources: \(error)")
        }
    }
}
