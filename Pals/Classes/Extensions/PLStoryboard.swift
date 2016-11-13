//
//  PLStoryboard.swift
//  Pals
//
//  Created by Vitaliy Delidov on 9/2/16.
//  Copyright © 2016 citirex. All rights reserved.
//

enum SegueIdentifier: String {
    case OrderPlacesSegue
    case OrderFriendsSegue
    case PlaceProfileSegue
    case FriendProfileSegue
    case EditProfileSegue
    case CardInfoSegue
    case NotificationsSegue
    case OrderHistorySegue
    case HelpAndFAQSegue
    case TermsOfServiceSegue
    case PrivacyPolicySegue
}

enum PLStoryboardType: String {
    case LoginViewController
    case TabBarController
    case FriendsViewController
    case OrderFriendsViewController
    var string: String {return rawValue}
}

extension UIStoryboard {
    
    class var mainStoryboard: UIStoryboard { return UIStoryboard(name: "Main", bundle: .mainBundle()) }
    
    class func viewControllerWithType(type: PLStoryboardType) -> UIViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier(type.string)
    }
    
    class func tabBarController() -> PLTabBarController? {
        return viewControllerWithType(.TabBarController) as? PLTabBarController
    }
    
    class func loginViewController() -> PLLoginViewController? {
        return viewControllerWithType(.LoginViewController) as? PLLoginViewController
    }
 
}