class ChatbotTrainingData {
  final String? id;
  final String question;
  final String answer;
  final String category;
  final List<String> keywords;
  final String difficulty; // beginner, intermediate, advanced
  final String language;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final double confidence; // 0.0 to 1.0
  final String source; // manual, imported, generated

  ChatbotTrainingData({
    this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.keywords,
    this.difficulty = 'intermediate',
    this.language = 'en',
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.confidence = 1.0,
    this.source = 'manual',
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'keywords': keywords,
      'difficulty': difficulty,
      'language': language,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'confidence': confidence,
      'source': source,
    };
  }

  factory ChatbotTrainingData.fromMap(Map<String, dynamic> map) {
    return ChatbotTrainingData(
      id: map['id'],
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: map['category'] ?? 'general',
      keywords: List<String>.from(map['keywords'] ?? []),
      difficulty: map['difficulty'] ?? 'intermediate',
      language: map['language'] ?? 'en',
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
      confidence: (map['confidence'] ?? 1.0).toDouble(),
      source: map['source'] ?? 'manual',
    );
  }

  ChatbotTrainingData copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    List<String>? keywords,
    String? difficulty,
    String? language,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? confidence,
    String? source,
  }) {
    return ChatbotTrainingData(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      keywords: keywords ?? this.keywords,
      difficulty: difficulty ?? this.difficulty,
      language: language ?? this.language,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'ChatbotTrainingData(id: $id, question: $question, answer: $answer, category: $category, keywords: $keywords, difficulty: $difficulty, language: $language, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive, confidence: $confidence, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatbotTrainingData &&
        other.id == id &&
        other.question == question &&
        other.answer == answer &&
        other.category == category &&
        other.keywords == keywords &&
        other.difficulty == difficulty &&
        other.language == language &&
        other.metadata == metadata &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.confidence == confidence &&
        other.source == source;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        answer.hashCode ^
        category.hashCode ^
        keywords.hashCode ^
        difficulty.hashCode ^
        language.hashCode ^
        metadata.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isActive.hashCode ^
        confidence.hashCode ^
        source.hashCode;
  }
}

// Categories for agriculture chatbot
class AgricultureCategories {
  static const String pestManagement = 'pest_management';
  static const String diseaseControl = 'disease_control';
  static const String soilHealth = 'soil_health';
  static const String irrigation = 'irrigation';
  static const String cropManagement = 'crop_management';
  static const String weather = 'weather';
  static const String marketInfo = 'market_info';
  static const String equipment = 'equipment';
  static const String financial = 'financial';
  static const String general = 'general';

  static const List<String> all = [
    pestManagement,
    diseaseControl,
    soilHealth,
    irrigation,
    cropManagement,
    weather,
    marketInfo,
    equipment,
    financial,
    general,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case pestManagement:
        return 'Pest Management';
      case diseaseControl:
        return 'Disease Control';
      case soilHealth:
        return 'Soil Health';
      case irrigation:
        return 'Irrigation';
      case cropManagement:
        return 'Crop Management';
      case weather:
        return 'Weather';
      case marketInfo:
        return 'Market Information';
      case equipment:
        return 'Equipment';
      case financial:
        return 'Financial Planning';
      case general:
        return 'General';
      default:
        return 'Unknown';
    }
  }
}

// Difficulty levels
class DifficultyLevels {
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String advanced = 'advanced';

  static const List<String> all = [beginner, intermediate, advanced];

  static String getDisplayName(String difficulty) {
    switch (difficulty) {
      case beginner:
        return 'Beginner';
      case intermediate:
        return 'Intermediate';
      case advanced:
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }
}
























