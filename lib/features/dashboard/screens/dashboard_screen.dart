import 'package:documind/features/dashboard/data_module_data.dart';
import 'package:documind/features/image_generation/image_generation_screen.dart';
import 'package:documind/features/ocr/ocr_screen.dart';
import 'package:documind/features/pdf_chat/pdf_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  // Fixed card dimensions
  static const double _cardWidth = 280;
  static const double _cardHeight = 270;
  static const double _cardSpacing = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _buildWebLayout(),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        // Sidebar
        const WebSidebar(),
        // Main Content
        Expanded(child: _buildDashboardContent()),
      ],
    );
  }

  Widget _buildDashboardContent() {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Web Header
          _buildWebHeader(),

          // Welcome Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose an AI module to get started with your creative journey',
                  style: TextStyle(fontSize: 18, color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),

          // Fixed Grid Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Wrap(
              spacing: _cardSpacing,
              runSpacing: _cardSpacing,
              children: ModuleData.modules.map((module) {
                return SizedBox(
                  width: _cardWidth,
                  height: _cardHeight,
                  child: ModuleCard(
                    module: module,
                    onTap: () => _navigateToModule(module.route),
                    isWebLayout: true,
                  ),
                );
              }).toList(),
            ),
          ),

          // Footer spacing
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWebHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen, // Changed to green
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
                  color: AppTheme.white, // Changed to white for contrast
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryGreen, // Changed to green
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.white, // Changed to white
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Text(
                        'User', // Removed specific name
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.white, // Changed to white
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
            icon: const Icon(
              Icons.logout,
              color: AppTheme.white,
            ), // Changed to white
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  void _navigateToModule(String route) {
    if (route == '/pdf-chat') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SimpleChatScreen()),
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
    }
  }

  void _logout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
  }
}
