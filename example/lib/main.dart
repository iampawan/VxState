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
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final MyStore store = VxState.store as MyStore;
    // VxState.watch(context, on: [FetchApi]);
    print("Build Called");

    return Scaffold(
        appBar: AppBar(
          title: const Text("Counter example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  VxConsumer<MyStore>(
                    mutations: {IncrementMutation, DecrementMutation},
                    builder: (ctx, store, status) {
                      if (status == VxStatus.loading)
                        return const CircularProgressIndicator();
                      else
                        return Text(
                          "${store.counter.count.toString()}",
                          style: Theme.of(context).textTheme.headline4,
                        );
                    },
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "${store.data}",
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  VxBuilder<MyStore>(
                      builder: (context, store, status) {
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
