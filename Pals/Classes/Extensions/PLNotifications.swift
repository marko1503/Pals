//
//  PLNotifications.swift
//  Pals
//
//  Created by ruckef on 14.11.16.
//  Copyright © 2016 citirex. All rights reserved.
//

class PLPlaceEventNotification {
    var place: PLPlace
    var eventId: UInt64?
    
    convenience init(place: PLPlace){
        self.init(place: place, eventId: nil)
    }
    init(place: PLPlace, eventId: UInt64?) {
        self.place = place
        self.eventId = eventId
    }
}

enum PLNotificationType: String {
    case ProfileChanged
    case ProfileSet
    case PlaceDidSelect
    var str: String {return rawValue}
}

class PLNotifications {
    
    static func postNotification(type: PLNotificationType) {
        postNotification(type, object: nil)
    }
    
    static func postNotification(type: PLNotificationType, object: AnyObject!) {
        NSNotificationCenter.defaultCenter().postNotificationName(type.str, object: object)
    }
    
    static func addObserver(observer: AnyObject, selector: Selector, type: PLNotificationType) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: type.str, object: nil)
    }
    
    static func removeObserver(observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}