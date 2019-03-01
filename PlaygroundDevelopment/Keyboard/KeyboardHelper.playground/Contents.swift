//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
//
//class SomeClass: NSObject {
//    @objc func originalMethod() {
//        print("original method")
//    }
//}
//
//extension SomeClass {
//    @objc func newMethod() {
//        print("owerrided")
//    }
//}
//
//let cl = SomeClass()
//
//cl.originalMethod()
//
//let originalMethod = class_getInstanceMethod(NotificationCenter.self, #selector(SomeClass.originalMethod))
//
//let swizzledMethod = class_getInstanceMethod(NotificationCenter.self, #selector(SomeClass.newMethod))
//print(originalMethod)
//print(swizzledMethod)
//method_exchangeImplementations(originalMethod!, swizzledMethod!)
//
//cl.originalMethod()


class MyViewController : UIViewController {
    
    private lazy var firstTextField = UITextField()
    private lazy var textField = UITextField()
    private var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        textField.backgroundColor = UIColor.orange
        firstTextField.backgroundColor = UIColor.yellow
        
        firstTextField.placeholder = "first"
        textField.placeholder = "second"
        
        firstTextField.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(firstTextField)
        view.addSubview(textField)
        
        let constraints = [
            firstTextField.leftAnchor.constraint(equalTo: view.leftAnchor),
            firstTextField.rightAnchor.constraint(equalTo: view.rightAnchor),
            firstTextField.heightAnchor.constraint(equalToConstant: 42),
            firstTextField.bottomAnchor.constraint(equalTo: textField.topAnchor),
            textField.leftAnchor.constraint(equalTo: view.leftAnchor),
            textField.rightAnchor.constraint(equalTo: view.rightAnchor),
            textField.heightAnchor.constraint(equalToConstant: 42),
            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        bottomConstraint = constraints.last!

        NSLayoutConstraint.activate(constraints)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardFrameChanged(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil)
    }
    
    @objc private func keyboardFrameChanged(notification: Notification) {
        print("got notification", notification)
        guard let userInfo = notification.userInfo else { return }
        
        guard let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
        
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        let bottomValue: CGFloat = {
            if endFrame.origin.y >= view.bounds.height {
                return  0
            } else {
                return -endFrame.size.height
            }
        }()
        
        bottomConstraint.constant = bottomValue
        view.setNeedsLayout()
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: animationCurve,
            animations: {
                self.view.layoutIfNeeded()
        },
            completion: { (_) in})
    }
}

initializeFakeKeyboard()
let controller = MyViewController()
controller.view.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = playgroundBox(device: .iphone4, for: controller)

