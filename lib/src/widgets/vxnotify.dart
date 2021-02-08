import 'dart:async';

import 'package:flutter/material.dart';

import '../vxstate.dart';

/// Function signature for the callback with context.
typedef ContextCallback = void Function(
    BuildContext context, VxMutation mutation);

/// Helper widget that executes the provided callbacks with context
/// on execution of the mutations. Useful to show SnackBar or navigate
/// to a different route after a mutation.
class VxNotify extends StatefulWidget {
  /// Optional child widget
  final Widget child;

  /// Map of mutations and their corresponding callback
  final Map<Type, ContextCallback> mutations;

  /// [VxNotify] make callbacks for given mutations
  VxNotify({
    this.child,
    @required this.mutations,
  }) : assert(mutations != null);

  @override
  _VxNotifyState createState() => _VxNotifyState();
}

class _VxNotifyState extends State<VxNotify> {
  StreamSubscription eventSub;

  @override
  void initState() {
    super.initState();
    final mutations = widget.mutations.keys.toSet();
    final stream = VxState.events.where(
      (e) => mutations.contains(e.runtimeType),
    );
    eventSub = stream.listen((e) {
      widget.mutations[e.runtimeType]?.call(context, e);
    });
  }

  @override
  void dispose() {
    eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // allow null child
    return widget.child ?? SizedBox();
  }
}
