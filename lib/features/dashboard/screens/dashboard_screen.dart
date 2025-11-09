import 'package:documind/features/dashboard/data_module_data.dart';
import 'package:documind/features/image_generation/screens/image_generation_screen.dart';
import 'package:documind/features/ocr/screen_ocr_screen.dart';
import 'package:documind/features/pdf_chat/screens/pdf_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/module_card.dart';
import '../widgets/web_sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: isDesktop ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        // Sidebar
        const WebSidebar(),
        // Main Content
        Expanded(child: _buildDashboardContent(isWeb: true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _buildDashboardContent(isWeb: false);
  }

  Widget _buildDashboardContent({bool isWeb = false}) {
    final authProvider = Provider.of<AuthProvider>(context);

    return CustomScrollView(
      slivers: [
        // App Bar for mobile, Header for web
        if (!isWeb) _buildMobileAppBar(),
        if (isWeb) _buildWebHeader(),

        // Welcome Section
        SliverToBoxAdapter(
          child: Container(
            padding: isWeb
                ? const EdgeInsets.symmetric(horizontal: 40, vertical: 32)
                : const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${authProvider.userEmail?.split('@').first ?? 'User'}! 👋',
                  style: TextStyle(
                    fontSize: isWeb ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose an AI module to get started with your creative journey',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    color: AppTheme.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Modules Grid
        SliverPadding(
          padding: isWeb
              ? const EdgeInsets.symmetric(horizontal: 40, vertical: 20)
              : const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWeb ? _getWebGridCount(context) : 2,
              crossAxisSpacing: isWeb ? 24 : 16,
              mainAxisSpacing: isWeb ? 24 : 16,
              childAspectRatio: isWeb ? 1.2 : 0.9,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final module = ModuleData.modules[index];
              return ModuleCard(
                module: module,
                onTap: () => _navigateToModule(module.route),
                isWebLayout: isWeb,
              );
            }, childCount: ModuleData.modules.length),
          ),
        ),

        // Footer spacing
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  int _getWebGridCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 700) return 2;
    return 1;
  }

  SliverAppBar _buildMobileAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: AppTheme.white,
      title: const Text('FrogBase AI'),
      floating: true,
      snap: true,
      actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
    );
  }

  Widget _buildWebHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // User info
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome!',
                      style: TextStyle(fontSize: 12, color: AppTheme.grey),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Text(
                          authProvider.userEmail?.split('@').first ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.grey),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToModule(String route) {
    if (route == '/pdf-chat') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PdfChatScreen()),
      );
    } else if (route == '/ocr') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OcrScreen()),
      );
    } else if (route == '/image-generation') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ImageGenerationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigating to $route - To be implemented'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
  }
}
