//
//  PLOrderOffersView
//  Pals
//
//  Created by Maks Sergeychuk on 9/6/16.
//  Copyright © 2016 citirex. All rights reserved.
//

import UIKit

protocol OrderCurrentTabDelegate: class {
    func orderTabChanged(tab: CurrentTab)
}

class PLOrdeStickyHeader: UICollectionViewCell {
    
    static let height: CGFloat = 70
    
    @IBOutlet private var coverButton: UIButton!
    @IBOutlet private var drinkButton: UIButton!
    
    @IBOutlet private var coverConstraint: NSLayoutConstraint!
    @IBOutlet private var drinkConstraint: NSLayoutConstraint!
    
    weak var delegate: OrderCurrentTabDelegate?
    
    var currentTab: CurrentTab = .Drinks {
        didSet{
            updateButtonsState()
            updateListIndicator()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateButtonsState()
        func setupGestureForDirection(direction: UISwipeGestureRecognizerDirection) {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognized(_:)))
            swipe.direction = direction
            self.addGestureRecognizer(swipe)
        }
        setupGestureForDirection(.Left)
        setupGestureForDirection(.Right)
        //FIXME: Memory leak?
        }
    
    @objc private func swipeRecognized(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Left:
            coverButtonPressed(nil)
        case UISwipeGestureRecognizerDirection.Right:
            drinksButtonPressed(nil)
        default: break
        }
    }
    
    
    @IBAction private func coverButtonPressed(sender: UIButton?) {
        if currentTab != .Covers {
            setupCollectionForState(.Covers)
        }
    }
    
    @IBAction private func drinksButtonPressed(sender: UIButton?) {
        if currentTab != .Drinks {
            setupCollectionForState(.Drinks)
        }
    }
    
    private func setupCollectionForState(state: CurrentTab) {
        currentTab = state
        updateButtonsState()
        updateListIndicator()
        delegate?.orderTabChanged(state)
    }
    
    private func updateButtonsState() {
        coverButton.selected = (currentTab == .Drinks) ? false : true
        drinkButton.selected = (currentTab == .Drinks) ? true : false
    }
    
    private func updateListIndicator() {
        coverConstraint.priority = (currentTab == .Covers) ? UILayoutPriorityDefaultHigh : UILayoutPriorityDefaultLow
        drinkConstraint.priority = (currentTab == .Covers) ? UILayoutPriorityDefaultLow : UILayoutPriorityDefaultHigh
        
        UIView.animateWithDuration(0.2) {
            self.layoutIfNeeded()
        }
    }
}
