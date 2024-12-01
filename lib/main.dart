// import 'dart:ffi';

import 'dart:developer';

import 'package:boonote/controllers/auth_controller.dart';
import 'package:boonote/route/routes.dart';
import 'package:boonote/ui/booknote_main.dart';
import 'package:boonote/ui/setting_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX 패키지 추가
import 'firebase_options.dart';
import 'ui/login.dart'; // 로그인 화면 임포트
// 달력 한글화
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // firebase 연동(비동기)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AuthController _authController = Get.put(AuthController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFCFCFC),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ko', ''), // Korean, no country code
      ],
      getPages: RouteManager.getRoutes(),
      home:
      Obx(() {
        // 로그인 상태에 따라 화면 분리
        return _authController.isLoggedIn.value
            ? MyHomePage(title: '홈') // MyHomePage로 변경
            : LoginPage();
      })
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    MainPage(), // 메인 홈 화면
    SettingPage(), // 설정 화면
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 선택된 화면 표시
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFCFCFC),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}