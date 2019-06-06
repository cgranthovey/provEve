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
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        print("in img large")
        super.viewDidLoad()
        backImg.isUserInteractionEnabled = true

        scrollView.delegate = self
        imgView.image = img
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        
        bottomView.isHidden = true
        setUpTargets()
        setUpTaps()
    }
    
    //////////////////////////////////////////////////////
    //////////////////////////////////////////////////////
    //targets for bottom back and download button
    
    func setUpTargets(){
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdDown(_:)), for: UIControl.Event.touchDown)
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseInside(_:)), for: UIControl.Event.touchUpInside)
        downloadImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseOutside(_:)), for: UIControl.Event.touchUpOutside)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdDown(_:)), for: UIControl.Event.touchDown)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseOutside(_:)), for: UIControl.Event.touchUpOutside)
        backImgButton.addTarget(self, action: #selector(ImageLargeVC.holdReleaseInside(_:)), for: UIControl.Event.touchUpInside)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ImageLargeVC.swipePopBack))
        swipeDown.direction = .down
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ImageLargeVC.swipePopBack))
        swipeUp.direction = .up
        
        self.view.addGestureRecognizer(swipeDown)
        self.view.addGestureRecognizer(swipeUp)
    }
    
    @objc func holdDown(_ sender: UIButton){
        sender.backgroundColor = UIColor.black
        sender.alpha = 0.3
    }
    
    @objc func holdReleaseInside(_ sender: UIButton){
        sender.backgroundColor = UIColor.clear
        if sender == downloadImgButton{
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            showCheckmark()
        } else if sender == backImgButton{
            if scrollView.zoomScale != scrollView.minimumZoomScale{
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            }
            handleSingleTap()
            perform(#selector(ImageLargeVC.swipePopBack), with: self, afterDelay: 0.5)
        }
    }
    
    @objc func holdReleaseOutside(_ sender: UIButton){
        sender.backgroundColor = UIColor.clear
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
        oneTap.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(oneTap)
    }
    
    @objc func handleSingleTap(){
        if self.bottomView.isHidden == true{
            self.bottomView.isHidden = false
            self.bottomView.center.y = self.bottomView.center.y + 52

            UIView.animate(withDuration: 0.2, animations: {
                self.bottomView.center.y = self.bottomView.center.y - 52
            })
        } else{
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomView.center.y = self.bottomView.center.y + 52
                }, completion: { (true) in
                    self.bottomView.isHidden = true
                    self.bottomView.center.y = self.bottomView.center.y - 52
            })
        }
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer){
        if (scrollView.zoomScale > scrollView.minimumZoomScale){
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            
        }else{
            let zoomRect = self.zoomRectForScale(scrollView.maximumZoomScale/2, center: recognizer.location(in: recognizer.view))
            self.scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect{
        var zoomRect = CGRect.zero
        if let imageV = self.imgView{
            zoomRect.size.height = imageV.frame.size.height / scale;
            zoomRect.size.width  = imageV.frame.size.width  / scale;
            let newCenter = imageV.convert(center, from: self.scrollView)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        }
        return zoomRect
    }
    
    @objc override func swipePopBack() {
        _ = self.navigationController?.popViewController(animated: false)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
}
