import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lid/flutter_lid.dart';
import 'package:state_notifier/state_notifier.dart';

class CounterState extends StateNotifier<int> {
  CounterState() : super(0);

  void increment() => state += 1;
}

void main() {
  group('MultiLidListener', () {
    testWidgets('throws if initialized with no listeners and no child',
        (tester) async {
      try {
        await tester.pumpWidget(
          MultiLidListener(
            listeners: null,
            child: null,
          ),
        );
        fail('should throw AssertionError');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no listeners', (tester) async {
      try {
        await tester.pumpWidget(
          MultiLidListener(
            listeners: null,
            child: const SizedBox(),
          ),
        );
        fail('should throw AssertionError');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child', (tester) async {
      try {
        await tester.pumpWidget(
          MultiLidListener(
            listeners: const <Null>[],
            child: null,
          ),
        );
        fail('should throw AssertionError');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('calls listeners on state changes', (tester) async {
      final statesA = <int>[];
      const expectedStatesA = [1, 2];
      final counterStateA = CounterState();

      final statesB = <int>[];
      final expectedStatesB = [1];
      final counterStateB = CounterState();

      await tester.pumpWidget(
        MultiLidListener(
          listeners: [
            LidListener<int>(
              stateNotifier: counterStateA,
              listener: (context, state) => statesA.add(state),
            ),
            LidListener<int>(
              stateNotifier: counterStateB,
              listener: (context, state) => statesB.add(state),
            ),
          ],
          child: const SizedBox(key: Key('multiLidListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multiLidListener_child')), findsOneWidget);

      counterStateA.increment();
      await tester.pump();
      counterStateA.increment();
      await tester.pump();
      counterStateB.increment();
      await tester.pump();

      expect(statesA, expectedStatesA);
      expect(statesB, expectedStatesB);
    });

    testWidgets('calls listeners on state changes without explicit types',
        (tester) async {
      final statesA = <int>[];
      const expectedStatesA = [1, 2];
      final counterStateA = CounterState();

      final statesB = <int>[];
      final expectedStatesB = [1];
      final counterStateB = CounterState();

      await tester.pumpWidget(
        MultiLidListener(
          listeners: [
            LidListener<int>(
              stateNotifier: counterStateA,
              listener: (context, state) => statesA.add(state),
            ),
            LidListener<int>(
              stateNotifier: counterStateB,
              listener: (context, state) => statesB.add(state),
            ),
          ],
          child: const SizedBox(key: Key('multiLidListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multiLidListener_child')), findsOneWidget);

      counterStateA.increment();
      await tester.pump();
      counterStateA.increment();
      await tester.pump();
      counterStateB.increment();
      await tester.pump();

      expect(statesA, expectedStatesA);
      expect(statesB, expectedStatesB);
    });
  });
}
