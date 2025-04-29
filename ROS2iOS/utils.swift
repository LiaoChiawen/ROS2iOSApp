//
//  ROSTopic.swift
//  ROS2iOS
//
//  Created by Chiawen Liao on 4/28/25.
//


import SwiftROS2
import FastRTPSSwift
import ROS2FastRTPSMessages

public struct ROSTopic<T: DDSMessageType>: DDSWriterTopic {
    public let name: String

        /// Use the Swift type name as the DDS type name
        public var typeName: String {
            String(describing: T.self)
        }

        public var writerProfile: RTPSWriterProfile

        public init(name: String, transientLocal: Bool = false, reliable: Bool = false) {
            self.name = name
            self.writerProfile = RTPSWriterProfile(
                keyed: false, reliability: reliable   ? .reliable      : .bestEffort, durability: transientLocal ? .transientLocal : .volatile,
                disablePositiveACKs: false
            )
        }
}

extension CentralNode {
  
    public func createPublisher<T: DDSMessageType>(
        topicName: String,
        transientLocal: Bool = false,
        reliable: Bool = false
    ) async -> DDSPublisher<T>? {
        let validName = validDDSROSTopic(topicName)
        let topic = ROSTopic<T>(
            name: validName,
            transientLocal: transientLocal,
            reliable: reliable
        )
        
        return await self.createPublisher(topic: topic)
    }
}

