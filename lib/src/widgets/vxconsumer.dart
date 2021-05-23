import 'dart:async';

import 'package:flutter/widgets.dart';

import '../vxstate.dart';
import 'vxnotifier.dart';

/// A stream builder like widget that accepts
/// mutations and rebuilds after their execution.
class VxConsumer<T> extends StatefulWidget {
  /// [builder] provides the child widget to rendered.
  final VxStateWidgetBuilder<T> builder;

  /// Widget will rerender every time any of [mutations] executes.
  final Set<Type> mutations;

  /// Map of mutations and their corresponding callback
  final Map<Type, ContextCallback> notifications;

  /// Creates widget to rerender child widgets when given
  /// [mutations] execute.
  const VxConsumer({
    required this.builder,
    required this.mutations,
    required this.notifications,
  });

  @override
  _VxConsumerState createState() => _VxConsumerState<T>();
}

class _VxConsumerState<T> extends State<VxConsumer> {
  StreamSubscription? eventSub;

  @override
  void initState() {
    super.initState();
    final notifications = widget.notifications.keys.toSet();
    final stream = VxState.events.where(
      (e) => notifications.contains(e.runtimeType),
    );
    eventSub = stream.listen((e) {
      widget.notifications[e.runtimeType]?.call(context, e);
    });
  }

  @override
  void dispose() {
    eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stream = VxState.events.where(
      (e) => widget.mutations.contains(e.runtimeType),
    );
    return StreamBuilder<VxMutation>(
      stream: stream,
      builder: (context, mut) {
        VxStatus? status;
        if (!mut.hasData || mut.connectionState == ConnectionState.waiting) {
          status = VxStatus.none;
        } else {
          status = mut.data?.status;
        }
        return widget.builder(context, VxState.store as T, status);
      },
    );
  }
}
