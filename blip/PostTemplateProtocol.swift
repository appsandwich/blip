//
//  Template.swift
//  blip
//
//  Created by Vinny Coyne on 03/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

enum TemplateFilename: String {
    case index = "index_template.html"
    case indexPost = "index_post_template.html"
    case post = "post_template.html"
}

protocol PostTemplateProtocol {
    func htmlFromFile(_ file: File?) -> String?
    func stringByReplacingTokensIn(_ string: String, using file: File?) -> String?
}

class BaseTemplate {
    
    var path: String
    var templateFilename: TemplateFilename?
    
    init(path: String) {
        self.path = path
    }
    
    func contentsOfTemplate() -> String? {
        
        guard let tf = self.templateFilename else {
            return nil
        }
        
        let fm = FileManager.default
        
        let url = URL(fileURLWithPath: self.path + Config.Path.templates.rawValue + tf.rawValue)
        
        guard fm.fileExists(atPath: url.path) else {
            return nil
        }
        
        
        do {
            let string = try String(contentsOf: url)
            return string
        }
        catch {
            return nil
        }
    }
    
    func stringByReplacingTokensIn(_ string: String, using file: File?) -> String? {
        
        guard let f = file else {
            return nil
        }
        
        
        var s = string
        
        if let timestamp = f.postTimestamp() {
            s = s.replacingOccurrences(of: Config.Token.postTimestamp.rawValue, with: timestamp)
        }
        
        s = s.replacingOccurrences(of: Config.Token.postTitle.rawValue, with: f.postTitle())
        
        return s
    }
}
