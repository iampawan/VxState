import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vxstate/vxstate.dart';

void main() {
  testWidgets('increment number in text', (tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(
      MaterialApp(
        home: VxState(
          store: TestStore(),
          child: ExampleWidget(),
        ),
      ),
    );

    expect(find.text("count is 0"), findsOneWidget);
    Increment();
    await tester.pump();
    expect(find.text("count is 1"), findsOneWidget);
  });

  testWidgets('UpdateOn widget', (tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(
      MaterialApp(
        home: VxState(
          store: TestStore(),
          child: ExampleBuilderWidget(),
        ),
      ),
    );

    expect(find.text("count is 0"), findsOneWidget);
    Increment();
    await tester.pump();
    expect(find.text("count is 1"), findsOneWidget);
  });
}

class TestStore extends VxStore {
  int count = 0;
}

class Increment extends VxMutation<TestStore> {
  @override
  void perform() {
    store.count++;
  }
}

class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    VxState.listen(context, to: [Increment]);
    final store = VxState.store as TestStore;
    return Text("count is ${store.count}");
  }
}

class ExampleBuilderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = VxState.store as TestStore;
    return VxBuilder(
      mutations: {Increment},
      builder: (_, mut) => Text("count is ${store.count}"),
    );
  }
}
