//
//  InternetUtils.swift
//  ROS2iOS
//
//  Created by Chiawen Liao on 4/21/25.
//


//
//  File.swift
//
//
//  Created by Yaoyu Hu on 12/21/23.
//

import Foundation
import OSLog


public func getWiFiIPv4Address() -> String? {
    var address: String?
    var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?

    guard getifaddrs(&ifaddrPtr) == 0, let firstAddr = ifaddrPtr else {
        return nil
    }

    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ptr.pointee

        let addrFamily = interface.ifa_addr.pointee.sa_family
        guard addrFamily == UInt8(AF_INET) else { continue }

        let name = String(cString: interface.ifa_name)
        guard name == "en0" else { continue }

        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let saLen = socklen_t(interface.ifa_addr.pointee.sa_len)
        if getnameinfo(interface.ifa_addr,
                       saLen,
                       &hostname,
                       socklen_t(hostname.count),
                       nil,
                       0,
                       NI_NUMERICHOST) == 0 {
            address = String(cString: hostname)
            break
        }
    }

    freeifaddrs(ifaddrPtr)
    return address
}
