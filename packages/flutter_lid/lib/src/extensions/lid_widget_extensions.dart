import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../flutter_lid.dart';

extension StateNotifierExtension<S> on StateNotifier<S> {
  Widget builder({
    Key? key,
    required LidWidgetBuilder<S> builder,
    BuilderCondition<S>? buildWhen,
    bool animate = false,
    AnimatedSwitcherTransitionBuilder transitionBuilder =
        AnimatedSwitcher.defaultTransitionBuilder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return LidBuilder<S>(
      key: key,
      stateNotifier: this,
      builder: builder,
      buildWhen: buildWhen,
      animate: animate,
      transitionBuilder: transitionBuilder,
      duration: duration,
    );
  }

  Widget listener({
    Key? key,
    required LidWidgetListener<S> listener,
    ListenerCondition<S>? listenWhen,
    Widget? child,
  }) {
    return LidListener<S>(
      key: key,
      stateNotifier: this,
      listener: listener,
      listenWhen: listenWhen,
      child: child,
    );
  }

  Widget consumer({
    Key? key,
    required LidWidgetBuilder<S> builder,
    BuilderCondition<S>? buildWhen,
    required LidWidgetListener<S> listener,
    ListenerCondition<S>? listenWhen,
    bool animate = false,
    AnimatedSwitcherTransitionBuilder transitionBuilder =
        AnimatedSwitcher.defaultTransitionBuilder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return LidConsumer<S>(
      key: key,
      stateNotifier: this,
      builder: builder,
      buildWhen: buildWhen,
      listener: listener,
      listenWhen: listenWhen,
      animate: animate,
      transitionBuilder: transitionBuilder,
      duration: duration,
    );
  }
}
