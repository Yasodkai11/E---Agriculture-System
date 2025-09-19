import 'dart:io';
import 'package:e_agriculture_system/core/constants/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/marketplace_service.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/common/adaptive_image_widget.dart';
import '../../widgets/common/web_image_upload_widget.dart';
import '../../widgets/common/image_upload_widget.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? productToEdit;
  
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedCategory = 'vegetables';
  String _selectedUnit = 'kg';
  List<File> _selectedImages = [];
  final List<String> _selectedImageUrls = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEditing = false;

  final List<String> _units = ['kg', 'pieces', 'bags', 'tons', 'liters', 'dozen'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.productToEdit != null;
    if (_isEditing) {
      _initializeFormWithProduct();
    }
  }

  void _initializeFormWithProduct() {
    final product = widget.productToEdit!;
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _quantityController.text = product.quantity.toString();
    _locationController.text = product.location ?? '';
    _selectedCategory = product.category;
    _selectedUnit = product.unit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xFile) => File(xFile.path)).toList();
        if (_selectedImages.length > 5) {
          _selectedImages = _selectedImages.take(5).toList();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 5 images allowed. Only first 5 will be used.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final marketplaceService = MarketplaceService();
      
      if (_isEditing) {
        // Update existing product
        await marketplaceService.updateProduct(
          productId: widget.productToEdit!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          unit: _selectedUnit,
          quantity: int.parse(_quantityController.text),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
        );

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${_nameController.text}" updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Create new product
        final productId = await marketplaceService.createProduct(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          unit: _selectedUnit,
          quantity: int.parse(_quantityController.text),
          category: _selectedCategory,
          location: _locationController.text.trim(),
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          imageUrls: _selectedImageUrls.isNotEmpty ? _selectedImageUrls : null,
        );

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${_nameController.text}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate back to marketplace
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = _isEditing 
          ? 'Failed to update product: $e'
          : 'Failed to add product: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.veryLightGreen,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppDimensions.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'e.g., Fresh Organic Tomatoes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  if (value.trim().length < 3) {
                    return 'Product name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe your product...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter product description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.getResponsiveSpacing(context, 16)),

              // Category and Unit Row - Mobile Responsive Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  // On small screens, stack vertically; on larger screens, use row
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        // Category
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          isExpanded: true,
                          items: MarketplaceService().getProductCategories().map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category[0].toUpperCase() + category.substring(1),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.getResponsiveSpacing(context, 16)),
                        
                        // Unit
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.scale),
                          ),
                          isExpanded: true,
                          items: _units.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(
                                unit.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedUnit = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a unit';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  } else {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Category
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              isExpanded: true,
                              items: MarketplaceService().getProductCategories().map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category[0].toUpperCase() + category.substring(1),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: AppDimensions.getResponsiveSpacing(context, 12)),
                          
                          // Unit
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: const InputDecoration(
                                labelText: 'Unit *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              isExpanded: true,
                              items: _units.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(
                                    unit.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedUnit = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a unit';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: AppDimensions.getResponsiveSpacing(context, 16)),

              // Price and Quantity Row - Mobile Responsive Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  // On small screens, stack vertically; on larger screens, use row
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        // Price
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price per Unit (Rs.) *',
                            hintText: '0.00',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter price';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.getResponsiveSpacing(context, 16)),
                        
                        // Quantity
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Available Quantity *',
                            hintText: '0',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter quantity';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity <= 0) {
                              return 'Please enter a valid quantity';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  } else {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Price
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Price per Unit (Rs.) *',
                                hintText: '0.00',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: AppDimensions.getResponsiveSpacing(context, 12)),
                          
                          // Quantity
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Available Quantity *',
                                hintText: '0',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.inventory_2),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter quantity';
                                }
                                final quantity = int.tryParse(value);
                                if (quantity == null || quantity <= 0) {
                                  return 'Please enter a valid quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: AppDimensions.getResponsiveSpacing(context, 16)),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'e.g., Colombo, Sri Lanka',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.getResponsiveSpacing(context, 24)),

              // Image Selection - Enhanced Card
              Card(
                elevation: 4,
                shadowColor: AppTheme.primaryGreen.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Padding(
                  padding: AppDimensions.getResponsivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.spacingS),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: const Icon(
                              Icons.photo_library,
                              color: AppTheme.primaryGreen,
                              size: AppDimensions.iconM,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingM),
                          const Expanded(
                            child: Text(
                              'Product Images',
                              style: TextStyle(
                                fontSize: AppDimensions.fontSizeL,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingS,
                              vertical: AppDimensions.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                            ),
                            child: Text(
                              '${_selectedImages.length}/5',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: AppDimensions.fontSizeS,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      const Text(
                        'Add up to 5 images of your product (optional)',
                        style: TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: AppDimensions.fontSizeS,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingL),
                      
                      // Image Grid
                      if (_selectedImages.isNotEmpty) ...[
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: AdaptiveImageWidget(
                                      imagePath: _selectedImages[index].path,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Add Image Button
                      if (_selectedImages.length < 5)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add Images'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppTheme.primaryGreen),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Web-Compatible Image Upload Section
              if (kIsWeb) ...[
                Card(
                  elevation: 4,
                  shadowColor: AppTheme.primaryGreen.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                  child: Padding(
                    padding: AppDimensions.getResponsivePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.spacingS),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: const Icon(
                                Icons.cloud_upload,
                                color: AppTheme.primaryGreen,
                                size: AppDimensions.iconM,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingM),
                            const Expanded(
                              child: Text(
                                'Web-Compatible Image Upload',
                                style: TextStyle(
                                  fontSize: AppDimensions.fontSizeL,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingS),
                        const Text(
                          'Upload images directly to ImageBB (works on web)',
                          style: TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: AppDimensions.fontSizeS,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingL),
                        
                        // Web Image Upload Widget
                        Center(
                          child: WebImageUploadWidget(
                            onImageUploaded: (imageUrl) {
                              setState(() {
                                if (_selectedImageUrls.length < 5) {
                                  _selectedImageUrls.add(imageUrl);
                                }
                              });
                            },
                            onImageDeleted: (imageUrl) {
                              setState(() {
                                _selectedImageUrls.remove(imageUrl);
                              });
                            },
                            width: 300,
                            height: 200,
                            uploadButtonText: 'Upload Product Image',
                            uploadIcon: Icons.agriculture,
                          ),
                        ),
                        
                        // Show selected web images
                        if (_selectedImageUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Selected Images:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedImageUrls.map((imageUrl) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primaryGreen),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error);
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Error Message - Enhanced
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorRed,
                        size: AppDimensions.iconM,
                      ),
                      const SizedBox(width: AppDimensions.spacingM),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: AppDimensions.fontSizeM,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingL),
              ],

              // Submit Button - Enhanced
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitForm,
                  icon: _isLoading 
                      ? const SizedBox(
                          width: AppDimensions.iconS,
                          height: AppDimensions.iconS,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(_isEditing ? Icons.update : Icons.add),
                  label: Text(
                    _isLoading 
                        ? 'Processing...' 
                        : (_isEditing ? 'Update Product' : 'Add Product'),
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.getResponsiveSpacing(context, 16),
                      horizontal: AppDimensions.getResponsiveSpacing(context, 20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    elevation: 4,
                    shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
                    minimumSize: Size(
                      double.infinity,
                      AppDimensions.getResponsiveSpacing(context, 48),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.getResponsiveSpacing(context, 24)),
            ],
          ),
        ),
      ),
    );
  }
}
