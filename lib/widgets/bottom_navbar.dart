import 'package:flutter/material.dart';
import 'package:proyecto_android_videollamada/models/navbar_pages.dart';
import 'package:proyecto_android_videollamada/themes/app_colors.dart';

class PersistentBottomNavBar extends StatefulWidget {
  final List<NavbarPages> menuItems;

  const PersistentBottomNavBar({super.key, required this.menuItems});

  @override
  State<PersistentBottomNavBar> createState() => _PersistentBottomNavBarState();
}

class _PersistentBottomNavBarState extends State<PersistentBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: widget.menuItems[_selectedIndex].screen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.lightViolet,
        unselectedItemColor: Colors.white,
        backgroundColor: AppColors.darkBlue,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items:
            widget.menuItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.titleMenu,
                  ),
                )
                .toList(),
      ),
    );
  }
}
