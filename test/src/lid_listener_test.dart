import 'package:flutter/material.dart';
import 'package:flutter_lid/flutter_lid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_notifier/state_notifier.dart';

class CounterState extends StateNotifier<int> {
  CounterState() : super(0);

  void increment() => state += 1;
}

class MyApp extends StatefulWidget {
  final CounterState counterState;
  const MyApp({
    Key? key,
    this.onListenerCalled,
    required this.counterState,
  }) : super(key: key);

  final LidWidgetListener<int>? onListenerCalled;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CounterState _counterState = widget.counterState;

  @override
  void dispose() {
    _counterState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LidListener<int>(
          stateNotifier: _counterState,
          listener: (context, state) {
            widget.onListenerCalled?.call(context, state);
          },
          child: Column(
            children: [
              ElevatedButton(
                key: const Key('lid_listener_reset_button'),
                onPressed: () {
                  setState(() => _counterState = CounterState());
                },
                child: const Text('lid_listener_reset_button'),
              ),
              ElevatedButton(
                key: const Key('lid_listener_noop_button'),
                onPressed: () {
                  setState(() => _counterState = _counterState);
                },
                child: const Text('lid_listener_noop_button'),
              ),
              ElevatedButton(
                key: const Key('lid_listener_increment_button'),
                onPressed: () => _counterState.increment(),
                child: const Text('lid_listener_increment_button'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('LidListener', () {
    testWidgets('renders child properly', (tester) async {
      const targetKey = Key('lid_listener_container');
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: CounterState(),
          listener: (_, __) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('debugFillProperties', (tester) async {
      final counterState = CounterState();
      final child = LidListener<int>(
        stateNotifier: counterState,
        listenWhen: (_, __) => true,
        listener: (_, __) {},
        child: const SizedBox(),
      );

      expect(
        child.toString(),
        "LidListener<int>(stateNotifier: Instance of 'CounterState', has listener, has listenWhen)",
      );

      await tester.pumpWidget(child);

      final state = tester.state(find.byWidget(child));

      expect(state.toString(), endsWith('(state: 0)'));

      counterState.increment();

      expect(state.toString(), endsWith('(state: 1)'));
    });

    testWidgets('calls listener on single state change', (tester) async {
      final counterState = CounterState();
      final states = <int>[];
      const expectedStates = [1];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listener: (_, state) {
            states.add(state);
          },
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets('calls listener on single state change', (tester) async {
      final counterState = CounterState();
      final states = <int>[];
      const expectedStates = [1];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listener: (_, state) {
            states.add(state);
          },
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets('calls listener on multiple state change', (tester) async {
      final counterState = CounterState();
      final states = <int>[];
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listener: (_, state) {
            states.add(state);
          },
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets(
        'updates when the state notifier is changed at runtime to a different state notifier '
        'and unsubscribes from old state notifier', (tester) async {
      final counterState = CounterState();
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('lid_listener_increment_button'),
      );
      final resetLidFinder = find.byKey(
        const Key('lid_listener_reset_button'),
      );
      await tester.pumpWidget(MyApp(
        counterState: counterState,
        onListenerCalled: (_, state) {
          listenerCallCount++;
          latestState = state;
        },
      ));

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(counterState.hasListeners, isTrue);
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(counterState.hasListeners, isTrue);
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(resetLidFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(counterState.hasListeners, isFalse);
      expect(listenerCallCount, 3);
      expect(latestState, 1);
    });

    testWidgets(
        'does not update when the state notifier is changed at runtime to same state notifier '
        'and stays subscribed to current state notifier', (tester) async {
      final counterState = CounterState();
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('lid_listener_increment_button'),
      );
      final noopLidFinder = find.byKey(
        const Key('lid_listener_noop_button'),
      );
      await tester.pumpWidget(MyApp(
        counterState: counterState,
        onListenerCalled: (context, state) {
          listenerCallCount++;
          latestState = state;
        },
      ));

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(counterState.hasListeners, isTrue);
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(counterState.hasListeners, isTrue);
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(noopLidFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(counterState.hasListeners, isTrue);
      expect(listenerCallCount, 3);
      expect(latestState, 3);
    });

    testWidgets(
        'calls listenWhen on single state change with correct previous '
        'and current states', (tester) async {
      int? latestPreviousState;
      var conditionCallCount = 0;
      final states = <int>[];
      final counterState = CounterState();
      const expectedStates = [1];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listenWhen: (previous, state) {
            conditionCallCount++;
            latestPreviousState = previous;
            states.add(state);
            return true;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(conditionCallCount, 1);
      expect(latestPreviousState, 0);
    });

    testWidgets(
        'calls listenWhen with previous listener state and current state notifier state',
        (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterState = CounterState();
      const expectedStates = [2];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listenWhen: (previous, state) {
            listenWhenCallCount++;
            if ((previous + state) % 3 == 0) {
              latestPreviousState = previous;
              states.add(state);
              return true;
            }
            return false;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 3);
      expect(latestPreviousState, 1);
    });

    testWidgets(
        'calls listenWhen on multiple state change with correct previous '
        'and current states', (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterState = CounterState();
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listenWhen: (previous, state) {
            listenWhenCallCount++;
            latestPreviousState = previous;
            states.add(state);
            return true;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      await tester.pump();
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 2);
      expect(latestPreviousState, 1);
    });

    testWidgets(
        'does not call listener when listenWhen returns false on single state '
        'change', (tester) async {
      final states = <int>[];
      final counterState = CounterState();
      const expectedStates = <int>[];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listenWhen: (_, __) => false,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on single state change',
        (tester) async {
      final states = <int>[];
      final counterState = CounterState();
      const expectedStates = [1];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listenWhen: (_, __) => true,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'does not call listener when listenWhen returns false '
        'on multiple state changes', (tester) async {
      final states = <int>[];
      final counterState = CounterState();
      const expectedStates = <int>[];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listenWhen: (_, __) => false,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on multiple state change',
        (tester) async {
      final states = <int>[];
      final counterState = CounterState();
      const expectedStates = [1, 2, 3, 4];
      await tester.pumpWidget(
        LidListener<int>(
          stateNotifier: counterState,
          listenWhen: (_, __) => true,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();
      counterState.increment();
      await tester.pump();

      expect(states, expectedStates);
    });
  });
}
