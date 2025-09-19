import 'package:e_agriculture_system/data/models/chatbot_training_data.dart';

class InitialTrainingData {
  static List<ChatbotTrainingData> getInitialTrainingData() {
    return [
      // Pest Management Examples
      ChatbotTrainingData(
        question: "How do I control aphids on my tomato plants?",
        answer: "For aphid control on tomatoes, try these methods: 1) Spray with neem oil solution (2-3ml per liter of water) every 7-10 days, 2) Introduce beneficial insects like ladybugs, 3) Use insecticidal soap, 4) Remove heavily infested leaves. Start with organic methods before using chemical pesticides.",
        category: AgricultureCategories.pestManagement,
        keywords: ["aphids", "tomatoes", "neem oil", "organic control", "beneficial insects"],
        difficulty: DifficultyLevels.intermediate,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      ChatbotTrainingData(
        question: "What are natural ways to control whiteflies?",
        answer: "Natural whitefly control methods include: 1) Yellow sticky traps to catch adults, 2) Neem oil spray (2ml per liter) every 5-7 days, 3) Introduce parasitic wasps, 4) Use reflective mulch, 5) Plant trap crops like marigolds, 6) Remove heavily infested leaves. Consistent application is key for success.",
        category: AgricultureCategories.pestManagement,
        keywords: ["whiteflies", "natural control", "sticky traps", "neem oil", "parasitic wasps"],
        difficulty: DifficultyLevels.intermediate,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      // Soil Health Examples
      ChatbotTrainingData(
        question: "How often should I test my soil?",
        answer: "Soil testing frequency depends on your farming practices: 1) Annual testing for intensive farming, 2) Every 2-3 years for moderate farming, 3) Before starting new crops. Test different areas separately if soil varies. Best time is before planting season. Include pH, NPK, organic matter, and micronutrients in your test.",
        category: AgricultureCategories.soilHealth,
        keywords: ["soil testing", "pH", "NPK", "organic matter", "planting season"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.95,
        source: "initial",
      ),

      ChatbotTrainingData(
        question: "How can I improve soil fertility naturally?",
        answer: "Natural soil fertility improvement methods: 1) Add compost and organic matter, 2) Use green manure crops like legumes, 3) Practice crop rotation, 4) Apply animal manure (well-composted), 5) Use cover crops, 6) Mulch with organic materials, 7) Avoid chemical fertilizers that harm soil life. These methods build long-term soil health.",
        category: AgricultureCategories.soilHealth,
        keywords: ["soil fertility", "compost", "organic matter", "crop rotation", "green manure"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      // Irrigation Examples
      ChatbotTrainingData(
        question: "When is the best time to water my crops?",
        answer: "Optimal watering times: 1) Early morning (6-8 AM) - best for most crops, allows leaves to dry, 2) Late afternoon (4-6 PM) - acceptable for some crops, 3) Avoid midday - water evaporates quickly, 4) Avoid evening - promotes disease. Use drip irrigation for efficiency. Monitor soil moisture and adjust based on weather.",
        category: AgricultureCategories.irrigation,
        keywords: ["watering time", "early morning", "drip irrigation", "soil moisture", "disease prevention"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.95,
        source: "initial",
      ),

      ChatbotTrainingData(
        question: "How much water do my vegetables need?",
        answer: "Vegetable water requirements vary by crop: 1) Leafy greens (lettuce, spinach) - 1-2 inches per week, 2) Root vegetables (carrots, potatoes) - 1-1.5 inches per week, 3) Fruiting vegetables (tomatoes, peppers) - 1.5-2 inches per week. Water deeply but less frequently to encourage deep root growth. Check soil moisture 2-3 inches deep.",
        category: AgricultureCategories.irrigation,
        keywords: ["vegetables", "water requirements", "deep watering", "root growth", "soil moisture"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      // Disease Control Examples
      ChatbotTrainingData(
        question: "My rice plants have brown spots on leaves, what should I do?",
        answer: "Brown spots on rice leaves could indicate several issues: 1) Bacterial leaf blight - use copper-based fungicides, 2) Brown spot disease - apply mancozeb, 3) Nutrient deficiency - check nitrogen levels. Examine the spots closely - if they have yellow halos, it's likely bacterial. Remove affected leaves and improve air circulation.",
        category: AgricultureCategories.diseaseControl,
        keywords: ["rice", "brown spots", "bacterial blight", "fungicide", "nutrient deficiency"],
        difficulty: DifficultyLevels.intermediate,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      ChatbotTrainingData(
        question: "How do I prevent fungal diseases in my garden?",
        answer: "Fungal disease prevention strategies: 1) Improve air circulation by proper plant spacing, 2) Water at soil level, not on leaves, 3) Use disease-resistant varieties, 4) Practice crop rotation, 5) Remove infected plant material immediately, 6) Apply preventive fungicides like copper or sulfur, 7) Avoid overhead watering, 8) Keep garden clean and weed-free.",
        category: AgricultureCategories.diseaseControl,
        keywords: ["fungal diseases", "air circulation", "crop rotation", "fungicides", "prevention"],
        difficulty: DifficultyLevels.intermediate,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      // Crop Management Examples
      ChatbotTrainingData(
        question: "When should I harvest my rice crop?",
        answer: "Rice harvest timing is critical for quality and yield. Look for these indicators: 1) 80-85% of grains are golden yellow, 2) Grains are hard when pressed, 3) Moisture content is 20-25%, 4) Stalks start to bend. Harvest in dry weather, preferably early morning. Use sharp tools to avoid grain loss. Dry immediately after harvest to prevent spoilage.",
        category: AgricultureCategories.cropManagement,
        keywords: ["rice harvest", "timing", "moisture content", "grain quality", "drying"],
        difficulty: DifficultyLevels.intermediate,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      ChatbotTrainingData(
        question: "How do I know when my tomatoes are ready to harvest?",
        answer: "Tomato harvest indicators: 1) Color changes from green to red (or variety color), 2) Firm but slightly soft when gently squeezed, 3) Easy to remove from vine with slight twist, 4) Full size for the variety. Harvest in early morning when cool. Store at room temperature until fully ripe, then refrigerate. Green tomatoes can ripen off the vine.",
        category: AgricultureCategories.cropManagement,
        keywords: ["tomatoes", "harvest timing", "ripeness", "color change", "storage"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.95,
        source: "initial",
      ),

      // Weather Examples
      ChatbotTrainingData(
        question: "How does weather affect my crops?",
        answer: "Weather significantly impacts crop growth: 1) Temperature affects growth rate and flowering, 2) Rainfall determines irrigation needs, 3) Humidity influences disease pressure, 4) Wind can damage plants and affect pollination, 5) Frost can kill sensitive crops. Monitor forecasts and adjust farming practices accordingly. Use protective measures like row covers or windbreaks when needed.",
        category: AgricultureCategories.weather,
        keywords: ["weather", "temperature", "rainfall", "humidity", "frost protection"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      // Market Information Examples
      ChatbotTrainingData(
        question: "How do I determine the right price for my vegetables?",
        answer: "Vegetable pricing strategies: 1) Research local market prices, 2) Consider production costs (seeds, labor, inputs), 3) Factor in quality and freshness, 4) Check competitor prices, 5) Consider seasonal demand, 6) Account for transportation costs, 7) Build in profit margin (20-30%). Start with market rates and adjust based on your costs and quality. Direct sales often command higher prices than wholesale.",
        category: AgricultureCategories.marketInfo,
        keywords: ["vegetable pricing", "market research", "production costs", "quality", "profit margin"],
        difficulty: DifficultyLevels.intermediate,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.85,
        source: "initial",
      ),

      // Equipment Examples
      ChatbotTrainingData(
        question: "What basic tools do I need for small-scale farming?",
        answer: "Essential small-scale farming tools: 1) Hand tools - hoe, rake, shovel, hand trowel, 2) Cutting tools - pruning shears, harvesting knife, 3) Watering equipment - watering can, hose, drip irrigation system, 4) Soil tools - pH meter, soil thermometer, 5) Storage - buckets, baskets, containers, 6) Protection - gloves, hat, sun protection. Start with basics and add specialized tools as needed.",
        category: AgricultureCategories.equipment,
        keywords: ["farming tools", "hand tools", "irrigation", "soil testing", "small-scale farming"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      // Financial Planning Examples
      ChatbotTrainingData(
        question: "How do I calculate farming costs and profits?",
        answer: "Farming cost and profit calculation: 1) Input costs - seeds, fertilizers, pesticides, 2) Labor costs - your time and hired help, 3) Equipment costs - tools, machinery, maintenance, 4) Land costs - rent or mortgage, 5) Utilities - water, electricity, 6) Marketing costs - transportation, packaging. Total costs ÷ yield = cost per unit. Selling price - cost per unit = profit per unit. Track everything for accurate calculations.",
        category: AgricultureCategories.financial,
        keywords: ["farming costs", "profit calculation", "input costs", "labor costs", "break-even"],
        difficulty: DifficultyLevels.intermediate,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),

      // General Examples
      ChatbotTrainingData(
        question: "What is crop rotation and why is it important?",
        answer: "Crop rotation is growing different crops in the same area over time. Benefits include: 1) Prevents soil nutrient depletion, 2) Reduces pest and disease buildup, 3) Improves soil structure, 4) Increases yields, 5) Reduces need for chemical inputs. Plan 3-4 year rotations with different plant families. Example: Year 1 - tomatoes, Year 2 - beans, Year 3 - corn, Year 4 - leafy greens.",
        category: AgricultureCategories.general,
        keywords: ["crop rotation", "soil health", "pest control", "nutrient management", "sustainable farming"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.95,
        source: "initial",
      ),

      ChatbotTrainingData(
        question: "How do I start organic farming?",
        answer: "Starting organic farming: 1) Get organic certification if selling, 2) Use organic seeds and inputs, 3) Build healthy soil with compost and organic matter, 4) Practice crop rotation and companion planting, 5) Use natural pest control methods, 6) Avoid synthetic chemicals, 7) Keep detailed records, 8) Start small and learn gradually. Focus on soil health as the foundation of organic farming success.",
        category: AgricultureCategories.general,
        keywords: ["organic farming", "certification", "organic inputs", "soil health", "natural pest control"],
        difficulty: DifficultyLevels.beginner,
        language: "en",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        confidence: 0.9,
        source: "initial",
      ),
    ];
  }
}
