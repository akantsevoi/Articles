//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class CustomCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(label)
        label.textColor = UIColor.black
    }
    
    override func layoutSubviews() {
        label.frame = bounds
    }
}

class Collection: UIViewController {
    private enum Constants {
        static let reuseIdentifier = "reuseIdentifier"
    }
    
    struct Props {
        struct Item {
            let text: String
        }
        
        var items: [Item]
        var jumpSize: Int
        var previous: () -> Void
        var next: () -> Void
    }
    
    var props: Props {
        didSet {
            colletionView.contentOffset = CGPoint(
                x: 0,
                y: colletionView.contentOffset.y - CGFloat(30 * props.jumpSize))
            colletionView.reloadData()
        }
    }
    
    private let colletionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init(props: Props) {
        self.props = props
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func addSubviews() {
        colletionView.backgroundColor = UIColor.white
        view.addSubview(colletionView)
        colletionView.register(CustomCell.self, forCellWithReuseIdentifier: Constants.reuseIdentifier)
        colletionView.delegate = self
        colletionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        colletionView.frame = view.bounds
        colletionView.collectionViewLayout.invalidateLayout()
    }
}

extension Collection: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return props.items.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = colletionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier, for: indexPath) as! CustomCell
        cell.label.text = props.items[indexPath.row].text
        
        return cell
    }
}

extension Collection: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 30)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < scrollView.contentSize.height * 0.1 {
            props.previous()
        }
        
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height * 0.9 {
            props.next()
        }
    }
}


let intSequence = sequence(first: 0) { (previous) -> Int? in
    return previous + 1
    }.prefix(1000)

let strings = intSequence.map(String.init)
var topPoint = 0
var bottomPoint = 130
let items = strings.map(Collection.Props.Item.init)

let props = Collection.Props(
    items: Array(items[topPoint..<bottomPoint]),
    jumpSize: 0,
    previous: {},
    next: {})
let controller = Collection(props: props)

func loadMore(isForward: Bool, force: Bool = false) {
    let step = 50
    
    var jumpSize = 0
    
    if isForward {
        if bottomPoint + step <= items.count {
            topPoint += step
            bottomPoint += step
            jumpSize = step
        } else if !force {
            return
        }
    } else {
        if topPoint - step >= 0 {
            topPoint -= step
            bottomPoint -= step
            jumpSize = -step
        } else if !force {
            return
        }
    }
    
    controller.props = Collection.Props(
        items: Array(items[topPoint..<bottomPoint]),
        jumpSize: jumpSize,
        previous: {
            loadMore(isForward: false)
            
    },
        next: {
            loadMore(isForward: true)
    })
}

loadMore(isForward: false, force: true)

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = controller
