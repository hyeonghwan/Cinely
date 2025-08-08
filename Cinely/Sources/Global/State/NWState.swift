//
//  NWState.swift
//  Cinely
//
//  Created by hwan on 8/6/25.
//

import Foundation
import Network
import RxRelay

typealias NetworkState = NWState.State

final class NWState {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "nwtracker.shopping.com")
    
    enum State {
        case wifi(Bool)
        case cellular(Bool)
        case other(Bool)
        case none
        
        var imageString: String {
            return switch self {
            case .wifi(let bool):
                bool ? "wifi" : "wifi.slash"
            case .cellular(let bool):
                bool ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash"
            case .other(let bool):
                bool ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash"
            case .none:
                "antenna.radiowaves.left.and.right.slash"
            }
        }
    }
    
    
    private var _state = BehaviorRelay<State>(value: .none)
    
    deinit { stopMonitoring() }
    
    init() {
        monitor.start(queue: queue)
        
        defer {
            setState(path: monitor.currentPath)
            monitor.pathUpdateHandler = { [weak self] path in
                DispatchQueue.main.async {
                    self?.setState(path: path)
                }
            }
        }
    }
    
    private func setState(path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            self._state.accept(.wifi(path.status == .satisfied))
        } else if path.usesInterfaceType(.cellular) {
            self._state.accept(.cellular(path.status == .satisfied))
        } else if path.usesInterfaceType(.other) {
            self._state.accept(.other(path.status == .satisfied))
        }
        self._state.accept(.cellular(path.status == .satisfied))
    }
    
    func stopMonitoring() { monitor.cancel() }
}

