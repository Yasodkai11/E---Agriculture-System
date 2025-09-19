import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../data/models/farmer_model.dart';

class SearchFarmersScreen extends StatefulWidget {
  const SearchFarmersScreen({super.key});

  @override
  State<SearchFarmersScreen> createState() => _SearchFarmersScreenState();
}

class _SearchFarmersScreenState extends State<SearchFarmersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<FarmerModel> _allFarmers = [
    FarmerModel(
      id: '1',
      name: 'Kumara Perera',
      location: 'Anuradhapura',
      district: 'Anuradhapura',
      contactNumber: '+94 71 234 5678',
      email: 'kumara@example.com',
      profileImage: '👨‍🌾',
      crops: ['Rice', 'Corn', 'Vegetables'],
      livestock: ['Chickens'],
      farmSize: '5 acres',
      experience: '15',
      rating: 4.8,
      reviewCount: 24,
      isVerified: true,
      bio: 'Experienced rice farmer with 15 years of organic farming experience.',
      certifications: {'organic': true, 'fair_trade': true},
      joinedDate: DateTime.now().subtract(const Duration(days: 365)),
      isOnline: true,
      socialMedia: {'facebook': 'kumara.perera', 'whatsapp': '+94 71 234 5678'},
    ),
    FarmerModel(
      id: '2',
      name: 'Nimal Silva',
      location: 'Kandy',
      district: 'Kandy',
      contactNumber: '+94 77 345 6789',
      email: 'nimal@example.com',
      profileImage: '👨‍🌾',
      crops: ['Tea', 'Spices'],
      livestock: [],
      farmSize: '3 acres',
      experience: '8',
      rating: 4.5,
      reviewCount: 18,
      isVerified: true,
      bio: 'Tea and spice farmer from the hill country.',
      certifications: {'organic': true},
      joinedDate: DateTime.now().subtract(const Duration(days: 180)),
      isOnline: false,
      socialMedia: {'whatsapp': '+94 77 345 6789'},
    ),
    FarmerModel(
      id: '3',
      name: 'Sunil Fernando',
      location: 'Galle',
      district: 'Galle',
      contactNumber: '+94 76 456 7890',
      email: 'sunil@example.com',
      profileImage: '👨‍🌾',
      crops: ['Coconut', 'Fruits'],
      livestock: ['Cows'],
      farmSize: '8 acres',
      experience: '12',
      rating: 4.9,
      reviewCount: 31,
      isVerified: true,
      bio: 'Coconut and fruit farmer from the southern province.',
      certifications: {'organic': true, 'fair_trade': true},
      joinedDate: DateTime.now().subtract(const Duration(days: 240)),
      isOnline: true,
      socialMedia: {'facebook': 'sunil.fernando', 'instagram': 'sunil_farm'},
    ),
  ];

  List<FarmerModel> _filteredFarmers = [];
  String _selectedDistrict = 'All';
  String _selectedCrop = 'All';
  String _selectedExperience = 'All';
  bool _showVerifiedOnly = false;
  bool _showOnlineOnly = false;

  final List<String> _districts = [
    'All', 'Anuradhapura', 'Kandy', 'Galle', 'Colombo', 'Jaffna', 
    'Kurunegala', 'Matara', 'Ratnapura', 'Badulla', 'Polonnaruwa'
  ];

  final List<String> _crops = [
    'All', 'Rice', 'Corn', 'Vegetables', 'Tea', 'Spices', 
    'Coconut', 'Fruits', 'Wheat', 'Pulses'
  ];

  final List<String> _experienceLevels = [
    'All', '0-5 years', '5-10 years', '10-15 years', '15+ years'
  ];

  @override
  void initState() {
    super.initState();
    _filteredFarmers = List.from(_allFarmers);
    _searchController.addListener(_filterFarmers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFarmers() {
    setState(() {
      _filteredFarmers = _allFarmers.where((farmer) {
        // Search by name, location, or crops
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            farmer.name.toLowerCase().contains(searchQuery) ||
            farmer.location.toLowerCase().contains(searchQuery) ||
            farmer.crops.any((crop) => crop.toLowerCase().contains(searchQuery));

        // Filter by district
        final matchesDistrict = _selectedDistrict == 'All' || 
            farmer.district == _selectedDistrict;

        // Filter by crop
        final matchesCrop = _selectedCrop == 'All' || 
            farmer.crops.contains(_selectedCrop);

        // Filter by experience
        final matchesExperience = _filterByExperience(farmer);

        // Filter by verification status
        final matchesVerification = !_showVerifiedOnly || farmer.isVerified;

        // Filter by online status
        final matchesOnline = !_showOnlineOnly || farmer.isOnline;

        return matchesSearch && matchesDistrict && matchesCrop && 
               matchesExperience && matchesVerification && matchesOnline;
      }).toList();
    });
  }

  bool _filterByExperience(FarmerModel farmer) {
    if (_selectedExperience == 'All') return true;
    
    final experience = int.tryParse(farmer.experience) ?? 0;
    
    switch (_selectedExperience) {
      case '0-5 years':
        return experience >= 0 && experience < 5;
      case '5-10 years':
        return experience >= 5 && experience < 10;
      case '10-15 years':
        return experience >= 10 && experience < 15;
      case '15+ years':
        return experience >= 15;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Search Farmers',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildActiveFilters(),
          _buildStatsCard(),
          Expanded(
            child: _filteredFarmers.isEmpty
                ? _buildEmptyState()
                : _buildFarmersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: ResponsiveHelper.getResponsivePadding(context),
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search farmers by name, location, or crops...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.textSecondary, size: ResponsiveHelper.getResponsiveIconSize(context)),
          suffixIcon: Icon(Icons.clear, color: AppColors.textSecondary, size: ResponsiveHelper.getResponsiveIconSize(context)),
        ),
        style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03)),
        onChanged: (value) => _filterFarmers(),
      ),
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <String>[];
    
    if (_selectedDistrict != 'All') activeFilters.add(_selectedDistrict);
    if (_selectedCrop != 'All') activeFilters.add(_selectedCrop);
    if (_selectedExperience != 'All') activeFilters.add(_selectedExperience);
    if (_showVerifiedOnly) activeFilters.add('Verified Only');
    if (_showOnlineOnly) activeFilters.add('Online Only');

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      height: ResponsiveHelper.getResponsiveHeight(context, 0.06),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: activeFilters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.015),
              vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.008),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context) * 2),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeFilters[index],
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
                GestureDetector(
                  onTap: () => _removeFilter(activeFilters[index]),
                  child: Icon(
                    Icons.close,
                    color: AppColors.primary,
                    size: ResponsiveHelper.getResponsiveIconSize(context) * 0.6,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    final verifiedCount = _filteredFarmers.where((f) => f.isVerified).length;
    final onlineCount = _filteredFarmers.where((f) => f.isOnline).length;
    final avgRating = _filteredFarmers.isEmpty 
        ? 0.0 
        : _filteredFarmers.map((f) => f.rating).reduce((a, b) => a + b) / _filteredFarmers.length;

    return Container(
      margin: ResponsiveHelper.getResponsivePadding(context),
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
      ),
      child: ResponsiveHelper.isSmallScreen(context)
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Farmers', _filteredFarmers.length.toString(), '👨‍🌾'),
                    ),
                    Expanded(
                      child: _buildStatItem('Verified', verifiedCount.toString(), '✅'),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Online', onlineCount.toString(), '🟢'),
                    ),
                    Expanded(
                      child: _buildStatItem('Avg Rating', avgRating.toStringAsFixed(1), '⭐'),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildStatItem('Farmers', _filteredFarmers.length.toString(), '👨‍🌾'),
                ),
                Expanded(
                  child: _buildStatItem('Verified', verifiedCount.toString(), '✅'),
                ),
                Expanded(
                  child: _buildStatItem('Online', onlineCount.toString(), '🟢'),
                ),
                Expanded(
                  child: _buildStatItem('Avg Rating', avgRating.toStringAsFixed(1), '⭐'),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, String icon) {
    return Column(
      children: [
        Text(
          icon,
          style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.05)),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
          ),
        ),
      ],
    );
  }

  Widget _buildFarmersList() {
    return ListView.builder(
      padding: ResponsiveHelper.getResponsivePadding(context),
      itemCount: _filteredFarmers.length,
      itemBuilder: (context, index) {
        final farmer = _filteredFarmers[index];
        return _buildFarmerCard(farmer);
      },
    );
  }

  Widget _buildFarmerCard(FarmerModel farmer) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
        ),
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getResponsiveWidth(context, 0.15),
                    height: ResponsiveHelper.getResponsiveHeight(context, 0.08),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context) * 2),
                    ),
                    child: Center(
                      child: Text(
                        farmer.profileImage,
                        style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.06)),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                farmer.name,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (farmer.isVerified) ...[
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: ResponsiveHelper.getResponsiveIconSize(context) * 0.8,
                              ),
                            ],
                            if (farmer.isOnline) ...[
                              SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                              Container(
                                width: ResponsiveHelper.getResponsiveWidth(context, 0.02),
                                height: ResponsiveHelper.getResponsiveHeight(context, 0.01),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
                        Text(
                          farmer.displayLocation,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: ResponsiveHelper.getResponsiveIconSize(context) * 0.6,
                            ),
                            SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
                            Text(
                              farmer.ratingText,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
              Text(
                farmer.bio,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
              Wrap(
                spacing: ResponsiveHelper.getResponsiveSpacing(context, 0.01),
                runSpacing: ResponsiveHelper.getResponsiveSpacing(context, 0.01),
                children: [
                  _buildChip('🌾 ${farmer.displayCrops}', AppColors.primary),
                  _buildChip('🏠 ${farmer.farmSize}', Colors.green),
                  _buildChip('⏰ ${farmer.experienceText}', Colors.orange),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
              ResponsiveHelper.isSmallScreen(context)
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _contactFarmer(farmer),
                            icon: Icon(Icons.phone, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                            label: Text('Contact'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _viewFarmerProfile(farmer),
                            icon: Icon(Icons.person, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                            label: Text('Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _contactFarmer(farmer),
                            icon: Icon(Icons.phone, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                            label: Text('Contact'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewFarmerProfile(farmer),
                            icon: Icon(Icons.person, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                            label: Text('Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.01),
        vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.005),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No farmers found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria or filters',
            style: TextStyle(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Farmers'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    border: OutlineInputBorder(),
                  ),
                  items: _districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCrop,
                  decoration: const InputDecoration(
                    labelText: 'Crop',
                    border: OutlineInputBorder(),
                  ),
                  items: _crops.map((crop) {
                    return DropdownMenuItem(
                      value: crop,
                      child: Text(crop),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCrop = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedExperience,
                  decoration: const InputDecoration(
                    labelText: 'Experience',
                    border: OutlineInputBorder(),
                  ),
                  items: _experienceLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExperience = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Verified Farmers Only'),
                  value: _showVerifiedOnly,
                  onChanged: (value) {
                    setState(() {
                      _showVerifiedOnly = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Online Farmers Only'),
                  value: _showOnlineOnly,
                  onChanged: (value) {
                    setState(() {
                      _showOnlineOnly = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _filterFarmers();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFilter(String filter) {
    if (filter == _selectedDistrict) {
      _selectedDistrict = 'All';
    } else if (filter == _selectedCrop) {
      _selectedCrop = 'All';
    } else if (filter == _selectedExperience) {
      _selectedExperience = 'All';
    } else if (filter == 'Verified Only') {
      _showVerifiedOnly = false;
    } else if (filter == 'Online Only') {
      _showOnlineOnly = false;
    }
    _filterFarmers();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDistrict = 'All';
      _selectedCrop = 'All';
      _selectedExperience = 'All';
      _showVerifiedOnly = false;
      _showOnlineOnly = false;
      _searchController.clear();
    });
    _filterFarmers();
  }

  void _contactFarmer(FarmerModel farmer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${farmer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primary),
              title: const Text('Phone'),
              subtitle: Text(farmer.contactNumber),
              onTap: () {
                // Implement phone call functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text('Email'),
              subtitle: Text(farmer.email),
              onTap: () {
                // Implement email functionality
                Navigator.pop(context);
              },
            ),
            if (farmer.socialMedia['whatsapp'] != null)
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text('WhatsApp'),
                subtitle: Text(farmer.socialMedia['whatsapp']),
                onTap: () {
                  // Implement WhatsApp functionality
                  Navigator.pop(context);
                },
              ),
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

  void _viewFarmerProfile(FarmerModel farmer) {
    // Navigate to farmer profile screen
    Navigator.pop(context);
    // TODO: Implement farmer profile screen navigation
  }
}


