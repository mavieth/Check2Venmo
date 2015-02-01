//
//  ViewController.swift
//  Check2Venmo
//
//  Created by Joseph Lin on 11/26/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TesseractDelegate  {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratioConstraint: NSLayoutConstraint!
    let shapeLayer = CAShapeLayer();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Black & white source image
        let bwImage = UIImage(named: "IMG_5684")!.blackAndWhite();
        let imageSize = bwImage.size;
        self.imageView.image = bwImage;
        
        // Fit imageView to image
        self.imageView.removeConstraint(self.ratioConstraint);
        self.ratioConstraint = NSLayoutConstraint(item: self.imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.imageView, attribute: NSLayoutAttribute.Height, multiplier: imageSize.width / imageSize.height, constant: 0);
        self.imageView.addConstraint(self.ratioConstraint);
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        // Fit shapeLayer to imageView
        self.shapeLayer.strokeColor = UIColor.redColor().CGColor;
        self.shapeLayer.fillColor = UIColor.yellowColor().colorWithAlphaComponent(0.2).CGColor;
        self.shapeLayer.frame = self.imageView.bounds;
        self.imageView.layer.addSublayer(self.shapeLayer);
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

        // Parse words and draw bounding boxes
        let path = UIBezierPath();
        let ratio = self.imageView.frame.size.width / self.imageView.image!.size.width;
        let y = self.imageView.frame.origin.y;
        let height = self.imageView.frame.size.height;

        for object in tesseract.getConfidenceByWord {
            
            let dict = object as [String : AnyObject];
            let text = dict["text"] as String;
            let range = regex?.rangeOfFirstMatchInString(text, options: nil, range: NSMakeRange(0, countElements(text)));
            
            if (range?.location != NSNotFound) {
            
                NSLog("%@", dict);
                
                let string = (text as NSString).substringWithRange(range!);
                NSLog("%@", string);

                let box = (dict["boundingbox"] as NSValue).CGRectValue();
                let confidence = dict["confidence"] as Double;
                let convertedBox = CGRect(x: box.origin.x * ratio, y: height - (box.origin.y + box.size.height) * ratio, width: box.size.width * ratio, height: box.size.height * ratio)
                let boxPath = UIBezierPath(rect: convertedBox);
                path.appendPath(boxPath);
            }
        }

        self.shapeLayer.path = path.CGPath;
    }
    
    
    func progressImageRecognitionForTesseract(tesseract: Tesseract!) {
//        NSLog("%@", String(tesseract.progress));
    }
    
    
    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
        // return true, if you need to interrupt tesseract before it finishes
        return false;
    }
}

