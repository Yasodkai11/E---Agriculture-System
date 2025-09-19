import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/rice_mill_model.dart';

class RiceMillCardWidget extends StatelessWidget {
  final RiceMillModel riceMill;
  final VoidCallback? onTap;
  final bool showContactInfo;
  final bool showOwnerInfo;

  const RiceMillCardWidget({
    super.key,
    required this.riceMill,
    this.onTap,
    this.showContactInfo = true,
    this.showOwnerInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and location
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.grain,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          riceMill.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          riceMill.displayLocation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (riceMill.hasContactInfo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Contact Available',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Business details
              if (riceMill.businessType != null || riceMill.capacity != null)
                Row(
                  children: [
                    if (riceMill.businessType != null) ...[
                      _buildInfoChip(
                        Icons.business,
                        riceMill.businessType!,
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (riceMill.capacity != null)
                      _buildInfoChip(
                        Icons.speed,
                        riceMill.capacity!,
                        Colors.orange,
                      ),
                  ],
                ),

              const SizedBox(height: 8),

              // Rice varieties
              if (riceMill.riceVarieties.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: riceMill.riceVarieties.take(3).map((variety) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        variety,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),

              // Contact information
              if (showContactInfo && riceMill.hasContactInfo) ...[
                const Divider(height: 1),
                const SizedBox(height: 8),
                _buildContactSection(),
              ],

              // Owner information
              if (showOwnerInfo && riceMill.hasOwnerInfo) ...[
                const SizedBox(height: 8),
                _buildOwnerSection(),
              ],

              // Footer with last updated
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Updated: ${riceMill.lastUpdatedText}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (riceMill.establishedYear != null)
                    Text(
                      'Est. ${riceMill.establishedYear}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
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

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        if (riceMill.phone != null)
          _buildContactItem(
            Icons.phone,
            riceMill.phone!,
            () => _copyToClipboard(riceMill.phone!),
          ),
        if (riceMill.email != null)
          _buildContactItem(
            Icons.email,
            riceMill.email!,
            () => _copyToClipboard(riceMill.email!),
          ),
        if (riceMill.website != null)
          _buildContactItem(
            Icons.web,
            riceMill.website!,
            () => _copyToClipboard(riceMill.website!),
          ),
      ],
    );
  }

  Widget _buildOwnerSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Owner Information',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          if (riceMill.ownerName != null)
            _buildContactItem(
              Icons.person,
              riceMill.ownerName!,
              null,
            ),
          if (riceMill.ownerPhone != null)
            _buildContactItem(
              Icons.phone,
              riceMill.ownerPhone!,
              () => _copyToClipboard(riceMill.ownerPhone!),
            ),
          if (riceMill.ownerEmail != null)
            _buildContactItem(
              Icons.email,
              riceMill.ownerEmail!,
              () => _copyToClipboard(riceMill.ownerEmail!),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: onTap != null ? AppColors.primary : Colors.grey[700],
                  ),
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.copy,
                  size: 14,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    // You could show a snackbar here to indicate text was copied
  }
}

/// Compact rice mill card for list views
class CompactRiceMillCardWidget extends StatelessWidget {
  final RiceMillModel riceMill;
  final VoidCallback? onTap;

  const CompactRiceMillCardWidget({
    super.key,
    required this.riceMill,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grain,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      riceMill.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      riceMill.displayLocation,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (riceMill.hasContactInfo)
                const Icon(
                  Icons.phone,
                  color: Colors.green,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
