import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildDropdownMenu<T>(T initValue, List<(String, T)> values, void Function(T) onSelected) {
  var initPair = values.firstWhereOrNull((e) => e.$2 == initValue) ?? values.first;

  return DropdownMenu<(String, T)>(
    initialSelection: initPair,
// requestFocusOnTap is enabled/disabled by platforms when it is null.
// On mobile platforms, this is false by default. Setting this to true will
// trigger focus request on the text field and virtual keyboard will appear
// afterward. On desktop platforms however, this defaults to true.
    requestFocusOnTap: true,
// controller: TextEditingController(),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
// contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      border: InputBorder.none,
    ),
// enableFilter: true,
    onSelected: ((String, T)? pair) {
      if (pair != null) {
        onSelected.call(pair.$2);
      }
    },
    dropdownMenuEntries: values.map<DropdownMenuEntry<(String, T)>>(((String, T) pair) {
      return DropdownMenuEntry<(String, T)>(
        value: pair,
        label: pair.$1,
      );
    }).toList(),
  );
}
