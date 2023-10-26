import 'package:example/view_model/event/counter_event.dart';
import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import '../view_model/counter_view_model.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider(
      create: (context) => CounterViewModel(),
      child: ViewModelConsumer<CounterViewModel, int, CounterEvent>(
        onEvent: (context, event) {
          event.when(
            evenNumber: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Even'),
                duration: Duration(seconds: 1),
              ),
            ),
            oddNumber: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Odd'),
                duration: Duration(seconds: 1),
              ),
            ),
            logout: (event) =>
                Navigator.of(context).pushReplacementNamed(event.route),
          );
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Counter'), actions: [
            TextButton.icon(
              onPressed: () async =>
                  await context.read<CounterViewModel>().logout(),
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).primaryColorDark,
              ),
              label: Text(
                'logout',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            )
          ]),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have pushed the button this many times:'),
                Text(
                  '$state',
                  style: Theme.of(context).textTheme.displayLarge,
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<CounterViewModel>().add(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
