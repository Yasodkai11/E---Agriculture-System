import 'package:flutter/material.dart';
import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
        _buildNumber = '1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About AGRIGO',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            _buildAppHeader(),

            const SizedBox(height: 20),

            // App Information
            _buildAppInfoSection(),

            const SizedBox(height: 20),

            // Features Section
            _buildFeaturesSection(),

            const SizedBox(height: 20),

            // Team Section
            _buildTeamSection(),

            const SizedBox(height: 20),

            // Links Section
            _buildLinksSection(),

            const SizedBox(height: 20),

            // Legal Section
            _buildLegalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 40),
          ),

          const SizedBox(height: 16),

          // App Name
          const Text(
            'AGRIGO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          // App Tagline
          const Text(
            'Empowering Farmers, Growing Communities',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Version Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Version $_appVersion (Build $_buildNumber)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About AGRIGO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AGRIGO is a comprehensive agricultural management platform designed to empower farmers with modern technology and data-driven insights. Our mission is to bridge the gap between traditional farming practices and digital innovation.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'We provide farmers with tools for crop monitoring, market analysis, financial management, and expert consultation to improve productivity and profitability.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.agriculture,
            title: 'Crop Management',
            description: 'Track crops, set reminders, and monitor growth',
          ),
          _buildFeatureItem(
            icon: Icons.trending_up,
            title: 'Market Analysis',
            description: 'Real-time market prices and trends',
          ),
          _buildFeatureItem(
            icon: Icons.account_balance_wallet,
            title: 'Financial Records',
            description: 'Track income, expenses, and profitability',
          ),
          _buildFeatureItem(
            icon: Icons.support_agent,
            title: 'Expert Consultation',
            description: 'Connect with agricultural experts',
          ),
          _buildFeatureItem(
            icon: Icons.shopping_cart,
            title: 'Marketplace',
            description: 'Buy and sell agricultural products',
          ),
          _buildFeatureItem(
            icon: Icons.wb_sunny,
            title: 'Weather Updates',
            description: 'Real-time weather forecasts and alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Our Team',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AGRIGO is developed by a dedicated team of agricultural experts, software engineers, and farming enthusiasts committed to revolutionizing the agricultural sector in Sri Lanka.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildTeamMember(
            name: 'Dr. Agricultural Expert',
            role: 'Lead Agricultural Consultant',
            description:
                'Specializes in crop management and sustainable farming practices',
          ),
          _buildTeamMember(
            name: 'Tech Development Team',
            role: 'Software Engineers',
            description: 'Building innovative solutions for modern agriculture',
          ),
          _buildTeamMember(
            name: 'Market Analysts',
            role: 'Data Specialists',
            description:
                'Providing accurate market insights and price analysis',
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connect With Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLinkItem(
            icon: Icons.language,
            title: 'Website',
            subtitle: 'www.agrigo.com',
            onTap: () => _openWebsite(),
          ),
          _buildLinkItem(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'info@agrigo.com',
            onTap: () => _sendEmail(),
          ),
          _buildLinkItem(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: '+94 11 234 5678',
            onTap: () => _makePhoneCall(),
          ),
          _buildLinkItem(
            icon: Icons.facebook,
            title: 'Facebook',
            subtitle: 'AGRIGO Sri Lanka',
            onTap: () => _openFacebook(),
          ),
          _buildLinkItem(
            icon: Icons.camera_alt,
            title: 'Instagram',
            subtitle: '@agrigo_srilanka',
            onTap: () => _openInstagram(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildLegalItem(
            title: 'Privacy Policy',
            onTap: () => _openPrivacyPolicy(),
          ),
          _buildLegalItem(
            title: 'Terms of Service',
            onTap: () => _openTermsOfService(),
          ),
          _buildLegalItem(
            title: 'Data Protection',
            onTap: () => _openDataProtection(),
          ),
          _buildLegalItem(title: 'Licenses', onTap: () => _openLicenses()),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  // Action Methods
  void _openWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.agrigo.com');

    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open website'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'info@agrigo.com',
      query: 'subject=AGRIGO Inquiry',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open email app'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+94112345678');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone app'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openFacebook() async {
    final Uri facebookUri = Uri.parse('https://facebook.com/agrigosrilanka');

    if (await canLaunchUrl(facebookUri)) {
      await launchUrl(facebookUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Facebook'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openInstagram() async {
    final Uri instagramUri = Uri.parse('https://instagram.com/agrigo_srilanka');

    if (await canLaunchUrl(instagramUri)) {
      await launchUrl(instagramUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Instagram'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openPrivacyPolicy() {
    // TODO: Implement privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy Policy coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openTermsOfService() {
    // TODO: Implement terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terms of Service coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openDataProtection() {
    // TODO: Implement data protection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data Protection coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openLicenses() {
    // TODO: Implement licenses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Licenses coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
