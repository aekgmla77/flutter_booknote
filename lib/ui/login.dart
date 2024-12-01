import 'dart:developer';

import 'package:boonote/controllers/auth_controller.dart';
import 'package:boonote/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX 패키지 추가
import 'package:boonote/ui/join.dart'; // 회원가입

import 'booknote_main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage>{
  final emailController = TextEditingController();
  final passController = TextEditingController();

  String errorString = '';//login error 보려고 만든 String state

  //firebase auth login 함수, 이멜 + 비번으로 로그인
  void fireAuthLogin() async {
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    try{
      await Get.find<AuthController>().login(email, pass);
      // 로그인 성공 시 MainPage로 이동
      Future.delayed(const Duration(milliseconds: 100), () {
        if (Get.find<AuthController>().isLoggedIn.value) {
          Get.offAll(() => MyHomePage(title: '홈'));
        }
      });
    } catch (e) {
      setState(() => errorString = e.toString()); // 오류 메시지 업데이트
      log('로그인 실패: $errorString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo and Title
            Column(
              children: [
                Image.asset('assets/image/blogo.png', height: 200), // Replace with actual asset
                const SizedBox(height: 16),
                const Text(
                  'BookNote',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email),
                hintText: '이메일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Password Field
            TextField(
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                hintText: '비밀번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => fireAuthLogin(), //로그인 버튼!
              child: const Text('로그인'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('계정이 없으신가요?'),
                TextButton(
                  onPressed: () {
                    // GetX로 회원가입 페이지로 이동
                    Get.to(() => JoinPage());
                  },
                  child: const Text('회원가입'),
                ),
              ],
            ),
            // Footer Note
            const Text(
              '가입시 BookNote의 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
