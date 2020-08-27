import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lid/flutter_lid.dart';
import 'package:state_notifier/state_notifier.dart';

class CounterState extends StateNotifier<int> {
  CounterState() : super(0);

  void increment() => state += 1;
}

void main() {
  group('LidConsumer', () {
    testWidgets('throws AssertionError if builder and state notifier are null',
        (tester) async {
      try {
        await tester.pumpWidget(
          LidConsumer<int>(
            stateNotifier: null,
            builder: null,
            listener: (_, __) {},
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws AssertionError if builder is null', (tester) async {
      try {
        await tester.pumpWidget(
          LidConsumer<int>(
            stateNotifier: CounterState(),
            builder: null,
            listener: (_, __) {},
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws AssertionError if listener is null', (tester) async {
      try {
        await tester.pumpWidget(
          LidConsumer<int>(
            stateNotifier: null,
            builder: (_, __) => const SizedBox(),
            listener: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('debugFillProperties', (tester) async {
      final counterState = CounterState();
      final child = LidConsumer<int>(
        stateNotifier: counterState,
        buildWhen: (_, __) => true,
        listenWhen: (_, __) => true,
        listener: (_, __) {},
        builder: (_, value) {
          return Text(
            '$value',
            textDirection: TextDirection.ltr,
          );
        },
      );

      expect(
        child.toString(),
        "LidConsumer<int>(stateNotifier: Instance of 'CounterState', has builder, has buildWhen, has listener, has listenWhen)",
      );
    });

    testWidgets(
        'accesses the state notifier directly and passes initial state to builder and '
        'nothing to listener', (tester) async {
      final counterState = CounterState();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LidConsumer<int>(
              stateNotifier: counterState,
              builder: (context, state) {
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
    });

    testWidgets(
        'accesses the state notifier directly '
        'and passes multiple states to builder and listener', (tester) async {
      final counterState = CounterState();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LidConsumer<int>(
              stateNotifier: counterState,
              builder: (context, state) {
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
      counterState.increment();
      await tester.pump();
      expect(find.text('State: 1'), findsOneWidget);
      expect(listenerStates, [1]);
    });

    testWidgets('does not trigger rebuilds when buildWhen evaluates to false',
        (tester) async {
      final counterState = CounterState();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LidConsumer<int>(
              stateNotifier: counterState,
              buildWhen: (previous, current) => (previous + current) % 3 == 0,
              builder: (context, state) {
                builderStates.add(state);
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterState.increment();
      await tester.pump();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, [1]);

      counterState.increment();
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 2]);
      expect(listenerStates, [1, 2]);
    });

    testWidgets('does not trigger listen when listenWhen evaluates to false',
        (tester) async {
      final counterState = CounterState();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LidConsumer<int>(
              stateNotifier: counterState,
              builder: (context, state) {
                builderStates.add(state);
                return Text('State: $state');
              },
              listenWhen: (previous, current) => (previous + current) % 3 == 0,
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterState.increment();
      await tester.pump();

      expect(find.text('State: 1'), findsOneWidget);
      expect(builderStates, [0, 1]);
      expect(listenerStates, isEmpty);

      counterState.increment();
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 1, 2]);
      expect(listenerStates, [2]);
    });
  });
}
