import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/buyer_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/imagebb_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/image_upload_widget.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final BuyerService _buyerService = BuyerService();
  final FirebaseService _firebaseService = FirebaseService();
  final ImageBBService _imageBBService = ImageBBService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _businessLicenseController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _currentImageUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBuyerData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessLicenseController.dispose();
    _taxIdController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadBuyerData() async {
    setState(() => _isLoading = true);
    
    try {
      final buyerData = await _buyerService.getCurrentBuyerData();
      if (buyerData != null) {
        setState(() {
          _nameController.text = buyerData.fullName;
          _emailController.text = buyerData.email;
          _phoneController.text = buyerData.phoneNumber;
          _locationController.text = buyerData.location ?? '';
          _businessNameController.text = buyerData.businessName ?? '';
          _businessTypeController.text = buyerData.businessType ?? '';
          _businessLicenseController.text = buyerData.businessLicense ?? '';
          _taxIdController.text = buyerData.taxId ?? '';
          _currentImageUrl = buyerData.profileImageUrl;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load buyer data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading buyer data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_isEditing) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _buyerService.updateBuyerProfile(
        buyerId: userId,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        businessName: _businessNameController.text.trim(),
        businessType: _businessTypeController.text.trim(),
      );

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: $e';
        _isLoading = false;
      });
    }
  }

  void _onImageUploaded(String imageUrl) {
    setState(() {
      _currentImageUrl = imageUrl;
    });
  }

  void _onImageDeleted() {
    setState(() {
      _currentImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image Section
                  _buildProfileImageSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Company Information
                  _buildCompanyForm(),
                  
                  const SizedBox(height: 24),
                  
                  // Error Message
                  if (_errorMessage != null) _buildErrorMessage(),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: ImageUploadWidget(
        currentImageUrl: _currentImageUrl,
        collectionName: 'buyers',
        documentId: Provider.of<AuthProvider>(context, listen: false).user?.uid,
        fieldName: 'profileImageUrl',
        onImageUploaded: _onImageUploaded,
        onImageDeleted: (String imageUrl) {
          _onImageDeleted();
        },
        width: 200,
        height: 200,
        uploadButtonText: 'Upload Company Logo',
        uploadIcon: Icons.business,
      ),
    );
  }

  Widget _buildCompanyForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Business Name
            TextFormField(
              controller: _businessNameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Company Name *',
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Enter your company or business name',
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            
            // Business Type
            TextFormField(
              controller: _businessTypeController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Business Type *',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'e.g., Retail, Wholesale, Restaurant, Supermarket',
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            
            // Business License
            TextFormField(
              controller: _businessLicenseController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Business License Number',
                prefixIcon: const Icon(Icons.assignment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Your business registration number',
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            
            // Tax ID
            TextFormField(
              controller: _taxIdController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Tax ID / VAT Number',
                prefixIcon: const Icon(Icons.receipt),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Your tax identification number',
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Full Name
            TextFormField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Contact Person Name *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              enabled: false, // Email cannot be changed
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                helperText: 'Email cannot be changed',
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            
            // Location
            TextFormField(
              controller: _locationController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Business Location',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'City, State, Country',
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            
            // Bio
            TextFormField(
              controller: _bioController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Company Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Tell us about your company and what you do',
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_isEditing) return const SizedBox.shrink();
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
                _loadBuyerData(); // Reload original data
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }
}






