import 'package:flutter/material.dart';
import '../../../data/services/ai_chatbot_service.dart';
import '../../../data/services/initial_training_data.dart';

class ChatbotSetupScreen extends StatefulWidget {
  const ChatbotSetupScreen({super.key});

  @override
  State<ChatbotSetupScreen> createState() => _ChatbotSetupScreenState();
}

class _ChatbotSetupScreenState extends State<ChatbotSetupScreen> {
  final AIChatbotService _chatbotService = AIChatbotService();
  final _apiKeyController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _apiKeyConfigured = false;
  bool _trainingDataAdded = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentStatus();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _checkCurrentStatus() {
    // Check if API key is configured (not the default placeholder)
    setState(() {
      _apiKeyConfigured = !_chatbotService.toString().contains('YOUR_OPENAI_API_KEY');
    });
  }

  Future<void> _testApiKey() async {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your OpenAI API key';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Test the API key by making a simple request
      final testResponse = await _chatbotService.generateAIResponse(
        'Hello, this is a test message.',
        'test-user',
      );

      if (testResponse.isNotEmpty) {
        setState(() {
          _apiKeyConfigured = true;
          _successMessage = 'API key is working! AI responses are now enabled.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'API key test failed. Please check your key and try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'API key test failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addInitialTrainingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final initialData = InitialTrainingData.getInitialTrainingData();
      
      for (final data in initialData) {
        await _chatbotService.addTrainingData(data);
      }

      setState(() {
        _trainingDataAdded = true;
        _successMessage = 'Successfully added ${initialData.length} training examples! Your chatbot is now ready to help farmers.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add training data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Setup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              '🤖 AI Chatbot Setup',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set up your AI-powered agriculture chatbot to provide intelligent assistance to farmers.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Step 1: API Key Configuration
            _buildApiKeySection(),
            
            const SizedBox(height: 24),
            
            // Step 2: Training Data
            _buildTrainingDataSection(),
            
            const SizedBox(height: 24),
            
            // Status Summary
            _buildStatusSummary(),
            
            const SizedBox(height: 24),
            
            // Error/Success Messages
            if (_errorMessage != null) _buildErrorMessage(),
            if (_successMessage != null) _buildSuccessMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _apiKeyConfigured ? Icons.check_circle : Icons.key,
                  color: _apiKeyConfigured ? Colors.green : Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Step 1: OpenAI API Key',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _apiKeyConfigured ? Colors.green : Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (!_apiKeyConfigured) ...[
              const Text(
                'To enable AI responses, you need an OpenAI API key:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              
              const Text(
                '1. Visit https://platform.openai.com/',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Text(
                '2. Create an account and get your API key',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Text(
                "3. Add credits to your account (\$5-10 minimum)",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'OpenAI API Key',
                  hintText: 'sk-your-api-key-here',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testApiKey,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Test API Key'),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'API Key is configured and working!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _trainingDataAdded ? Icons.check_circle : Icons.school,
                  color: _trainingDataAdded ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Step 2: Training Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _trainingDataAdded ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Add initial training data to help your chatbot understand agriculture topics:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            
            const Text(
              '• 15+ agriculture Q&A examples',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Text(
              '• Covers pest management, soil health, irrigation, etc.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const Text(
              '• Ready-to-use training examples',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading || _trainingDataAdded ? null : _addInitialTrainingData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_trainingDataAdded ? 'Training Data Added' : 'Add Initial Training Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Setup Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildStatusItem(
              'API Key Configuration',
              _apiKeyConfigured,
              _apiKeyConfigured ? 'AI responses enabled' : 'AI responses disabled (using fallback)',
            ),
            
            const SizedBox(height: 12),
            
            _buildStatusItem(
              'Training Data',
              _trainingDataAdded,
              _trainingDataAdded ? 'Chatbot is trained and ready' : 'Add training data for better responses',
            ),
            
            const SizedBox(height: 16),
            
            if (_apiKeyConfigured && _trainingDataAdded) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.celebration, color: Colors.green, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      '🎉 Setup Complete!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your AI chatbot is ready to help farmers with intelligent, contextual advice!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/expert-chat');
                      },
                      child: const Text('Test Your Chatbot'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isComplete, String description) {
    return Row(
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isComplete ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isComplete ? Colors.green : Colors.grey.shade700,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _successMessage!,
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
























