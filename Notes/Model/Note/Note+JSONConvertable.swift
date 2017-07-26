//
//  Note+JSONConvertable.swift
//  Notes
//
//  Created by Anton Fresher on 18.07.17.
//  Copyright © 2017 Anton Fresher. All rights reserved.
//

import Foundation
import UIKit

// MARK: JSON conversion support for Note

public protocol JSONConvertable {
    
    var json: [String: Any] { get }
    
    static func parse(_ json: [String: Any]) -> Note?
}

extension Note: JSONConvertable {
    
    public var json: [String: Any] {
        var result: [String: Any] = [
            "uid": uuid,
            "title": title,
            "content": content
        ]
        
        if color != Note.defaultColor {
            result["color"] = color.hexString
        }
        
        result["creation_date"] = creationDate.timeIntervalSince1970
        
        result["destroy_date"] = erasureDate?.timeIntervalSince1970
        
        return result
    }
    
    public static func parse(_ json: [String: Any]) -> Note? {        
        guard let uuid = json["uid"] as? String,
            let title = json["title"] as? String,
            let content = json["content"] as? String,
            let creationDateTimeInterval = json["creation_date"] as? TimeInterval else {
                return nil
        }
        
        let creationDate = Date(timeIntervalSince1970: creationDateTimeInterval)
        
        let color : UIColor
        if let colorString = json["color"] as? String {
            if let uiColor = UIColor(hex: colorString) {
                color = uiColor
            } else {
                return nil
            }
        } else {
            color = Note.defaultColor
        }
        
        let erasureDate: Date?
        if let erasureDateTimeInterval = json["destroy_date"] as? TimeInterval {
            erasureDate = Date(timeIntervalSince1970: erasureDateTimeInterval)
        } else {
            erasureDate = nil
        }
        
        return Note(uuid: uuid,
                    title: title, content: content, color: color,
                    creationDate: creationDate, erasureDate: erasureDate)
    }

}