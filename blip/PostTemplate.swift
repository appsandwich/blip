//
//  PostTemplate.swift
//  blip
//
//  Created by Vinny Coyne on 03/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

class PostTemplate: BaseTemplate, PostTemplateProtocol {
    
    override init(path: String) {
        super.init(path: path)
        self.templateFilename = TemplateFilename.post
    }
    
    func htmlFromFile(_ file: File?) -> String? {
        
        guard let post = file, let templateString = self.contentsOfTemplate(), let postHTML = post.convertedHTML() else {
            return nil
        }
        
        guard let html = self.stringByReplacingTokensIn(templateString, using: post) else {
            return nil
        }
        
        return html.replacingOccurrences(of: Config.Token.postBody.rawValue, with: postHTML)
    }
}
