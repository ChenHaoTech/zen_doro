import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_extension/ui_extension.dart';

/**
 *
 * @author chenhao91
 * @date   2024/4/2
 */
class ErrorDemo extends StatefulWidget {
  const ErrorDemo({Key? key}) : super(key: key);

  @override
  State<ErrorDemo> createState() => _ErrorDemoState();
}

class _ErrorDemoState extends State<ErrorDemo> {
  @override
  Widget build(BuildContext context) {
    // boxsize
    return this.build(context);
    return Row(
      children: [
        SizedBox(
          width: Get.width * 13,
          height: 200,
          child: SizedBox(
            width: 300,
            height: 200,
            child: Container(
              color: Colors.red,
            ),
          ),
        )
      ],
    );

    // // col=> listview
    // return Column(
    //   children: [
    //     ListView(),
    //   ],
    // );

    // throw
    // throw "Container";
    return Container(
      color: Colors.red,
    ).easyTap(onTap: () {
      throw "Container_ontap";
    });
  }

  @override
  void initState() {
    super.initState();
    // throw "initState";
    Future.delayed(1.seconds, () => throw "initState");
  }

  @override
  void dispose() {
    super.dispose();
    throw "dispose";
  }
}
