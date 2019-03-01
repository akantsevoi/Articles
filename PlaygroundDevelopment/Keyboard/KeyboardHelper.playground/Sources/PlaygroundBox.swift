import UIKit

public enum iDevice {
    case iphone4 // 5, 5s, 5c, SE
    case iphone47// 6, 6s, 7, 8
    case iphone55// 6+, 6s+, 7+, 8+
    case iphone58// X, Xs
    case iphone61// Xr
    case iphone65// Xs Max
}

public func playgroundBox(device: iDevice, for child: UIViewController) -> ParentController {
    var parentSize = CGSize.zero
    
    switch device {
    case .iphone4:
        parentSize = CGSize(width: 320, height: 568)
    case .iphone47:
        parentSize = CGSize(width: 375, height: 667)
    case .iphone55:
        parentSize = CGSize(width: 414, height: 736)
    case .iphone58:
        parentSize = CGSize(width: 375, height: 812)
    case .iphone61, .iphone65:
        parentSize = CGSize(width: 414, height: 896)
    }
    
    let parent = ParentController()
    parent.addChild(child)
    parent.view.addSubview(child.view)
    
    child.view.translatesAutoresizingMaskIntoConstraints = false
    
    parent.view.frame.size = parentSize
    parent.preferredContentSize = parentSize
    
    parent.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        child.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
        child.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
        child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
        child.view.topAnchor.constraint(equalTo: parent.view.topAnchor),
        ])
    
    return parent
}

public func viewBox(for child: UIView, with parentSize: CGSize = CGSize(width: 600, height: 600)) -> UIViewController {
    
    let parent = UIViewController()
    parent.view.addSubview(child)
    
    parent.view.frame.size = parentSize
    parent.preferredContentSize = parentSize
    
    parent.view.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate(
        [child.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor),
         child.centerYAnchor.constraint(equalTo: parent.view.centerYAnchor)])
    
    return parent
}
