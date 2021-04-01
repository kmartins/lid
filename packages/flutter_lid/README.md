# Lid

<p align="center">
<a href="https://pub.dev/packages/flutter_lid"><img src="https://img.shields.io/pub/v/flutter_lid.svg" alt="Pub"></a>
<a href="https://github.com/kmartins/lid/actions"><img src="https://github.com/kmartins/lid/workflows/flutter_lid/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/kmartins/lid"><img src="https://codecov.io/gh/kmartins/lid/branch/main/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/kmartins/lid"><img src="https://img.shields.io/github/stars/kmartins/lid.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on GitHub"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>

A Flutter library built to expose widgets that integrate with `state notifier`. Built to work with the [state_notifier](https://pub.dev/packages/state_notifier) state management packages.

It's very similar to widgets the [bloc](https://pub.dev/packages/flutter_bloc).

## Motivation

Already exists a package to integrate with the status notifier, called [flutter_state_notifier](https://pub.dev/packages/flutter_state_notifier), but `flutter_lid` covers different cases.

## Usage

**Remember this package is destined to be used together with [state_notifier](https://pub.dev/packages/state_notifier)**

Let's take a look at how to use `LidBuilder` to hook up a `CounterPage` widget to a `CounterState`.

Add it in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_lid:
  state_notifier:
```

### `counter_lid.dart`

```dart
class CounterState extends StateNotifier<int> {
  CounterState() : super(0);

  void increment() => state += 1;

  void decrement() => state -= 1;
}
```

### `main.dart`

```dart
void main() => runApp(const LidCounter());

class LidCounter extends StatelessWidget {
  const LidCounter({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterPage(),
    );
  }
}

class CounterPage extends StatelessWidget {
  CounterPage({Key key}) : super(key: key);

  final _counter = CounterState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lid Counter')),
      body: LidBuilder<int>(
        stateNotifier: _counter,
        builder: (_, count) {
          return Center(
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.headline1,
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              onPressed: _counter.increment,
              child: const Icon(Icons.add),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: FloatingActionButton(
              onPressed: _counter.decrement,
              child: const Icon(Icons.remove),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Lid Widgets

**LidBuilder** is a Flutter widget which requires a `stateNotifier` and a `builder` function. `LidBuilder` handles building the widget in response to new states. `LidBuilder` is very similar to `StreamBuilder` but has a more simple API to reduce the amount of boilerplate code needed. The `builder` function will potentially be called many times and should be a [pure function](https://en.wikipedia.org/wiki/Pure_function) that returns a widget in response to the state.

See `LidListener` if you want to "do" anything in response to state changes such as navigation, showing a dialog, etc...

```dart
LidBuilder<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  builder: (context, state) {
    // return widget here based on State Notifier's state
  }
)
```

For fine-grained control over when the `builder` function is called `buildWhen` that can be provided that omitted, it will default `true` if previous
state`is different current`state`, otherwise is`false`.`buildWhen`takes the previous state and current state and returns a boolean. If`buildWhen`returns true,`builder`will be called with`state`and the widget will rebuild. If`buildWhen`returns false,`builder`will not be called with`state` and no rebuild will occur.

`buildWhen` is only called once for each state change (**NOT** including `initialState`).

```dart
LidBuilder<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  buildWhen: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on State Notifier's state
  }
)
```

There is the possibility to animate between state changes. 

```dart
LidBuilder<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  animate: true, // Setting to `true`, fadeIn animation will be performed between widget changes.
  transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder, // Here you can modify the default animation which is FadeIn.
  duration: Duration(milliseconds: 300), // Sets the duration of the animation.  
  builder: (context, state) {
    // return widget here based on State Notifier's state
  }
)
```


**LidListener** is a Flutter widget which takes a `LidWidgetListener` and requires a `stateNotifier` and invokes the `listener` in response to state changes in the state notifier. It should be used for functionality that needs to occur once per state change such as navigation, showing a `SnackBar`, showing a `Dialog`, etc...

`listener` is only called once for each state change (**NOT** including `initialState`) unlike `builder` in `LidBuilder` and is a `void` function.

```dart
LidListener<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  listener: (context, state) {
    // do stuff here based on State Notifier's state
  },
  child: const SizedBox(),
)
```

For fine-grained control over when the `listener` function is called an optional `listenWhen` can be provided. `listenWhen` takes the previous state and current state and returns a boolean. If `listenWhen` returns true, `listener` will be called with `state`. If `listenWhen` returns false, `listener` will not be called with `state`.

```dart
LidListener<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  listenWhen: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on State Notifier's state
  },
  child: const SizedBox(),
)
```

**MultiLidListener** is a Flutter widget that merges multiple `LidListener` widgets into one.
`MultiLidListener` improves the readability and eliminates the need to nest multiple `LidListeners`.
By using `MultiLidListener` we can go from:

```dart
LidListener<StateType>(
  stateNotifier: stateNotifierA, // provide the state notifier instance
  listener: (context, state) {},
  child: LidListener<StateType>(
    stateNotifier: stateNotifierB, // provide the state notifier instance
    listener: (context, state) {},
    child: LidListener<StateType>(
      stateNotifier: stateNotifierC,// provide the state notifier instance
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

to:

```dart
MultiLidListener(
  listeners: [
    LidListener<StateType>(
      stateNotifier: stateNotifierA, // provide the state notifier instance
      listener: (context, state) {},
    ),
    LidListener<StateType>(
      stateNotifier: stateNotifierB, // provide the state notifier instance
      listener: (context, state) {},
    ),
    LidListener<StateType>(
      stateNotifier: stateNotifierC, // provide the state notifier instance
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

**LidConsumer** exposes a `builder` and `listener` in order react to new states. `LidConsumer` is analogous to a nested `LidListener` and `LidBuilder` but reduces the amount of boilerplate needed. `LidConsumer` should only be used when it is necessary to both rebuild UI and execute other reactions to state changes in the `state notifier`. `LidConsumer` takes a required `LidWidgetBuilder` and `LidWidgetListener` and `StateNotifier`, an optional `LidBuilderCondition`, and `LidListenerCondition`.

```dart
LidConsumer<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  listener: (context, state) {
    // do stuff here based on State Notifier's state
  },
  builder: (context, state) {
    // return widget here based on State Notifier's state
  }
)
```

An optional `listenWhen` and `buildWhen` can be implemented for more granular control over when `listener` and `builder` are called. The `listenWhen` and `buildWhen` will be invoked on each `state` change. They each take the previous `state` and current `state` and must return a `bool` which determines whether or not the `builder` and/or `listener` function will be invoked. The previous `state` will be initialized to the `state` of the `state_notifier` when the `LidConsumer` is initialized. `listenWhen` and `buildWhen` are optional and if they aren't implemented, they will default to `true`.

If `buildWhen` é omitted then, it will default `true` if previous `state` is different current `state`, otherwise is `false`.

```dart
LidConsumer<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  listenWhen: (previous, current) {
    // return true/false to determine whether or not
    // to invoke listener with state
  },
  listener: (context, state) {
    // do stuff here based on State Notifier's state
  },
  buildWhen: (previous, current) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on State Notifier's state
  }
)
```

There is the possibility to animate between state changes. 

```dart
LidConsumer<StateType>(
  stateNotifier: stateNotifier, // provide the state notifier instance
  animate: true, // Setting to `true`, fadeIn animation will be performed between widget changes.
  transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder, // Here you can modify the default animation which is FadeIn.
  duration: Duration(milliseconds: 300), // Sets the duration of the animation.  
  listener: (context, state) {
    // do stuff here based on State Notifier's state
  },
  builder: (context, state) {
    // return widget here based on State Notifier's state
  }
)
```

## Extensions 

There are 3 extensions for -> LidBuilder, LidListener and LidConsumer.

It's super simple to use:

``` dart
// Same as LidBuilder
stateNotifier.toLidBuilder(  
  buildWhen: (previousState, state) {},
  builder: (context, state) {},
);

// Same as LidListener
stateNotifier.toLidListener(  
  listenWhen: (previousState, state) {},
  listener: (context, state) {},
  child: const SizedBox(),
);

// Same as LidConsumer
stateNotifier.toLidConsumer(
  listenWhen: (previous, current) {},
  listener: (context, state) {},
  buildWhen: (previous, current) {},
  builder: (context, state) {}
);
```

## Maintainers

- [Kauê Martins](https://github.com/kmartins)

## Support

You liked this package? then give it a star. If you want to help then:

- Fork this repository
- Send a Pull Request with new features
- Share this package
- Create issues if you find a Bug or want to suggest something
