import 'package:flutter_pasteboard/misc/fn_random.dart';
import 'package:flutter_pasteboard/model/time_block.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AudioConfig', () {
    var current = StackTrace.current;
    print(current.toString().split("\n"));
    print(current.invoker);
    return;
  });
  test('Pormodo Json', () {
    var emptyPromodo = TimeBlock.emptyFocus();
    print(emptyPromodo.toJson().toString());
    print("fuck");
    // {uuid: cab8ede5-2fbb-4dc4-9a8d-790b52a091e2, body: {"leftSeconds":1500,"progressSeconds":0,"logs":[],"tags":[],"title":null,"context":null,"feedback":null}, type: 0, startTime: null, endTime: null}
    print("decode: ${TimeBlock.fromJson({
          "uuid": "cab8ede5-2fbb-4dc4-9a8d-790b52a091e2",
          "body": {"progressSeconds": 0, "logs": [], "tags": [], "title": null, "context": null, "feedback": null},
          "type": 0,
          "startTime": null,
          "endTime": null
        })}");
    return;
  });

  test("random", () {
    var nor = NonRepeatingRandomGenerator();
    var list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    for (var value in list) {
      var result = nor.random(list);
      print(result);
    }
    var result = nor.random(list);
    print(result);
  });
}
