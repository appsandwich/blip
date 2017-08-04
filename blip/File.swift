//
//  File.swift
//  blip
//
//  Created by Vinny Coyne on 02/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation
import Down

struct File {
    
    var filename: String
    var directory: Directory
    
    // MARK: - URL / Path
    
    public func url() -> URL {
        
        let separator = self.directory.path.hasSuffix("/") ? "" : "/"
        
        return URL(fileURLWithPath: self.directory.path + separator + filename)
    }
    
    // yyyy/MM/dd
    
    public func pathFromFilename() -> String? {
        
        let dateString = self.url().deletingPathExtension().lastPathComponent
        
        guard dateString.characters.count == Config.postFilenameDateFormat.characters.count else {
            return nil
        }
        
        let yyyy = dateString.substring(to: dateString.index(dateString.startIndex, offsetBy: 4))
        let mm = dateString.substring(with: dateString.index(dateString.startIndex, offsetBy: 4)..<dateString.index(dateString.startIndex, offsetBy: 6))
        let dd = dateString.substring(with: dateString.index(dateString.startIndex, offsetBy: 6)..<dateString.endIndex)
        
        return yyyy + "/" + mm + "/" + dd
    }
    
    // yyyy/MM/dd.html
    
    public func htmlPathFromFilename() -> String? {
        
        guard let path = self.pathFromFilename() else {
            return nil
        }
        
        return path + ".html"
    }
    
    // yyyy/MM/dd.md
    
    public func markdownPathFromFilename() -> String? {
        
        guard let path = self.pathFromFilename() else {
            return nil
        }
        
        return path + Config.MarkdownExtension.md.rawValue
    }

    // posts/yyyy/MM/dd.html
    
    public func publishedURL() -> URL? {
        
        guard let path = self.htmlPathFromFilename() else {
            return nil
        }
        
        return URL(fileURLWithPath: self.directory.path.replacingOccurrences(of: Config.Path.drafts.rawValue, with: Config.Path.published.rawValue) + path)
    }
    
    // MARK: - File access
    
    internal func markdownString() -> String? {
        
        let url = self.url()
        
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: url.path) else {
            return nil
        }
        
        
        do {
            let markdownString = try String(contentsOf: url)
            return markdownString
        }
        catch {
            return nil
        }
    }
    
    // MARK: - Conversion
    
    public func convertedHTML() -> String? {
        
        guard let markdownString = self.markdownString() else {
            return nil
        }
        
        let down = Down(markdownString: markdownString.replacingOccurrences(of: Config.Token.readMore.rawValue, with: ""))
        
        do {
            return try down.toHTML()
        }
        catch {
            return nil
        }
    }
    
    public func convertedPreview() -> String? {
        
        guard let markdownString = self.markdownString() else {
            return nil
        }
        
        
        var subMarkdown = markdownString
        var hasReadMore = false
        
        if let readMoreRange = markdownString.range(of: Config.Token.readMore.rawValue) {
            subMarkdown = markdownString.substring(to: readMoreRange.lowerBound)
            hasReadMore = true
        }
        
        var comps = subMarkdown.components(separatedBy: .newlines)
        
        if comps.count > 1 {
            comps.remove(at: 0)
            subMarkdown = comps.reduce("", { (md, line) -> String in
                return md + "\n" + line
            })
        }
        
        let down = Down(markdownString: subMarkdown)
        
        do {
            
            var convertedHTML = try down.toHTML()
            
            if hasReadMore {
                
                if let htmlURL = self.htmlPathFromFilename() {
                    convertedHTML += "<p class=\"index_post_readmore\"><a href=\"\(htmlURL)\">" + Config.TokenReplacement.readMore.rawValue + "</a></p>"
                }
            }
            
            return convertedHTML
        }
        catch {
            return nil
        }
    }
    
    
    // MARK: - Metadata
    
    public func postTimestamp() -> String? {
        
        let dateString = self.url().deletingPathExtension().lastPathComponent
        
        guard dateString.characters.count == Config.postFilenameDateFormat.characters.count else {
            return nil
        }
        
        let df = DateFormatter()
        df.dateFormat = Config.postFilenameDateFormat
        
        guard let date = df.date(from: dateString) else {
            return nil
        }
        
        df.dateFormat = Config.postDateFormat
        
        return df.string(from: date)
    }
    
    public func postTitle() -> String {
        
        guard let markdownString = self.markdownString() else {
            return ""
        }
        
        let lines = markdownString.components(separatedBy: .newlines)
        
        guard lines.count > 0, let title = lines.first else {
            return ""
        }
        
        return title.replacingOccurrences(of: "#", with: "")
    }
    
    public func shouldPreview() -> Bool {
        
        guard let markdownString = self.markdownString() else {
            return false
        }
        
        return markdownString.range(of: Config.Token.readMore.rawValue) != nil
    }
    
    public func shouldPublish(overwrite: Bool = false) -> Bool {
        
        guard let publishedURL = self.publishedURL() else {
            return false
        }
        
        
        let draftURL = self.url()
        
        
        let dateString = draftURL.deletingPathExtension().lastPathComponent
        
        guard dateString.characters.count == Config.postFilenameDateFormat.characters.count else {
            return false
        }
        
        let df = DateFormatter()
        df.dateFormat = Config.postFilenameDateFormat
        
        guard let date = df.date(from: dateString), date < Date() || Calendar.current.isDateInToday(date) else {
            return false
        }
        
        let fm = FileManager.default
        
        guard fm.fileExists(atPath: publishedURL.path) else {
            return true
        }
        
        if !overwrite {
            
            // Check modified timestamps and update if necessary
            
            do {
                
                let publishedAttributes = try fm.attributesOfItem(atPath: publishedURL.path)
                
                if let publishedModifiedDate = publishedAttributes[.modificationDate], publishedModifiedDate is Date {
                    
                    do {
                        
                        let draftAttributes = try fm.attributesOfItem(atPath: draftURL.path)
                        
                        if let draftModifiedDate = draftAttributes[.modificationDate], draftModifiedDate is Date {
                            
                            if let draftDate = draftModifiedDate as? Date, let publishedDate = publishedModifiedDate as? Date {
                                return draftDate > publishedDate
                            }
                        }
                    }
                    catch {
                        print("WARNING: Couldn't load attributes for file: \(publishedURL.path)")
                    }
                }
            }
            catch {
                print("WARNING: Couldn't load attributes for file: \(publishedURL.path)")
            }
        }
        
        return overwrite
    }
}
