
class MarketPricesService {
  static const String _baseUrl = 'https://api.example.com'; // Replace with actual API
  
  // Sri Lankan Agricultural Commodities with simulated real-time data
  // In a real app, you would fetch this from Department of Agriculture or Economic Centers
  static Future<List<CommodityPrice>> getSriLankanMarketPrices() async {
    try {
      // For now, we'll return Sri Lankan specific commodities with realistic prices
      // In production, you would integrate with:
      // - Department of Agriculture Sri Lanka APIs
      // - Dedicated Lanka Economic Research Institute data
      // - Local wholesale market data feeds
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call
      
      return [
        CommodityPrice(
          name: 'Rice (Nadu)',
          currentPrice: 185.00,
          previousPrice: 180.50,
          unit: 'per kg',
          trend: PriceTrend.up,
          image: '🌾',
          market: 'Colombo Economic Center',
          category: 'Grains',
        ),
        CommodityPrice(
          name: 'Rice (Samba)',
          currentPrice: 195.00,
          previousPrice: 198.00,
          unit: 'per kg',
          trend: PriceTrend.down,
          image: '🌾',
          market: 'Pettah Wholesale',
          category: 'Grains',
        ),
        CommodityPrice(
          name: 'Coconut',
          currentPrice: 85.00,
          previousPrice: 82.00,
          unit: 'per piece',
          trend: PriceTrend.up,
          image: '🥥',
          market: 'Kurunegala',
          category: 'Fruits',
        ),
        CommodityPrice(
          name: 'Tea (Pekoe)',
          currentPrice: 1250.00,
          previousPrice: 1235.00,
          unit: 'per kg',
          trend: PriceTrend.up,
          image: '🍃',
          market: 'Colombo Tea Auction',
          category: 'Beverages',
        ),
        CommodityPrice(
          name: 'Rubber',
          currentPrice: 485.00,
          previousPrice: 490.00,
          unit: 'per kg',
          trend: PriceTrend.down,
          image: '🔴',
          market: 'Rubber Development Dept',
          category: 'Industrial',
        ),
        CommodityPrice(
          name: 'Cinnamon',
          currentPrice: 3200.00,
          previousPrice: 3150.00,
          unit: 'per kg',
          trend: PriceTrend.up,
          image: '🌰',
          market: 'Negombo Spice Market',
          category: 'Spices',
        ),
        CommodityPrice(
          name: 'Black Pepper',
          currentPrice: 2850.00,
          previousPrice: 2900.00,
          unit: 'per kg',
          trend: PriceTrend.down,
          image: '🌶️',
          market: 'Matara Spice Center',
          category: 'Spices',
        ),
        CommodityPrice(
          name: 'Cardamom',
          currentPrice: 4500.00,
          previousPrice: 4450.00,
          unit: 'per kg',
          trend: PriceTrend.up,
          image: '🫚',
          market: 'Kandy Spice Market',
          category: 'Spices',
        ),
        CommodityPrice(
          name: 'Banana (Ambul)',
          currentPrice: 120.00,
          previousPrice: 125.00,
          unit: 'per dozen',
          trend: PriceTrend.down,
          image: '🍌',
          market: 'Dambulla Economic Center',
          category: 'Fruits',
        ),
        CommodityPrice(
          name: 'Pineapple',
          currentPrice: 150.00,
          previousPrice: 145.00,
          unit: 'per piece',
          trend: PriceTrend.up,
          image: '🍍',
          market: 'Gampaha Wholesale',
          category: 'Fruits',
        ),
        CommodityPrice(
          name: 'Green Chili',
          currentPrice: 450.00,
          previousPrice: 420.00,
          unit: 'per kg',
          trend: PriceTrend.up,
          image: '🌶️',
          market: 'Matara Vegetable Market',
          category: 'Vegetables',
        ),
        CommodityPrice(
          name: 'Onions (Big)',
          currentPrice: 280.00,
          previousPrice: 285.00,
          unit: 'per kg',
          trend: PriceTrend.down,
          image: '🧅',
          market: 'Nuwara Eliya',
          category: 'Vegetables',
        ),
        CommodityPrice(
          name: 'Potatoes',
          currentPrice: 320.00,
          previousPrice: 315.00,
          unit: 'per kg',
          trend: PriceTrend.up,
          image: '🥔',
          market: 'Badulla Economic Center',
          category: 'Vegetables',
        ),
        CommodityPrice(
          name: 'Tomatoes',
          currentPrice: 240.00,
          previousPrice: 250.00,
          unit: 'per kg',
          trend: PriceTrend.down,
          image: '🍅',
          market: 'Anuradhapura',
          category: 'Vegetables',
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch Sri Lankan market prices: $e');
    }
  }
  
  // Method to get prices for specific category
  static Future<List<CommodityPrice>> getPricesByCategory(String category) async {
    final allPrices = await getSriLankanMarketPrices();
    if (category == 'All') return allPrices;
    return allPrices.where((price) => price.category == category).toList();
  }
  
  // Method to search commodities
  static Future<List<CommodityPrice>> searchCommodities(String query) async {
    final allPrices = await getSriLankanMarketPrices();
    return allPrices
        .where((price) =>
            price.name.toLowerCase().contains(query.toLowerCase()) ||
            price.category.toLowerCase().contains(query.toLowerCase()) ||
            price.market.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  
  // Simulate real-time price updates
  static Stream<List<CommodityPrice>> getPriceUpdatesStream() async* {
    while (true) {
      yield await getSriLankanMarketPrices();
      await Future.delayed(const Duration(minutes: 5)); // Update every 5 minutes
    }
  }
}

class CommodityPrice {
  final String name;
  final double currentPrice;
  final double previousPrice;
  final String unit;
  final PriceTrend trend;
  final String image;
  final String market;
  final String category;

  CommodityPrice({
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
    required this.unit,
    required this.trend,
    required this.image,
    required this.market,
    required this.category,
  });

  factory CommodityPrice.fromJson(Map<String, dynamic> json) {
    return CommodityPrice(
      name: json['name'],
      currentPrice: json['currentPrice'].toDouble(),
      previousPrice: json['previousPrice'].toDouble(),
      unit: json['unit'],
      trend: PriceTrend.values.firstWhere(
        (trend) => trend.toString() == 'PriceTrend.${json['trend']}',
        orElse: () => PriceTrend.stable,
      ),
      image: json['image'],
      market: json['market'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'unit': unit,
      'trend': trend.toString().split('.').last,
      'image': image,
      'market': market,
      'category': category,
    };
  }
}

enum PriceTrend { up, down, stable }
