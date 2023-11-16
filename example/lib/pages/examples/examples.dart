import 'package:flutter/widgets.dart';
import 'package:flutter_view_model/flutter_view_model.dart';

import 'counter/counter_page.dart';
import 'counter/counter_page_view_model.dart';
import 'login/login_page.dart';
import 'login/login_page_view_model.dart';

typedef Example = ({String name, Widget widget});

final examples = <Example>[
  (
    name: "Counter",
    widget: ViewModelProvider<CounterPageViewModel>(
      create: (_) => CounterPageViewModel(),
      child: const CounterPage(),
    )
  ),
  (
    name: "Login",
    widget: ViewModelProvider<LoginPageViewModel>(
      create: (_) => LoginPageViewModel(),
      child: const LoginPage(),
    ),
  )
];
