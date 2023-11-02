import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

import 'counter_page_event.dart';
import 'counter_page_view_model.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelConsumer<CounterPageViewModel, int, CounterPageEvent>(
      onEvent: (context, event) {
        event.when(
          logout: (event) =>
              Navigator.of(context).pushReplacementNamed(event.route),
        );
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Counter'), actions: [
          TextButton.icon(
            onPressed: () async =>
                await context.read<CounterPageViewModel>().logout(),
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
          onPressed: () => context.read<CounterPageViewModel>().add(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
