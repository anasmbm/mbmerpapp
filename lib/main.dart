import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mbm_store/firebase_options.dart';
import 'package:mbm_store/notification.dart';
import 'package:mbm_store/pages/approval/list.dart';
import 'package:mbm_store/pages/auth.dart';
import 'package:mbm_store/pages/complain/complain.dart';
import 'package:mbm_store/pages/complain/complain_list.dart';
import 'package:mbm_store/pages/contact.dart';
import 'package:mbm_store/pages/dashboard.dart';
import 'package:mbm_store/pages/job_order/list.dart';
import 'package:mbm_store/providers/user_provider.dart';
import 'package:provider/provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
    ),
  ] ,child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationSetup _noti = NotificationSetup();
  @override
  void initState(){
    _noti.configurePushNotifications(context);
    _noti.eventListenerCallback(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MBM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Provider.of<UserProvider>(context).user.token.isNotEmpty
          ? const DashboardScreen()
          : const AuthScreen(),
      routes: {
        '/auth-screen': (context) => const AuthScreen(),
        '/home': (context) => const DashboardScreen(),
        '/job-order-list': (context) => POCashApproval(),
        '/complain-list': (context) => ComplainList(),
        '/complain': (context) => Complain(),
        '/contact': (context) => const ContactPage(),
      },
      initialRoute: '/auth-screen',
    );
  }
}