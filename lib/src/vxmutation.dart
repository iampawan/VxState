part of 'vxstate.dart';

/// Function signature for mutations that has deferred execution.
/// [VxMutation.next] accepts functions with this signature.
typedef VxMutationBuilder = VxMutation Function();

/// An implementation of this class holds the logic for updating the [VxStore].

abstract class VxMutation<T extends VxStore?> {
  /// Reference to the current instance of [Store]
  T? get store => VxState.store as T?;

  /// Status of this current mutation
  VxStatus? status;

  /// List of mutation to execute after current one.
  final List<VxMutationBuilder> _laterMutations = [];

  /// A mutation logic inside [perform] is executed immediately after
  /// creating an object of the mutation.
  VxMutation() {
    status = VxStatus.none;
    _run();
  }

  /// [_run] executes mutation.
  Future<void> _run() async {
    // Execute all the interceptors. If returns false cancel mutation.
    for (final i in VxState._interceptors) {
      if (!i.beforeMutation(this)) {
        return;
      }
    }

    try {
      // If the execution results in a Future then await it.
      // Useful for building an HTTP request using values from
      // some async source.
      status = VxStatus.loading;
      VxState.notify(this);
      dynamic result = perform();
      if (result is Future) {
        result = await result;
      }

      // If the result is a VxEffects object then pipe the
      // result to the branch function. If its result is async
      // await that. And finally notify the widgets again about
      // the end of execution.
      if (result != null && this is VxEffects) {
        final dynamic out = (this as VxEffects).fork(result);
        if (out is Future) {
          await out;
        }
        status = VxStatus.success;
        VxState.notify(this);
      }
      // Notify the widgets that execution is done
      VxState.notify(this);
      status = VxStatus.success;

      // Once this is done execute all the deferred mutations
      for (final mut in _laterMutations) {
        mut();
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      status = VxStatus.error;
      // If an exception happens in exec or VxEffects then
      // it is caught and sent to exception callback. This is
      // useful for showing a generic error message or crash reporting.
      onException(e, s);
      VxState.notify(this);
    }

    // Execute all the interceptors.
    for (final i in VxState._interceptors) {
      i.afterMutation(this);
    }
  }

  /// Adds the mutationBuilder to the list.
  void next(VxMutationBuilder mutationBuilder) {
    _laterMutations.add(mutationBuilder);
  }

  /// This function implements the logic of the mutation.
  /// It can return any value. If it is a [Future] it will be awaited.
  /// If it is [VxEffects] object, result will be piped to its
  /// [VxEffects.fork] call.
  dynamic perform();

  /// [onException] callback receives all the errors with their [StackTrace].
  /// If assertions are on, which usually means app is in debug mode, then
  /// both exception and stack trace is printed. This can be overridden by
  /// the mutation implementation.
  void onException(dynamic e, StackTrace s) {
    var isAssertOn = false;
    assert(isAssertOn = true);
    if (isAssertOn) {
      print(e);
      print(s);
    }
  }
}

/// Secondary mutation executed based on the result of the first.
/// Similar to chaining actions in Redux. For example, an http request
/// will have a success or a fail side effect after request is complete.
mixin VxEffects<ON> {
  /// Divide your branches from here to create a chain
  dynamic fork(ON result);
}

/// Implementation of this class can be used to act before or after
/// a mutation execution.
abstract class VxInterceptor {
  /// Function called before mutation is executed.
  /// Execution can be cancelled by returning false.
  bool beforeMutation(VxMutation mutation);

  /// Function called after mutation and its side effects are executed.
  void afterMutation(VxMutation mutation);
}
