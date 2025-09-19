import 'package:flutter/material.dart';
import '../../../data/services/ai_chatbot_service.dart';
import '../../../data/models/chatbot_training_data.dart';
import '../../widgets/common/loading_widget.dart';

class ChatbotTrainingScreen extends StatefulWidget {
  const ChatbotTrainingScreen({super.key});

  @override
  State<ChatbotTrainingScreen> createState() => _ChatbotTrainingScreenState();
}

class _ChatbotTrainingScreenState extends State<ChatbotTrainingScreen> {
  final AIChatbotService _chatbotService = AIChatbotService();
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _keywordsController = TextEditingController();

  String _selectedCategory = AgricultureCategories.general;
  String _selectedDifficulty = DifficultyLevels.intermediate;
  String _selectedLanguage = 'en';
  bool _isActive = true;
  double _confidence = 1.0;

  List<ChatbotTrainingData> _trainingData = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _chatbotService.getTrainingData();
      setState(() {
        _trainingData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load training data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addTrainingData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final keywords = _keywordsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final trainingData = ChatbotTrainingData(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        category: _selectedCategory,
        keywords: keywords,
        difficulty: _selectedDifficulty,
        language: _selectedLanguage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: _isActive,
        confidence: _confidence,
        source: 'manual',
      );

      await _chatbotService.addTrainingData(trainingData);
      
      // Clear form
      _questionController.clear();
      _answerController.clear();
      _keywordsController.clear();
      
      // Reload data
      await _loadTrainingData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Training data added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add training data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTrainingData(String id) async {
    try {
      await _chatbotService.deleteTrainingData(id);
      await _loadTrainingData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Training data deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete training data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Training'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrainingData,
          ),
        ],
      ),
      body: _isLoading && _trainingData.isEmpty
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Training Data Form
                  _buildAddForm(),
                  
                  const SizedBox(height: 24),
                  
                  // Training Data List
                  _buildTrainingDataList(),
                  
                  // Error Message
                  if (_errorMessage != null) _buildErrorMessage(),
                ],
              ),
            ),
    );
  }

  Widget _buildAddForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Training Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Question Field
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'What is the user asking?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Answer Field
              TextFormField(
                controller: _answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  hintText: 'What should the chatbot respond?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: AgricultureCategories.all.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(AgricultureCategories.getDisplayName(category)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Keywords Field
              TextFormField(
                controller: _keywordsController,
                decoration: const InputDecoration(
                  labelText: 'Keywords (comma-separated)',
                  hintText: 'pest, insect, control, management',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at least one keyword';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Difficulty and Language Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: DifficultyLevels.all.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(DifficultyLevels.getDisplayName(difficulty)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Language',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'si', child: Text('Sinhala')),
                        DropdownMenuItem(value: 'ta', child: Text('Tamil')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Confidence Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confidence: ${(_confidence * 100).toInt()}%'),
                  Slider(
                    value: _confidence,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _confidence = value;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Active Switch
              Row(
                children: [
                  const Text('Active'),
                  const Spacer(),
                  Switch(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addTrainingData,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Training Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingDataList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Training Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text('${_trainingData.length} items'),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_trainingData.isEmpty)
              const Center(
                child: Text(
                  'No training data found. Add some data to get started!',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trainingData.length,
                itemBuilder: (context, index) {
                  final data = _trainingData[index];
                  return _buildTrainingDataItem(data);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingDataItem(ChatbotTrainingData data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(data);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              data.answer,
              style: const TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Chip(
                  label: Text(AgricultureCategories.getDisplayName(data.category)),
                  backgroundColor: Colors.blue.shade100,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(DifficultyLevels.getDisplayName(data.difficulty)),
                  backgroundColor: Colors.green.shade100,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${(data.confidence * 100).toInt()}%'),
                  backgroundColor: Colors.orange.shade100,
                ),
                const Spacer(),
                Icon(
                  data.isActive ? Icons.check_circle : Icons.cancel,
                  color: data.isActive ? Colors.green : Colors.red,
                  size: 16,
                ),
              ],
            ),
            
            if (data.keywords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: data.keywords.map((keyword) {
                  return Chip(
                    label: Text(keyword),
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(ChatbotTrainingData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Training Data'),
        content: Text('Are you sure you want to delete this training data?\n\nQuestion: ${data.question}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTrainingData(data.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
























