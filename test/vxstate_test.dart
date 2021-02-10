import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:vxstate/vxstate.dart';

class TestStore extends VxStore {
  int count = 0;
}

class Increment extends VxMutation<TestStore> {
  @override
  void perform() {
    store.count++;
  }
}

class AsyncIncrement extends VxMutation<TestStore> {
  final Completer comp = Completer();

  @override
  void perform() async {
    await Future.delayed(Duration(milliseconds: 10));
    store.count++;
    comp.complete();
  }
}

class IncrementLater extends VxMutation<TestStore> {
  @override
  void perform() {
    next(() => Increment());
    next(() => Increment());
  }
}

class ExceptionMutation extends VxMutation<TestStore> {
  bool caught = false;

  @override
  void perform() {
    throw Exception();
  }

  @override
  void onException(dynamic e, StackTrace s) {
    caught = true;
  }
}

class MutationCounter extends VxInterceptor {
  int finished = 0;

  @override
  bool beforeMutation(VxMutation<VxStore> mutation) {
    return true;
  }

  @override
  void afterMutation(VxMutation<VxStore> mutation) {
    finished++;
  }
}

class MutationRejector extends VxInterceptor {
  int rejected = 0;

  @override
  bool beforeMutation(VxMutation<VxStore> mutation) {
    if (mutation is Increment) {
      rejected++;
      return false;
    }
    return true;
  }

  @override
  void afterMutation(VxMutation<VxStore> mutation) {}
}

void main() {
  group("event management", () {
    test('incrementing count', () {
      VxState(store: TestStore(), child: null);
      final store = VxState.store as TestStore;

      expect(store.count, 0);
      Increment();
      expect(store.count, 1);
    });

    test('stream of events', () {
      VxState(store: TestStore(), child: null);

      final stream = VxState.events;
      expectLater(stream.first, completion(isA<Increment>()));
      Increment();
    });

    test('stream of mutation events', () {
      VxState(store: TestStore(), child: null);

      final stream = VxState.streamOf(Increment);
      expectLater(stream.first, completion(isA<Increment>()));
      Increment();
    });

    test('exception catching', () {
      VxState(store: TestStore(), child: null);

      final em = ExceptionMutation();
      expect(em.caught, true);
    });

    test('lazy execution', () {
      VxState(store: TestStore(), child: null);
      final store = VxState.store as TestStore;

      IncrementLater();
      expect(store.count, 2);
    });

    test('async execution', () async {
      VxState(store: TestStore(), child: null);
      final store = VxState.store as TestStore;

      final mut = AsyncIncrement();
      expect(store.count, 0);
      await mut.comp.future;
      expect(store.count, 1);
    });

    test('interceptor execution', () async {
      final mutCount = MutationCounter();
      VxState(
        store: TestStore(),
        child: null,
        interceptors: [mutCount],
      );

      expect(mutCount.finished, 0);
      Increment();
      expect(mutCount.finished, 1);
    });

    test('interceptor rejection', () async {
      final mutReject = MutationRejector();
      VxState(
        store: TestStore(),
        child: null,
        interceptors: [mutReject],
      );
      final store = VxState.store as TestStore;

      expect(mutReject.rejected, 0);
      expect(store.count, 0);
      Increment();
      expect(mutReject.rejected, 1);
      expect(store.count, 0);
    });
  });
}
