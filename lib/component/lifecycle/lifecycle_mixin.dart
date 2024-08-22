import 'package:flutter/material.dart';

import 'lifecycle.dart';

abstract class LifecycleMixin {
  void whenShow();

  void whenHide();
}

mixin LifecycleStatelessMixin on StatelessWidget implements LifecycleMixin {
  @override
  StatelessElement createElement() {
    lifeCycle.unBindImplIntoRoute(this);
    lifeCycle.bindImplIntoRoute(this);
    return super.createElement();
  }
}
mixin LifecycleStatefulMixin<T extends StatefulWidget> on State<T> implements LifecycleMixin {
  @override
  void initState() {
    super.initState();
    if (lifeCycle.pageSize == 0) {
      whenShow();
    } else {
      lifeCycle.unBindImplIntoRoute(this);
      lifeCycle.bindImplIntoRoute(this);
    }
  }

  //now we dont need call this method

  @override
  void dispose() {
    super.dispose();
    lifeCycle.unBindImplIntoRoute(this);
  }
}
