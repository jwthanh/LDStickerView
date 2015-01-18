//
//  LDStickerView.swift
//  LDStickerView
//
//  Created by Vũ Trung Thành on 1/18/15.
//  Copyright (c) 2015 V2T Multimedia. All rights reserved.
//

import UIKit

@objc protocol LDStickerViewDelegate{
    optional func stickerViewDidBeginEditing(sticker:LDStickerView)
    optional func stickerViewDidChangeEditing(sticker:LDStickerView)
    optional func stickerViewDidEndEditing(sticker:LDStickerView)
    optional func stickerViewDidClose(sticker:LDStickerView)
    optional func stickerViewDidShowEditingHandles(sticker:LDStickerView)
    optional func stickerViewDidHideEditingHandles(sticker:LDStickerView)
}
class LDStickerView: UIView, UIGestureRecognizerDelegate, LDStickerViewDelegate {
    private var _globalInset: CGFloat!
    
    private var _initialBounds: CGRect!
    private var _initialDistance: CGFloat!
    
    private var _beginningPoint: CGPoint!
    private var _beginningCenter: CGPoint!
    
    private var _prevPoint: CGPoint!
    private var _touchLocation: CGPoint!
    
    private var _deltaAngle: CGFloat!
    
    private var _startTransform: CGAffineTransform!
    private var _beginBounds: CGRect!
    
    private var _resizeView: UIImageView!
    private var _rotateView: UIImageView!
    private var _closeView: UIImageView!
    private var _isShowingEditingHandles: Bool!
    private var _contentView: UIView!
    private var _delegate: LDStickerViewDelegate?
    private var _showContentShadow: Bool! //Default is YES.
    private var _showCloseView: Bool! //Default is YES. If set to NO, user can't delete the view
    private var _showResizeView: Bool! //Default is YES. If set to NO, user can't resize the view
    private var _showRotateView: Bool! //Default is YES. If set to NO, user can't rotate the view
    
    private var lastTouchedView: LDStickerView!
    
    func refresh(){
        if (superview != nil)
        {
            var scale: CGSize  = CGAffineTransformGetScale(transform)
            var t: CGAffineTransform = CGAffineTransformMakeScale(scale.width, scale.height)
            _closeView.transform = CGAffineTransformInvert(t)
            _resizeView.transform = CGAffineTransformInvert(t)
            _rotateView.transform = CGAffineTransformInvert(t)
            if ((_isShowingEditingHandles) != false){
                _contentView.layer.borderWidth = 1/scale.width
            } else {
                _contentView.layer.borderWidth = 0.0
            }
        }
    }
    
    override func didMoveToSuperview(){
        super.didMoveToSuperview()
        refresh()
    }
    
    override init(frame: CGRect) {
        /*(1+_globalInset*2)*/
        if (frame.size.width < (1+12*2)) {
            //frame.size.width = 25
            //frame = CGRectMake(frame.origin.x, frame.origin.y, 25, frame.size.height)
        }
        if (frame.size.height < (1+12*2)){
            //frame.size.height = 25
            
        }
        
        super.init(frame: frame)
        
        _globalInset = 12;
        
        backgroundColor = UIColor.clearColor()
        
        //Close button view which is in top left corner
        _closeView = UIImageView(frame: CGRectMake(bounds.size.width - _globalInset*2, 0, _globalInset*2, _globalInset*2))
        _closeView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin
        _closeView.backgroundColor = UIColor.clearColor()
        _closeView.image = UIImage(named: "icon_delete")
        _closeView.userInteractionEnabled = true
        addSubview(_closeView)
        
        //Rotating view which is in bottom left corner
        _rotateView = UIImageView(frame: CGRectMake(bounds.size.width - _globalInset*2, bounds.size.height - _globalInset*2, _globalInset*2, _globalInset*2))
        _rotateView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin
        _rotateView.backgroundColor = UIColor.clearColor()
        _rotateView.image = UIImage(named: "icon_rotate")
        _rotateView.userInteractionEnabled = true
        addSubview(_rotateView)
        
        //Resizing view which is in bottom right corner
        _resizeView = UIImageView(frame: CGRectMake(0, bounds.size.height - _globalInset*2, _globalInset*2, _globalInset*2))
        _resizeView.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleTopMargin
        _resizeView.backgroundColor = UIColor.clearColor()
        _resizeView.userInteractionEnabled = true
        _resizeView.image = UIImage(named: "icon_scale")
        addSubview(_resizeView)
        
        var moveGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("moveGesture:"))
        moveGesture.minimumPressDuration = 0.1
        addGestureRecognizer(moveGesture)
        
