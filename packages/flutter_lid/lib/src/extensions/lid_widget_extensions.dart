import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../flutter_lid.dart';

extension StateNotifierExtension<S> on StateNotifier<S> {
  Widget toLidBuilder({
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

  Widget toLidListener({
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

  Widget toLidConsumer({
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

  Widget toLidSelector<T>({
    Key? key,
    required LidWidgetBuilder<T> builder,
    required LidWidgetSelector<S, T> selector,
    bool animate = false,
    AnimatedSwitcherTransitionBuilder transitionBuilder =
        AnimatedSwitcher.defaultTransitionBuilder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return LidSelector<S, T>(
      key: key,
      stateNotifier: this,
      selector: selector,
      builder: builder,
      animate: animate,
      transitionBuilder: transitionBuilder,
      duration: duration,
    );
  }
}
