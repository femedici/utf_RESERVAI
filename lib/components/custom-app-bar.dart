import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  CustomAppBar({required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu),
        color: Colors.black,
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(
        children: [
          Image.asset(
            'images/logo_reservai.png', // Certifique-se de que o caminho está correto
            width: 200,
            height: 120,
          ),
        ],
      ),
      backgroundColor: Colors.white.withOpacity(0.6),
      iconTheme: const IconThemeData(
        color: Colors.black,
      ),
      elevation: 4.0,
      shadowColor: Colors.grey.withOpacity(0.5),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
