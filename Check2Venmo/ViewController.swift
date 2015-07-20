//
//  ViewController.swift
//  Check2Venmo
//
//  Created by Joseph Lin on 11/26/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TesseractDelegate  {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratioConstraint: NSLayoutConstraint!
    var buttons: [UIButton] = [];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateVenmoStatus()

        // Black & white source image
        let bwImage = UIImage(named: "IMG_5684")!.blackAndWhite();
        let imageSize = bwImage.size;
        self.imageView.image = bwImage;
        
        // Fit imageView to image
        self.imageView.removeConstraint(self.ratioConstraint);
        self.ratioConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.imageView, attribute: NSLayoutAttribute.Height, multiplier: imageSize.width / imageSize.height, constant: 0);
        self.imageView.addConstraint(self.ratioConstraint);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        // Run Tesseract
        var tesseract:Tesseract = Tesseract();
        tesseract.language = "eng";
        tesseract.delegate = self;
        tesseract.image = self.imageView.image;
        tesseract.recognize();
        NSLog("%@", tesseract.recognizedText);
        
        // Setup regex
        var error: NSError?
        let regex = NSRegularExpression(pattern: "[0-9]+[.][0-9]{2}", options: nil, error: &error);

        // Setup constants
        let ratio = self.imageView.frame.size.width / self.imageView.image!.size.width;
        let x = self.imageView.frame.origin.x;
        let y = self.imageView.frame.origin.y;
        let width = self.imageView.frame.size.width;
        let height = self.imageView.frame.size.height;

        // Parse words and draw bounding boxes
        for object in tesseract.getConfidenceByWord {
            
            let dict = object as! [String : AnyObject];
            let text = dict["text"] as! String;
            let range = regex?.rangeOfFirstMatchInString(text, options: nil, range: NSMakeRange(0, count(text)));
            
            if (range?.location != NSNotFound) {
            
                NSLog("%@", dict);
                let number = (text as NSString).substringWithRange(range!);
                NSLog("%@", number);

                let box = (dict["boundingbox"] as! NSValue).CGRectValue();
                let convertedBox = CGRect(
                    x: x + box.origin.x * ratio,
                    y: y + height - (box.origin.y + box.size.height) * ratio,
                    width: box.size.width * ratio,
                    height: box.size.height * ratio
                );
                
                let button = UIButton(frame: convertedBox);
                button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside);
                button.backgroundColor = UIColor.greenColor();
                button.titleLabel?.font = UIFont.systemFontOfSize(16.0);
                button.titleLabel?.adjustsFontSizeToFitWidth = true;
                button.setTitle(number, forState: UIControlState.Normal);
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
                button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted);
                self.containerView.addSubview(button);
                self.buttons.append(button);
            }
        }
    }
    
    func updateVenmoStatus() {
        if (Venmo.sharedInstance().isSessionValid() == true) {
            let username = Venmo.sharedInstance().session.user.displayName;
            let leftItem = UIBarButtonItem(title: username, style: UIBarButtonItemStyle.Bordered, target: self, action: "logout");
            self.navigationItem.setLeftBarButtonItem(leftItem, animated: true);
        }
        else {
            let leftItem = UIBarButtonItem(title: "Log in", style: UIBarButtonItemStyle.Bordered, target: self, action: "login");
            self.navigationItem.setLeftBarButtonItem(leftItem, animated: true);
        }
    }
    
    func login() {
        Venmo.sharedInstance().requestPermissions(["access_profile", "make_payments"], withCompletionHandler: { (success, error) -> Void in
            if (success) {
                self.updateVenmoStatus()
            }
            else {
                UIAlertView(title: "Authorization failed", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "OK").show();
            }
        });
    }

    func logout() {
        Venmo.sharedInstance().logout();
    }
    
    func buttonTapped(sender: UIButton) {
        self.performSegueWithIdentifier("Payment", sender: sender);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! PaymentViewController;
        let text = (sender as! UIButton).titleForState(UIControlState.Normal)!;
        controller.amount = (text as NSString).doubleValue;
    }
    
    func progressImageRecognitionForTesseract(tesseract: Tesseract!) {
//        NSLog("%@", String(tesseract.progress));
    }
    
    
    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
        // return true, if you need to interrupt tesseract before it finishes
        return false;
    }
}

