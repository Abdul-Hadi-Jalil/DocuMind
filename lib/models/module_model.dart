import 'package:flutter/material.dart';

class Module {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final String route;

  const Module({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}
