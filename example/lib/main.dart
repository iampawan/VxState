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
    return VxState(
      store: MyStore(),
      interceptors: [LogInterceptor()],
      child: MaterialApp(
        title: 'VxState Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VxState.listen(context, to: [FetchApi]);

    final MyStore store = VxState.store;
    return Scaffold(
      appBar: AppBar(
        title: Text("Counter example"),
        actions: [
          if (store.isFetching)
            CircularProgressIndicator(
              strokeWidth: 10.0,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              store.data,
            ),
            VxBuilder(
              mutations: {IncrementMutation},
              builder: (ctx) => Text(
                store.counter.count.toString(),
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => IncrementMutation(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
