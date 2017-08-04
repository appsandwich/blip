//
//  main.swift
//  blip
//
//  Created by Vinny Coyne on 02/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

enum Argument: String {
    
    case watchFolder = "-w"
    case rebuildSite = "-r"
    case rebuildIndex = "-i"
    case help = "-h"
}

let arguments = CommandLine.arguments

func printHelp() {
    print("Usage: blip /path/to/your/blog [ -w (watch folder) -r (rebuild entire site) -i (rebuild index*.html pages) ]")
}

guard arguments.count > 1 else {
    printHelp()
    exit(1)
}

let directory = arguments[1]

let dir = Directory(path: directory)

let generator = Generator(directory: dir)

var rebuildSite = false
var rebuildIndex = false
var watchFolder = false

if arguments.count > 2 {
    
    arguments.forEach({ (argument) in
        
        let arg = argument.replacingOccurrences(of: "--", with: "-")
        
        if let a = Argument(rawValue: arg) {
            
            switch a {
            case .watchFolder:
                watchFolder = true
            case .rebuildSite:
                rebuildSite = true
            case .rebuildIndex:
                rebuildIndex = true
            case .help:
                printHelp()
                exit(0)
            }
        }
    })
}
else {
  generator.publishNewDrafts()
}


if !rebuildIndex && !rebuildSite {
    generator.publishNewDrafts()
}
else {
    
    if rebuildSite {
        generator.rebuildSite()
    }
    
    if rebuildIndex {
        generator.rebuildIndex()
    }
}

if watchFolder {
    print("Watching for changes in \(directory)...")
    RunLoop.current.run()
}
