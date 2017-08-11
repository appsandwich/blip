//
//  HTMLString.swift
//  blip
//
//  Created by Vinny Coyne on 11/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

enum HTMLCode: UInt32 {
    case doubleQuotes = 34
    case singleQuote = 39
    case start = 160
    case breakStart = 402
    case breakEnd = 8211
    case end = 8482
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
}
