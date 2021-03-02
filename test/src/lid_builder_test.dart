import 'package:flutter/material.dart';
import 'package:flutter_lid/flutter_lid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_notifier/state_notifier.dart';

class ThemeState extends StateNotifier<ThemeData> {
  ThemeState() : super(ThemeData.light());

  void setDarkTheme() => state = ThemeData.dark();
  void setLightTheme() => state = ThemeData.light();
}

class DarkThemeState extends StateNotifier<ThemeData> {
  DarkThemeState() : super(ThemeData.dark());

  void setDarkTheme() => state = ThemeData.dark();
  void setLightTheme() => state = ThemeData.light();
}

class MyThemeApp extends StatefulWidget {
  const MyThemeApp({
    Key? key,
    required StateNotifier<ThemeData> themeState,
    required Function onBuild,
  })   : _themeState = themeState,
        _onBuild = onBuild,
        super(key: key);

  final StateNotifier<ThemeData> _themeState;
  final Function _onBuild;

  @override
  State<MyThemeApp> createState() => MyThemeAppState();
}

class MyThemeAppState extends State<MyThemeApp> {
  late StateNotifier<ThemeData> themeState = widget._themeState;
  late Function onBuild = widget._onBuild;

  @override
  Widget build(BuildContext context) {
    return LidBuilder<ThemeData>(
      stateNotifier: themeState,
      builder: (context, theme) {
        onBuild();
        return MaterialApp(
          key: const Key('material_app'),
          theme: theme,
          home: Column(
            children: [
              ElevatedButton(
                key: const Key('raised_button_1'),
                onPressed: () {
                  setState(() => themeState = DarkThemeState());
                },
                child: const Text('raised_button_1'),
              ),
              ElevatedButton(
                key: const Key('raised_button_2'),
                onPressed: () {
                  setState(() => themeState = themeState);
                },
                child: const Text('raised_button_2'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CounterState extends StateNotifier<int> {
  CounterState() : super(0);

  void increment() => state += 1;
}

class MyCounterApp extends StatefulWidget {
  const MyCounterApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyCounterAppState();
}

class MyCounterAppState extends State<MyCounterApp> {
  final CounterState _counter = CounterState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: const Key('myCounterApp'),
        body: Column(
          children: <Widget>[
            LidBuilder<int>(
              stateNotifier: _counter,
              buildWhen: (previousState, state) {
                return (previousState + state) % 3 == 0;
              },
              builder: (context, count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppTextCondition'),
                );
              },
            ),
            LidBuilder<int>(
              stateNotifier: _counter,
              builder: (context, count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppText'),
                );
              },
            ),
            ElevatedButton(
              key: const Key('myCounterAppIncrementButton'),
              onPressed: _counter.increment,
              child: const Text('myCounterAppIncrementButton'),
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  group('LidBuilder', () {
    testWidgets('debugFillProperties', (tester) async {
      final counterState = CounterState();
      final child = LidBuilder<int>(
        stateNotifier: counterState,
        buildWhen: (_, __) => true,
        builder: (_, value) {
          return Text(
            '$value',
            textDirection: TextDirection.ltr,
          );
        },
      );

      expect(
        child.toString(),
        "LidBuilder<int>(stateNotifier: Instance of 'CounterState', has builder, has buildWhen)",
      );

      await tester.pumpWidget(child);

      final state = tester.state(find.byWidget(child));

      expect(state.toString(), endsWith('(state: 0)'));

      counterState.increment();

      expect(state.toString(), endsWith('(state: 1)'));
    });

    testWidgets('passes initial state to widget', (tester) async {
      final themeState = ThemeState();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeState: themeState,
          onBuild: () => numBuilds++,
        ),
      );

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(numBuilds, 1);
      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);
    });

    testWidgets('receives events and sends state updates to widget',
        (tester) async {
      final themeState = ThemeState();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeState: themeState,
          onBuild: () => numBuilds++,
        ),
      );

      themeState.setDarkTheme();

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'updates when the state notifier is changed at runtime to a different state notifier and '
        'unsubscribes from old state notifier', (tester) async {
      final themeState = ThemeState();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeState: themeState,
          onBuild: () => numBuilds++,
        ),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(themeState.hasListeners, isTrue);
      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_1')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(themeState.hasListeners, isFalse);
      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeState.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(themeState.hasListeners, isFalse);
      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'does not update when the state_notifier is changed at runtime to same state_notifier '
        'and stays subscribed to current state_notifier', (tester) async {
      final themeState = DarkThemeState();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeState: themeState,
          onBuild: () => numBuilds++,
        ),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(themeState.hasListeners, isTrue);
      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_2')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(themeState.hasListeners, isTrue);
      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeState.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(themeState.hasListeners, isTrue);
      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets('shows latest state instead of initial state', (tester) async {
      final themeState = ThemeState()..setDarkTheme();
      await tester.pumpAndSettle();

      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(
          themeState: themeState,
          onBuild: () => numBuilds++,
        ),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);
    });

    testWidgets('with buildWhen only rebuilds when buildWhen evaluates to true',
        (tester) async {
      await tester.pumpWidget(const MyCounterApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('myCounterApp')), findsOneWidget);

      final incrementButtonFinder =
          find.byKey(const Key('myCounterAppIncrementButton'));
      expect(incrementButtonFinder, findsOneWidget);

      final counterText1 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText1.data, '0');

      final conditionalCounterText1 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText1.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText2 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText2.data, '1');

      final conditionalCounterText2 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText2.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText3 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText3.data, '2');

      final conditionalCounterText3 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText3.data, '2');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText4 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText4.data, '3');

      final conditionalCounterText4 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText4.data, '2');
    });
  });
}
