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
        
        super.viewDidLoad()
        scrollView.delegate = self
        imgView.image = img
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        
        bottomView.hidden = true
        bottomView.alpha = 0
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageLargeVC.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(ImageLargeVC.handleSingleTap))
        oneTap.requireGestureRecognizerToFail(doubleTap)
        scrollView.addGestureRecognizer(oneTap)
        
        
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdDown(_:)), forControlEvents: UIControlEvents.TouchDown)
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseOutside(_:)), forControlEvents: UIControlEvents.TouchUpOutside)

        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdDown(_:)), forControlEvents: UIControlEvents.TouchDown)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseOutside(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func holdReleaseOutside(sender: UIButton){
        sender.backgroundColor = UIColor.clearColor()
    }
    
    func showCheckmark(){
        var checkmarkImgView = UIImageView(image: UIImage(named: "checkmark"))
        checkmarkImgView.frame = CGRectMake(0, 0, 150, 150)
        checkmarkImgView.contentMode = .ScaleAspectFit
        checkmarkImgView.center = view.center
        checkmarkImgView.center.y = checkmarkImgView.center.y + 50
        view.addSubview(checkmarkImgView)
        view.bringSubviewToFront(checkmarkImgView)
        checkmarkImgView.alpha = 0
        
        UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 2.0, initialSpringVelocity: 3.0, options: .CurveEaseIn, animations: { 
            checkmarkImgView.alpha = 1
            checkmarkImgView.center.y = checkmarkImgView.center.y - 75
            }) { (true) in
                UIView.animateWithDuration(0.3, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: { 
                    checkmarkImgView.alpha = 0
                    }, completion: { (true) in
                        checkmarkImgView.removeFromSuperview()
                })
        }
    }
    
    
    
    
    func handleSingleTap(){
        if self.bottomView.hidden == true{
            UIView.animateWithDuration(0.5) {
                self.bottomView.hidden = false
                self.bottomView.alpha = 1
            }
        } else{
            UIView.animateWithDuration(0.5, animations: { 
                self.bottomView.alpha = 0
                }, completion: { (true) in
                    self.bottomView.hidden = true
            })
        }
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer){
        print(" recognizer view : \(recognizer.locationInView(recognizer.view))")
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

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }

}
