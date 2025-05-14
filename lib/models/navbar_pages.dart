import 'package:flutter/material.dart';

class NavbarPages {
  final IconData icon;
  final String titleMenu;
  final String route;
  final Widget screen;

  const NavbarPages({
    required this.icon,
    required this.titleMenu,
    required this.route,
    required this.screen,
  });
}
