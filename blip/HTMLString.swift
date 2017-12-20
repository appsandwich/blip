//
//  HTMLString.swift
//  blip
//
//  Created by Vinny Coyne on 11/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation
import Down

enum HTMLCode: UInt32 {
    case doubleQuotes = 34
    case singleQuote = 39
    case start = 160
    case breakStart = 402
    case breakEnd = 8211
    case end = 1112064      // https://stackoverflow.com/a/27416004
}

// Modified code taken from https://stackoverflow.com/a/29835826

extension String {
    
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII||$0.value<=HTMLCode.end.rawValue}.map{$0.value}
    }
    
    var needsConversion: Bool {
        return self.asciiArray.first(where: { (code) -> Bool in
            return code >= HTMLCode.start.rawValue || code == HTMLCode.singleQuote.rawValue
        }) != nil
    }
    
    public func stringByConvertingHTMLCodes() -> String {
        
        guard self.needsConversion else {
            return self
        }
        
        let asciis = self.unicodeScalars.filter { (scalar) -> Bool in
            
            let code = scalar.value
            let ascii = scalar.isASCII || UInt32(scalar.hashValue) <= HTMLCode.end.rawValue
            
            return ascii && (code >= HTMLCode.start.rawValue || code == HTMLCode.singleQuote.rawValue)
        }
        

        let asciiSet = Set.init(asciis)
        
        var s = self
        
        asciiSet.forEach { (scalar) in
            s = s.replacingOccurrences(of: String(scalar), with: "&#\(scalar.value);")
        }
        
        return s
    }
    
    public func htmlStringFromMarkdown() -> String? {
        
        // Hack to maintain HTML codes
        
        // The Down framework's toHTML() doesn't seem to handle raw HTML
        // codes very well - it actually converts e.g. &hellip; to … for example,
        // which causes display issues. There might be a setting / parameter
        // I'm missing to prevent this, but for now, we'll just extract and
        // replace those codes.
        
        let markdownString = self
        
        var htmlTags: [Tag] = []
        
        var startRange = markdownString.range(of: "&")
        
        var index = markdownString.startIndex
        
        while (startRange != nil) {
            
            if let start = startRange {
                
                let distance = markdownString.distance(from: index, to: start.lowerBound)
                
                let startIndex = markdownString.index(index, offsetBy: distance)
                
                var endIndex = markdownString.endIndex
                
                let nextStartIndex = markdownString.range(of: "&", options: .literal, range: start.upperBound..<endIndex, locale: nil)
                
                if let next = nextStartIndex {
                    endIndex = next.lowerBound
                }
                
                let endRange = markdownString.range(of: ";", options: .literal, range: startIndex..<endIndex, locale: nil)
                
                if let end = endRange {
                    
                    let tagEndIndex = end.upperBound
                    
                    let tagRange = startIndex..<tagEndIndex
                    
                    let htmlTag = markdownString.substring(with: tagRange)
                    
                    if htmlTag.range(of: "\n") == nil, htmlTag.count < 10 {
                        
                        htmlTags.append(Tag(range: tagRange, string: htmlTag))
                        
                        index = tagEndIndex
                        
                        startRange = markdownString.range(of: "&", options: .literal, range: index..<markdownString.endIndex, locale: nil)
                    }
                    else {
                        startRange = nil
                    }
                }
                else {
                    startRange = nil
                }
            }
        }
        
        
        var string = markdownString
        
        var replacements: Dictionary<String, String> = [:]
        
        htmlTags.forEach { (tag) in
            
            let replRange = tag.string.index(tag.string.startIndex, offsetBy: 1)..<tag.string.index(tag.string.endIndex, offsetBy: -1)
            
            let replacement = tag.string.substring(with: replRange)
            
            string = string.replacingCharacters(in: tag.range, with: "±\(replacement)±")
            
            replacements[replacement] = tag.string
        }
        
        
        let down = Down(markdownString: string)
        
        do {
            
            var htmlString = try down.toHTML()
            
            replacements.forEach({ (replacement, tag) in
                htmlString = htmlString.replacingOccurrences(of: "±\(replacement)±", with: tag)
            })
            
            return htmlString.stringByConvertingHTMLCodes()
        }
        catch {
            return nil
        }
    }
}
