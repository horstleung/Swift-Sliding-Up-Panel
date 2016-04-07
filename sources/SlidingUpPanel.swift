//
//  SlidingUpPanel.swift
//  SlidingUpPanel
//
//  Created by Horst Leung on 1/4/2016.
//  Copyright © 2016 Horst Leung. All rights reserved.
//

import UIKit

protocol SlidingUpPanelDelegate {
    func willOpen()
    func didOpen()
    func willHalfOpen()
    func didHalfOpen()
    func willClose()
    func didClose()
}

class SlidingUpPanel: UIView {
    enum SlidingState {
        case closed;
        case halfOpened;
        case opened;
    }
    
    //MARK: Variables
    var delegate: SlidingUpPanelDelegate?;
    var state:SlidingState = .closed;
    var topView: UIView?;
    var topViewHeight: CGFloat {
        get {
            return self.topView?.frame.height ?? 0
        }
    };
    var tooltipHeight: CGFloat {
        get {
            return self.tooltip?.frame.height ?? 0
        }
    };
    var animationDuration = 0.2;
    var threshold: CGFloat = 30.0;
    var lastLocation:CGPoint = CGPointMake(0, 0)
    var toolTipLastLocation:CGPoint? = CGPointMake(0, 0)
    var tooltip: UIView?
    
    //MARK: Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.userInteractionEnabled = true;
        let tap = UITapGestureRecognizer(target: self, action: #selector(SlidingUpPanel.togglePanel));
        self.addGestureRecognizer(tap);
        
        let pan = UIPanGestureRecognizer(target:self, action:#selector(SlidingUpPanel.detectPan(_:)))
        self.addGestureRecognizer(pan);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview();
        setup()
    }
    
    //MARK: Private functions
    func setup()
    {
        self.state = .closed;
        if let tv = topView {
            var f = tv.frame
            f.origin.y = 0;
            tv.frame = f;
            self.addSubview(tv)
        }
        
        if let parent = superview {
            
            frame.origin.y = parent.bounds.height - tooltipHeight;
            if let tooltipView = tooltip {
                var tFrame = frame
                tFrame.size = tooltipView.frame.size
                tFrame.origin.y = 0
                tooltipView.frame = tFrame
                self.addSubview(tooltipView)
                
            }
        }
        
        if let tooltipView = tooltip {
            tooltipView.userInteractionEnabled = true;
            tooltipView.exclusiveTouch = false;
        }
    }
    
    func moveToNearestState(shouldMove shouldMove: Bool) {
        if let parent = superview {
            let parentY = parent.frame.height
            let y = self.frame.minY
            if shouldMove {
                switch state {
                case .closed:
                    if y < parentY / 2.0 {
                        self.open()
                    } else {
                        self.halfOpen()
                    }
                    break;
                case .halfOpened:
                    if y < parentY / 2.0 {
                        self.open()
                    } else {
                        self.close()
                    }
                    break;
                case .opened:
                    if y < parentY / 2.0 {
                        self.halfOpen()
                    } else {
                        self.close()
                    }
                    break;
                }
            } else {
                //earth to earth, dust to dust
                switch state {
                case .closed:
                    self.close()
                    break;
                case .halfOpened:
                    self.halfOpen()
                    break;
                case .opened:
                    self.open();
                    break;
                }
            }

        }
    }
    
    //MARK: Public functions
    func togglePanel()
    {
        switch self.state {
        case .closed:
            self.halfOpen();
            break;
        case .halfOpened:
            self.open();
            break;
        default:
            self.close();
            break;
        }
    }
    
    func open() {
        self.delegate?.willOpen()
        UIView.animateWithDuration(self.animationDuration, animations: { 
            if let parent = self.superview {
                self.frame.origin.y = parent.bounds.height - self.frame.height;
                self.tooltip?.frame.origin.y = (self.frame.height - self.tooltipHeight) * 2;
            }
        }) { (_) in
            self.state = .opened
            self.delegate?.didOpen()
        }
        
    }
    
    func halfOpen() {
        self.delegate?.willHalfOpen()
        UIView.animateWithDuration(self.animationDuration, animations: {
            if let parent = self.superview {
                self.frame.origin.y = parent.bounds.height / 2.0;
                self.tooltip?.frame.origin.y = self.frame.height - self.tooltipHeight * 2 ;
            }
        }) { (_) in
            self.state = .halfOpened
            self.delegate?.didHalfOpen()
        }

    }

    
    func close() {
        self.delegate?.willClose()
        UIView.animateWithDuration(self.animationDuration, animations: {
            if let parent = self.superview {
                self.frame.origin.y = parent.bounds.height - self.tooltipHeight;
                self.tooltip?.frame.origin.y = 0;
            }
        }) { (_) in
            self.state = .closed
            self.delegate?.didClose()
        }
    }
    
    //MARK: Interactions
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        //check if user touching on the top bar
        
        let barFrame = CGRectMake(0,0,self.frame.width,self.tooltipHeight)
        return CGRectContainsPoint(barFrame, point)
    }
    
    func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translationInView(self.superview!)
        self.center = CGPointMake(lastLocation.x, lastLocation.y + translation.y)
        if let tooltipView = tooltip , loc = toolTipLastLocation{
            tooltipView.center = CGPointMake(loc.x, loc.y - 2*translation.y)
            if tooltipView.frame.minY < 0 {
                tooltipView.frame.origin.y = 0;
            }
            
            if tooltipView.frame.maxY > self.frame.maxY + tooltipView.frame.height{
                tooltipView.frame.origin.y = self.frame.maxY + tooltipView.frame.height;
            }
        }
        if(recognizer.state == UIGestureRecognizerState.Ended)
        {
            //All fingers are lifted.
            let shouldMove = (translation.y >= self.threshold) || (translation.y <= 0 - self.threshold)
            self.moveToNearestState(shouldMove: shouldMove);
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.superview?.bringSubviewToFront(self)
        
        lastLocation = self.center
        toolTipLastLocation = tooltip?.center
    }

}
