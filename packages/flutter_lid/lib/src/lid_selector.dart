import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:state_notifier/state_notifier.dart';

import 'lid_builder.dart';
import 'lid_listener.dart';

/// Signature for the `selector` function which
/// is responsible for returning a selected value, [T], based on [state].
typedef LidWidgetSelector<S, T> = T Function(S state);

/// {@template lid_selector}
/// [LidSelector] is analogous to [LidBuilder] but allows developers to
/// filter updates by selecting a new value based on the state.
/// Unnecessary builds are prevented if the selected value does not change.
///
/// **Note**: the selected value must be immutable in order for [LidSelector]
/// to accurately determine whether [builder] should be called again.
///
/// ```dart
/// LifSelector<State, SelectedState>(
///   selector: (state) {
///     // return selected state based on the provided state.
///   },
///   builder: (context, state) {
///     // return widget here based on the selected state.
///   },
/// )
/// ```
/// {@endtemplate}
class LidSelector<S, T> extends StatefulWidget {
  /// {@macro lid_selector}
  const LidSelector({
    Key? key,
    required this.stateNotifier,
    required this.selector,
    required this.builder,
    this.animate = false,
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  /// The [stateNotifier] that the [LidSelector] will interact with.
  final StateNotifier<S> stateNotifier;

  /// The [builder] function which will be invoked
  /// when the selected state changes.
  /// The [builder] takes the [BuildContext] and selected `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [LidBuilder].
  final LidWidgetBuilder<T> builder;

  /// The [selector] function which will be invoked on each widget build
  /// and is responsible for returning a selected value of type [T] based on
  /// the current state.
  final LidWidgetSelector<S, T> selector;

  // /// Animates when change state, using [AnimatedSwitcher]
  final bool animate;

  /// Type of the animation, the default animation is FadeIn
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  /// The duration of the animation
  final Duration duration;

  @override
  State<LidSelector<S, T>> createState() => _LidSelectorState<S, T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<StateNotifier<S>>('stateNotifier', stateNotifier),
      )
      ..add(
        ObjectFlagProperty<LidWidgetBuilder<T>>.has('builder', builder),
      )
      ..add(FlagProperty('animate',
          value: animate,
          ifTrue: 'animates when changing state',
          ifFalse: 'not animates when changing state'))
      ..add(IntProperty('duration', duration.inMilliseconds, unit: 'ms'))
      ..add(
        ObjectFlagProperty<AnimatedSwitcherTransitionBuilder>.has(
            'transitionBuilder', transitionBuilder),
      );
  }
}

class _LidSelectorState<S, T> extends State<LidSelector<S, T>> {
  late StateNotifier<S> _stateNotifier = widget.stateNotifier;
  late T _state;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(LidSelector<S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stateNotifier != oldWidget.stateNotifier) {
      //Restart state
      _stateNotifier = widget.stateNotifier;
      _listen();
    }
  }

  void _listen() => _stateNotifier
      .addListener(
        (state) => _state = widget.selector(state),
      )
      .call();

  @override
  Widget build(BuildContext context) {
    return LidListener<S>(
      listener: (context, state) {
        final selectedState = widget.selector(state);
        if (_state != selectedState) {
          setState(() => _state = selectedState);
        }
      },
      stateNotifier: widget.stateNotifier,
      child: widget.animate
          ? AnimatedSwitcher(
              duration: widget.duration,
              transitionBuilder: widget.transitionBuilder,
              child: widget.builder(context, _state),
            )
          : widget.builder(context, _state),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('state', _state))
      ..add(
        DiagnosticsProperty<StateNotifier<S>>('stateNotifier', _stateNotifier),
      );
  }
}
