import 'package:flutter/material.dart';
import 'package:mbm_store/pages/BillDetails.dart';
import 'package:mbm_store/pages/approval/order_costing.dart';
import 'package:mbm_store/pages/approval/bill_details.dart';
import 'package:mbm_store/pages/approval/list.dart';
import 'package:mbm_store/pages/complain/complain_list.dart';
import 'package:mbm_store/pages/contact.dart';
import 'package:mbm_store/pages/auth.dart';
import 'package:mbm_store/pages/dashboard.dart';
import 'package:mbm_store/pages/profile.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings){
  switch(routeSettings.name){
    case AuthScreen.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const AuthScreen(),
    );
    case DashboardScreen.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const DashboardScreen(),
    );
    case BillDetails.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const BillDetails(),
    );
    case ContactPage.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const ContactPage(),
    );
    case ApprovalPage.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const ApprovalPage(approvalName: '',),
    );
    case ApprovalDetailsPageOrderCosting.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const ApprovalDetailsPageOrderCosting(approvalId: '',),
    );
    case ApprovalDetailsBill.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const ApprovalDetailsBill(approvalId: '',),
    );
    case ProfilePage.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const ProfilePage(),
    );
    case ComplainList.routeName:
      return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const ComplainList(),
    );
    default:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const Scaffold(
          body: Center(
            child: Text('Screen does not exist!'),
          ),
        ),
      );
  }
}