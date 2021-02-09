import 'package:http/http.dart' as http;
import 'package:vxstate/vxstate.dart';

class MyStore extends VxStore {
  final counter = Counter();
  var data = "";
  bool isFetching = false;

  @override
  String toString() {
    return "{counter: ${counter.count}, isFetching: $isFetching, data: $data}";
  }
}

class Counter {
  int count = 0;

  increment() {
    count++;
  }

  decrement() {
    count--;
  }
}

class IncrementMutation extends VxMutation<MyStore> {
  @override
  make() {
    store.counter.increment();
  }
}

class DecrementMutation extends VxMutation<MyStore> {
  @override
  make() {
    store.counter.decrement();
  }
}

abstract class HttpEffects implements VxEffects<http.Request> {
  @override
  branch(http.Request result) async {
    final res = await http.Response.fromStream(await result.send());

    if (res.statusCode == 200) {
      success(res);
    } else {
      fail(res);
    }
  }

  void success(http.Response res);
  void fail(http.Response res);
}

class FetchApi extends VxMutation<MyStore> with HttpEffects {
  @override
  void fail(http.Response res) {
    store.isFetching = false;
    store.data = "Failed";
  }

  @override
  make() async {
    store.isFetching = true;
    return http.Request("GET", Uri.parse("https://google.com"));
  }

  @override
  void success(http.Response res) {
    store.isFetching = false;
    store.data = res.body;
  }

  @override
  onException(e, s) {
    store.isFetching = false;
    store.data = "Exception";
    super.onException(e, s);
  }
}

class LogInterceptor extends VxInterceptor {
  @override
  void afterMutation(VxMutation<VxStore> mutation) {
    print("Next State ${mutation.store.toString()}");
  }

  @override
  bool beforeMutation(VxMutation<VxStore> mutation) {
    print("Prev State ${mutation.store.toString()}");
    return true;
  }
}
