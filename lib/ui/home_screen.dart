import 'package:flutter/material.dart';

// Design Constants
const double kDefaultPadding = 24.0;
const double kGridSpacing = 16.0; // DIKURANGI DARI 20
const double kBorderRadius = 24.0; // DIKURANGI DARI 28
const double kIconSize = 32.0;

// Color Palette
const Color kPrimaryColor = Color(0xFF3A2EC3);
const Color kSecondaryColor = Color(0xFF6C63FF);
const Color kAccentColor = Color(0xFF00D4AA);
const Color kBackgroundColor = Color(0xFFF8F9FF);
const Color kCardColor = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);

// Gradient Colors
const LinearGradient kBlueGradient = LinearGradient(
  colors: [Color(0xFF3A2EC3), Color(0xFF6C63FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kRedGradient = LinearGradient(
  colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kGreenGradient = LinearGradient(
  colors: [Color(0xFF00D4AA), Color(0xFF00B09B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kPurpleGradient = LinearGradient(
  colors: [Color(0xFF8A2BE2), Color(0xFFDA70D6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class User {
  final String name;
  final String role;
  final String profileImagePath;

  const User({
    required this.name,
    required this.role,
    required this.profileImagePath,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _currentUser = User(
    name: 'Abdurrohman',
    role: 'Fullstack Developer',
    profileImagePath: 'assets/images/profile.jpg',
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView( // TAMBAHKAN SINGLECHILDSCROLLVIEW
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? kDefaultPadding : kDefaultPadding * 2,
              vertical: isSmallScreen ? 16 : 24, // TAMBAHKAN VERTICAL PADDING
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                _buildAppBar(),
                const SizedBox(height: 20),

                // User Profile
                UserProfileHeader(user: _currentUser),
                const SizedBox(height: 28),

                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 32),

                // Main Grid
                _buildMainGrid(isSmallScreen, screenHeight),

                // Bottom Info
                const SizedBox(height: 24),
                _buildBottomInfo(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QR S&G',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Scan & Generate',
              style: TextStyle(
                fontSize: 14,
                color: kTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: IconButton(
            icon: Icon(Icons.settings_outlined, color: kPrimaryColor),
            onPressed: () {}, // TODO: Settings screen
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 16,
            color: kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'QR S',
                style: TextStyle(
                  fontSize: 36, // DIKURANGI DARI 40
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: '&',
                style: TextStyle(
                  fontSize: 36, // DIKURANGI DARI 40
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              TextSpan(
                text: 'G',
                style: TextStyle(
                  fontSize: 36, // DIKURANGI DARI 40
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Create, scan, share and print QR codes\nwith professional quality',
          style: TextStyle(
            fontSize: 14, // DIKURANGI DARI 15
            color: kTextSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMainGrid(bool isSmallScreen, double screenHeight) {
    return GridView.count(
      crossAxisCount: isSmallScreen ? 2 : 4,
      mainAxisSpacing: kGridSpacing,
      crossAxisSpacing: kGridSpacing,
      childAspectRatio: isSmallScreen ? 0.95 : 1.0, // SESUAIKAN ASPECT RATIO
      shrinkWrap: true, // PENTING: Agar GridView bisa di dalam Column
      physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll grid internal
      padding: EdgeInsets.only(
        bottom: 8,
      ),
      children: const [
        _MenuButton(
          icon: Icons.qr_code_2_outlined,
          activeIcon: Icons.qr_code_2,
          label: 'Create',
          gradient: kBlueGradient,
          route: '/create',
          description: 'Generate new QR code',
        ),
        _MenuButton(
          icon: Icons.qr_code_scanner_outlined,
          activeIcon: Icons.qr_code_scanner,
          label: 'Scan',
          gradient: kRedGradient,
          route: '/scan',
          description: 'Scan QR code',
        ),
        _MenuButton(
          icon: Icons.send_outlined,
          activeIcon: Icons.send,
          label: 'Share',
          gradient: kGreenGradient,
          route: '/share',
          description: 'Share QR codes',
        ),
        _MenuButton(
          icon: Icons.print_outlined,
          activeIcon: Icons.print,
          label: 'Print',
          gradient: kPurpleGradient,
          route: '/print',
          description: 'Print QR codes',
        ),
      ],
    );
  }

  Widget _buildBottomInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: kPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'All features available offline',
              style: TextStyle(
                fontSize: 13,
                color: kTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18), // DIKURANGI DARI 20
      decoration: BoxDecoration(
        gradient: kBlueGradient,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 20, // DIKURANGI DARI 25
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image dengan ukuran lebih kecil
          Container(
            padding: const EdgeInsets.all(2.5), // DIKURANGI
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5), // DIKURANGI
            ),
            child: CircleAvatar(
              radius: 30, // DIKURANGI DARI 36
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 28, // DIKURANGI DARI 33
                backgroundImage: AssetImage(user.profileImagePath),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user.name}!',
                  style: const TextStyle(
                    fontSize: 20, // DIKURANGI DARI 22
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.role,
                  style: TextStyle(
                    fontSize: 14, // DIKURANGI DARI 15
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                // Stats Row
                Row(
                  children: [
                    _buildStatItem('24', 'Created'),
                    const SizedBox(width: 16), // DIKURANGI DARI 20
                    _buildStatItem('12', 'Scanned'),
                    const SizedBox(width: 16), // DIKURANGI DARI 20
                    _buildStatItem('8', 'Shared'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16, // DIKURANGI DARI 18
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11, // DIKURANGI DARI 12
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatefulWidget {
  const _MenuButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.gradient,
    required this.route,
    required this.description,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final LinearGradient gradient;
  final String route;
  final String description;

  @override
  State<_MenuButton> createState() => __MenuButtonState();
}

class __MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.route.isNotEmpty
            ? () => Navigator.pushNamed(context, widget.route)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(20), // DIKURANGI DARI kBorderRadius
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
            border: Border.all(
              color: Colors.grey.shade100,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20), // DIKURANGI DARI 24
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isHovered ? 70 : 64, // DIKURANGI
                  width: _isHovered ? 70 : 64, // DIKURANGI
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    shape: BoxShape.circle,
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    _isHovered ? widget.activeIcon : widget.icon,
                    color: Colors.white,
                    size: _isHovered ? 32 : 28, // DIKURANGI
                  ),
                ),
                const SizedBox(height: 16),

                // Label
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16, // DIKURANGI DARI 18
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11, // DIKURANGI DARI 12
                    color: kTextSecondary,
                    height: 1.4,
                  ),
                ),

                // Arrow indicator on hover
                if (_isHovered) ...[
                  const SizedBox(height: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: kPrimaryColor,
                    size: 16, // DIKURANGI DARI 18
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}