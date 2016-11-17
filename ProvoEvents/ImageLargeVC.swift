//
//  ImageLargeVC.swift
//  ProvoEvents
//
//  Created by Chris Hovey on 9/22/16.
//  Copyright © 2016 Chris Hovey. All rights reserved.
//

import UIKit

class ImageLargeVC: GeneralVC, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var downloadImg: UIImageView!
    @IBOutlet weak var backImg: UIImageView!
    @IBOutlet var downloadImgButton: UIButton!
    @IBOutlet var backImgButton: UIButton!
    
    var img: UIImage!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        print("in img large")
        super.viewDidLoad()
        backImg.userInteractionEnabled = true

        scrollView.delegate = self
        imgView.image = img
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        
        bottomView.hidden = true
        setUpTargets()
        setUpTaps()
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //targets for bottom back and download button
    
    func setUpTargets(){
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdDown(_:)), forControlEvents: UIControlEvents.TouchDown)
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseOutside(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdDown(_:)), forControlEvents: UIControlEvents.TouchDown)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseOutside(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ImageLargeVC.swipePopBack))
        swipeDown.direction = .Down
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ImageLargeVC.swipePopBack))
        swipeUp.direction = .Up
        
        self.view.addGestureRecognizer(swipeDown)
        self.view.addGestureRecognizer(swipeUp)
    }
    
    func holdDown(sender: UIButton){
        sender.backgroundColor = UIColor.blackColor()
        sender.alpha = 0.3
    }
    
    func holdReleaseInside(sender: UIButton){
        sender.backgroundColor = UIColor.clearColor()
        if sender == downloadImgButton{
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            showCheckmark()
        } else if sender == backImgButton{
            if scrollView.zoomScale != scrollView.minimumZoomScale{
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
            handleSingleTap()
            performSelector(#selector(ImageLargeVC.swipePopBack), withObject: self, afterDelay: 0.5)
        }
    }
    
    func holdReleaseOutside(sender: UIButton){
        sender.backgroundColor = UIColor.clearColor()
    }
    
    func showCheckmark(){
        let checkmarkImgView = UIImageView(image: UIImage(named: "checkmark"))
        checkmarkImgView.showCheckmarkAnimatedTempImg(view)
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //sets up single tap to show bottom buttons or double for zoom
    
    func setUpTaps(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageLargeVC.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(ImageLargeVC.handleSingleTap))
        oneTap.requireGestureRecognizerToFail(doubleTap)
        scrollView.addGestureRecognizer(oneTap)
    }
    
    func handleSingleTap(){
        if self.bottomView.hidden == true{
            self.bottomView.hidden = false
            self.bottomView.center.y = self.bottomView.center.y + 52

            UIView.animateWithDuration(0.2, animations: {
                self.bottomView.center.y = self.bottomView.center.y - 52
            })
        } else{
            UIView.animateWithDuration(0.2, animations: {
                self.bottomView.center.y = self.bottomView.center.y + 52
                }, completion: { (true) in
                    self.bottomView.hidden = true
                    self.bottomView.center.y = self.bottomView.center.y - 52
            })
        }
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer){
        if (scrollView.zoomScale > scrollView.minimumZoomScale){
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            
        }else{
            let zoomRect = self.zoomRectForScale(scrollView.maximumZoomScale/2, center: recognizer.locationInView(recognizer.view))
            self.scrollView.zoomToRect(zoomRect, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect{
        var zoomRect = CGRectZero
        if let imageV = self.imgView{
            zoomRect.size.height = imageV.frame.size.height / scale;
            zoomRect.size.width  = imageV.frame.size.width  / scale;
            let newCenter = imageV.convertPoint(center, fromView: self.scrollView)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        }
        return zoomRect
    }
    
    override func swipePopBack() {
        self.navigationController?.popViewControllerAnimated(false)
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
}
