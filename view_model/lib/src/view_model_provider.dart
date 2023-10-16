import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'view_model.dart';

class ViewModelProvider<T extends ViewModel<Object?, Object?>>
    extends SingleChildStatelessWidget {
  const ViewModelProvider({
    required Create<T> create,
    Key? key,
    this.child,
    this.lazy = true,
  })  : _create = create,
        _value = null,
        super(key: key, child: child);

  const ViewModelProvider.value({
    required T value,
    Key? key,
    this.child,
  })  : _value = value,
        _create = null,
        lazy = true,
        super(key: key, child: child);

  final Widget? child;

  final bool lazy;

  final Create<T>? _create;

  final T? _value;

  static T of<T extends ViewModel<Object?, Object?>>(
    BuildContext context, {
    bool listen = false,
  }) {
    try {
      return Provider.of<T>(context, listen: listen);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        ViewModelProvider.of() called with a context that does not contain a $T.
        No ancestor could be found starting from the context that was passed to ViewModelProvider.of<$T>().

        This can happen if the context you used comes from a widget above the ViewModelProvider.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final value = _value;
    return value != null
        ? InheritedProvider<T>.value(
            value: value,
            startListening: _startListening,
            lazy: lazy,
            child: child,
          )
        : InheritedProvider<T>(
            create: _create,
            dispose: (_, viewModel) => viewModel.close(),
            startListening: _startListening,
            lazy: lazy,
            child: child,
          );
  }

  static VoidCallback _startListening(
    InheritedContext<ViewModel<dynamic, dynamic>?> e,
    ViewModel<dynamic, dynamic> value,
  ) {
    final subscription = value.stateStream.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
  }
}