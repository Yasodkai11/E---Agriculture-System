import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/firebase_service.dart';
import '../../../data/services/imagebb_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/image_upload_widget.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImageBBService _imageBBService = ImageBBService();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _currentImageUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    _experienceController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId != null) {
        final userData = await _firebaseService.getDocument(
          collection: 'users',
          documentId: userId,
        );
        
        if (userData != null) {
          setState(() {
            _nameController.text = userData['fullName'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['phoneNumber'] ?? '';
            _locationController.text = userData['location'] ?? '';
            _farmSizeController.text = userData['farmSize'] ?? '';
            _experienceController.text = userData['experience'] ?? '';
            _specializationController.text = userData['specialization'] ?? '';
            _bioController.text = userData['bio'] ?? '';
            _currentImageUrl = userData['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_isEditing) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId != null) {
        await _firebaseService.updateDocument(
          collection: 'users',
          documentId: userId,
          data: {
            'fullName': _nameController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
            'location': _locationController.text.trim(),
            'farmSize': _farmSizeController.text.trim(),
            'experience': _experienceController.text.trim(),
            'specialization': _specializationController.text.trim(),
            'bio': _bioController.text.trim(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
        
        setState(() => _isEditing = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onImageUploaded(String imageUrl) {
    setState(() {
      _currentImageUrl = imageUrl;
    });
  }

  void _onImageDeleted(String imageUrl) {
    setState(() {
      _currentImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enhanced Profile',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () {
                setState(() => _isEditing = true);
              },
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
                  
                  // Profile Information
                  _buildProfileForm(),
                  
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
        collectionName: 'users',
        documentId: Provider.of<AuthProvider>(context, listen: false).user?.uid,
        fieldName: 'profileImageUrl',
        onImageUploaded: _onImageUploaded,
        onImageDeleted: _onImageDeleted,
        width: 200,
        height: 200,
        uploadButtonText: 'Upload Profile Picture',
        uploadIcon: Icons.camera_alt,
      ),
    );
  }

  Widget _buildProfileForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Basic Information Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Email Field (Read-only)
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'Email cannot be changed',
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            
            // Location Field
            TextFormField(
              controller: _locationController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Location',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            
            // User-specific Information Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isBuyer = authProvider.isBuyer;
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isBuyer ? Colors.blue.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isBuyer ? Colors.blue.shade200 : Colors.green.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isBuyer ? Icons.business : Icons.agriculture,
                            color: isBuyer ? Colors.blue.shade600 : Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isBuyer ? 'Company Information' : 'Farming Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isBuyer ? Colors.blue.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (isBuyer) ...[
                        // Company Name Field
                        TextFormField(
                          controller: _farmSizeController, // Reusing for company name
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Company Name *',
                            prefixIcon: const Icon(Icons.business),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'Enter your company or business name',
                            filled: true,
                            fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Business Type and License Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _experienceController, // Reusing for business type
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  labelText: 'Business Type *',
                                  prefixIcon: const Icon(Icons.category),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  helperText: 'e.g., Retail, Wholesale',
                                  filled: true,
                                  fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _specializationController, // Reusing for business license
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  labelText: 'Business License',
                                  prefixIcon: const Icon(Icons.assignment),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Farm Size and Experience Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _farmSizeController,
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  labelText: 'Farm Size (acres)',
                                  prefixIcon: const Icon(Icons.agriculture),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _experienceController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Experience (years)',
                                  prefixIcon: const Icon(Icons.timeline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Specialization Field
                        TextFormField(
                          controller: _specializationController,
                          enabled: _isEditing,
                          decoration: InputDecoration(
                            labelText: 'Specialization',
                            prefixIcon: const Icon(Icons.eco),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'e.g., Organic farming, Livestock, Crops',
                            filled: true,
                            fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Bio Field
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final isBuyer = authProvider.isBuyer;
                return TextFormField(
                  controller: _bioController,
                  enabled: _isEditing,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isBuyer ? 'Company Description' : 'Bio/About Me',
                    prefixIcon: Icon(isBuyer ? Icons.business : Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: isBuyer 
                        ? 'Tell us about your company and what you do'
                        : 'Tell us about yourself and your farming journey',
                    filled: true,
                    fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Debug Information (only show if no data loaded)
            if (_nameController.text.isEmpty && _phoneController.text.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Debug Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No profile data loaded. This might be because:',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• User is not authenticated\n• Profile data not found in Firestore\n• Data loading failed',
                      style: TextStyle(color: Colors.orange.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _loadUserData,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Retry Loading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Statistics Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Farming Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.agriculture,
                          title: 'Products',
                          value: '0',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.shopping_cart,
                          title: 'Orders',
                          value: '0',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          title: 'Rating',
                          value: '5.0',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.eco,
                          title: 'Experience',
                          value: '${_experienceController.text.isEmpty ? '0' : _experienceController.text} years',
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Additional Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // User Type
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Account Type',
                    value: 'Farmer',
                    color: Colors.green,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Member Since
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Member Since',
                    value: '2024',
                    color: Colors.blue,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Profile Status
                  _buildInfoRow(
                    icon: Icons.verified,
                    label: 'Profile Status',
                    value: 'Complete',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () {
                setState(() => _isEditing = !_isEditing);
              },
              icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
              label: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEditing ? Colors.grey.shade600 : Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfile,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
