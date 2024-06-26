//
//  PopupView.swift
//  FIDSDK
//
//  Created by Nguyen Thanh Bình on 16/08/2021.
//

import UIKit

public class PopupView: UIView {
    public struct ShowType: OptionSet {
        public let rawValue: Int
        
        public static let none = ShowType(rawValue: 1 << 0)
        public static let fadeIn = ShowType(rawValue: 1 << 1)
        public static let growIn = ShowType(rawValue: 1 << 2)
        public static let shrinkIn = ShowType(rawValue: 1 << 3)
        public static let slideInFromTop = ShowType(rawValue: 1 << 4)
        public static let slideInFromBottom = ShowType(rawValue: 1 << 5)
        public static let slideInFromLeft = ShowType(rawValue: 1 << 6)
        public static let slideInFromRight = ShowType(rawValue: 1 << 7)
        public static let bounceIn = ShowType(rawValue: 1 << 8)
        public static let bounceInFromTop = ShowType(rawValue: 1 << 9)
        public static let bounceInFromBottom = ShowType(rawValue: 1 << 10)
        public static let bounceInFromLeft = ShowType(rawValue: 1 << 11)
        public static let bounceInFromRight = ShowType(rawValue: 1 << 12)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct DismissType: OptionSet {
        public let rawValue: Int
        
        public static let none = DismissType(rawValue: 1 << 0)
        public static let fadeOut = DismissType(rawValue: 1 << 1)
        public static let growOut = DismissType(rawValue: 1 << 2)
        public static let shrinkOut = DismissType(rawValue: 1 << 3)
        public static let slideOutToTop = DismissType(rawValue: 1 << 4)
        public static let slideOutToBottom = DismissType(rawValue: 1 << 5)
        public static let slideOutToLeft = DismissType(rawValue: 1 << 6)
        public static let slideOutToRight = DismissType(rawValue: 1 << 7)
        public static let bounceOut = DismissType(rawValue: 1 << 8)
        public static let bounceOutToTop = DismissType(rawValue: 1 << 9)
        public static let bounceOutToBottom = DismissType(rawValue: 1 << 10)
        public static let bounceOutToLeft = DismissType(rawValue: 1 << 11)
        public static let bounceOutToRight = DismissType(rawValue: 1 << 12)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct HorizontalLayout: OptionSet {
        public let rawValue: Int
        
        public static let custom = HorizontalLayout(rawValue: 1 << 0)
        public static let left = HorizontalLayout(rawValue: 1 << 1)
        public static let leftOfCenter = HorizontalLayout(rawValue: 1 << 2)
        public static let center = HorizontalLayout(rawValue: 1 << 3)
        public static let rightOfCenter = HorizontalLayout(rawValue: 1 << 4)
        public static let right = HorizontalLayout(rawValue: 1 << 5)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct VerticalLayout: OptionSet {
        public let rawValue: Int
        
        public static let custom = VerticalLayout(rawValue: 1 << 0)
        public static let top = VerticalLayout(rawValue: 1 << 1)
        public static let aboveCenter = VerticalLayout(rawValue: 1 << 2)
        public static let center = VerticalLayout(rawValue: 1 << 3)
        public static let belowCenter = VerticalLayout(rawValue: 1 << 4)
        public static let bottom = VerticalLayout(rawValue: 1 << 5)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct MaskType: OptionSet {
        public let rawValue: Int
        
        public static let none = MaskType(rawValue: 1 << 0)
        public static let clear = MaskType(rawValue: 1 << 1)
        public static let dimmed = MaskType(rawValue: 1 << 2)
        public static let lightBlur = MaskType(rawValue: 1 << 3)
        public static let darkBlur = MaskType(rawValue: 1 << 4)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    public struct Layout {
        let horizontal: HorizontalLayout
        let vertical: VerticalLayout
        
        public static func center() -> Layout {
            return Layout(horizontal: .center, vertical: .center)
        }
    }
    
    var contentView: UIView!
    var showType: ShowType = .shrinkIn
    var dismissType: DismissType = .shrinkOut
    var maskType: MaskType = .dimmed
    var dimmedMaskAlpha: CGFloat = 0.5
    var shouldDismissOnBackgroundTouch: Bool = true
    var shouldDismissOnContentTouch: Bool = false
    var shouldHandleKeyboard: Bool = false
    var willFinishShowingHandler: (() -> Void)?
    var didFinishShowingHandler: (() -> Void)?
    var willStartDismissingHandler: (() -> Void)?
    var didFinishDismissingCompletion: (() -> Void)?
    private(set) var backgroundView: UIView
    private(set) var containerView: UIView
    private(set) var isBeingShown: Bool = false
    private(set) var isShowing: Bool = false
    private(set) var isBeingDismissed: Bool = false
    private var keyboardRect: CGRect = .zero
    private let kAnimationOptionCurveIOS7 = AnimationOptions(rawValue: (7 << 16))
    private var containerBottomConstraint: NSLayoutConstraint?
    
    public convenience init(contentView: UIView, showType: ShowType = .shrinkIn, dismissType: DismissType = .shrinkOut, maskType: MaskType = .dimmed, shouldDismissOnBackgroundTouch: Bool = false, shouldDismissOnContentTouch: Bool = false) {
        self.init(frame: UIScreen.main.bounds)
        self.contentView = contentView
        self.showType = showType
        self.dismissType = dismissType
        self.maskType = maskType
        self.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch
        self.shouldDismissOnContentTouch = shouldDismissOnContentTouch
    }
    
    class func instantiate(contentView: UIView, showType: ShowType = .shrinkIn, dismissType: DismissType = .shrinkOut, maskType: MaskType = .dimmed, shouldDismissOnBackgroundTouch: Bool = true, shouldDismissOnContentTouch: Bool = false) -> PopupView {
        let popup = PopupView()
        popup.contentView = contentView
        popup.showType = showType
        popup.dismissType = dismissType
        popup.maskType = maskType
        popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch
        popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch
        return popup
    }
    
    class func dismissAll() {
        
    }
    
    public func show(with layout: PopupView.Layout = .center(), duration: TimeInterval = 0.0, inView view: UIView? = nil) {
        var params: [String: Any] = [
            "layout": layout,
            "duration": duration
        ]
        if let view = view {
            params["view"] = view
        }
        self.show(withParams: params)
    }
    
    public func show(at center: CGPoint, in view: UIView? = nil, with duration: TimeInterval = 0.0) {
        var params: [String: Any] = [
            "center": center,
            "duration": duration
        ]
        if let view = view {
            params["view"] = view
        }
        self.show(withParams: params)
    }
    
    public func dismiss(animated: Bool = true) {
        guard self.isShowing && !self.isBeingDismissed else {
            return
        }
        self.isBeingShown = false
        self.isShowing = false
        self.isBeingDismissed = true

        // cancel previous dismiss requests (i.e. the dismiss after duration call).
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(dismiss), object: nil)
        self.willStartDismissing()
        self.willStartDismissingHandler?()
        DispatchQueue.main.async {
            // Animate background if needed
            let backgroundAnimationBlock: (() -> Void) = { [weak self] in
                self?.backgroundView.alpha = 0
            }

            if animated && self.showType != .none {
                // Make fade happen faster than motion. Use linear for fades.
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: backgroundAnimationBlock, completion: nil)
            } else {
                backgroundAnimationBlock();
            }
            let completionBlock = { [weak self] (finished: Bool) in
                guard let self = self else {
                    return
                }
                self.removeFromSuperview()
                self.isBeingShown = false
                self.isShowing = false
                self.isBeingDismissed = false
                self.didFinishDismissing()
                self.didFinishDismissingCompletion?()
            }

            let bounce1Duration: TimeInterval = 0.13
            let bounce2Duration: TimeInterval = bounce1Duration * 2.0

            // Animate content if needed
            if animated {
                switch self.dismissType {
                case .fadeOut:
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
                        self.containerView.alpha = 0
                    }, completion: completionBlock)
                case .growOut:
                    UIView.animate(withDuration: 0.15, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                        self.containerView.alpha = 0
                        self.containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }, completion: completionBlock)
                case .shrinkOut:
                    UIView.animate(withDuration: 0.15, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                        self.containerView.alpha = 0
                        self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }, completion: completionBlock)
                case .slideOutToTop:
                    UIView.animate(withDuration: 0.3, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.y = -finalFrame.height
                        self.containerView.frame = finalFrame
                    }, completion: completionBlock)
                case .slideOutToBottom:
                    UIView.animate(withDuration: 1, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.y = self.bounds.height
                        self.containerView.frame = finalFrame
                    }, completion: completionBlock)
                case .slideOutToLeft:
                    UIView.animate(withDuration: 0.3, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.y = -finalFrame.width
                        self.containerView.frame = finalFrame
                    }, completion: completionBlock)
                case .slideOutToRight:
                    UIView.animate(withDuration: 0.3, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.y = self.bounds.width
                        self.containerView.frame = finalFrame
                    }, completion: completionBlock)
                case .bounceOut:
                    UIView.animate(withDuration: bounce1Duration, delay: 0, options: .curveEaseOut, animations: {
                        self.containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }, completion: { finished in
                        UIView.animate(withDuration: bounce2Duration, delay: 0, options: .curveEaseIn, animations: {
                            self.containerView.alpha = 0
                            self.containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        }, completion: completionBlock)
                    })
                case .bounceOutToTop:
                    UIView.animate(withDuration: bounce1Duration, delay: 0, options: .curveEaseOut, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.y += 40
                        self.containerView.frame = finalFrame
                    }, completion: { finished in
                        UIView.animate(withDuration: bounce2Duration, delay: 0, options: .curveEaseIn, animations: {
                            var finalFrame = self.containerView.frame
                            finalFrame.origin.y = -finalFrame.height
                            self.containerView.frame = finalFrame
                        }, completion: completionBlock)
                    })
                case .bounceOutToBottom:
                    UIView.animate(withDuration: bounce1Duration, delay: 0, options: .curveEaseOut, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.y -= 40
                        self.containerView.frame = finalFrame
                    }, completion: { finished in
                        UIView.animate(withDuration: bounce2Duration, delay: 0, options: .curveEaseIn, animations: {
                            var finalFrame = self.containerView.frame
                            finalFrame.origin.y = self.bounds.height
                            self.containerView.frame = finalFrame
                        }, completion: completionBlock)
                    })
                case .bounceOutToLeft:
                    UIView.animate(withDuration: bounce1Duration, delay: 0, options: .curveEaseOut, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.x += 40
                        self.containerView.frame = finalFrame
                    }, completion: { finished in
                        UIView.animate(withDuration: bounce2Duration, delay: 0, options: .curveEaseIn, animations: {
                            var finalFrame = self.containerView.frame
                            finalFrame.origin.x = -finalFrame.width
                            self.containerView.frame = finalFrame
                        }, completion: completionBlock)
                    })
                case .bounceOutToRight:
                    UIView.animate(withDuration: bounce1Duration, delay: 0, options: .curveEaseOut, animations: {
                        var finalFrame = self.containerView.frame
                        finalFrame.origin.x -= 40
                        self.containerView.frame = finalFrame
                    }, completion: { finished in
                        UIView.animate(withDuration: bounce2Duration, delay: 0, options: .curveEaseIn, animations: {
                            var finalFrame = self.containerView.frame
                            finalFrame.origin.x = self.bounds.width
                            self.containerView.frame = finalFrame
                        }, completion: completionBlock)
                    })
                default:
                    self.containerView.alpha = 0.0
                    completionBlock(true)
                }
            } else {
                self.containerView.alpha = 0.0
                completionBlock(true)
            }
        }
    }
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private override init(frame: CGRect) {
        self.backgroundView = UIView()
        self.backgroundView.backgroundColor = .clear
        self.backgroundView.isUserInteractionEnabled = false
        self.backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.containerView = UIView()
        self.containerView.autoresizesSubviews = false
        self.containerView.isUserInteractionEnabled = true
        self.containerView.backgroundColor = .clear
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
        self.alpha = 0
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.autoresizesSubviews = true
        self.backgroundView.frame = self.bounds
        self.addSubview(self.backgroundView)
        self.addSubview(self.containerView)
#if !TARGET_OS_TV
        // register for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatusBarOrientation(_:)), name: Notification.Name.UIApplicationDidChangeStatusBarFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: Notification.Name.UIKeyboardDidHide, object: nil)
#endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didChangeStatusBarOrientation(_ notification: Notification) {
        self.updateForInterfaceOrientation()
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            self.keyboardRect = self.convert(keyboardRect, from: nil)
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        self.keyboardRect = .zero
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !self.keyboardRect.contains(point), let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        if hitView == self || "\(hitView.classForCoder)" == "_UIVisualEffectContentView" {
            if self.shouldDismissOnBackgroundTouch {
                self.dismiss()
            }
            if self.maskType == .none {
                return nil
            }
        } else if hitView.isDescendant(of: self.containerView), self.shouldDismissOnContentTouch {
            self.dismiss()
        }
        return hitView
    }
    
    private func show(withParams params: [String: Any]) {
        guard !self.isBeingShown && !self.isShowing && !self.isBeingDismissed else {
            return
        }
        self.isBeingShown = true
        self.isShowing = false
        self.isBeingDismissed = false
        self.willStartShowing()
        DispatchQueue.main.async {
            var destView: UIView?
            if self.superview == nil {
                if let v = params["view"] as? UIView {
                    destView = v
                } else if let v = UIApplication.shared.windows.reversed().first(where: { $0.windowLevel == UIWindow.Level.leastNormalMagnitude }){
                    destView = v
                }
                destView?.addSubview(self)
                destView?.bringSubview(toFront: self)
            }
            self.updateForInterfaceOrientation()
            self.isHidden = false
            self.alpha = 1.0
            self.backgroundView.alpha = 0.0
            let backgroundAnimationHandler: (() -> Void) = { [weak self] in
                self?.backgroundView.alpha = 1.0
            }
            switch self.maskType {
            case .dimmed:
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(self.dimmedMaskAlpha)
                backgroundAnimationHandler()
            case .none:
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: backgroundAnimationHandler, completion: nil)
            case .clear:
                self.backgroundView.backgroundColor = .clear
            case .lightBlur:
                self.setupMaskTypeBlurEffect(style: .light)
            case .darkBlur:
                self.setupMaskTypeBlurEffect(style: .dark)
            default:
                backgroundAnimationHandler()
            }
            let duration: TimeInterval = (params["duration"] as? TimeInterval) ?? 0.0
            let completionHandler = { [weak self] (finished: Bool) in
                guard let self = self else {
                    return
                }
                self.isBeingShown = false
                self.isShowing = true
                self.isBeingDismissed = false
                self.didFinishShowing()
                self.didFinishShowingHandler?()
                if duration > 0.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        self.dismiss()
                    }
                }
            }
            if self.contentView.superview != self.containerView {
                self.containerView.addSubview(self.contentView)
            }
            self.contentView.layoutIfNeeded()
            var contentViewFrame = self.contentView.frame
            var containerFrame = self.containerView.frame
            containerFrame.size = contentViewFrame.size
            self.containerView.frame = containerFrame
            contentViewFrame.origin = CGPoint.zero
            self.contentView.frame = contentViewFrame
            let views: [String: Any] = ["contentView": self.contentView!]
            self.containerView.removeConstraints(self.containerView.constraints)
            self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: .Element(rawValue: 0), metrics: nil, views: views))
            self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: .Element(rawValue: 0), metrics: nil, views: views))
            var finalContainerFrame = containerFrame
            var containerAutoresizingMask: AutoresizingMask = []
            if let center = params["center"] as? NSValue {
                let centerInView = center.cgPointValue
                let centerInSelf: CGPoint
                if let destView = destView {
                    centerInSelf = self.convert(centerInView, from: destView)
                } else {
                    centerInSelf = centerInView
                }
                finalContainerFrame.origin.x = centerInSelf.x - finalContainerFrame.width / 2
                finalContainerFrame.origin.y = centerInSelf.y - finalContainerFrame.height / 2
                containerAutoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleTopMargin]
            } else {
                let layout = params["layout"] as? PopupView.Layout ?? PopupView.Layout.center()
                switch layout.horizontal {
                case .left:
                    finalContainerFrame.origin.x = 0.0
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleRightMargin]
                case .leftOfCenter:
                    finalContainerFrame.origin.x = CGFloat(floorf(Float(self.bounds.width / 3 - containerFrame.width / 2)))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleLeftMargin, .flexibleRightMargin]
                case .center:
                    finalContainerFrame.origin.x = CGFloat(floorf(Float((self.bounds.width - containerFrame.width) / 2)))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleLeftMargin, .flexibleRightMargin]
                case .rightOfCenter:
                    finalContainerFrame.origin.x = CGFloat(floorf(Float(self.bounds.width * 2 / 3 - containerFrame.width / 2)))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleLeftMargin, .flexibleRightMargin]
                case .right:
                    finalContainerFrame.origin.x = self.bounds.width - containerFrame.width
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleLeftMargin]
                default:
                    ()
                }
                switch layout.vertical {
                case .top:
                    finalContainerFrame.origin.y = 0
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleBottomMargin]
                case .aboveCenter:
                    finalContainerFrame.origin.y = CGFloat(floorf(Float(self.bounds.height / 3 - containerFrame.height / 2)))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin, .flexibleBottomMargin]
                case .center:
                    finalContainerFrame.origin.y = CGFloat(floorf(Float((self.bounds.height - containerFrame.height) / 2)))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin, .flexibleBottomMargin]
                case .belowCenter:
                    finalContainerFrame.origin.y = CGFloat(floorf(Float(self.bounds.height * 2 / 3 - containerFrame.height / 2)))
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin, .flexibleBottomMargin]
                case .bottom:
                    finalContainerFrame.origin.y = self.bounds.height - containerFrame.height
                    containerAutoresizingMask = [containerAutoresizingMask, .flexibleTopMargin]
                default:
                    ()
                }
            }
            self.containerView.autoresizingMask = containerAutoresizingMask
            switch self.showType {
            case .fadeIn:
                self.containerView.alpha = 0.0
                self.containerView.transform = .identity
                self.containerView.frame = finalContainerFrame
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveLinear, animations: {
                    self.containerView.alpha = 1.0
                }, completion: completionHandler)
            case .growIn:
                self.containerView.alpha = 0
                self.containerView.frame = finalContainerFrame
                self.containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                UIView.animate(withDuration: 0.15, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                    self.containerView.alpha = 1
                    self.containerView.transform = .identity
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .shrinkIn:
                self.containerView.alpha = 0
                self.containerView.frame = finalContainerFrame
                self.containerView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                UIView.animate(withDuration: 0.15, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                    self.containerView.alpha = 1
                    self.containerView.transform = .identity
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .slideInFromTop:
                self.containerView.alpha = 1
                self.containerView.transform = .identity
                var startFrame = finalContainerFrame
                startFrame.origin.y = -finalContainerFrame.height
                self.containerView.frame = startFrame
                UIView.animate(withDuration: 0.3, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .slideInFromBottom:
                self.containerView.alpha = 1
                self.containerView.transform = .identity
                var startFrame = finalContainerFrame
                startFrame.origin.y = self.bounds.height
                self.containerView.frame = startFrame
                UIView.animate(withDuration: 1, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .slideInFromLeft:
                self.containerView.alpha = 1
                self.containerView.transform = .identity
                var startFrame = finalContainerFrame
                startFrame.origin.x = -finalContainerFrame.width
                self.containerView.frame = startFrame
                UIView.animate(withDuration: 0.3, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .slideInFromRight:
                self.containerView.alpha = 1
                self.containerView.transform = .identity
                var startFrame = finalContainerFrame
                startFrame.origin.x = self.bounds.width
                self.containerView.frame = startFrame
                UIView.animate(withDuration: 0.3, delay: 0, options: self.kAnimationOptionCurveIOS7, animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .bounceIn:
                self.containerView.alpha = 0
                self.containerView.frame = finalContainerFrame
                self.containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 15, options: AnimationOptions(rawValue: 0), animations: {
                    self.containerView.frame = finalContainerFrame
                    self.containerView.transform = .identity
                }, completion: completionHandler)
            case .bounceInFromTop:
                self.containerView.alpha = 1
                var startFrame = finalContainerFrame
                startFrame.origin.y = -finalContainerFrame.height
                self.containerView.frame = startFrame
                self.containerView.transform = .identity
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: AnimationOptions(rawValue: 0), animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .bounceInFromBottom:
                self.containerView.alpha = 1
                var startFrame = finalContainerFrame
                startFrame.origin.y = self.bounds.height
                self.containerView.frame = startFrame
                self.containerView.transform = .identity
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: AnimationOptions(rawValue: 0), animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .bounceInFromLeft:
                self.containerView.alpha = 1
                var startFrame = finalContainerFrame
                startFrame.origin.x = -finalContainerFrame.width
                self.containerView.frame = startFrame
                self.containerView.transform = .identity
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: AnimationOptions(rawValue: 0), animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            case .bounceInFromRight:
                self.containerView.alpha = 1
                var startFrame = finalContainerFrame
                startFrame.origin.x = self.bounds.width
                self.containerView.frame = startFrame
                self.containerView.transform = .identity
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: AnimationOptions(rawValue: 0), animations: {
                    self.containerView.frame = finalContainerFrame
                }, completion: completionHandler)
            default:
                self.containerView.alpha = 1.0
                self.containerView.transform = .identity
                self.containerView.frame = finalContainerFrame
                completionHandler(true)
            }
        }
    }
    
    private func setupMaskTypeBlurEffect(style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let visualBlur = UIVisualEffectView(effect: blurEffect)
        visualBlur.frame = self.backgroundView.frame
        visualBlur.contentView.addSubview(self.backgroundView)
        self.insertSubview(visualBlur, belowSubview: self.containerView)
    }
    
    private func updateForInterfaceOrientation() {
        #if !TARGET_OS_TV
        let orientation = UIApplication.shared.statusBarOrientation
        let angle: CGFloat
        switch orientation {
        case .portraitUpsideDown:
            angle = CGFloat.pi
        case .landscapeLeft:
            angle = -CGFloat.pi / 2
        case .landscapeRight:
            angle = CGFloat.pi / 2
        default:
            angle = 0
        }
        self.transform = CGAffineTransform(rotationAngle: angle)
        self.frame = self.window?.bounds ?? .zero
        #endif
    }
    
    private func willStartDismissing() {
        
    }
    
    private func didFinishShowing() {
        
    }
    
    private func willStartShowing() {
        #if !TARGET_OS_TV
        if self.shouldHandleKeyboard {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        }
        #endif
    }
    
    func didFinishDismissing() {
        #if !TARGET_OS_TV
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        #endif
    }
    // MARK: - Keyboard notification handlers

    #if !TARGET_OS_TV
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        self.moveContainerViewForKeyboard(notification, up: true)
    }

    @objc func keyboardWillHideNotification(_ notification: Notification) {
        self.moveContainerViewForKeyboard(notification, up: false)
    }

    func moveContainerViewForKeyboard(_ notification: Notification, up: Bool) {
        let userInfo = notification.userInfo
        let animationDuration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        let animationCurve = userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve ?? .linear
        let keyboardEndFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero
        self.containerView.center = CGPoint(x: self.containerView.superview?.frame.size.width ?? 0 / 2, y: self.containerView.superview?.frame.size.height ?? 0 / 2)
        var frame = self.containerView.frame
        if up {
            frame.origin.y -= keyboardEndFrame.size.height / 2
        }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animationDuration)
        UIView.setAnimationCurve(animationCurve)
        self.containerView.frame = frame
        UIView.commitAnimations()
    }
    #endif
}

extension UIView {
    public func dismissPresentingPopup() {
        var view: UIView? = self
        while view != nil {
            if let v = view as? PopupView {
                v.dismiss()
            }
            view = view?.superview
        }
    }
}
