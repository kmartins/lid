import 'package:flutter/material.dart';
import 'package:flutter_lid/flutter_lid.dart';
import 'package:state_notifier/state_notifier.dart';

void main() => runApp(const LidCounter());

/// A [StatelessWidget] which uses:
/// * [state_notifier](https://pub.dev/packages/state_notifier)
/// * [lid](https://pub.dev/packages/lid)
/// to manage the state of a counter.
class LidCounter extends StatelessWidget {
  const LidCounter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterPage(),
    );
  }
}

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterState].
class CounterPage extends StatelessWidget {
  CounterPage({Key? key}) : super(key: key);

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

/// {@template counter_lid}
/// A simple [State Notifier] which manages an `int` as its state
/// and exposes two public methods to [increment] and [decrement]
/// the value of the state.
/// {@endtemplate}
class CounterState extends StateNotifier<int> {
  /// {@macro counter_state}
  CounterState() : super(0);

  /// Increments the state by 1.
  void increment() => state += 1;

  /// Decrements the state by 1.
  void decrement() => state -= 1;
}
