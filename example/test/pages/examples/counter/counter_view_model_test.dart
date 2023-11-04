import 'package:example/pages/examples/counter/counter_page_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CounterPageViewModel viewModel;

  setUp(() {
    viewModel = CounterPageViewModel();
  });

  tearDown(() {
    viewModel.close();
  });

  test("", () async {
    expect(viewModel.stateStream, emitsInOrder([1, 2, 3]));
    viewModel.add();
    viewModel.add();
    viewModel.add();
    await viewModel.close();
  });
}
