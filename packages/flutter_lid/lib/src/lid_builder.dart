import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:state_notifier/state_notifier.dart';

/// Signature for the `builder` function which takes the `BuildContext` and
/// the state `value` and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef LidWidgetBuilder<T> = Widget Function(BuildContext context, T value);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [LidBuilder] with the current `state`.
typedef BuilderCondition<T> = bool Function(T previous, T current);

/// {@template lid_builder}
/// [LidBuilder] handles building a widget in response to new `states`.
/// [LidBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed.
/// Specify the [stateNotifier].

/// Please refer to `LidListener` if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// ```dart
/// LidBuilder<StateType>(
///   stateNotifier: stateNotifier,
///   builder: (context, state) {
///   // return widget here based on State Notifier's state
///   }
/// )
/// ```
/// {@endtemplate}
/// {@template lid_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [LidBuilder] rebuilds.
/// [buildWhen] will be invoked on each [stateNotifier] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [stateNotifier] when
/// the [LidBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default `true` if previous
/// `state` is different current `state`, otherwise is `false`, however the
/// first time does not have an effect, always `true`.
///
/// ```dart
/// LidBuilder<StateType>(
///   stateNotifier: stateNotifier,
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///   // return widget here based on State Notifier's state
///   }
///)
/// ```
/// {@endtemplate}
class LidBuilder<T> extends StatefulWidget {
  /// {@macro lid_builder}
  const LidBuilder({
    Key? key,
    required this.builder,
    required this.stateNotifier,
    this.buildWhen,
  }) : super(key: key);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final LidWidgetBuilder<T> builder;

  /// The [stateNotifier] that the [LidBuilder] will interact with `true`.
  final StateNotifier<T> stateNotifier;

  /// {@macro lid_builder_build_when}
  final BuilderCondition<T>? buildWhen;

  @override
  _LidBuilderState<T> createState() => _LidBuilderState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<StateNotifier<T>>('stateNotifier', stateNotifier),
      )
      ..add(
        ObjectFlagProperty<LidWidgetBuilder<T>>.has('builder', builder),
      )
      ..add(
        ObjectFlagProperty<BuilderCondition<T>>.has('buildWhen', buildWhen),
      );
  }
}

class _LidBuilderState<T> extends State<LidBuilder<T>> {
  late T _state;
  T? _previousState;
  late StateNotifier<T> _stateNotifier = widget.stateNotifier;
  VoidCallback? _removeListener;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(LidBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stateNotifier != oldWidget.stateNotifier) {
      //Restart state
      _previousState = null;
      _stateNotifier = widget.stateNotifier;
      _listen();
    }
  }

  void _listen() {
    _removeListener?.call();
    _removeListener = _stateNotifier.addListener(_listener);
  }

  // Build first time forever, without pass through [buildWhen].
  // First time = _lid == nul
  void _listener(T value) {
    _state = value;
    final builderCondition =
        widget.buildWhen?.call(_previousState ?? _state, value) ??
            _defaultBuilderCondition(_previousState ?? _state, value);
    if (builderCondition) {
      setState(() {});
    }
    _previousState = _state;
  }

  @override
  void dispose() {
    _removeListener?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _state);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('state', _state))
      ..add(
        DiagnosticsProperty<StateNotifier<T>>('stateNotifier', _stateNotifier),
      );
  }

  /// Not to rebuild if previous `state` is equal current `state`.
  bool _defaultBuilderCondition(T previous, T current) => previous != current;
}
