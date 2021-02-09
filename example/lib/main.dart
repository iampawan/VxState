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
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                VxBuilder(
                  mutations: {IncrementMutation, DecrementMutation},
                  builder: (ctx) => Text(
                    store.counter.count.toString(),
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                SizedBox(height: 20.0,),
                if (store.isFetching)
                  CircularProgressIndicator()
                else
                  Text(
                    store.data,
                  ),
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
              child: Icon(Icons.add),
            ),
            SizedBox(
              width: 10.0,
            ),
            FloatingActionButton(
              onPressed: () => DecrementMutation(),
              tooltip: 'Decrement',
              child: Icon(Icons.remove),
            ), //
            SizedBox(
              width: 10.0,
            ), //
            FloatingActionButton.extended(
              onPressed: () => FetchApi(),
              tooltip: 'Fetch API',
              label: Text("Fetch API"),
            ), //// This trailing comma makes auto-formatting nicer for build methods.
          ],
        ));
  }
}
