//
//  FontDefaults.swift
//  Codinator
//
//  Created by Vladimir Danila on 14/06/16.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit

let fontsKey = "[P]CustomFontsKey"
let fontKeyName = "[Polaris]CustomFontKeyFontName"
let fontKeySize = "[Polaris]CustomFontKeyFontSize"


extension UserDefaults {
    
    func font(key: String) -> UIFont? {
        let fonts = self.dictionary(forKey: fontsKey)
        let fontComponent = fonts?[key] as? [String : AnyObject]
        
        guard let fontName = fontComponent?[fontKeyName] as? String,
            let fontSize = fontComponent?[fontKeySize] as? CGFloat else {
                return nil
        }
        
        return UIFont(name: fontName, size: fontSize)
    }
    
    
    func set(font: UIFont, key: String) {
        
        var fonts = self.object(forKey: fontsKey) as? [String : AnyObject]
        
        if fonts == nil {
            fonts = [String : AnyObject]()
        }
        
        let fontComponents = [
            fontKeyName : font.fontName,
            fontKeySize : font.pointSize
        ]
        

        fonts![key] = fontComponents
        
        self.setValue(fonts, forKey: fontsKey)
        
    }
    
}
