import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chatbot_training_data.dart';
import '../models/chatbot_conversation.dart';

class AIChatbotService {
  static final AIChatbotService _instance = AIChatbotService._internal();
  factory AIChatbotService() => _instance;
  AIChatbotService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // AI Service Configuration
  static const String _openaiApiKey = 'YOUR_OPENAI_API_KEY'; // Replace with your API key
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-3.5-turbo';
  
  // Firestore Collections
  CollectionReference get _trainingDataCollection => _firestore.collection('chatbot_training_data');
  CollectionReference get _conversationsCollection => _firestore.collection('chatbot_conversations');
  CollectionReference get _knowledgeBaseCollection => _firestore.collection('agriculture_knowledge_base');

  /// Generate AI response using OpenAI API
  Future<String> generateAIResponse(String userMessage, String userId) async {
    try {
      // Get context from knowledge base
      final context = await _getRelevantContext(userMessage);
      
      // Prepare the prompt with agriculture-specific context
      final systemPrompt = _buildSystemPrompt(context);
      
      // Make API call to OpenAI
      final response = await http.post(
        Uri.parse('$_openaiBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage}
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        // Save conversation to Firestore
        await _saveConversation(userId, userMessage, aiResponse);
        
        return aiResponse;
      } else {
        debugPrint('OpenAI API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      debugPrint('Error generating AI response: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  /// Build system prompt with agriculture context
  String _buildSystemPrompt(String context) {
    return '''
You are Dr. Agriculture Expert, an AI assistant specialized in agriculture and farming. You help farmers with:

1. **Pest Management**: Integrated pest management (IPM), natural controls, chemical treatments
2. **Disease Control**: Plant diseases, fungicides, prevention strategies
3. **Soil Health**: Soil testing, fertilization, organic matter, pH levels
4. **Irrigation**: Water management, drip systems, scheduling
5. **Crop Management**: Planting, harvesting, crop rotation, yield optimization
6. **Weather Impact**: Climate considerations, seasonal planning
7. **Market Information**: Pricing, market trends, selling strategies
8. **Equipment**: Farm machinery, maintenance, selection
9. **Financial Planning**: Cost analysis, budgeting, profit optimization

Context from knowledge base: $context

Guidelines:
- Provide practical, actionable advice
- Consider local conditions when possible
- Suggest both traditional and modern farming methods
- Always prioritize sustainable farming practices
- Ask clarifying questions when needed
- Be encouraging and supportive
- Use simple, clear language
- Provide specific examples when helpful

If you don't know something specific, admit it and suggest where the farmer might find more information.
''';
  }

  /// Get relevant context from knowledge base
  Future<String> _getRelevantContext(String userMessage) async {
    try {
      final lowerMessage = userMessage.toLowerCase();
      
      // Search for relevant documents in knowledge base
      QuerySnapshot snapshot = await _knowledgeBaseCollection
          .where('keywords', arrayContainsAny: _extractKeywords(lowerMessage))
          .limit(3)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .map((data) => '${data['title']}: ${data['content']}')
            .join('\n\n');
      }
      
      return 'No specific context found, but general agriculture knowledge applies.';
    } catch (e) {
      debugPrint('Error getting context: $e');
      return 'General agriculture knowledge available.';
    }
  }

  /// Extract keywords from user message
  List<String> _extractKeywords(String message) {
    final keywords = <String>[];
    final words = message.split(' ');
    
    for (final word in words) {
      if (word.length > 3) {
        keywords.add(word);
      }
    }
    
    return keywords;
  }

  /// Save conversation to Firestore
  Future<void> _saveConversation(String userId, String userMessage, String aiResponse) async {
    try {
      await _conversationsCollection.add({
        'userId': userId,
        'userMessage': userMessage,
        'aiResponse': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
        'model': _model,
        'context': await _getRelevantContext(userMessage),
      });
    } catch (e) {
      debugPrint('Error saving conversation: $e');
    }
  }

  /// Get fallback response when AI fails
  String _getFallbackResponse(String userMessage) {
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
      return "Soil health is fundamental to successful farming. Consider soil testing, organic matter addition, proper pH levels, and crop rotation. What specific soil issues are you facing?";
    } else if (lowerMessage.contains('seed') || lowerMessage.contains('planting')) {
      return "Choose quality seeds from reliable sources. Consider your local climate, soil conditions, and crop rotation. Proper planting depth, spacing, and timing are crucial for good establishment.";
    } else {
      return "Thank you for your question! I'm here to help with all aspects of farming. Feel free to ask about pest management, disease control, fertilization, irrigation, harvesting, weather impacts, soil health, or any other farming concerns.";
    }
  }

  // ========== TRAINING DATA MANAGEMENT ==========

  /// Add training data
  Future<void> addTrainingData(ChatbotTrainingData trainingData) async {
    try {
      await _trainingDataCollection.add(trainingData.toMap());
    } catch (e) {
      throw Exception('Failed to add training data: $e');
    }
  }

  /// Get all training data
  Future<List<ChatbotTrainingData>> getTrainingData() async {
    try {
      final snapshot = await _trainingDataCollection.get();
      return snapshot.docs
          .map((doc) => ChatbotTrainingData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get training data: $e');
    }
  }

  /// Update training data
  Future<void> updateTrainingData(String id, ChatbotTrainingData trainingData) async {
    try {
      await _trainingDataCollection.doc(id).update(trainingData.toMap());
    } catch (e) {
      throw Exception('Failed to update training data: $e');
    }
  }

  /// Delete training data
  Future<void> deleteTrainingData(String id) async {
    try {
      await _trainingDataCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete training data: $e');
    }
  }

  // ========== KNOWLEDGE BASE MANAGEMENT ==========

  /// Add knowledge base entry
  Future<void> addKnowledgeBaseEntry(Map<String, dynamic> entry) async {
    try {
      await _knowledgeBaseCollection.add(entry);
    } catch (e) {
      throw Exception('Failed to add knowledge base entry: $e');
    }
  }

  /// Get knowledge base entries
  Future<List<Map<String, dynamic>>> getKnowledgeBaseEntries() async {
    try {
      final snapshot = await _knowledgeBaseCollection.get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to get knowledge base entries: $e');
    }
  }

  /// Update knowledge base entry
  Future<void> updateKnowledgeBaseEntry(String id, Map<String, dynamic> entry) async {
    try {
      await _knowledgeBaseCollection.doc(id).update(entry);
    } catch (e) {
      throw Exception('Failed to update knowledge base entry: $e');
    }
  }

  /// Delete knowledge base entry
  Future<void> deleteKnowledgeBaseEntry(String id) async {
    try {
      await _knowledgeBaseCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete knowledge base entry: $e');
    }
  }

  // ========== CONVERSATION ANALYTICS ==========

  /// Get conversation history for a user
  Future<List<ChatbotConversation>> getUserConversations(String userId) async {
    try {
      final snapshot = await _conversationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs
          .map((doc) => ChatbotConversation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user conversations: $e');
    }
  }

  /// Get conversation analytics
  Future<Map<String, dynamic>> getConversationAnalytics() async {
    try {
      final snapshot = await _conversationsCollection.get();
      final conversations = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      
      return {
        'totalConversations': conversations.length,
        'uniqueUsers': conversations.map((c) => c['userId']).toSet().length,
        'averageResponseLength': conversations
            .map((c) => (c['aiResponse'] as String).length)
            .reduce((a, b) => a + b) / conversations.length,
        'mostCommonTopics': _getMostCommonTopics(conversations),
      };
    } catch (e) {
      throw Exception('Failed to get conversation analytics: $e');
    }
  }

  /// Get most common topics from conversations
  List<Map<String, dynamic>> _getMostCommonTopics(List<Map<String, dynamic>> conversations) {
    final topicCounts = <String, int>{};
    
    for (final conversation in conversations) {
      final message = (conversation['userMessage'] as String).toLowerCase();
      
      if (message.contains('pest')) topicCounts['pest'] = (topicCounts['pest'] ?? 0) + 1;
      if (message.contains('disease')) topicCounts['disease'] = (topicCounts['disease'] ?? 0) + 1;
      if (message.contains('fertilizer')) topicCounts['fertilizer'] = (topicCounts['fertilizer'] ?? 0) + 1;
      if (message.contains('water')) topicCounts['irrigation'] = (topicCounts['irrigation'] ?? 0) + 1;
      if (message.contains('harvest')) topicCounts['harvest'] = (topicCounts['harvest'] ?? 0) + 1;
      if (message.contains('weather')) topicCounts['weather'] = (topicCounts['weather'] ?? 0) + 1;
      if (message.contains('soil')) topicCounts['soil'] = (topicCounts['soil'] ?? 0) + 1;
      if (message.contains('seed')) topicCounts['planting'] = (topicCounts['planting'] ?? 0) + 1;
    }
    
    return topicCounts.entries
        .map((entry) => {'topic': entry.key, 'count': entry.value})
        .toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
  }

  // ========== MODEL TRAINING ==========

  /// Train the model with new data
  Future<void> trainModel(List<ChatbotTrainingData> trainingData) async {
    try {
      // This would typically involve:
      // 1. Preparing training data
      // 2. Fine-tuning the model
      // 3. Updating the model endpoint
      
      // For now, we'll just save the training data
      for (final data in trainingData) {
        await addTrainingData(data);
      }
      
      debugPrint('Model training data saved successfully');
    } catch (e) {
      throw Exception('Failed to train model: $e');
    }
  }

  /// Export training data
  Future<String> exportTrainingData() async {
    try {
      final trainingData = await getTrainingData();
      final jsonData = trainingData.map((data) => data.toMap()).toList();
      return jsonEncode(jsonData);
    } catch (e) {
      throw Exception('Failed to export training data: $e');
    }
  }

  /// Import training data
  Future<void> importTrainingData(String jsonData) async {
    try {
      final List<dynamic> dataList = jsonDecode(jsonData);
      final trainingData = dataList
          .map((data) => ChatbotTrainingData.fromMap(data as Map<String, dynamic>))
          .toList();
      
      for (final data in trainingData) {
        await addTrainingData(data);
      }
    } catch (e) {
      throw Exception('Failed to import training data: $e');
    }
  }
}
