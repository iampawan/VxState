import 'package:vxstate/vxstate.dart';
import 'package:http/http.dart' as http;

class MyStore extends VxStore {
  final counter = Counter();
  var data = "Hi";
  bool isFetching = false;

  @override
  String toString() {
    return "{counter: ${counter.count}, isFetching: $isFetching, data: $data}";
  }
}

class Counter {
  int count = 0;

  void increment() {
    count++;
  }

  void decrement() {
    count--;
  }
}

class IncrementMutation extends VxMutation<MyStore> {
  @override
  Future<void> perform() async {
    await Future.delayed(const Duration(seconds: 1));
    store?.counter.increment();
  }

  @override
  void onException(e, StackTrace s) {
    super.onException(e, s);
  }
}

class DecrementMutation extends VxMutation<MyStore> {
  @override
  void perform() {
    store?.counter.decrement();
  }
}

abstract class HttpEffects implements VxEffects<http.Response> {
  @override
  Future<void> fork(http.Response result) async {
    if (result.statusCode == 200) {
      success(result);
    } else {
      fail(result);
    }
  }

  void success(http.Response res);
  void fail(http.Response res);
}

class FetchApi extends VxMutation<MyStore> with HttpEffects {
  @override
  void fail(http.Response res) {
    store?.data = "Failed";
  }

  @override
  Future<http.Response> perform() async {
    return http.get(Uri.parse("https://en8brj58lmty9.x.pipedream.net"));
  }

  @override
  void success(http.Response res) {
    store?.data = res.body;
  }

  @override
  void onException(e, s) {
    store?.data = "Exception";
    super.onException(e, s);
  }
}

class LogInterceptor extends VxInterceptor {
  @override
  void afterMutation(VxMutation<VxStore?> mutation) {
    print("Next State ${mutation.store.toString()}");
  }

  @override
  bool beforeMutation(VxMutation<VxStore?> mutation) {
    print("Prev State ${mutation.store.toString()}");
    return true;
  }
}
