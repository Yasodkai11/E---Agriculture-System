import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../widgets/common/custom_button.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String _selectedCategory = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _supportCategories = [
    'General Inquiry',
    'Order Issues',
    'Payment Problems',
    'Delivery Questions',
    'Product Quality',
    'Account Issues',
    'Technical Support',
    'Refund Request',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I track my order?',
      'answer': 'You can track your order in the Delivery Tracking section. Simply navigate to the tracking page and view your order status.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept Cash on Delivery, Bank Transfer, Mobile Payment, and Digital Wallet payments.',
    },
    {
      'question': 'How long does delivery take?',
      'answer': 'Standard delivery takes 3-5 business days. Express delivery is available for 1-2 business days.',
    },
    {
      'question': 'Can I cancel my order?',
      'answer': 'Yes, you can cancel pending orders. Once confirmed by the farmer, cancellation may not be possible.',
    },
    {
      'question': 'What if I receive damaged products?',
      'answer': 'Contact support immediately with photos. We\'ll arrange a replacement or refund.',
    },
    {
      'question': 'How do I contact a farmer?',
      'answer': 'You can contact farmers through the order details or use the Search Farmers feature to connect directly.',
    },
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitSupportTicket() async {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      _showSnackBar('Please fill in all required fields', Colors.red);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        _showSnackBar('Support ticket submitted successfully!', Colors.green);
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to submit ticket. Please try again.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _subjectController.clear();
    _messageController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedCategory = 'General Inquiry';
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    final screenHeight = ResponsiveHelper.screenHeight(context);
    
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
          'Support & Help',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const Text(
                    'Our support team is here to assist you with any questions or issues',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // Quick Actions
            _buildSection(
              title: 'Quick Actions',
              description: 'Get help with common issues',
              children: [
                _buildQuickActionCard(
                  icon: Icons.phone,
                  title: 'Call Support',
                  subtitle: 'Speak with our team',
                  onTap: () => _showContactDialog(),
                  color: Colors.green,
                ),
                _buildQuickActionCard(
                  icon: Icons.email,
                  title: 'Email Support',
                  subtitle: 'Send us a message',
                  onTap: () => _showEmailDialog(),
                  color: Colors.blue,
                ),
                _buildQuickActionCard(
                  icon: Icons.chat,
                  title: 'Live Chat',
                  subtitle: 'Chat with support',
                  onTap: () => _showLiveChatDialog(),
                  color: Colors.orange,
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.03),

            // FAQ Section
            _buildSection(
              title: 'Frequently Asked Questions',
              description: 'Find answers to common questions',
              children: [
                ..._faqs.map((faq) => _buildFAQCard(
                  question: faq['question'],
                  answer: faq['answer'],
                )),
              ],
            ),

            SizedBox(height: screenHeight * 0.03),

            // Support Ticket Form
            _buildSection(
              title: 'Submit Support Ticket',
              description: 'Create a new support ticket for specific issues',
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Dropdown
                      Text(
                        'Category *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _supportCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Subject Field
                      Text(
                        'Subject *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          hintText: 'Brief description of your issue',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Message Field
                      Text(
                        'Message *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe your issue in detail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Contact Information
                      Text(
                        'Contact Information (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                hintText: 'Phone',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: _isSubmitting ? 'Submitting...' : 'Submit Ticket',
                          onPressed: _isSubmitting ? null : _submitSupportTicket,
                          backgroundColor: AppColors.primary,
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildFAQCard({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Call us at:'),
            SizedBox(height: 8),
            Text('📞 +94 11 234 5678', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            Text('Available:'),
            Text('Monday - Friday: 8:00 AM - 6:00 PM'),
            Text('Saturday: 9:00 AM - 4:00 PM'),
            Text('Sunday: Closed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send us an email at:'),
            SizedBox(height: 8),
            Text('📧 support@eagriculture.lk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            Text('We typically respond within:'),
            Text('• 2-4 hours during business hours'),
            Text('• 24 hours on weekends'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live chat is available:'),
            SizedBox(height: 16),
            Text('🕒 Monday - Friday: 9:00 AM - 5:00 PM'),
            SizedBox(height: 8),
            Text('💬 Click the chat icon in the bottom right corner to start a conversation with our support team.'),
            SizedBox(height: 16),
            Text('Note: Live chat may have longer wait times during peak hours.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
