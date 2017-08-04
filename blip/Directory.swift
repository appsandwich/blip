//
//  Directory.swift
//  blip
//
//  Created by Vinny Coyne on 02/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

struct Directory {
    
    var path: String
    
    public func contents() -> [File]? {
        
        let fm = FileManager.default
        
        do {
            
            let contents = try fm.contentsOfDirectory(atPath: self.path)
            
            let markdownContents = contents.filter({ (filename) -> Bool in
                return filename.hasSuffix(Config.MarkdownExtension.md.rawValue) || filename.hasSuffix(Config.MarkdownExtension.markdown.rawValue)
            })
            
            guard markdownContents.count > 0 else {
                return nil
            }
            
            return markdownContents.map({ (filename) -> File in
                return File(filename: filename, directory: self)
            })
        }
        catch {
            return nil
        }
    }
}
