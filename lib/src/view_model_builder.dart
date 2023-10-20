import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

class ViewModelBuilder<VM extends ViewModel<STATE, dynamic>, STATE>
    extends StatefulWidget {
  const ViewModelBuilder({
    Key? key,
    required this.builder,
    this.viewModel,
    this.buildWhen,
  }) : super(key: key);

  final VM? viewModel;

  final Widget Function(BuildContext context, STATE state) builder;

  final bool Function(STATE previous, STATE current)? buildWhen;

  @override
  State<ViewModelBuilder<VM, STATE>> createState() =>
      _ViewModelBuilderState<VM, STATE>();
}

class _ViewModelBuilderState<VM extends ViewModel<STATE, dynamic>, STATE>
    extends State<ViewModelBuilder<VM, STATE>> {
  late VM _viewModel;
  StreamSubscription<STATE>? _stateSubscription;
  late STATE _state;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _state = _viewModel.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelBuilder<VM, STATE> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_stateSubscription != null) {
        _viewModel = currentViewModel;
        _state = _viewModel.state;
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = widget.viewModel ?? context.read<VM>();
    if (_viewModel != viewModel) {
      if (_stateSubscription != null) {
        _viewModel = viewModel;
        _state = _viewModel.state;
        _unsubscribe();
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel == null) {
      context.select<VM, bool>((viewModel) => identical(_viewModel, viewModel));
    }

    return widget.builder(context, _state);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _stateSubscription = _viewModel.stateStream.listen((state) {
      if (widget.buildWhen?.call(_state, state) ?? true) {
        setState(() {});
      }
      _state = state;
    });
  }

  void _unsubscribe() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }
}
