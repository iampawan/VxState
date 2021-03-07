import 'package:flutter/material.dart';
import 'package:vxstate/vxstate.dart';

import 'mystore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final store = MyStore();
    return VxState(
      store: store,
      interceptors: [LogInterceptor()],
      child: MaterialApp(
        title: 'VxState Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: HomePage(
          store: store,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final MyStore store;

  const HomePage({Key? key, required this.store}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // VxState.listen(context, to: [FetchApi]);
    print("Build Called");

    return Scaffold(
        appBar: AppBar(
          title: const Text("Counter example"),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                VxBuilder(
                    mutations: {IncrementMutation, DecrementMutation},
                    builder: (ctx, _) {
                      if (store.isFetching)
                        return const CircularProgressIndicator();
                      else
                        return Text(
                          "${store.counter.count.toString()}",
                          style: Theme.of(context).textTheme.headline4,
                        );
                    }),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  "${store.data}",
                ),
                const SizedBox(
                  height: 20.0,
                ),
                VxBuilder(
                    builder: (context, status) {
                      print("$status");
                      if (status == VxStatus.loading)
                        return const CircularProgressIndicator();
                      else
                        return Text(
                          "$status ${store.data}",
                        );
                    },
                    mutations: {FetchApi})
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => IncrementMutation(),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            const SizedBox(
              width: 10.0,
            ),
            FloatingActionButton(
              onPressed: () => DecrementMutation(),
              tooltip: 'Decrement',
              child: const Icon(Icons.remove),
            ), //
            const SizedBox(
              width: 10.0,
            ), //
            FloatingActionButton.extended(
              onPressed: () => FetchApi(),
              tooltip: 'Fetch API',
              label: const Text("Fetch API"),
            ), //// This trailing comma makes auto-formatting nicer for build methods.
          ],
        ));
  }
}
