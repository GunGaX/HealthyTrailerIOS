//
//  TerminalLogModel.swift
//  TrailerWatchDog
//
//  Created by Dmytro Savka on 16.11.2023.
//

import Foundation

struct TerminalLog: Hashable {
    let time: Date
    let text: String
    
    static var mockLogs: [TerminalLog] {
        [
            TerminalLog(time: Date.now, text: "<L>,<LS1:68.8F>,<LS2:68.6F>,<LS3:-999.0F>,<LS4:-999.0F></L>,<R>,<RS1:68.8F>,<RS2:69.1F>,<RS3:-999.0F>,<RS4:-999.00F></R>"),
            TerminalLog(time: Date.now, text: "<L>,<LS1:68.8F>,<LS2:68.6F>,<LS3:-999.0F>,<LS4:-999.0F></L>,<R>,<RS1:68.8F>,<RS2:69.1F>,<RS3:-999.0F>,<RS4:-999.00F></R>"),
            TerminalLog(time: Date.now, text: "<L>,<LS1:68.8F>,<LS2:68.6F>,<LS3:-999.0F>,<LS4:-999.0F></L>,<R>,<RS1:68.8F>,<RS2:69.1F>,<RS3:-999.0F>,<RS4:-999.00F></R>"),
            TerminalLog(time: Date.now, text: "<L>,<LS1:68.8F>,<LS2:68.6F>,<LS3:-999.0F>,<LS4:-999.0F></L>,<R>,<RS1:68.8F>,<RS2:69.1F>,<RS3:-999.0F>,<RS4:-999.00F></R>"),
            TerminalLog(time: Date.now, text: "<L>,<LS1:68.8F>,<LS2:68.6F>,<LS3:-999.0F>,<LS4:-999.0F></L>,<R>,<RS1:68.8F>,<RS2:69.1F>,<RS3:-999.0F>,<RS4:-999.00F></R>")
        ]
    }
}
