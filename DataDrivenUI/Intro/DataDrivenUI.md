# Data driven UI #

Hi in that small sequence of notes I wanna show you my approach and thoughts/practices in development UI layer.

And firstly I wanna tell you about DataDriven View Controllers. It’s not new idea. I think you’ve heard/seen or even worked with that approach. But I want to define the terms.

So the main idea - we should have isolated UI components with one input point. And we should influence on our UI component only by this point. Also only UI component should define what it can do. In code it looks like this:

``` code
class MyView: UIView {
	struct Props {
		enum State{
			case error
			case normal
		}
		let title: String
		let action: () -> Void
		let state: State
	}

	var props: Props { // TODO: }
	init(props: Props) { // TODO: }
}
```

Here we see that UI component defines all possibilities of it’s data/state/actions. And that’s enough for view to do its work completely. And, another main idea - we can communicate with our view only by `props` variable. 
One important notion - we should architect Props in a way that it’s impossible to create invalid state from them.

There’re few pros from such a structure which I’ll explain later. Such as: fast development*, isolation, testability/screenshot testing. And cons: code duplication, bigger code base, lot’s of props transformations.

Let’s look at example below. We wanna create a simple UI component. For example loginView. I’ll do it in a simple way just as an example.

Login view should have three states: input, progress, error. And I should have possibility to login only in input state, and have some information for error state. So let’s define it in our props structure:

```
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
```

It’s clear and understandable even at one glance you realize what this view can do. And how I can work with it. Also I can run it in playground.
We can construct some simple test flow:

```
func loginRun(pair: LoginView.Props.NamePass) {
    view.props = LoginView.Props(state: .progress)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
        view.props = LoginView.Props(state: .error("Wrong name or password"))
    }
}

let command: LoginView.Props.LoginCommand = loginRun
view.props = LoginView.Props(state: .input(command))
```

## Insert GIF with that view here ##

You can find the example of create this view in [playground](https://github.com/akantsevoi/login_example.gif)

And that’s the whole principle about Data Driven approach.

Next I wanna show one example which usually is interested by new people.
It's collectionview with infinite or huge data set. 
Let’s define our props:

```
struct Props {
    struct Item {
        let text: String
    }
    
    var items: [Item]
    var jumpSize: Int
    var previous: () -> Void
    var next: () -> Void
}
```
It actually looks similar to your view controller if you wanna do the same you should have smart datasource which can handle range of data and provide it to our view.

In next article I will show you my tips for development in playground. And some more examples of Data Driven UI.
