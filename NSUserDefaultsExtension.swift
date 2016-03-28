//
//  NSUserDefaultsExtension.swift
//  Codinator
//
//  Created by Vladimir Danila on 28/03/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import Foundation

extension NSUserDefaults {
    
    func attributesForKey(key: String) -> [String:UIColor] {
        
        guard let dictionaryData = self.objectForKey(key) as? NSData else {
            return [:]
        }
        
        guard let dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(dictionaryData) as? [String:UIColor] else {
            return [:]
        }
        
        return dictionary
    }
        
}