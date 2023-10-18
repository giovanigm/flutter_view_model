import 'package:flutter/material.dart';
import 'package:view_model/view_model.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ViewModelProvider(
        create: (context) => CounterViewModel(),
        child: const CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: ViewModelConsumer<CounterViewModel, int, bool>(
        onEvent: (context, event) {
          final isEven = event;
          final message = isEven ? 'Even' : 'Odd';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        builder: (context, state) => Center(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterViewModel>().add(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CounterViewModel extends ViewModel<int, bool> {
  CounterViewModel() : super(initialState: 0);

  void add() {
    final newState = state + 1;
    emitState(newState);
    emitEvent(newState % 2 == 0);
  }
}
