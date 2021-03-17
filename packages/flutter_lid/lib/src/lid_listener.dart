import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';
import 'package:state_notifier/state_notifier.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the state `value` and is responsible for executing in response to
/// `state` changes.
typedef LidWidgetListener<T> = void Function(BuildContext context, T value);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [LidWidgetListener] of [LidListener]
/// with the current `state`
typedef ListenerCondition<T> = bool Function(T previous, T current);

/// {@template lid_listener}
/// Takes a [LidWidgetListener] and an optional [stateNotifier] and invokes
/// the [listener] in response to `state` changes in the [stateNotifier].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `LidBuilder`.
/// Specify the [stateNotifier].
///
/// ```dart
/// LidListener<StateType>(
///   stateNotifier: stateNotifier,
///   listener: (context, state) {
///     // do stuff here based on State Notifier's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
/// {@template lid_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [stateNotifier] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [stateNotifier]
/// when the [LidListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// LidListener<StateType>(
///   stateNotifier: stateNotifier,
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on State Notifier's state
///   }
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class LidListener<T> extends SingleChildStatefulWidget {
  const LidListener({
    Key? key,
    required this.listener,
    required this.stateNotifier,
    this.listenWhen,
    this.child,
  }) : super(key: key, child: child);

  /// The [LidWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final LidWidgetListener<T> listener;

  /// The [stateNotifier] that the [LidBuilder] will interact with.
  final StateNotifier<T> stateNotifier;

  /// {@macro lid_listener_listen_when}
  final ListenerCondition<T>? listenWhen;

  /// The widget which will be rendered as a descendant of the [LidListener].
  final Widget? child;

  @override
  _LidListenerState<T> createState() => _LidListenerState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<StateNotifier<T>>('stateNotifier', stateNotifier),
      )
      ..add(
        ObjectFlagProperty<LidWidgetListener<T>>.has('listener', listener),
      )
      ..add(
        ObjectFlagProperty<ListenerCondition<T>>.has('listenWhen', listenWhen),
      );
  }
}

class _LidListenerState<T> extends SingleChildState<LidListener<T>> {
  late T _state;
  T? _previousState;
  VoidCallback? _removeListener;
  late StateNotifier<T> _stateNotifier = widget.stateNotifier;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(LidListener<T> oldWidget) {
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

  void _listener(T value) {
    _state = value;
    if (_previousState != null) {
      if (widget.listenWhen?.call(_previousState ?? _state, value) ?? true) {
        widget.listener(context, value);
      }
    }
    _previousState = _state;
  }

  @override
  void dispose() {
    _removeListener?.call();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) =>
      child ?? const SizedBox.shrink();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('state', _state));
  }
}
