//
//  ViewController.swift
//  SlidingUpPanel
//
//  Created by Horst Leung on 1/4/2016.
//  Copyright © 2016 Horst Leung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var panel:SlidingUpPanel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        panel = SlidingUpPanel(frame: self.view.bounds);
        
        panel.backgroundColor = UIColor.darkGrayColor()
        var frame = self.view.bounds
        frame.size.height = 80.0
        let bar = UIView(frame: frame);
        bar.backgroundColor = UIColor.redColor()
        panel.topView = bar;
        
        let tooltip = UIView(frame: frame);
        tooltip.backgroundColor = UIColor.lightGrayColor()
        panel.tooltip = tooltip
        
        
        self.view.addSubview(panel)
    }
}

