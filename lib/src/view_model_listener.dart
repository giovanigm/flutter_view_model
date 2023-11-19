import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'view_model.dart';

/// A Widget that reacts to `Events` emitted by [ViewModel] and invokes
/// [onEvent] callback.
///
/// It should be used when you only need to deal with side effects such as
/// navigating after some validation, displaying feedback SnackBars, and similar
/// cases.
///
/// ```dart
/// ViewModelListener<MyViewModel, MyEvent>() {
///   onEvent: (context, event) {
///     // do something
///   },
///   child: const SizedBox(),
/// }
/// ```
///
/// If the [viewModel] parameter is omitted, [ViewModelListener] will automatically
/// perform a lookup using [ViewModelProvider] and the current `BuildContext`.
///
///
class ViewModelListener<VM extends ViewModel<dynamic, EVENT>, EVENT>
    extends StatefulWidget {
  const ViewModelListener({
    Key? key,
    this.viewModel,
    required this.onEvent,
    this.reactToEventWhen,
    required this.child,
  }) : super(key: key);

  final VM? viewModel;

  /// The callback that will be invoked for every [event] emitted by [viewModel].
  final void Function(BuildContext context, EVENT event) onEvent;

  /// Controls whether [onEvent] is called or not.
  final bool Function(EVENT? previous, EVENT current)? reactToEventWhen;

  /// The Widget to be rendered.
  final Widget child;

  @override
  State<ViewModelListener<VM, EVENT>> createState() =>
      _ViewModelListenerState<VM, EVENT>();
}

class _ViewModelListenerState<VM extends ViewModel<dynamic, EVENT>, EVENT>
    extends State<ViewModelListener<VM, EVENT>> {
  late VM _viewModel;
  StreamSubscription<EVENT>? _eventSubscription;
  EVENT? _event;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? context.read<VM>();
    _event = _viewModel.lastEvent;
    _subscribe();
  }

  @override
  void didUpdateWidget(ViewModelListener<VM, EVENT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldViewModel = oldWidget.viewModel ?? context.read<VM>();
    final currentViewModel = widget.viewModel ?? oldViewModel;
    if (oldViewModel != currentViewModel) {
      if (_eventSubscription != null) {
        _viewModel = currentViewModel;
        _event = _viewModel.lastEvent;
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
      if (_eventSubscription != null) {
        _viewModel = viewModel;
        _event = _viewModel.lastEvent;
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
    _eventSubscription = _viewModel.eventStream.listen((event) {
      if (widget.reactToEventWhen?.call(_event, event) ?? true) {
        widget.onEvent.call(context, event);
      }
      _event = event;
    });
  }

  void _unsubscribe() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}
