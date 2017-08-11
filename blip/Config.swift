//
//  Config.swift
//  blip
//
//  Created by Vinny Coyne on 03/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

struct Config {
    
    enum MarkdownExtension: String {
        case md = ".md"
        case markdown = ".markdown"
    }
    
    enum Path: String {
        case templates = "config/templates/"
        case published = "posts/published/"
        case drafts = "posts/drafts/"
    }
    
    enum Token: String {
        
        case readMore = "[[MORE]]"
        
        case copyRight = "$(COPYRIGHT)"
        
        case posts = "$(POSTS)"
        case postsOlder = "$(POSTS_OLDER)"
        case postsNewer = "$(POSTS_NEWER)"
        
        case postTitle = "$(POST_TITLE)"
        case postTimestamp = "$(POST_TIMESTAMP)"
        case postBody = "$(POST_BODY)"
        case postPermalink = "$(POST_PERMALINK)"
    }
    
    enum TokenReplacement: String {
        
        case postsOlder = "Older Posts &#8594;"
        case postsNewer = "&#8592; Newer Posts"
        case readMore = "Read More &#8594;"
        case copyRight = "&copy; 2017 Vinny Coyne"
    }

    static var postsPerPage = 10
    
    static var postFilenameDateFormat = "yyyyMMdd"
    static var postDateFormat = "dd MMMM yyyy"
}
