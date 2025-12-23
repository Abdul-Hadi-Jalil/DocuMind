import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Navbar
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 80,
            collapsedHeight: 70,
            backgroundColor: const Color(0xFF1A1A1A).withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFF00FF88).withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                            ).createShader(bounds),
                            child: const Text(
                              'Froggy AI',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Dashboard Title
                        Expanded(
                          child: Center(
                            child: Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // User Info and Logout
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // User Info
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Open user profile
                                    print('User profile tapped');
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00FF88,
                                        ).withOpacity(0.2),
                                      ),
                                      color: Colors.transparent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          // User Avatar
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF00FF88),
                                                  Color(0xFF00D4FF),
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'ES',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),

                                          if (!isMobile) ...[
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Eshmal Syeda',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Logout Button
                                ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement logout logic
                                    print('Logout pressed');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.05,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 768 ? 40 : 16,
                vertical: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modules Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFF00FF88)],
                        ).createShader(bounds),
                        child: Text(
                          'Modules',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 768
                                ? 32
                                : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Modules Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 768;
                          final crossAxisCount = isMobile ? 1 : 3;
                          final childAspectRatio = isMobile ? 1.4 : 1.7;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: childAspectRatio,
                                ),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              final modules = [
                                {
                                  'icon': '📄',
                                  'title': 'Chat with PDF',
                                  'description':
                                      'Upload and chat with your PDF '
                                      'documents. Ask questions and get '
                                      'instant answers powered by AI.',
                                  'color1': const Color(0xFFFF6B6B),
                                  'color2': const Color(0xFFFF4757),
                                  'onTap': () {
                                    // TODO: Open PDF module
                                    print('PDF module opened');
                                  },
                                },
                                {
                                  'icon': '🎨',
                                  'title': 'Image Generation',
                                  'description':
                                      'Create stunning images from text '
                                      'descriptions. Turn your ideas into '
                                      'beautiful visuals instantly.',
                                  'color1': const Color(0xFF4ECDC4),
                                  'color2': const Color(0xFF44A08D),
                                  'onTap': () {
                                    // TODO: Open Image Generation module
                                    print('Image Generation module opened');
                                  },
                                },
                                {
                                  'icon': '👁️',
                                  'title': 'Smart OCR',
                                  'description':
                                      'Extract text from images and '
                                      'documents with high accuracy. '
                                      'Convert any visual content to '
                                      'editable text.',
                                  'color1': const Color(0xFFFFD93D),
                                  'color2': const Color(0xFFFFAA00),
                                  'onTap': () {
                                    // TODO: Open OCR module
                                    print('OCR module opened');
                                  },
                                },
                                {
                                  'icon': '✍️',
                                  'title': 'SignatureFlow',
                                  'description':
                                      'Generate multiple signatures from a name.',
                                  'color1': const Color(0xFFA29BFE),
                                  'color2': const Color(0xFF6C5CE7),
                                  'onTap': () {
                                    // TODO: Open Signature module
                                    print('Signature module opened');
                                  },
                                },
                              ];

                              final module = modules[index];

                              return MouseRegion(
                                onEnter: (_) => setState(() {
                                  // TODO: Add hover animation
                                }),
                                child: GestureDetector(
                                  onTap: module['onTap'] as VoidCallback,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF1A1A1A,
                                      ).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF00FF88,
                                        ).withOpacity(0.2),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.transparent,
                                                  const Color(
                                                    0xFF00FF88,
                                                  ).withOpacity(0.1),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(28),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Module Icon
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      module['color1'] as Color,
                                                      module['color2'] as Color,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          (module['color2']
                                                                  as Color)
                                                              .withOpacity(0.4),
                                                      blurRadius: 20,
                                                      offset: const Offset(
                                                        0,
                                                        5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    module['icon'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              // Module Title
                                              Text(
                                                module['title'] as String,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),

                                              const SizedBox(height: 12),

                                              // Module Description
                                              Expanded(
                                                child: Text(
                                                  module['description']
                                                      as String,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF888888),
                                                    height: 1.6,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              // Open Module Button
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed:
                                                      module['onTap']
                                                          as VoidCallback,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    foregroundColor:
                                                        Colors.black,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 16,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Ink(
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFF00FF88),
                                                              Color(0xFF00D4FF),
                                                            ],
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                            minWidth: 88.0,
                                                            minHeight: 20.0,
                                                          ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                        'Open Module',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
