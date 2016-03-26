//
//  PlaygroundDocument.swift
//  Codinator
//
//  Created by Vladimir Danila on 26/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

enum PlaygroundDocumentEmbeddedFile: Int {
    case Neuron = 0
    case CSS = 1
    case JS = 2
}


class PlaygroundDocument: UIDocument {

    private var contents: [String]!
    
    override init(fileURL url: NSURL) {
        contents = ["", "", ""]
        super.init(fileURL: url)
    }
    
    override func contentsForType(typeName: String) throws -> AnyObject {
        
        if contents == nil {
            contents = ["", "", ""]
        }
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(contents!)
        return data
    }
    
    override func loadFromContents(fileContents: AnyObject, ofType typeName: String?) throws {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if fileContents.length > 0 {
                self.contents = NSKeyedUnarchiver.unarchiveObjectWithData(fileContents as! NSData) as? [String]
            }
            else {
                self.contents = []
            }
        }
    }
    
    
    
    

    // MARK: - Getting and Setting 
    
    
    func embeddedFile(embeddedFile: PlaygroundDocumentEmbeddedFile) -> String {
        return contents[embeddedFile.rawValue]
    }
    
    func setFile(embeddedFile: PlaygroundDocumentEmbeddedFile, toFile file: String) {
        contents[embeddedFile.rawValue] = file
    }
    
    
}
