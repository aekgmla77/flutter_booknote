import 'dart:developer';

import 'package:boonote/controllers/auth_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'login.dart';

class SettingPage extends StatelessWidget {

  void fireAuthLogout() async {
    String errorString = '';

    try{
      await Get.find<AuthController>().logout();
    } catch (e) {
      log('로그아웃 실패: $errorString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        title: Center(
          child: Text('설정'),
        )
      ),
      body: Center(
        child: OutlinedButton(
            onPressed: fireAuthLogout,
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(40, 30),
                textStyle: const TextStyle(fontSize: 12),
                side: BorderSide(
                    color: Colors.black38
                )
            ),
            child: Text("로그아웃", style: const TextStyle(color: Colors.indigo),)),
      ),
    );
  }
}