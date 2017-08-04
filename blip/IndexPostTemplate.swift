//
//  IndexPostTemplate.swift
//  blip
//
//  Created by Vinny Coyne on 03/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

class IndexPostTemplate: BaseTemplate, PostTemplateProtocol {
    
    override init(path: String) {
        super.init(path: path)
        self.templateFilename = TemplateFilename.indexPost
    }
    
    func htmlFromFile(_ file: File?) -> String? {
        
        guard let post = file, var templateString = self.contentsOfTemplate(), let postHTML = post.convertedPreview(), let htmlPath = post.htmlPathFromFilename() else {
            return nil
        }
        
        templateString = templateString.replacingOccurrences(of: Config.Token.postTitle.rawValue, with: "<a href=\"" + htmlPath + "\">" + post.postTitle() + "</a>")
        
        guard let html = self.stringByReplacingTokensIn(templateString, using: post) else {
            return nil
        }
        
        return html.replacingOccurrences(of: Config.Token.postBody.rawValue, with: postHTML)
    }
}
