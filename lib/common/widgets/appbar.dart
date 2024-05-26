import 'package:flutter/material.dart';
import 'package:mbm_store/constants/global_variables.dart';
import 'package:mbm_store/pages/approval/list.dart';
import 'package:mbm_store/pages/dashboard.dart';
import 'package:mbm_store/pages/complain/complain_list.dart';
import 'package:mbm_store/services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;
  final String backLink;
  final String approvalName;
  final String translateText;
  final bool showHomeIcon;
  final VoidCallback? onPressed;

  const CustomAppBar({
    required this.pageTitle,
    this.showHomeIcon = false,
    this.backLink = '',
    this.approvalName = '',
    this.translateText = '',
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: GlobalVariables.appBarGradient,
        ),
      ),
      leading: showHomeIcon
          ? GestureDetector(
        onTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            DashboardScreen.routeName,
                (route) => false,
          );
        },
        child: const Icon(Icons.home_outlined, color: Colors.white),
      )
          : IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if(backLink != '' && backLink != '/approvals') {
            Navigator.pushNamed(context, backLink);
          }else if(backLink == '/approvals' && approvalName != ''){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ApprovalPage(
                  approvalName: approvalName,
                ),
              ),
            );
          }else{
            Navigator.pushNamedAndRemoveUntil(
              context,
              DashboardScreen.routeName,
                  (route) => false,
            );
          }
        },
      ),
      title: Text(pageTitle, style: const TextStyle(color: Colors.white, fontSize: 17)),
      actions: [
        Visibility(
            visible: pageTitle == 'Leave Application'||pageTitle == 'ছুটির আবেদন'||pageTitle == 'Complain Form'|| pageTitle=='অভিযোগ ফর্ম',
            child: ElevatedButton(
                onPressed: this.onPressed,
                child: Text(translateText,style: TextStyle(color: Colors.white, fontSize: 15),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Border radius
                  ),
                ),
            )
        ),
        Visibility(
            visible: pageTitle == 'Complain Form'|| pageTitle=='অভিযোগ ফর্ম',
            child: IconButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                ComplainList.routeName,
                (route) => false,
              ),
              icon: const Icon(Icons.view_list, color: Colors.white),
            ),
        ),
        IconButton(
          onPressed: () => AuthService.logout(context),
          icon: const Icon(Icons.logout, color: Colors.white),
        ),
      ],
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    );
  }
}