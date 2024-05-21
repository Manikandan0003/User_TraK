//
//  NetworkMonitor.swift
//  User-TraK
//
//  Created by MANIKANDAN RAJA on 18/05/24.
//
import Foundation
import Network

protocol NetworkStatusDelegate: AnyObject {
    func internetConnected()
    func internetDisconnected()
}

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    weak var delegate: NetworkStatusDelegate?
    
    private init() {}
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                self?.delegate?.internetConnected()
            } else {
                self?.delegate?.internetDisconnected()
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
