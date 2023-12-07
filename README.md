# flutter_view_model

[![codecov](https://codecov.io/gh/giovanigm/flutter_view_model/graph/badge.svg?token=B9YX8Y0GYZ)](https://codecov.io/gh/giovanigm/flutter_view_model)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)

A MVVM Flutter State Management library based on [orbit-mvi](https://orbit-mvi.org/) and [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Motivation

## Usage

#### ViewModelBuilder

A widget that uses `States` emitted by the `ViewModel` to construct new widgets through the `builder` function.

If you also need to react to `Effects`, please see `ViewModelConsumer`.

```dart
ViewModelBuilder<MyViewModel, MyState>() {
  builder: (context, state) {
    return MyWidget();
  },
}
```

If `viewModel` is not provided, `ViewModelBuilder` will look up the widget tree using `ViewModelProvider` and the current `BuildContext` for a compatible ViewModel.

#### ViewModelListener

A Widget that reacts to `Effects` emitted by `ViewModel` and invokes `listener` callback.

It should be used when you only need to deal with side effects such as navigating after some validation, displaying feedback SnackBars, and similar cases.

If you also need to react to `States`, please see `ViewModelConsumer`.

```dart
ViewModelListener<MyViewModel, MyEffect>() {
  listener: (context, effect) {
    // do something
  },
  child: const SizedBox(),
}
```

If `viewModel` is not provided, `ViewModelListener` will look up the widget tree using `ViewModelProvider` and the current `BuildContext` for a compatible ViewModel.

#### ViewModelConsumer

A widget that uses both `States` and `Effects` emitted by the `ViewModel` to construct new widgets and react to effects.

If you need to react only either to `States` or `Effects`, see `ViewModelBuilder` and `ViewModelListener`.

```dart
ViewModelConsumer<MyViewModel, MyState, MyEffect>() {
  listener: (context, effect) {
    // do something
  },
  builder: (context, state) {
    return MyWidget();
  },
}
```

If `viewModel` is not provided, `ViewModelConsumer` will look up the widget tree using `ViewModelProvider` and the current `BuildContext` for a compatible ViewModel.

#### ViewModelProvider

Provides a `ViewModel` created through the `create` function to descendant widgets.

Widgets below in the tree can access the provided `ViewModel` through `ViewModelProvider.of(context)`.

```dart
ViewModelProvider<MyViewModel>() {
  create: (context) => MyViewModel(),
  child: const SizedBox(),
}
```

Automatically closes the created `ViewModel`. If you want to retain the ViewModel instance, use the `value` constructor.

The `ViewModel` instance will be created only when requested. For the opposite behavior, set `lazy = false`.

#### Context extensions

## Testing

#### ViewModel

#### Widgets

##### Mock ViewModel

##### Real ViewModel

## Contributing
