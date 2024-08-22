import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pasteboard/misc/extension.dart';
import 'package:flutter_pasteboard/service/account/account_service.dart';

class AccountFuture extends StatelessWidget {
  final Widget Function(AccountService accountService) builder;

  const AccountFuture({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AccountService.init,
        builder: (BuildContext context, AsyncSnapshot<AccountService> snapshot) {
          if (snapshot.hasData) {
            return builder.call(snapshot.data!);
          } else if (snapshot.hasError) {
            return Icon(Icons.error_outline);
          } else {
            return emptyWidget;
          }
        });
  }
}
