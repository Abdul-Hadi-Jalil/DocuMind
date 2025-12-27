import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const LandingScreen({super.key, required this.showLoginScreen});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Navbar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 80,
            collapsedHeight: 70,
            backgroundColor: _isScrolled
                // ignore: deprecated_member_use
                ? const Color(0xFF000000).withOpacity(0.95)
                // ignore: deprecated_member_use
                : const Color(0xFF000000).withOpacity(0.85),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              expandedTitleScale: 1.0,
              titlePadding: const EdgeInsets.symmetric(horizontal: 20),
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                      ).createShader(bounds),
                      child: const Text(
                        'Froggy AI',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: widget.showLoginScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FF88), Color(0xFF00D4FF)],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: const Color(0xFF00FF88).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 80,
                            minHeight: 40,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
                ),
              ),
              child: Stack(
                children: [
                  // Background glow effect
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            // ignore: deprecated_member_use
                            const Color(0xFF00FF88).withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.1, 0.8],
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Main Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Colors.white, Color(0xFF00FF88)],
                            ).createShader(bounds),
                            child: Text(
                              'Your Complete AI Toolkit',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 768
                                    ? 64
                                    : 40,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Subtitle
                          SizedBox(
                            width: MediaQuery.of(context).size.width > 768
                                ? 800
                                : double.infinity,
                            child: Text(
                              'Unleash the power of AI with document intelligence, '
                              'image generation, OCR technology, and seamless '
                              'signature workflows - all in one powerful platform',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 768
                                    ? 20
                                    : 16,
                                color: const Color(0xFFAAAAAA),
                                height: 1.6,
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Get Started Button
                          ElevatedButton(
                            onPressed: widget.showLoginScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00FF88),
                                    Color(0xFF00D4FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00FF88,
                                      // ignore: deprecated_member_use
                                    ).withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 200,
                                  minHeight: 60,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Get Started Free',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Features Section
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 80,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    // Section Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, Color(0xFF00FF88)],
                      ).createShader(bounds),
                      child: Text(
                        'Powerful Features at Your Fingertips',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width > 768
                              ? 48
                              : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Features Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile =
                            MediaQuery.of(context).size.width < 768;
                        final crossAxisCount = isMobile ? 1 : 2;
                        final childAspectRatio = isMobile ? 1.2 : 1.0;

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
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final features = [
                              {
                                'icon': '📄',
                                'title': 'Chat with PDF',
                                'description':
                                    'Transform your PDFs into interactive '
                                    'conversations. Ask questions, extract '
                                    'insights, and understand documents in '
                                    'seconds with AI-powered intelligence',
                                'color1': const Color(0xFFFF6B6B),
                                'color2': const Color(0xFFFF4757),
                              },
                              {
                                'icon': '🎨',
                                'title': 'Image Generation',
                                'description':
                                    'Create stunning visuals from text '
                                    'descriptions. Bring your imagination '
                                    'to life with cutting-edge AI image '
                                    'generation technology',
                                'color1': const Color(0xFF4ECDC4),
                                'color2': const Color(0xFF44A08D),
                              },
                              {
                                'icon': '📸',
                                'title': 'Smart OCR',
                                'description':
                                    'Extract text from any image or document '
                                    'with precision. Convert scanned documents, '
                                    'photos, and screenshots into editable '
                                    'text instantly',
                                'color1': const Color(0xFFFFD93D),
                                'color2': const Color(0xFFFFAA00),
                              },
                            ];

                            final feature = features[index];

                            return MouseRegion(
                              onEnter: (_) => setState(() {}),
                              onExit: (_) => setState(() {}),
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(
                                          0xFF1A1A1A,
                                          // ignore: deprecated_member_use
                                        ).withOpacity(0.8),
                                        const Color(
                                          0xFF0A0A0A,
                                          // ignore: deprecated_member_use
                                        ).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF00FF88,
                                        // ignore: deprecated_member_use
                                      ).withOpacity(0.2),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Feature Icon
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                feature['color1'] as Color,
                                                feature['color2'] as Color,
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (feature['color2'] as Color)
                                                    // ignore: deprecated_member_use
                                                    .withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              feature['icon'] as String,
                                              style: const TextStyle(
                                                fontSize: 32,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Feature Title
                                        Text(
                                          feature['title'] as String,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF00FF88),
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Feature Description
                                        Text(
                                          feature['description'] as String,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Color(0xFFAAAAAA),
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
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
              ),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    // Copyright
                    const Text(
                      '© 2024 AI Suite. All rights reserved.',
                      style: TextStyle(color: Color(0xFF666666), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
