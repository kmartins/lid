import 'package:flutter/material.dart';
import 'package:flutter_lid/flutter_lid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_notifier/state_notifier.dart';

class CounterState extends StateNotifier<int> {
  CounterState() : super(0);

  void increment() => state += 1;

  // ignore: use_setters_to_change_properties
  void setCounterValue(int value) => state = value;
}

void main() {
  group('LidSelector', () {
    testWidgets('debugFillProperties', (tester) async {
      final counterState = CounterState();
      final child = LidSelector<int, bool>(
        stateNotifier: counterState,
        selector: (state) => state % 2 == 0,
        builder: (_, value) {
          return Text(
            '$value',
            textDirection: TextDirection.ltr,
          );
        },
      );

      expect(
          child.toString(),
          "LidSelector<int, bool>(stateNotifier: Instance of 'CounterState', has builder, " +
              "not animates when changing state, duration: 300ms, has transitionBuilder)");

      await tester.pumpWidget(child);

      final state = tester.state(find.byWidget(child));

      expect(state.toString(),
          endsWith("(state: true, stateNotifier: Instance of 'CounterState')"));

      counterState.increment();

      expect(
          state.toString(),
          endsWith(
              "(state: false, stateNotifier: Instance of 'CounterState')"));
    });

    testWidgets('renders with correct state', (tester) async {
      final counterState = CounterState();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: LidSelector<int, bool>(
            stateNotifier: counterState,
            selector: (state) => state % 2 == 0,
            builder: (context, state) {
              builderCallCount++;
              return Text('isEven: $state');
            },
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(builderCallCount, equals(1));
    });

    testWidgets('only rebuilds when selected state changes', (tester) async {
      final counterState = CounterState();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: LidSelector<int, bool>(
            stateNotifier: counterState,
            selector: (state) => state == 1,
            builder: (context, state) {
              builderCallCount++;
              return Text('equals 1: $state');
            },
          ),
        ),
      );

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(1));

      counterState.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: true'), findsOneWidget);
      expect(builderCallCount, equals(2));

      counterState.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(3));

      counterState.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(3));
    });

    testWidgets('rebuilds when stateNotifier is changed at runtime',
        (tester) async {
      final firstCounterState = CounterState();
      final secondCounterState = CounterState()..setCounterValue(100);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: LidSelector<int, bool>(
            stateNotifier: firstCounterState,
            selector: (state) => state % 2 == 0,
            builder: (context, state) => Text('isEven: $state'),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);

      firstCounterState.increment();
      await tester.pumpAndSettle();
      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: LidSelector<int, bool>(
            stateNotifier: secondCounterState,
            selector: (state) => state % 2 == 0,
            builder: (context, state) => Text('isEven: $state'),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(find.text('isEven: false'), findsNothing);

      secondCounterState.increment();
      await tester.pumpAndSettle();

      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);
    });

    testWidgets('animates widget when receives a new state', (tester) async {
      final counterState = CounterState();
      var builderCallCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: LidSelector<int, bool>(
            stateNotifier: counterState,
            selector: (state) => state % 2 == 0,
            animate: true,
            builder: (context, state) {
              builderCallCount++;
              if (state) {
                return Text('isEven: $state');
              } else {
                return TextButton(
                  onPressed: null,
                  child: Text('isEven: $state'),
                );
              }
            },
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'isEven: false'), findsNothing);

      counterState.increment();
      await tester.pump();

      expect(find.text('isEven: true'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'isEven: false'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('isEven: true'), findsNothing);
      expect(find.widgetWithText(TextButton, 'isEven: false'), findsOneWidget);

      expect(builderCallCount, 2);
    });
  });

  group('with extension', () {
    testWidgets('renders with correct state', (tester) async {
      final counterState = CounterState();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: counterState.toLidSelector<bool>(
            selector: (state) => state % 2 == 0,
            builder: (context, state) {
              builderCallCount++;
              return Text('isEven: $state');
            },
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(builderCallCount, equals(1));
    });
  });
}
