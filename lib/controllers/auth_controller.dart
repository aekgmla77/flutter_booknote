import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../ui/login.dart';

class AuthController extends GetxController {
  // 로그인 여부 확인
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus(); // 초기 로그인 상태 확인
  }

  // Firebase 인증 상태 확인
  void _checkLoginStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      isLoggedIn.value = user != null; // 사용자 인증 여부에 따라 업데이트
    });
  }

  // // 로그인 함수
  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      isLoggedIn.value = true;
      Get.snackbar("로그인 성공", "환영합니다!");
      print('환영합니다! ${currentUser}');
    } catch (e) {
      Get.snackbar("로그인 실패", e.toString());
    }
  }

  // 로그아웃 함수
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      isLoggedIn.value = false;
      print("로그아웃 성공");
      Get.snackbar("로그아웃 성공", "다음에 또 만나요!");
      // 로그아웃 후 로그인 페이지로 이동 Get.offAll()은 기존의 모든 네비게이션 스택을 제거하고 새 페이지로 이동
      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar("로그아웃 실패", e.toString());
    }
  }

}