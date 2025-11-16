import 'package:documind/features/dashboard/data_module_data.dart';
import 'package:documind/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class WebSidebar extends StatelessWidget {
  const WebSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      width: dashboardProvider.isSidebarExpanded ? 280 : 80,
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            height: 100,
            child: dashboardProvider.isSidebarExpanded
                ? Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: AppTheme.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Froggy AI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.black,
                              ),
                            ),
                            Text(
                              'AI Platform',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: AppTheme.white,
                        size: 20,
                      ),
                    ),
                  ),
          ),
          const Divider(height: 1),
          // Navigation Items
          Expanded(
            child: ListView.builder(
              itemCount: ModuleData.modules.length,
              itemBuilder: (context, index) {
                final module = ModuleData.modules[index];
                return _buildSidebarItem(
                  module: module,
                  isExpanded: dashboardProvider.isSidebarExpanded,
                  onTap: () {
                    // TODO: Navigate to module
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${module.title}'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // User Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: dashboardProvider.isSidebarExpanded
                ? Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppTheme.lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  )
                : Center(
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => authProvider.logout(),
                      tooltip: 'Logout',
                    ),
                  ),
          ),
          // Toggle Button
          Container(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(
                dashboardProvider.isSidebarExpanded
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: AppTheme.grey,
              ),
              onPressed: () => dashboardProvider.toggleSidebar(),
              tooltip: dashboardProvider.isSidebarExpanded
                  ? 'Collapse sidebar'
                  : 'Expand sidebar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required Module module,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: module.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(module.icon, style: const TextStyle(fontSize: 16)),
      ),
      title: isExpanded
          ? Text(
              module.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            )
          : null,
      onTap: onTap,
      contentPadding: isExpanded
          ? const EdgeInsets.symmetric(horizontal: 16)
          : const EdgeInsets.symmetric(horizontal: 8),
      minLeadingWidth: 0,
    );
  }
}
