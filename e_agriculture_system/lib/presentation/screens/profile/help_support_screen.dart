import 'package:flutter/material.dart';
import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I add my farm details?',
      answer: 'Go to the Dashboard and tap on "Add Farm" or "Farm Details". You can enter your farm size, location, and crop information.',
    ),
    FAQItem(
      question: 'How do I track my crops?',
      answer: 'Use the Crop Monitor feature in the Dashboard. You can add crops, set reminders, and track their growth progress.',
    ),
    FAQItem(
      question: 'How do I check market prices?',
      answer: 'Navigate to the Market Prices section to view current prices for various agricultural products in your area.',
    ),
    FAQItem(
      question: 'How do I contact an expert?',
      answer: 'Use the Expert Chat feature to connect with agricultural experts for advice on farming practices and crop management.',
    ),
    FAQItem(
      question: 'How do I sell my products?',
      answer: 'Go to the Marketplace section and tap "Add Product" to list your agricultural products for sale.',
    ),
    FAQItem(
      question: 'How do I manage my financial records?',
      answer: 'Use the Financial Records feature to track your income, expenses, and overall farm profitability.',
    ),
    FAQItem(
      question: 'How do I get weather updates?',
      answer: 'The app automatically provides weather updates based on your location. You can also enable weather alerts in notifications.',
    ),
    FAQItem(
      question: 'How do I reset my password?',
      answer: 'Go to Profile > Privacy & Security > Change Password, or use the "Forgot Password" option on the login screen.',
    ),
  ];

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
          'Help & Support',
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
            // Quick Actions
            _buildQuickActionsSection(),

            const SizedBox(height: 20),

            // Contact Support
            _buildContactSection(),

            const SizedBox(height: 20),

            // FAQ Section
            _buildFAQSection(),

            const SizedBox(height: 20),

            // Resources Section
            _buildResourcesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
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
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get help quickly',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Live Chat',
                  onTap: () => _showLiveChatDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  onTap: () => _sendEmail(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.phone_outlined,
                  title: 'Call Support',
                  onTap: () => _makePhoneCall(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionItem(
                  icon: Icons.video_call_outlined,
                  title: 'Video Call',
                  onTap: () => _showVideoCallDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
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
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Get in touch with our support team',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'support@agrigo.com',
            onTap: () => _sendEmail(),
          ),
          _buildContactItem(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: '+94 11 234 5678',
            onTap: () => _makePhoneCall(),
          ),
          _buildContactItem(
            icon: Icons.access_time,
            title: 'Support Hours',
            subtitle: 'Mon-Fri: 8:00 AM - 6:00 PM',
            onTap: null,
          ),
          _buildContactItem(
            icon: Icons.location_on,
            title: 'Address',
            subtitle: '123 Agriculture St, Colombo, Sri Lanka',
            onTap: () => _openMaps(),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
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
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Find answers to common questions',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ..._faqItems.map((faq) => _buildFAQItem(faq)),
        ],
      ),
    );
  }

  Widget _buildResourcesSection() {
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
            'Resources',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Helpful resources and guides',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildResourceItem(
            icon: Icons.book_outlined,
            title: 'User Guide',
            subtitle: 'Complete guide to using AGRIGO',
            onTap: () => _openUserGuide(),
          ),
          _buildResourceItem(
            icon: Icons.video_library_outlined,
            title: 'Video Tutorials',
            subtitle: 'Learn with step-by-step videos',
            onTap: () => _openVideoTutorials(),
          ),
          _buildResourceItem(
            icon: Icons.forum_outlined,
            title: 'Community Forum',
            subtitle: 'Connect with other farmers',
            onTap: () => _openCommunityForum(),
          ),
          _buildResourceItem(
            icon: Icons.bug_report_outlined,
            title: 'Report Bug',
            subtitle: 'Report issues or bugs',
            onTap: () => _reportBug(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
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
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
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
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            faq.answer,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem({
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
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Live Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Connect with our support team for immediate assistance.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement live chat functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connecting to live chat...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Start Chat',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@agrigo.com',
      query: 'subject=AGRIGO Support Request',
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

  void _showVideoCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Video Call',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Schedule a video call with our support team.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement video call scheduling
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video call scheduling coming soon'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Schedule',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _openMaps() async {
    final Uri mapsUri = Uri.parse(
      'https://maps.google.com/?q=123+Agriculture+St+Colombo+Sri+Lanka'
    );
    
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openUserGuide() {
    // TODO: Implement user guide
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User guide coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openVideoTutorials() {
    // TODO: Implement video tutorials
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video tutorials coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openCommunityForum() {
    // TODO: Implement community forum
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Community forum coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _reportBug() {
    // TODO: Implement bug reporting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bug reporting coming soon'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}
