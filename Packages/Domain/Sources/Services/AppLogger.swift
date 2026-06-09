//
//  AppLoggerProtocol.swift
//  Domain
//
//  Created by patrick ridd on 3/1/26.
//


public protocol AppLogger: Sendable {
    func log(_ message: String)
}
