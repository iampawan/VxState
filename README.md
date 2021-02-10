# VxState

VxState is a state management library built for Flutter apps with focus on simplicity. It is inspired by StoreKeeper & libraries like Redux, Vuex etc with the power of streams. Here is a basic idea of how it works:

- Single Store (Single source of truth) to keep app's data
- Structured modifications to store with Mutations
- Widgets listen to mutations to rebuild themselves
- Enhance this process with Interceptors and Effects

Core of VxState is based on the [InheritedModel](https://api.flutter.dev/flutter/widgets/InheritedModel-class.html) widget from Flutter.

## Getting started

Add to your pubpsec:

```yaml
dependencies:
  ...
  vxstate: any
```

Create a store:

```dart
import 'package:vxstate/vxstate.dart';

class MyStore extends VxStore {
  int count = 0;
}
```

Define mutations:

```dart
class Increment extends VxMutation<MyStore> {
  perform() => store.count++;
}
```

Listen to mutations:

```dart
@override
Widget build(BuildContext context) {
  // Define when this widget should re render
  VxState.listen(context, to: [Increment]);

  // Get access to the store
  MyStore store = VxState.store;

  return Text("${store.count}");
}
```

Complete example:

```dart
import 'package:flutter/material.dart';
import 'package:vxstate/vxstate.dart';

// Build store and make it part of app
void main() {
  runApp(VxState(
    store: MyStore(),
    child: MyApp(),
  ));
}

// Store definition
class MyStore extends VxStore {
  int count = 0;
}

// Mutations
class Increment extends VxMutation<MyStore> {
  perform() => store.count++;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define when this widget should re render
    VxState.listen(context, to: [Increment]);

    // Get access to the store
    MyStore store = VxState.store;

    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Text("Count: ${store.count}"),
            RaisedButton(
              child: Text("Increment"),
              onPressed: () {
                // Invoke mutation
                Increment();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Documentation

- VxStore - Where your apps's data is kept
- VxMutation - Logic that modifies Store
- VxBuilder, VxNotifier, VxConsumer - Useful widgets for special cases
- VxEffect - Chained mutations
- VxInterceptors - Intercept execution of mutations