        var singleTapShowHide:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("contentTapped:"))
        addGestureRecognizer(singleTapShowHide)
        
        var singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("singleTap:"))
        _closeView.addGestureRecognizer(singleTap)
        
        var panResizeGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("resizeTranslate:"))
        
        panResizeGesture.minimumPressDuration = 0
        _resizeView.addGestureRecognizer(panResizeGesture)
        
        var panRotateGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("rotateViewPanGesture:"))
        
        panRotateGesture.minimumPressDuration = 0
        _rotateView.addGestureRecognizer(panRotateGesture)
        
        moveGesture.requireGestureRecognizerToFail(singleTap)
        
        setEnableClose(true)
        setEnableResize(true)
        setEnableRotate(true)
        setShowContentShadow(false)
        
        hideEditingHandles()
        
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func contentTapped(tapGesture:UITapGestureRecognizer){
        if ((_isShowingEditingHandles) != false){
            hideEditingHandles()
            superview?.bringSubviewToFront(self)
        } else {
            showEditingHandles()
        }
    }
    
    func setEnableClose(enableClose:Bool){
        _showCloseView = enableClose;
        _closeView.hidden = !_showCloseView
        _closeView.userInteractionEnabled = _showCloseView
    }
    
    func setEnableResize(enableResize:Bool){
        _showResizeView = enableResize;
        _resizeView.hidden = !_showResizeView
        _resizeView.userInteractionEnabled = _showResizeView
    }
    
    func setEnableRotate(enableRotate:Bool){
        _showRotateView = enableRotate;
        _rotateView.hidden = !_showRotateView
        _rotateView.userInteractionEnabled = _showRotateView
    }
    
    func setShowContentShadow(enableContentShadow:Bool){
        _showContentShadow = enableContentShadow;
        
        if ((_showContentShadow) != false){
            layer.shadowColor = UIColor.blackColor().CGColor
            layer.shadowOffset = CGSizeMake(0, 5)
            layer.shadowOpacity = 1.0
            layer.shadowRadius = 4.0
        } else {
            layer.shadowColor = UIColor.clearColor().CGColor
            layer.shadowOffset = CGSizeZero
            layer.shadowOpacity = 0.0
            layer.shadowRadius = 0.0
        }
    }
    
    func hideEditingHandles(){
        lastTouchedView = nil;
        
        _isShowingEditingHandles = false;
        if(_showCloseView != false){
            _closeView.hidden = true
        }
        if(_showResizeView != false){
            _resizeView.hidden = true
        }
        if(_showRotateView != false){
            _rotateView.hidden = true
        }
        
        refresh()
        
        _delegate?.stickerViewDidHideEditingHandles!(self)
        
    }
    
    func showEditingHandles(){
        if (lastTouchedView != nil){
            lastTouchedView.hideEditingHandles()
        }
        _isShowingEditingHandles = true;
        
        lastTouchedView = self;
        if(_showCloseView != false){
            _closeView.hidden = false
        }
        if(_showResizeView != false){
            _resizeView.hidden = false
        }
        if(_showRotateView != false){
            _rotateView.hidden = false
        }
        refresh()
        
        _delegate?.stickerViewDidShowEditingHandles!(self)
    }
    
    func setContentView(contentView: UIView){
        if _contentView != nil {
            _contentView.removeFromSuperview()
        }
        _contentView = contentView
        _contentView.frame = CGRectInset(self.bounds, _globalInset, _globalInset);
        _contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        _contentView.backgroundColor = UIColor.clearColor()
        _contentView.layer.borderColor = UIColor.grayColor().CGColor
        _contentView.layer.borderWidth = 1.0;
        insertSubview(_contentView, atIndex: 0)
    }
    
    func singleTap(recognizer: UITapGestureRecognizer){
        removeFromSuperview()
        if respondsToSelector(Selector("stickerViewDidClose:")){
            _delegate?.stickerViewDidClose!(self)
        }
    }
    func moveGesture(recognizer: UIPanGestureRecognizer){
        _touchLocation = recognizer.locationInView(superview)
        if(recognizer.state == UIGestureRecognizerState.Began){
            
            _beginningPoint = _touchLocation
            _beginningCenter = center
            center = CGPointMake(_beginningCenter.x + (_touchLocation.x - _beginningPoint.x), _beginningCenter.y + (_touchLocation.y - _beginningPoint.y))
            
            _beginBounds = self.bounds
            
            if respondsToSelector("stickerViewDidBeginEditing:"){
                _delegate?.stickerViewDidBeginEditing!(self)
            }
        } else if (recognizer.state == UIGestureRecognizerState.Changed){
            center = CGPointMake(_beginningCenter.x+(_touchLocation.x-_beginningPoint.x), _beginningCenter.y+(_touchLocation.y-_beginningPoint.y))
            if respondsToSelector("stickerViewDidChangeEditing:"){
                _delegate?.stickerViewDidChangeEditing!(self)
            }
        } else if (recognizer.state == UIGestureRecognizerState.Ended){
            center = CGPointMake(_beginningCenter.x+(_touchLocation.x-_beginningPoint.x), _beginningCenter.y+(_touchLocation.y-_beginningPoint.y))
            if respondsToSelector("stickerViewDidEndEditing:"){
                _prevPoint = _touchLocation
            }
        }
        
        _prevPoint = _touchLocation;
    }
    
    func resizeTranslate(recognizer: UIPanGestureRecognizer){
        _touchLocation = recognizer.locationInView(superview)
        //Reforming touch location to it's Identity transform.
        _touchLocation = CGPointRorate(_touchLocation, basePoint: CGRectGetCenter(frame),angle: -CGAffineTransformGetAngle(transform))
        if (recognizer.state == UIGestureRecognizerState.Began){
            if respondsToSelector("stickerViewDidBeginEditing:"){
                _delegate?.stickerViewDidBeginEditing!(self)
            }
        } else if (recognizer.state == UIGestureRecognizerState.Changed){
            var wChange: CGFloat = (_prevPoint.x - _touchLocation.x); //Slow down increment
            var hChange: CGFloat = (_touchLocation.y - _prevPoint.y); //Slow down increment
            var t: CGAffineTransform = transform
            transform = CGAffineTransformIdentity
            var scaleRect:CGRect = CGRectMake(frame.origin.x, frame.origin.y, max(frame.size.width + (wChange*2), 1 + _globalInset*2), max(frame.size.height + (hChange*2), 1 + _globalInset*2))
            /*var scaleRect:CGRect
            if (frame.size.width >= frame.size.height){
            scaleRect = CGRectMake(frame.origin.x, frame.origin.y, max(frame.size.width + (hChange*2), 1 + _globalInset*2), max(frame.size.height + (hChange*2), 1 + _globalInset*2))
            } else {
            scaleRect = CGRectMake(frame.origin.x, frame.origin.y, max(frame.size.width + (wChange*2), 1 + _globalInset*2), max(frame.size.height + (wChange*2), 1 + _globalInset*2))
            }*/
            scaleRect = CGRectSetCenter(scaleRect, center: center)
            frame = scaleRect
            transform = t
            if respondsToSelector(Selector("stickerViewDidChangeEditing:")) {
                _delegate?.stickerViewDidChangeEditing!(self)
            }
        }else if (recognizer.state == UIGestureRecognizerState.Ended){
            if respondsToSelector(Selector("stickerViewDidEndEditing:")){
                _delegate?.stickerViewDidEndEditing!(self)
            }
        }
        _prevPoint = _touchLocation;
    }
    
    func rotateViewPanGesture(recognizer: UIPanGestureRecognizer){
        _touchLocation =  recognizer.locationInView(superview)
        
        var c: CGPoint = CGRectGetCenter(frame);
        if (recognizer.state == UIGestureRecognizerState.Began){
            _deltaAngle = atan2(_touchLocation.y - c.y, _touchLocation.x - c.x) - CGAffineTransformGetAngle(transform)
            
            _initialBounds = bounds;
            _initialDistance = CGPointGetDistance(c, point2: _touchLocation);
            if (respondsToSelector("stickerViewDidBeginEditing:")){
                _delegate?.stickerViewDidBeginEditing!(self)
            }
        } else if (recognizer.state == UIGestureRecognizerState.Changed){
            var ang:CGFloat = atan2(_touchLocation.y - c.y, _touchLocation.x - c.x)
            var angleDiff:CGFloat = _deltaAngle - ang
            transform = CGAffineTransformMakeRotation(-angleDiff)
            setNeedsDisplay()
            var scale: CGFloat = sqrt(CGPointGetDistance(c, point2: _touchLocation) / _initialDistance)
            var scaleRect: CGRect = CGRectScale(_initialBounds, wScale: scale, hScale: scale);
            if (scaleRect.size.width >= (1 + _globalInset*2) && scaleRect.size.height >= (1 + _globalInset*2)){
                bounds = scaleRect
            }
            if respondsToSelector(Selector("stickerViewDidChangeEditing:")) {
                _delegate?.stickerViewDidChangeEditing!(self)
            }
        } else if (recognizer.state == UIGestureRecognizerState.Ended){
            if respondsToSelector(Selector("stickerViewDidEndEditing:")){
                _delegate?.stickerViewDidEndEditing!(self)
            }
        }
    }
    
    
    private func CGRectGetCenter(rect:CGRect) -> CGPoint{
        return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
    }
    private func CGPointRorate(point: CGPoint, basePoint: CGPoint, angle: CGFloat) -> CGPoint{
        var x: CGFloat = cos(angle) * (point.x-basePoint.x) - sin(angle) * (point.y-basePoint.y) + basePoint.x;
        var y: CGFloat = sin(angle) * (point.x-basePoint.x) + cos(angle) * (point.y-basePoint.y) + basePoint.y;
        
        return CGPointMake(x,y);
    }
    
    private func CGRectSetCenter(rect: CGRect, center: CGPoint) -> CGRect{
        return CGRectMake(center.x-CGRectGetWidth(rect)/2, center.y-CGRectGetHeight(rect)/2, CGRectGetWidth(rect), CGRectGetHeight(rect));
    }
    
    private func CGRectScale(rect: CGRect, wScale: CGFloat, hScale: CGFloat) -> CGRect{
        return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
    }
    
    private func CGPointGetDistance(point1: CGPoint, point2: CGPoint) -> CGFloat{
        var fx: CGFloat = (point2.x - point1.x);
        var fy: CGFloat = (point2.y - point1.y);
        
        return sqrt((fx*fx + fy*fy));
    }
    
    private func CGAffineTransformGetAngle(t:CGAffineTransform) -> CGFloat{
        return atan2(t.b, t.a);
    }
    
    
    private func CGAffineTransformGetScale(t:CGAffineTransform) -> CGSize{
        return CGSizeMake(sqrt(t.a * t.a + t.c * t.c), sqrt(t.b * t.b + t.d * t.d)) ;
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}