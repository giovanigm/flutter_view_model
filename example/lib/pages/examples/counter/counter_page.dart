import 'package:flutter/material.dart';
import 'package:flutter_view_model/flutter_view_model.dart';

import 'counter_page_view_model.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CounterPageViewModel, int>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Counter')),
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
