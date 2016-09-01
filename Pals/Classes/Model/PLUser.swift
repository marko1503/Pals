//
//  PLUser.swift
//  Pals
//
//  Created by ruckef on 31.08.16.
//  Copyright © 2016 citirex. All rights reserved.
//

import Foundation

class PLUser: PLUniqueObject {
    var name: String
    var email: String
    var picture: NSURL
    var balance: Float
    
    required init?(jsonDic: [String : AnyObject]) {
        guard
            let name = jsonDic[PLKeys.name.string] as? String,
            let email = jsonDic[PLKeys.email.string] as? String,
            let picture = jsonDic[PLKeys.picture.string] as? String,
            let balance = jsonDic[PLKeys.balance.string] as? Float
        else {
            return nil
        }
        self.name = name
        self.email = email
        self.picture = NSURL(string: picture)!
        self.balance = balance
        super.init(jsonDic: jsonDic)
    }
    
    override func serialize() -> [String : AnyObject] {
        var dic = [String : AnyObject]()
        dic[PLKeys.name.string] = name
        dic[PLKeys.email.string] = email
        dic[PLKeys.picture.string] = picture.absoluteString
        dic[PLKeys.balance.string] = String(balance)
        dic.append(super.serialize())
        return dic
    }
}