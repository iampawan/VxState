import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'inherited_model.dart';
part 'vxmutation.dart';

/// App's store should extend this class. An instance of this class is
/// given to [VxState] while initialization only once.
abstract class VxStore {}

/// The coordinating widget that keeps track of mutations
/// and the notify the same to the listening widgets.
class VxState extends StatelessWidget {
  /// App's root widget
  final Widget child;

  /// List of all mutation interceptors
  static List<VxInterceptor> _interceptors;

  /// This controller serves as the event broadcasting bus
  /// for the app.
  static final _events = StreamController<VxMutation>.broadcast();

  /// Broadcast stream of mutations executing across app
  static Stream<VxMutation> get events => _events.stream;

  /// Single store approach. This is set when initializing the app.
  static VxStore _store;

  /// Getter to get the current instance of [VxStore]. It can be
  /// casted to appropriate type by the widgets.
  static VxStore get store => _store;

  /// Keeps the set of mutations executed between previous and
  /// current build cycle.
  static final Set<Type> _buffer = <Type>{};

  /// Notifies widgets that mutation has executed.
  static void notify(VxMutation mutation) {
    // Adds the mutation type to the _events stream, for the
    // _VxStateModel to rebuild, and to _buffer for keeping
    // track of all the mutations in the build cycle.
    _buffer.add(mutation.runtimeType);
    _events.add(mutation);
  }

  /// Filters the main event stream with the mutation
  /// given as parameter. This can be used to perform some callbacks inside
  /// widgets after some mutation executed.
  static Stream<VxMutation> streamOf(Type mutation) {
    return _events.stream.where((e) => e.runtimeType == mutation);
  }

  /// Attaches context to the mutations given in `to` param.
  /// When a mutation specified execute widget will rebuild.
  static void listen(BuildContext context, {List<Type> to}) {
    for (var mutant in to) {
      context.dependOnInheritedWidgetOfExactType<_VxStateModel>(
        aspect: mutant,
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (events != null) {
      events.forEach((element) {
        properties.add(DiagnosticsProperty(
            element.runtimeType.toString(), element.store.toString()));
      });
    }
  }

  /// Constructor collects the store instance and interceptors.
  VxState({
    @required VxStore store,
    @required this.child,
    List<VxInterceptor> interceptors = const [],
  }) {
    assert(store != null, "Uninitialized store");
    assert(interceptors != null, "Interceptor list can't be null");

    VxState._store = store;
    VxState._interceptors = interceptors;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _events.stream,
      builder: (context, _) {
        // Copy all the mutations that executed before
        // current build and clear that buffer
        final clone = <Type>{}..addAll(_buffer);
        _buffer.clear();

        // Rebuild inherited model with all the mutations
        // inside "clone" as the aspects changed
        return _VxStateModel(child: child, recent: clone);
      },
    );
  }
}
