import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class DashboardProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _isSidebarExpanded = true;

  int get currentIndex => _currentIndex;
  bool get isSidebarExpanded => _isSidebarExpanded;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleSidebar() {
    _isSidebarExpanded = !_isSidebarExpanded;
    notifyListeners();
  }

  void setSidebarExpanded(bool expanded) {
    _isSidebarExpanded = expanded;
    notifyListeners();
  }
}
