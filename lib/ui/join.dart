// import 'dart:ffi';

import 'package:boonote/ui/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JoinPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _JoinPageState();
}


class _JoinPageState extends State<JoinPage>{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // 이메일 유효성 함수
  bool isValidEmail(String email){
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // 비밀번호 유효성 함수
  bool isValidPass(String pass){
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    );
    return passwordRegex.hasMatch(pass);
  }
  
  // 회원가입 함수
  Future<void> _Join() async{
    String email = _emailController.text.trim();
    String nickname = _nicknameController.text.trim();
    String pass = _passController.text.trim();
    String confirmPass = _confirmPassController.text.trim();

    // 이메일 유효성 검사
    if(!isValidEmail(email)){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('올바른 이메일 형식을 입력해주세요.')),
      );
      return;
    }

    // 비밀번호 유효성 검사
    if (!isValidPass(pass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호는 영어, 숫자를 포함한 최소 8자리여야 합니다.')),
      );
      return;
    }
    
    
    if(pass != confirmPass){
      //비밀번호 일치하지 않을 때
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }
    
    try {
      // 회원가입
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      // firestore 데이터 저장
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'nickname': nickname,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입이 성공했습니다.")),
        );

        // 로그인 페이지 이동
        Get.to(() => LoginPage());
      }
    }on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 사용 중인 이메일입니다.')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Email Field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email),
                hintText: '이메일',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nickname Field
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                hintText: '닉네임',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Password Field
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                hintText: '비밀번호(영문, 숫자 조합 8자 이상)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Confirm Password Field
            TextField(
              controller: _confirmPassController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                hintText: '비밀번호 확인',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.redAccent,
              ),
              onPressed: _Join,
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}