//
//  Config.swift
//  FlowFocusMini
//
//  Created by o9tech on 25/11/2025.
//


import Foundation

struct Config {

    static let openaiAPIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

}

