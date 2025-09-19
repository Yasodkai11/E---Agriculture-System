import 'package:e_agriculture_system/core/constants/app_colors.dart';
import 'package:e_agriculture_system/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PestControlScreen extends StatefulWidget {
  const PestControlScreen({super.key});

  @override
  State<PestControlScreen> createState() => _PestControlScreenState();
}

class _PestControlScreenState extends State<PestControlScreen> {
  final List<PestIssue> _pestIssues = [
    PestIssue(
      name: 'Aphids',
      crop: 'Wheat',
      severity: PestSeverity.high,
      description: 'Small green insects sucking plant sap',
      symptoms: 'Yellowing leaves, stunted growth',
      treatment: 'Neem oil spray, ladybugs',
      image: '🦗',
      detectedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PestIssue(
      name: 'Fungal Disease',
      crop: 'Rice',
      severity: PestSeverity.medium,
      description: 'Brown spots on leaves and stems',
      symptoms: 'Brown lesions, wilting',
      treatment: 'Fungicide application, proper drainage',
      image: '🍄',
      detectedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PestIssue(
      name: 'Armyworms',
      crop: 'Corn',
      severity: PestSeverity.critical,
      description: 'Caterpillars feeding on leaves',
      symptoms: 'Holes in leaves, defoliation',
      treatment: 'Bacillus thuringiensis, handpicking',
      image: '🐛',
      detectedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PestIssue(
      name: 'Root Rot',
      crop: 'Soybeans',
      severity: PestSeverity.medium,
      description: 'Fungal infection in roots',
      symptoms: 'Wilting, yellow leaves, poor growth',
      treatment: 'Improve drainage, fungicide drench',
      image: '🌱',
      detectedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PestIssue(
      name: 'Spider Mites',
      crop: 'Cotton',
      severity: PestSeverity.low,
      description: 'Tiny arachnids causing leaf damage',
      symptoms: 'Fine webbing, stippled leaves',
      treatment: 'Insecticidal soap, predatory mites',
      image: '🕷️',
      detectedDate: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.pestControl,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              _showAddIssueDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Overview Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF6B8E6B), const Color(0xFF8FBC8F)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B8E6B).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.bug_report,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Pest Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Severity indicators in a more compact layout
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildSeverityIndicator('Critical', Colors.red, 1),
                    _buildSeverityIndicator('High', Colors.orange, 1),
                    _buildSeverityIndicator('Medium', Colors.yellow, 2),
                    _buildSeverityIndicator('Low', Colors.green, 1),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Total Issues: ${_pestIssues.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Filter Chips
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Critical'),
                _buildFilterChip('High'),
                _buildFilterChip('Medium'),
                _buildFilterChip('Low'),
              ],
            ),
          ),

          // Issues List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pestIssues.length,
              itemBuilder: (context, index) {
                final issue = _pestIssues[index];
                return _buildIssueCard(issue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator(String label, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label $count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFE53E3E), const Color(0xFFC53030)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFE53E3E) : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFE53E3E).withOpacity(0.4)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildIssueCard(PestIssue issue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pest Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getSeverityColor(issue.severity).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    issue.image,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Issue Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crop: ${issue.crop}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(
                          issue.severity,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        issue.severity.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getSeverityColor(issue.severity),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Detection Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Detected',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(issue.detectedDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            issue.description,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showTreatmentDialog(context, issue);
                  },
                  icon: const Icon(Icons.healing, size: 16),
                  label: const Text('Treatment'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showIssueDetails(context, issue);
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(PestSeverity severity) {
    switch (severity) {
      case PestSeverity.critical:
        return Colors.red;
      case PestSeverity.high:
        return Colors.orange;
      case PestSeverity.medium:
        return Colors.yellow[700]!;
      case PestSeverity.low:
        return Colors.green;
    }
  }

  void _showAddIssueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report New Issue'),
        content: const Text('Pest reporting feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTreatmentDialog(BuildContext context, PestIssue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Treatment for ${issue.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Symptoms: ${issue.symptoms}'),
            const SizedBox(height: 12),
            Text('Treatment: ${issue.treatment}'),
            const SizedBox(height: 16),
            const Text('Treatment tracking feature coming soon!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showIssueDetails(BuildContext context, PestIssue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(issue.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop: ${issue.crop}'),
            const SizedBox(height: 8),
            Text('Severity: ${issue.severity.name}'),
            const SizedBox(height: 8),
            Text('Description: ${issue.description}'),
            const SizedBox(height: 8),
            Text('Symptoms: ${issue.symptoms}'),
            const SizedBox(height: 8),
            Text('Treatment: ${issue.treatment}'),
            const SizedBox(height: 8),
            Text('Detected: ${_formatDate(issue.detectedDate)}'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class PestIssue {
  final String name;
  final String crop;
  final PestSeverity severity;
  final String description;
  final String symptoms;
  final String treatment;
  final String image;
  final DateTime detectedDate;

  PestIssue({
    required this.name,
    required this.crop,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.image,
    required this.detectedDate,
  });
}

enum PestSeverity { critical, high, medium, low }

enum PestSeverityLevel { critical, high, medium, low }
