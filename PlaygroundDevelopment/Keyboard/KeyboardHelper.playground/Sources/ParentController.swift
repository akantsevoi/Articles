import UIKit

public extension NotificationCenter {
    @objc func swizzledPost(_ notification: Notification) {
        print("swizzled called")
        guard let userInfo = notification.userInfo else {return}
        let isKeyboardRelated = (userInfo[UIResponder.keyboardWillChangeFrameNotification] as? Bool) ?? false
        let isModified = (notification.userInfo?[ParentController.modifiedNotificationKey] as? Bool) ?? false
        
        if isModified  {
            print("щерук")
            self.swizzledPost(notification)
        } else {
            print("nice try")
        }
    }
}

public func initializeFakeKeyboard() {
    let originalMethod = class_getInstanceMethod(NotificationCenter.self, #selector(NotificationCenter.post(_:)))
    
    let swizzledMethod = class_getInstanceMethod(NotificationCenter.self, #selector(NotificationCenter.swizzledPost(_:)))
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
    print("initialize has finished")
}

public class ParentController: UIViewController {
    
    public var keyboardHeight: CGFloat = 200
    private let fakeKeyboard: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 500, width: 320, height: 200)
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    private let toggleKeyboardButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
        button.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        return button
    }()
    
    @objc func toggle() {
        let isClose = fakeKeyboard.frame.origin.y >= view.bounds.height
        
        if isClose {
            sendNewNotification(start: calculateCloseFrame(), end: calculateOpenFrame())
        } else {
            sendNewNotification(start: calculateOpenFrame(), end: calculateCloseFrame())
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(toggleKeyboardButton)
        view.addSubview(fakeKeyboard)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardChangeFrame(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    public override func viewWillLayoutSubviews() {
        view.bringSubviewToFront(toggleKeyboardButton)
        toggleKeyboardButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    }
    
    public static let modifiedNotificationKey = "ParentModifiedNotificationKey"
    @objc private func keyboardChangeFrame(notification: Notification) {
        hideOriginalKeyboardIfCan()
        
        guard let userInfo = notification.userInfo else { return }
        let modified = (userInfo[ParentController.modifiedNotificationKey] as? Bool) ?? false
        guard !modified else { return }
        
        guard let originalEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let originalStartFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let isOpeninig = originalStartFrame.origin.y > originalEndFrame.origin.y
        
        let openFrame = calculateOpenFrame()
        let closeFrame = calculateCloseFrame()
        
        let (newStartFrame, newEndFrame) = isOpeninig ? (closeFrame, openFrame) : (openFrame, closeFrame)
        
        self.sendNewNotification(start: newStartFrame, end: newEndFrame)
    }
    
    private func calculateOpenFrame() -> CGRect {
        return CGRect(
            origin: CGPoint(x: 0, y: view.bounds.height - keyboardHeight),
            size: CGSize(width: view.bounds.width, height: keyboardHeight))
    }
    
    private func calculateCloseFrame() -> CGRect {
        return CGRect(
            origin: CGPoint(x: 0, y: view.bounds.height),
            size: CGSize(width: view.bounds.width, height: keyboardHeight))
    }
    
    private func sendNewNotification(start: CGRect, end: CGRect) {
        var newNotification = Notification(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: [:])
        newNotification.userInfo?[ParentController.modifiedNotificationKey] = true
        newNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] = NSValue(cgRect: end)
        newNotification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] = NSValue(cgRect: start)
        newNotification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] = 7
        newNotification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] = 0.25
        newNotification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] = true
        
        view.bringSubviewToFront(fakeKeyboard)
        view.bringSubviewToFront(toggleKeyboardButton)
        
        UIView.animate(withDuration: 0.25) {
            self.fakeKeyboard.frame = end
        }
        
        NotificationCenter.default.post(newNotification)
    }
    
    private func hideOriginalKeyboardIfCan() {
        for window in UIApplication.shared.windows {
            if window.isKind(of: NSClassFromString("UIRemoteKeyboardWindow")!) {
                window.alpha = 0
            }
        }
    }
}
