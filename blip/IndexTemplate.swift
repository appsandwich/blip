//
//  IndexTemplate.swift
//  blip
//
//  Created by Vinny Coyne on 03/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

class IndexTemplate: BaseTemplate {
    
    override init(path: String) {
        super.init(path: path)
        self.templateFilename = TemplateFilename.index
    }
    
    func htmlFromPostsHTML(_ postsHTML: String, pageIndex: Int) -> String? {
        
        guard var templateString = self.contentsOfTemplate() else {
            return nil
        }
        
        let newerFilename = (pageIndex == 0) ? "" : ("<a href=\"index" + ((pageIndex == 1) ? "" : String(pageIndex - 1)) + ".html\">" + Config.TokenReplacement.postsNewer.rawValue + "</a>")
        let olderFilename = "<a href=\"index" + String(pageIndex + 1) + ".html\">" + Config.TokenReplacement.postsOlder.rawValue + "</a>"
        
        templateString = templateString.replacingOccurrences(of: Config.Token.postsOlder.rawValue, with: olderFilename)
        templateString = templateString.replacingOccurrences(of: Config.Token.postsNewer.rawValue, with: newerFilename)
        templateString = templateString.replacingOccurrences(of: Config.Token.copyRight.rawValue, with: Config.TokenReplacement.copyRight.rawValue)
        
        return templateString.replacingOccurrences(of: Config.Token.posts.rawValue, with: postsHTML)
    }
}
