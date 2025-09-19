import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../data/services/ai_chatbot_service.dart';

class ExpertChatScreen extends StatefulWidget {
  const ExpertChatScreen({super.key});

  @override
  State<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends State<ExpertChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final AIChatbotService _chatbotService = AIChatbotService();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hello! I'm Dr. Agriculture Expert. How can I help you with your farming today?",
      isUser: false,
      senderName: "Dr. Agriculture Expert",
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Get user's name from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProvider.userModel?.fullName.split(' ').first ?? 'You';

    // Add user message
    _messages.add(ChatMessage(
      text: messageText,
      isUser: true,
      senderName: userName,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    setState(() {
      _isTyping = true;
    });

    // Generate AI response
    _generateAIResponse(messageText);

    _scrollToBottom();
  }

  String _generateExpertResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('pest') || lowerMessage.contains('insect')) {
      return "For pest management, I recommend using integrated pest management (IPM) strategies. Can you describe the pests you're seeing? Also, consider using neem oil or beneficial insects as natural controls.";
    } else if (lowerMessage.contains('disease') || lowerMessage.contains('fungus')) {
      return "Plant diseases can be challenging. First, identify the symptoms and affected plant parts. Consider using fungicides, improving air circulation, and removing infected plant material. What specific symptoms are you observing?";
    } else if (lowerMessage.contains('fertilizer') || lowerMessage.contains('nutrient')) {
      return "Soil testing is crucial for proper fertilization. Different crops have different nutrient requirements. Consider organic options like compost, manure, or commercial fertilizers based on your soil test results.";
    } else if (lowerMessage.contains('water') || lowerMessage.contains('irrigation')) {
      return "Proper irrigation is essential. Monitor soil moisture, use drip irrigation for efficiency, and water early in the morning. Consider your crop's water requirements and local weather conditions.";
    } else if (lowerMessage.contains('harvest') || lowerMessage.contains('yield')) {
      return "Harvest timing is critical for quality and yield. Monitor crop maturity indicators, check weather forecasts, and plan your harvest schedule. What crop are you planning to harvest?";
    } else if (lowerMessage.contains('weather') || lowerMessage.contains('climate')) {
      return "Weather significantly impacts farming decisions. Monitor forecasts, protect crops from extreme weather, and adjust your farming practices accordingly. Consider using weather apps and local forecasts.";
    } else if (lowerMessage.contains('soil') || lowerMessage.contains('ground')) {
      return "Soil health is fundamental to successful farming. Regular soil testing, organic matter addition, and proper pH management are key. Consider crop rotation and cover crops for soil improvement.";
    } else if (lowerMessage.contains('seed') || lowerMessage.contains('planting')) {
      return "Choose quality seeds from reliable sources. Consider your local climate, soil conditions, and crop rotation. Proper planting depth, spacing, and timing are crucial for good establishment.";
    } else {
      return "Thank you for your question! I'm here to help with all aspects of farming. Feel free to ask about pest management, disease control, fertilization, irrigation, harvesting, weather impacts, soil health, or any other farming concerns.";
    }
  }

  Future<void> _generateAIResponse(String userMessage) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid ?? 'anonymous';
      
      final aiResponse = await _chatbotService.generateAIResponse(userMessage, userId);
      
      if (mounted) {
        _messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          senderName: "Dr. Agriculture Expert (AI)",
          timestamp: DateTime.now(),
        ));
        setState(() {
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        // Fallback to rule-based response
        final fallbackResponse = _generateExpertResponse(userMessage);
        _messages.add(ChatMessage(
          text: fallbackResponse,
          isUser: false,
          senderName: "Dr. Agriculture Expert",
          timestamp: DateTime.now(),
        ));
        setState(() {
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.veryLightGreen,
      appBar: AppBar(
        title: const Text(
          'Expert Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showExpertInfo(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Expert Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dr. Agriculture Expert',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Online • Available 24/7',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageCard(_messages[index]);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Dr. Expert is typing',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.agriculture,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: message.isUser ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isUser ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.agriculture,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpertInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expert Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. Agriculture Expert'),
            SizedBox(height: 8),
            Text('• PhD in Agricultural Sciences'),
            Text('• 15+ years of farming experience'),
            Text('• Specializes in crop management'),
            Text('• Available 24/7 for assistance'),
            SizedBox(height: 16),
            Text('Ask about:'),
            Text('• Pest and disease management'),
            Text('• Soil health and fertilization'),
            Text('• Irrigation and water management'),
            Text('• Harvest planning and timing'),
            Text('• Weather impacts on farming'),
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

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String senderName;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.senderName,
    required this.timestamp,
  });
}
