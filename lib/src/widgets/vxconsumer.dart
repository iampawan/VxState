import 'dart:async';

import 'package:flutter/widgets.dart';

import '../vxstate.dart';
import 'vxnotifier.dart';

/// A stream builder like widget that accepts
/// mutations and rebuilds after their execution.
class VxConsumer extends StatefulWidget {
  /// [builder] provides the child widget to rendered.
  final WidgetBuilder builder;

  /// Widget will rerender every time any of [mutations] executes.
  final Set<Type> mutations;

  /// Map of mutations and their corresponding callback
  final Map<Type, ContextCallback> notifications;

  /// Creates widget to rerender child widgets when given
  /// [mutations] execute.
  VxConsumer({
    @required this.builder,
    @required this.mutations,
    @required this.notifications,
  })  : assert(mutations != null),
        assert(notifications != null);

  @override
  _VxConsumerState createState() => _VxConsumerState();
}

class _VxConsumerState extends State<VxConsumer> {
  StreamSubscription eventSub;

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
      builder: (context, _) => widget.builder(context),
    );
  }
}
