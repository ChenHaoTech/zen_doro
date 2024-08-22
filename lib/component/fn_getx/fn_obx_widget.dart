import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/log/logger_extension.dart';
import 'package:get/get.dart';

class FnObxValue extends StatefulWidget {
  final List<RxObjectMixin> rxs;
  final Widget Function() builder;
  final String? debug;

  const FnObxValue(this.builder, this.rxs, {super.key, this.debug});

  @override
  State<FnObxValue> createState() => _FnObxValueState();
}

class _FnObxValueState extends State<FnObxValue> {
  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }

  @override
  void dispose() {
    super.dispose();
    subs.forEach((element) {
      element.cancel();
    });
    if (widget.debug != null) {
      this.log.dd(() => "[${widget.debug}] dispose, subs:${subs.length}");
    }
  }

  final subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    widget.rxs.forEach((e) {
      var sub = e.listen((event) {
        if (widget.debug != null) {
          this.log.dd(() => "[${widget.debug}] update by ${event}");
        }
        setState(() {});
      });
      subs.add(sub);
    });
    if (widget.debug != null) {
      this.log.dd(() => "[${widget.debug}] initState, subs:${subs.length}");
    }
  }
}