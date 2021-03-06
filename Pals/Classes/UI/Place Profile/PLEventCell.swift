//
//  PLEventCell.swift
//  Pals
//
//  Created by ruckef on 11.11.16.
//  Copyright © 2016 citirex. All rights reserved.
//

protocol PLEventCellDelegate {
    func eventCell(cell: PLEventCell, didClickBuyEvent event: PLEvent)
}

class PLEventCell: UICollectionViewCell {

    var delegate: PLEventCellDelegate?
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var eventDescriptionLabel: UILabel!
    @IBOutlet private var eventImageView: PLCircularImageView!
    @IBOutlet private var startDateLabel: UILabel!
    @IBOutlet private var endDateLabel: UILabel!
    @IBOutlet private var strip: UIView!
    @IBOutlet private var buyButton: UIButton!
    
    private var event: PLEvent?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for view in contentView.subviews {
            if view !== strip {
                view.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    func updateWithEvent(event: PLEvent) {
        let placeholder = UIImage(named: "no_image_placeholder")
        nameLabel.text = event.name
        eventImageView.setImageSafely(fromURL: event.picture, placeholderImage: placeholder)
        eventDescriptionLabel.text = event.info
        startDateLabel.text = dateString(event.start)
        endDateLabel.text = dateString(event.end)
        buyButton.hidden = !event.available
        self.event = event
    }
    
    @IBAction func buyButtonClicked() {
        if let event = self.event {
            delegate?.eventCell(self, didClickBuyEvent: event)
        }
    }
    
    func dateString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(date)
    }
    
    func compressedLayoutSizeFittingMinimumSize(minSize: CGSize) -> CGSize {
        // update cell frame to min size
        var cellFrame = frame
        cellFrame.size = minSize
        frame = cellFrame
        
        // make layout and constrain resizing label by width
        setNeedsLayout()
        layoutIfNeeded()
        eventDescriptionLabel.preferredMaxLayoutWidth = eventDescriptionLabel.frame.width
        
        // extract new layout size
        var resultSize = minSize
        let newSize = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        let contentHeight = contentView.frame.height
        if contentHeight < newSize.height {
            resultSize.height = newSize.height
        }
        return resultSize
    }
}

extension PLEventCell : PLReusableCell {
    static func nibName() -> String {
        return "PLEventCell"
    }
    static func identifier() -> String {
        return "kPLEventCell"
    }
}
