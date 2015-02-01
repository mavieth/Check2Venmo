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
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bwImage = UIImage(named: "IMG_5684")?.blackAndWhite();
        self.imageView.image = bwImage;

        var tesseract:Tesseract = Tesseract();
        tesseract.language = "eng";
        tesseract.delegate = self;
//        tesseract.setVariableValue("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", forKey: "tessedit_char_whitelist");
        tesseract.image = bwImage;
        tesseract.recognize();
        
        
        for object in tesseract.getConfidenceByWord {
            let dict = object as [String : AnyObject];
            NSLog("%@", dict);
            
            let boundingbox = (dict["boundingbox"] as NSValue).CGRectValue();
            let confidence = dict["confidence"] as Double;
            let text = dict["text"] as String;
        }

        
        let nsstring = NSString(string: tesseract.recognizedText);
        self.textView.text = nsstring;

        var error: NSError?
        let regex = NSRegularExpression(pattern: "[0-9]+[.][0-9]{2}", options: nil, error: &error);
        regex?.enumerateMatchesInString(tesseract.recognizedText, options: nil, range: NSMakeRange(0, countElements(tesseract.recognizedText)), usingBlock: { (match, flags, stop) -> Void in
            let string = nsstring.substringWithRange(match.range);
            NSLog("%@", string);
        })
    }
    
    func progressImageRecognitionForTesseract(tesseract: Tesseract!) {
        self.textView.text = String(tesseract.progress);
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: Tesseract!) -> Bool {
        return false; // return true, if you need to interrupt tesseract before it finishes
    }

}

