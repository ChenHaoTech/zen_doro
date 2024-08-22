import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IgnoreObx extends StatefulWidget {
  final WidgetCallback builder;

  IgnoreObx(this.builder, {super.key});

  @override
  State<IgnoreObx> createState() => _IgnoreObxState();
}

class _IgnoreObxState extends State<IgnoreObx> {
  final _observer = RxNotifier();

  @override
  Widget build(BuildContext context) {
    return RxInterface.notifyChildren(_observer, widget.builder);
  }

  @override
  void dispose() {
    _observer.close();
    super.dispose();
  }
}
