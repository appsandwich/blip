//
//  Generator.swift
//  blip
//
//  Created by Vinny Coyne on 03/08/2017.
//  Copyright © 2017 App Sandwich Limited. All rights reserved.
//

import Foundation

class Generator {
    
    var directory: Directory
    internal var draftsDirectory, publishedDirectory: Directory
    internal var fileWatcher: SwiftFSWatcher?
    
    init(directory: Directory) {
        
        self.directory = directory
        
        let separator = directory.path.hasSuffix("/") ? "" : "/"
        self.draftsDirectory = Directory(path: directory.path + separator + Config.Path.drafts.rawValue)
        self.publishedDirectory = Directory(path: directory.path + separator + Config.Path.published.rawValue)
        
        self.createDefaultDirectories()
        self.watchDraftsDirectory()
    }
    
    internal func createDefaultDirectories() {
        
        self.createDirectory(self.draftsDirectory)
        self.createDirectory(self.publishedDirectory)
    }
    
    internal func watchDraftsDirectory() {
        
        self.fileWatcher = SwiftFSWatcher([ self.draftsDirectory.path ])
        
        guard let fw = self.fileWatcher else {
            return
        }
        
        fw.watch { [weak self] (fileEvents) in
            
            fileEvents.forEach({ (ev) in
                
                if ev.eventFlag.intValue & kFSEventStreamEventFlagItemIsFile != 0 {
                    
                    if ev.eventFlag.intValue & kFSEventStreamEventFlagItemCreated != 0 ||
                        ev.eventFlag.intValue & kFSEventStreamEventFlagItemRenamed != 0 ||
                        ev.eventFlag.intValue & kFSEventStreamEventFlagItemModified != 0 {
                        
                        DispatchQueue.main.async {
                            self?.publishNewDrafts()
                        }
                    }
                }
            })
        }
    }
    
    internal func createDirectory(_ directory: Directory) {
        
        let fm = FileManager.default
        
        if !fm.fileExists(atPath: directory.path) {
            
            do {
                try fm.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("WARNING: Failed to create directory at: \(directory.path))")
            }
        }
    }
    
    internal func drafts() -> [File]? {
        return self.draftsDirectory.contents()
    }
    
    internal func draftsToPublish() -> [File]? {
        return self.drafts()?.filter({ (file) -> Bool in
            return file.shouldPublish()
        })
    }
    
    public func publishNewDrafts() {
        
        let separator = self.directory.path.hasSuffix("/") ? "" : "/"
        let postTemplate = PostTemplate(path: self.directory.path + separator)
        
        guard let draftsToPublish = self.draftsToPublish(), draftsToPublish.count > 0 else {
            print("No new or modified drafts to publish.")
            return
        }
        
        draftsToPublish.forEach({ (draft) in
            self.publishDraft(draft, using: postTemplate)
        })
        
        if draftsToPublish.count > 0 {
            self.rebuildIndex()
        }
    }
    
    public func rebuildIndex() {
        
        guard let drafts = self.drafts()?.filter({ (draft) -> Bool in
            return draft.shouldPublish(overwrite: true)
        }) else {
            return
        }
        
        let sortedDrafts = drafts.sorted { (d1, d2) -> Bool in
            return d1.filename > d2.filename
        }
        
        print("Rebuilding site indexes...")
        
        var page = 0
        var postOnPage = 0
        
        var pageDrafts: [File] = []
        
        
        let separator = self.directory.path.hasSuffix("/") ? "" : "/"
        let indexPostTemplate = IndexPostTemplate(path: self.directory.path + separator)
        
        sortedDrafts.enumerated().forEach { (index, draft) in
            
            pageDrafts.append(draft)
            
            postOnPage += 1
            
            if postOnPage == Config.postsPerPage {
                
                self.buildIndexForPage(page, with: pageDrafts, using: indexPostTemplate)
                
                postOnPage = 0
                page += 1
                
                pageDrafts.removeAll()
            }
        }
    }
    
    public func rebuildSite() {
        
        self.rebuildIndex()
        
        let separator = self.directory.path.hasSuffix("/") ? "" : "/"
        let postTemplate = PostTemplate(path: self.directory.path + separator)
        
        let drafts = self.drafts()
        
        drafts?.forEach({ (draft) in
            self.publishDraft(draft, using: postTemplate)
        })
    }
    
    internal func buildIndexForPage(_ pageIndex: Int, with files: [File], using template: IndexPostTemplate) {
        
        print("Building page \(pageIndex + 1) with \(files.count) posts...")
        
        let fm = FileManager.default
        
        let pageFilename = "index" + ((pageIndex == 0) ? "" : String(pageIndex)) + ".html"
        
        let postsHTML = files.reduce("", { (html, draft) -> String in
            
            guard let preview = template.htmlFromFile(draft) else {
                return html
            }
            
            
            return html + preview
        })
        
        
        let indexTemplate = IndexTemplate(path: template.path)
        
        guard let pageHTML = indexTemplate.htmlFromPostsHTML(postsHTML, pageIndex: pageIndex) else {
            print("WARNING: Couldn't generate page \(pageFilename)")
            return
        }
        
        
        let separator = self.publishedDirectory.path.hasSuffix("/") ? "" : "/"
        let url = URL(fileURLWithPath: self.publishedDirectory.path + separator + pageFilename)
        
        if !fm.fileExists(atPath: url.path) {
            
            do {
                try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("WARNING: Couldn't write page \(pageFilename)")
            }
        }
        
        do {
            try pageHTML.write(to: url, atomically: true, encoding: .utf8)
            
            print("\(pageFilename) written to disk.")
        }
        catch {
            print("WARNING: Couldn't write page \(pageFilename)")
        }

    }

    internal func publishDraft(_ draft: File, using template: PostTemplate) {
        
        let fm = FileManager.default
        
        if let html = template.htmlFromFile(draft), let url = draft.publishedURL() {
            
            print("Publishing \(draft.filename)...")
            
            if !fm.fileExists(atPath: url.path) {
                
                do {
                    try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    print("WARNING: Couldn't write post \(draft.filename)")
                }
            }
            
            do {
                try html.write(to: url, atomically: true, encoding: .utf8)
                
                print("Published: \(draft.filename) (\(url.path))")
            }
            catch {
                print("WARNING: Couldn't write post \(draft.filename)")
            }
        }
    }
}
