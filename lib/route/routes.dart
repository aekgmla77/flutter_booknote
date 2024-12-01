import 'package:get/get_navigation/src/routes/get_route.dart';

import '../ui/booknote_main.dart';
import '../ui/login.dart';

class RouteManager{
  static const String home = '/home';
  static const String login = '/login';

  static List<GetPage> getRoutes(){
    return [
      GetPage(name: home, page: () => MainPage()),
      GetPage(name: login, page: () => LoginPage()),
    ];
  }
}