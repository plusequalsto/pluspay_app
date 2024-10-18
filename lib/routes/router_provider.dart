import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class RouterProvider extends StatelessWidget {
  final Widget child;
  final FluroRouter router;

  const RouterProvider({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
