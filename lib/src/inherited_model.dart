part of 'vxstate.dart';

/// Tracks the listener widgets and notify them when
/// their corresponding mutation executes
class _VxStateModel extends InheritedModel {
  final Set<Type> recent;

  _VxStateModel({Widget child, this.recent}) : super(child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  @override
  bool updateShouldNotifyDependent(
      covariant InheritedModel oldWidget, Set dependencies) {
    // check if there is a mutation executed for which
    // dependent has listened
    return dependencies.intersection(recent).isNotEmpty;
  }
}
