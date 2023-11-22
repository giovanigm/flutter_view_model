import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_view_model/src/view_model.dart';

class TestViewModel extends ViewModel<int, int> {
  TestViewModel() : super(initialState: 0);
}

void main() {
  late TestViewModel viewModel;

  setUp(() {
    viewModel = TestViewModel();
  });

  tearDown(() async {
    await viewModel.close();
  });

  group("state", () {
    test("should return initial state", () {
      expect(viewModel.state, 0);
    });

    test("should return current state", () {
      viewModel.emitState(1);
      expect(viewModel.state, 1);
    });
  });

  group("lastEffect", () {
    test("should emit null if no effect was emitted", () {
      expect(viewModel.lastEffect, null);
    });

    test("should emit last effect", () {
      viewModel.emitEffect(1);
      expect(viewModel.lastEffect, 1);
    });
  });

  group("emitState", () {
    test("should emit states in correct order", () async {
      expect(viewModel.stateStream, emitsInOrder([1, 2, 3, emitsDone]));
      viewModel.emitState(1);
      viewModel.emitState(2);
      viewModel.emitState(3);
      await viewModel.close();
    });

    test("should not emit new states after close", () async {
      expect(viewModel.stateStream, emitsInOrder([1, 2, emitsDone]));
      viewModel.emitState(1);
      viewModel.emitState(2);
      await viewModel.close();
      viewModel.emitState(3);
    });

    test("should not emit the same state", () async {
      expect(viewModel.stateStream, emitsInOrder([1, 2, emitsDone]));
      viewModel.emitState(1);
      viewModel.emitState(1);
      viewModel.emitState(2);
      viewModel.emitState(2);
      await viewModel.close();
    });
  });

  group("emitEffect", () {
    test("should emit effects in correct order", () async {
      expect(viewModel.effectStream, emitsInOrder([1, 2, 3, emitsDone]));
      viewModel.emitEffect(1);
      viewModel.emitEffect(2);
      viewModel.emitEffect(3);
      await viewModel.close();
    });

    test("should not emit new effects after close", () async {
      expect(viewModel.effectStream, emitsInOrder([1, 2, emitsDone]));
      viewModel.emitEffect(1);
      viewModel.emitEffect(2);
      await viewModel.close();
      viewModel.emitEffect(3);
    });

    test("should allow emit the same effect", () async {
      expect(viewModel.effectStream, emitsInOrder([1, 1, 2, 2, emitsDone]));
      viewModel.emitEffect(1);
      viewModel.emitEffect(1);
      viewModel.emitEffect(2);
      viewModel.emitEffect(2);
      await viewModel.close();
    });
  });

  group("close", () {
    test("should close stateStream", () async {
      await viewModel.close();
      expect(viewModel.effectStream, emitsDone);
    });

    test("should close effectStream", () async {
      await viewModel.close();
      expect(viewModel.effectStream, emitsDone);
    });
  });
}
