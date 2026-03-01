import 'package:go_router/go_router.dart';
import 'package:taxi/screens/login_screen.dart';
import 'package:taxi/screens/map_screen.dart';
import 'package:taxi/screens/splash_screen.dart';
import 'package:taxi/screens/admin_panel/admin_panel.dart';
import 'package:taxi/screens/driver_panel/driver_panel.dart';

final goRouterProvider = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPanel(),
    ),
    GoRoute(
      path: '/driver',
      name: 'driver',
      builder: (context, state) => const DriverPanel(),
    ),
  ],
);
