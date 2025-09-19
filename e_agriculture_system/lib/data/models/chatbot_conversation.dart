class ChatbotConversation {
  final String? id;
  final String userId;
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;
  final String model;
  final String? context;
  final double? confidence;
  final String? category;
  final Map<String, dynamic>? metadata;
  final bool isHelpful; // User feedback
  final String? userFeedback;

  ChatbotConversation({
    this.id,
    required this.userId,
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
    required this.model,
    this.context,
    this.confidence,
    this.category,
    this.metadata,
    this.isHelpful = false,
    this.userFeedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'timestamp': timestamp.toIso8601String(),
      'model': model,
      'context': context,
      'confidence': confidence,
      'category': category,
      'metadata': metadata,
      'isHelpful': isHelpful,
      'userFeedback': userFeedback,
    };
  }

  factory ChatbotConversation.fromMap(Map<String, dynamic> map) {
    return ChatbotConversation(
      id: map['id'],
      userId: map['userId'] ?? '',
      userMessage: map['userMessage'] ?? '',
      aiResponse: map['aiResponse'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      model: map['model'] ?? 'unknown',
      context: map['context'],
      confidence: map['confidence']?.toDouble(),
      category: map['category'],
      metadata: map['metadata'],
      isHelpful: map['isHelpful'] ?? false,
      userFeedback: map['userFeedback'],
    );
  }

  ChatbotConversation copyWith({
    String? id,
    String? userId,
    String? userMessage,
    String? aiResponse,
    DateTime? timestamp,
    String? model,
    String? context,
    double? confidence,
    String? category,
    Map<String, dynamic>? metadata,
    bool? isHelpful,
    String? userFeedback,
  }) {
    return ChatbotConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userMessage: userMessage ?? this.userMessage,
      aiResponse: aiResponse ?? this.aiResponse,
      timestamp: timestamp ?? this.timestamp,
      model: model ?? this.model,
      context: context ?? this.context,
      confidence: confidence ?? this.confidence,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
      isHelpful: isHelpful ?? this.isHelpful,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }

  @override
  String toString() {
    return 'ChatbotConversation(id: $id, userId: $userId, userMessage: $userMessage, aiResponse: $aiResponse, timestamp: $timestamp, model: $model, context: $context, confidence: $confidence, category: $category, metadata: $metadata, isHelpful: $isHelpful, userFeedback: $userFeedback)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatbotConversation &&
        other.id == id &&
        other.userId == userId &&
        other.userMessage == userMessage &&
        other.aiResponse == aiResponse &&
        other.timestamp == timestamp &&
        other.model == model &&
        other.context == context &&
        other.confidence == confidence &&
        other.category == category &&
        other.metadata == metadata &&
        other.isHelpful == isHelpful &&
        other.userFeedback == userFeedback;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        userMessage.hashCode ^
        aiResponse.hashCode ^
        timestamp.hashCode ^
        model.hashCode ^
        context.hashCode ^
        confidence.hashCode ^
        category.hashCode ^
        metadata.hashCode ^
        isHelpful.hashCode ^
        userFeedback.hashCode;
  }
}
























