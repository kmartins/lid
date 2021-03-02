import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';

import '../flutter_lid.dart';

extension LidExtension<T> on StateNotifier<T> {
  Widget toLidBuilder({
    Key? key,
    required LidWidgetBuilder<T> builder,
    BuilderCondition<T>? buildWhen,
  }) {
    return LidBuilder<T>(
      key: key,
      stateNotifier: this,
      builder: builder,
      buildWhen: buildWhen,
    );
  }

  Widget toLidListener({
    Key? key,
    required LidWidgetListener<T> listener,
    ListenerCondition<T>? listenWhen,
    Widget? child,
  }) {
    return LidListener<T>(
      key: key,
      stateNotifier: this,
      listener: listener,
      listenWhen: listenWhen,
      child: child,
    );
  }

  Widget toLidConsumer({
    Key? key,
    required LidWidgetBuilder<T> builder,
    BuilderCondition<T>? buildWhen,
    required LidWidgetListener<T> listener,
    ListenerCondition<T>? listenWhen,
  }) {
    return LidConsumer<T>(
      key: key,
      stateNotifier: this,
      builder: builder,
      buildWhen: buildWhen,
      listener: listener,
      listenWhen: listenWhen,
    );
  }
}
