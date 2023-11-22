import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

class ViewModelListener<VM extends ViewModel<dynamic, EVENT>, EVENT>
    extends StatefulWidget {
  const ViewModelListener({
    Key? key,
    this.viewModel,
    required this.onEffect,
    this.reactToEffectWhen,
    required this.child,
  }) : super(key: key);

  final VM? viewModel;

  final void Function(BuildContext context, EVENT effect) onEffect;

  final bool Function(EVENT? previous, EVENT current)? reactToEffectWhen;

  final Widget child;

  @override
  State<ViewModelListener<VM, EVENT>> createState() =>
      _ViewModelListenerState<VM, EVENT>();
}

class _ViewModelListenerState<VM extends ViewModel<dynamic, EVENT>, EVENT>
    extends State<ViewModelListener<VM, EVENT>> {
  late VM _viewModel;
  StreamSubscription<EVENT>? _effectSubscription;
  EVENT? _effect;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _effect = _viewModel.lastEffect;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelListener<VM, EVENT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_effectSubscription != null) {
        _viewModel = currentViewModel;
        _effect = _viewModel.lastEffect;
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
      if (_effectSubscription != null) {
        _viewModel = viewModel;
        _effect = _viewModel.lastEffect;
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

    return widget.child;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _effectSubscription = _viewModel.effectStream.listen((effect) {
      if (widget.reactToEffectWhen?.call(_effect, effect) ?? true) {
        widget.onEffect.call(context, effect);
      }
      _effect = effect;
    });
  }

  void _unsubscribe() {
    _effectSubscription?.cancel();
    _effectSubscription = null;
  }
}
