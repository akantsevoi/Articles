//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class LoginView: UIView {
    struct Props {
        struct NamePass {
            var name: String
            var pass: String
        }
        
        typealias LoginCommand = (NamePass) -> Void
        
        enum State {
            case input(LoginCommand)
            case progress
            case error(String)
        }
        
        var state: State
    }
    
    var props: Props {
        didSet {
            setNeedsLayout()
        }
    }
    
     let mailTextField = UITextField()
     let passwordTextField = UITextField()
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        return button
    }()
    private let progressPlaceholder = UIView()
    private let progress = UIActivityIndicatorView(style: .whiteLarge)
    private let errorLabel = UILabel()
    
    init(props: Props) {
        self.props = props
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addViews()
    }
    
    override func layoutSubviews() {
        switch props.state {
        case .error(let message):
            errorLabel.text = message
            errorLabel.isHidden = false
            progressPlaceholder.isHidden = true
            progress.stopAnimating()
        case .input(_):
            errorLabel.isHidden = true
            progressPlaceholder.isHidden = true
            progress.stopAnimating()
        case .progress:
            errorLabel.isHidden = true
            backgroundColor = UIColor.white
            progressPlaceholder.isHidden = false
            progress.startAnimating()
        }
    }
    
    @objc private func loginAction() {
        if case let Props.State.input(command) = props.state {
            let value = Props.NamePass(
                name: mailTextField.text ?? "",
                pass: passwordTextField.text ?? "")
            command(value)
        }
    }
    
    // MARK: Service part of example
    private func addViews() {
        
        [mailTextField,
         passwordTextField,
         loginButton,
         progressPlaceholder,
         progress,
         errorLabel].forEach{ $0.translatesAutoresizingMaskIntoConstraints = false }
        
        addSubview(mailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(progressPlaceholder)
        progressPlaceholder.addSubview(progress)
        addSubview(errorLabel)
        
        let anchors = [
            mailTextField.topAnchor.constraint(equalTo: topAnchor),
            mailTextField.leftAnchor.constraint(equalTo: leftAnchor),
            mailTextField.rightAnchor.constraint(equalTo: rightAnchor),
            mailTextField.heightAnchor.constraint(equalToConstant: 60),
            
            passwordTextField.leftAnchor.constraint(equalTo: leftAnchor),
            passwordTextField.rightAnchor.constraint(equalTo: rightAnchor),
            passwordTextField.topAnchor.constraint(equalTo: mailTextField.bottomAnchor, constant: 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 80),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            loginButton.widthAnchor.constraint(equalToConstant: 40),
            
            progressPlaceholder.topAnchor.constraint(equalTo: topAnchor),
            progressPlaceholder.leftAnchor.constraint(equalTo: leftAnchor),
            progressPlaceholder.rightAnchor.constraint(equalTo: rightAnchor),
            progressPlaceholder.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            progress.centerXAnchor.constraint(equalTo: progressPlaceholder.centerXAnchor),
            progress.centerYAnchor.constraint(equalTo: progressPlaceholder.centerYAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: topAnchor),
            errorLabel.leftAnchor.constraint(equalTo: leftAnchor),
            errorLabel.rightAnchor.constraint(equalTo: rightAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        anchors.forEach{ $0.isActive = true }
        
        mailTextField.borderStyle = .line
        passwordTextField.borderStyle = .line
        passwordTextField.isSecureTextEntry = true
        
        loginButton.backgroundColor = UIColor.lightGray
        progressPlaceholder.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        errorLabel.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        errorLabel.textColor = UIColor.white
        errorLabel.font = UIFont.boldSystemFont(ofSize: 45)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




let props = LoginView.Props(state: .progress)
let view = LoginView(props: props)
view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)


func loginRun(pair: LoginView.Props.NamePass) {
    view.props = LoginView.Props(state: .progress)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
        view.props = LoginView.Props(state: .error("Wrong name or password"))
    }
}

let command: LoginView.Props.LoginCommand = loginRun
view.props = LoginView.Props(state: .input(command))

func fillString(string: String, to element: UITextField, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
        if let char = string.first {
            var nextString = string
            nextString.removeFirst()
            element.text = (element.text ?? "") + "\(char)"
            fillString(string: nextString, to: element, completion: completion)
        } else {
            completion()
        }
    }
}

fillString(string: "alex@alex.com", to: view.mailTextField) {
    fillString(string: "mypassword", to: view.passwordTextField, completion: {})
}


PlaygroundPage.current.liveView = view
