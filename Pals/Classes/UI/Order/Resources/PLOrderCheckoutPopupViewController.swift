//
//  PLOrderCheckoutPopupViewController.swift
//  Pals
//
//  Created by Maks Sergeychuk on 9/20/16.
//  Copyright © 2016 citirex. All rights reserved.
//

protocol CheckoutOrderPopupDelegate: class {
    func orderPopupCancelClicked(popup: PLOrderCheckoutPopupViewController)
    func orderPopupSendClicked(popup: PLOrderCheckoutPopupViewController)
}

class PLOrderCheckoutPopupViewController: UIViewController {
    
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var amountLabel: UILabel!
    @IBOutlet private var messageTextView: UITextView!
    @IBOutlet private var popupView: UIView!
    @IBOutlet weak var checkboxContainer: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!

    private let placeholderText = "Write a message... (optional)"
    private var didSetupConstraints = false
    private var checkboxes = [PLCheckbox]()
    
    lazy var drinksCheckbox: PLCheckbox! = {
        let checkbox = PLCheckbox(title: "Separate Drinks")
        return checkbox
    }()
    lazy var coversCheckbox: PLCheckbox! = {
        let checkbox = PLCheckbox(title: "Separate Covers")
        return checkbox
    }()
    lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(reciveTap(_:)))
    }()
    
    var userName: String?
    var locationName: String?
    var orderAmount: Float?
    
    var order: PLCheckoutOrder? {
        didSet {
            if let ord = order {
                if let user = ord.user {
                    userName = user.name
                }
                if let place = ord.place {
                    locationName = place.name
                }
                orderAmount = ord.calculateTotalAmount()
            }
        }
    }
    
    weak var delegate: CheckoutOrderPopupDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.hidden = true
        popupView.layer.cornerRadius = 10
        
        setupCheckbox()
        setupLayoutConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        userNameLabel.text = userName
        locationLabel.text = locationName
        amountLabel.text = String(format: "$%.2f", orderAmount!)
        if let o = order {
            if o.message != nil && o.message!.characters.count > 0 {
                messageTextView.text = o.message
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupCheckbox() {
        if order!.hasAtLeastTwoDrinks {
            checkboxContainer.addSubview(drinksCheckbox)
            checkboxes.append(drinksCheckbox)
            drinksCheckbox.stateChanged = { checkbox in
                self.order?.isSplitDrinks = checkbox.checked
            }
        }

        if order!.hasAtLeastTwoCovers {
            checkboxContainer.addSubview(coversCheckbox)
            checkboxes.append(coversCheckbox)
            coversCheckbox.stateChanged = { checkbox in
                self.order?.isSplitCovers = checkbox.checked
            }
        }
    }
    
    func setupLayoutConstraints() {
        if !didSetupConstraints {
            
            let checkboxHeight: CGFloat = 25.0
            let offset: CGFloat = 10.0
            
            if checkboxes.count > 1 {
                containerHeightConstraint.constant = CGFloat(checkboxes.count) * checkboxHeight + offset
                drinksCheckbox.autoSetDimension(.Height, toSize: checkboxHeight)
                drinksCheckbox.autoPinEdgeToSuperviewEdge(.Top)
                drinksCheckbox.autoPinEdgeToSuperviewEdge(.Leading)
                drinksCheckbox.autoPinEdgeToSuperviewEdge(.Trailing)
                
                coversCheckbox.autoPinEdge(.Top, toEdge: .Bottom, ofView: drinksCheckbox, withOffset: offset)
                
                coversCheckbox.autoSetDimension(.Height, toSize: checkboxHeight)
                coversCheckbox.autoPinEdgeToSuperviewEdge(.Bottom)
                coversCheckbox.autoPinEdgeToSuperviewEdge(.Leading)
                coversCheckbox.autoPinEdgeToSuperviewEdge(.Trailing)
            } else {
                if let checkbox = checkboxes.first {
                    containerHeightConstraint.constant = checkboxHeight
                    checkbox.autoSetDimension(.Height, toSize: checkboxHeight)
                    checkbox.autoPinEdgeToSuperviewEdge(.Bottom)
                    checkbox.autoPinEdgeToSuperviewEdge(.Leading)
                    checkbox.autoPinEdgeToSuperviewEdge(.Trailing)
                }
            }
            didSetupConstraints = true
        }
    }

    func show(from vc: UIViewController) {
        vc.presentViewController(self, animated: false) { [unowned self] in
            self.show()
        }
    }
    
    //MARK: - Actions
    func show() {
        popupView.alpha = 0
        view.alpha = 0
        view.hidden = false
        UIView.animateWithDuration(0.1, animations: {
            self.view.alpha = 1
            self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        }) { (complete) in
            self.popupView.transform = CGAffineTransformMakeScale(0, 0)
            self.popupView.transform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height)
            self.popupView.alpha = 0.5
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                self.popupView.transform = CGAffineTransformIdentity
                self.popupView.alpha = 1
                }, completion: { (complete) in
                    
            })
        }
    }
    
    func hide() {
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.popupView.transform = CGAffineTransformMakeTranslation(0, -self.view.bounds.size.height)
            self.view.backgroundColor = .clearColor()
            }, completion: { complete in
                self.popupView.transform = CGAffineTransformIdentity
                self.view.alpha = 1
                self.dismiss(false)
                self.view.hidden = true
        })
    }
    
    @IBAction private func cancelButtonPressed(sender: UIButton) {
        order?.isSplitCovers = false
        order?.isSplitDrinks = false
        order?.serialize()
        
        delegate?.orderPopupCancelClicked(self)
    }
    
    @IBAction private func sendButtonPressed(sender: UIButton) {
        if order == nil {
            PLShowAlert("Error", message: "Order is not selected")
            return
        }
        
        let message = (textViewText == placeholderText) ? "" : textViewText
        textViewText = placeholderText
        order?.message = message
        order?.serialize()
        delegate?.orderPopupSendClicked(self)
    }
    
    @objc private var textViewText: String {
        get{
            return messageTextView.text
        }
        set{
            messageTextView.text = newValue
        }
    }
    
    @objc private func reciveTap(gesture: UITapGestureRecognizer) {
        if messageTextView.isFirstResponder() && messageTextView.canResignFirstResponder() {
            messageTextView.resignFirstResponder()
        }
    }
    
    private func addGestures() {
        view.addGestureRecognizer(tapGesture)
    }
    
    private func removeGestures() {
        view.removeGestureRecognizer(tapGesture)
    }

    
    //MARK: - Textview delegate
    func textViewDidBeginEditing(textView: UITextView) {
        addGestures()
        if textViewText == placeholderText {
            textViewText = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textViewText == "" {
            textViewText = placeholderText
        }
    }
}
