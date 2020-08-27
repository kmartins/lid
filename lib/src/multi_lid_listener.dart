import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'lid_listener.dart';

/// {@template multi_lid_listener}
/// Merges multiple [LidListener] widgets into one widget tree.
///
/// [LidCubitListener] improves the readability and eliminates the need
/// to nest multiple [LidListener]s.
///
/// By using [MultiLidListener] we can go from:
///
/// ```dart
/// LidListener<StateType>(
///   listener: (context, state) {},
///   child: LidListener<StateType>(
///     stateNotifier: stateNotifier,
///     listener: (context, state) {},
///     child: LidListener<StateType>(
///       stateNotifier: stateNotifier,
///       listener: (context, state) {},
///       child: ChildA(),
///     ),
///   ),
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiLidListener(
///   listeners: [
///     LidListener<StateType>(
///       stateNotifier: stateNotifier,
///       listener: (context, state) {},
///     ),
///     LidListener<StateType>(
///       stateNotifier: stateNotifier,
///       listener: (context, state) {},
///     ),
///     LidListener<StateType>(
///       stateNotifier: stateNotifier,
///       listener: (context, state) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiLidListener] converts the [LidListener] list into a tree of nested
/// [LidListener] widgets.
/// As a result, the only advantage of using [MultiLidListener] is improved
/// readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiLidListener extends Nested {
  /// {@macro multi_lid_listener}
  MultiLidListener({
    Key key,
    @required List<LidListener> listeners,
    @required Widget child,
  })  : assert(listeners != null),
        assert(child != null),
        super(
          key: key,
          children: listeners,
          child: child,
        );
}
