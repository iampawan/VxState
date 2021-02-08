import 'package:flutter/widgets.dart';

import '../vxstate.dart';

/// A stream builder like widget that accepts
/// mutations and rebuilds after their execution.
class VxBuild extends StatelessWidget {
  /// [builder] provides the child widget to rendered.
  final WidgetBuilder builder;

  /// Widget will rerender every time any of [mutations] executes.
  final Set<Type> mutations;

  /// Creates widget to rerender child widgets when given
  /// [mutations] execute.
  VxBuild({
    @required this.builder,
    @required this.mutations,
  }) : assert(mutations != null);

  @override
  Widget build(BuildContext context) {
    final stream = VxState.events.where(
      (e) => mutations.contains(e.runtimeType),
    );
    return StreamBuilder<VxMutation>(
      stream: stream,
      builder: (context, _) => builder(context),
    );
  }
}
