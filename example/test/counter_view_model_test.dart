import 'package:example/view_model/counter_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CounterViewModel viewModel;

  setUp(() {
    viewModel = CounterViewModel();
  });

  tearDown(() {
    viewModel.close();
  });

  test("", () async {
    expect(viewModel.stateStream, emitsInOrder([1, 2, 3]));
    expect(viewModel.eventStream, emitsInOrder([false, true, false]));
    viewModel.add();
    viewModel.add();
    viewModel.add();
    await viewModel.close();
  });
}
