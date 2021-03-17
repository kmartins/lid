import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:state_notifier/state_notifier.dart';

import 'lid_builder.dart';
import 'lid_listener.dart';

/// {@template lid_consumer}
/// [LidConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [LidConsumer] is analogous to a nested `LidListener`
/// and `LidBuilder` but reduces the amount of boilerplate needed.
/// [LidConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [stateNotifier].
///
/// [LidConsumer] takes a required `LidWidgetBuilder`
/// and `CubitWidgetListener` and [stateNotifier] and an optional
/// `LidBuilderCondition`, and `LidListenerCondition`.
///
/// ```dart
/// LidConsumer<StateType>(
///   stateNotifier: stateNotifier,
///   listener: (context, state) {
///     // do stuff here based on State Notifier's state
///   },
///   builder: (context, state) {
///     // return widget here based on State Notifier's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [stateNotifier] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [stateNotifier] when
/// the [LidConsumer] is initialized.
/// [listenWhen] is optional and if it isn't implemented,
/// it will default to `true`.
/// [buildWhen] is optional and if omitted, it will default `true` if previous
/// `state` is different current `state`, otherwise is `false`, however the
/// first time does not have an effect, always `true`.
///
/// ```dart
/// CubitConsumer<CubitA, CubitAState>(
///   stateNotifier: stateNotifier,
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on State Notifier's state
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on State Notifier's state
///   }
/// )
/// ```
/// {@endtemplate}
class LidConsumer<S> extends StatelessWidget {
  /// Takes the `BuildContext` along with the [stateNotifier] `state`
  /// and is responsible for executing in response to `state` changes.
  final LidWidgetListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [LidConsumer] with the current `state`.
  final ListenerCondition<S>? listenWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final BuilderCondition<S>? buildWhen;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final LidWidgetBuilder<S> builder;

  /// The [stateNotifier] that the [LidConsumer] will interact with.
  final StateNotifier<S> stateNotifier;

  /// {@macro lid_consumer}
  const LidConsumer({
    Key? key,
    required this.listener,
    required this.stateNotifier,
    required this.builder,
    this.listenWhen,
    this.buildWhen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LidListener(
      listener: listener,
      stateNotifier: stateNotifier,
      listenWhen: listenWhen,
      child: LidBuilder(
        stateNotifier: stateNotifier,
        builder: builder,
        buildWhen: buildWhen,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<StateNotifier<S>>('stateNotifier', stateNotifier),
      )
      ..add(
        ObjectFlagProperty<LidWidgetBuilder<S>>.has('builder', builder),
      )
      ..add(
        ObjectFlagProperty<BuilderCondition<S>>.has('buildWhen', buildWhen),
      )
      ..add(
        ObjectFlagProperty<LidWidgetListener<S>>.has('listener', listener),
      )
      ..add(
        ObjectFlagProperty<ListenerCondition<S>>.has('listenWhen', listenWhen),
      );
  }
}
