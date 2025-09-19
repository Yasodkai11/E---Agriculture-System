import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../data/services/financial_service.dart';
import '../../../data/models/financial_record_model.dart';

class EnhancedFinancialRecordsScreen extends StatefulWidget {
  const EnhancedFinancialRecordsScreen({super.key});

  @override
  State<EnhancedFinancialRecordsScreen> createState() => _EnhancedFinancialRecordsScreenState();
}

class _EnhancedFinancialRecordsScreenState extends State<EnhancedFinancialRecordsScreen> {
  final FinancialService _financialService = FinancialService();
  
  List<FinancialRecordModel> _records = [];
  String _selectedFilter = 'All';
  String _selectedPeriod = 'This Month';
  bool _isLoading = true;
  String? _errorMessage;

  // Financial summary data
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _netProfit = 0.0;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get date range based on selected period
      final dateRange = _getDateRangeForPeriod(_selectedPeriod);
      
      // Load financial records
      final records = await _financialService.getAllFinancialRecords(
        startDate: dateRange['startDate'],
        endDate: dateRange['endDate'],
      );

      // Apply filter
      List<FinancialRecordModel> filteredRecords = records;
      if (_selectedFilter != 'All') {
        if (_selectedFilter == 'Income') {
          filteredRecords = records.where((r) => r.type == 'income').toList();
        } else if (_selectedFilter == 'Expense') {
          filteredRecords = records.where((r) => r.type == 'expense').toList();
        } else if (_selectedFilter == 'Inputs') {
          filteredRecords = records.where((r) => r.category == 'fertilizer' || r.category == 'pesticides' || r.category == 'seeds').toList();
        } else if (_selectedFilter == 'Sales') {
          filteredRecords = records.where((r) => r.category == 'crop_sales').toList();
        }
      }

      // Calculate financial summary
      final incomeRecords = records.where((r) => r.type == 'income');
      final expenseRecords = records.where((r) => r.type == 'expense');

      final totalIncome = incomeRecords.fold(0.0, (sum, record) => sum + record.amount);
      final totalExpense = expenseRecords.fold(0.0, (sum, record) => sum + record.amount);
      final netProfit = totalIncome - totalExpense;

      setState(() {
        _records = filteredRecords;
        _totalIncome = totalIncome;
        _totalExpense = totalExpense;
        _netProfit = netProfit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load financial data: $e';
        _isLoading = false;
      });
    }
  }

  Map<String, DateTime?> _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    switch (period) {
      case 'This Month':
        return {
          'startDate': DateTime(currentYear, currentMonth, 1),
          'endDate': DateTime(currentYear, currentMonth + 1, 0),
        };
      case 'Last Month':
        return {
          'startDate': DateTime(currentYear, currentMonth - 1, 1),
          'endDate': DateTime(currentYear, currentMonth, 0),
        };
      case 'This Year':
        return {
          'startDate': DateTime(currentYear, 1, 1),
          'endDate': DateTime(currentYear, 12, 31),
        };
      case 'All Time':
        return {
          'startDate': null,
          'endDate': null,
        };
      default:
        return {
          'startDate': DateTime(currentYear, currentMonth, 1),
          'endDate': DateTime(currentYear, currentMonth + 1, 0),
        };
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadFinancialData();
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadFinancialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.veryLightGreen,
      appBar: AppBar(
        title: const Text(
          'Financial Records',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontSizeXXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadFinancialData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddRecordDialog(),
            tooltip: 'Add Record',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildFinancialOverviewCard(_totalIncome, _totalExpense, _netProfit),
                    _buildFilters(),
                    Expanded(
                      child: _records.isEmpty 
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: ResponsiveHelper.getResponsivePadding(context),
                              itemCount: _records.length,
                              itemBuilder: (context, index) => _buildRecordCard(_records[index]),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFinancialOverviewCard(double income, double expense, double profit) {
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(context),
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getCompactFontSize(context, 0.03), // Reduced from 18
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getCompactSpacing(context, 0.012)), // Reduced spacing
                    Row(
                      children: [
                        _buildFinancialIndicator('Income', Colors.green, income),
                        const SizedBox(width: 16),
                        _buildFinancialIndicator('Expense', Colors.red, expense),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.white, size: ResponsiveHelper.getResponsiveIconSize(context)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Profit:', style: TextStyle(color: Colors.white)),
                Text(
                  '₹${profit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: profit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialIndicator(String label, Color color, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: ResponsiveHelper.getCompactFontSize(context, 0.02))), // Reduced from 12
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontSize: ResponsiveHelper.getCompactFontSize(context, 0.025), fontWeight: FontWeight.bold), // Reduced from 16
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 0.03), // Reduced from 0.04
      ),
      child: Column(
        children: [
          SizedBox(
            height: ResponsiveHelper.getResponsiveButtonHeight(context),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('This Month', _selectedPeriod == 'This Month', _onPeriodChanged),
                _buildFilterChip('Last Month', _selectedPeriod == 'Last Month', _onPeriodChanged),
                _buildFilterChip('This Year', _selectedPeriod == 'This Year', _onPeriodChanged),
                _buildFilterChip('All Time', _selectedPeriod == 'All Time', _onPeriodChanged),
              ],
            ),
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveButtonHeight(context),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', _selectedFilter == 'All', _onFilterChanged),
                _buildFilterChip('Income', _selectedFilter == 'Income', _onFilterChanged),
                _buildFilterChip('Expense', _selectedFilter == 'Expense', _onFilterChanged),
                _buildFilterChip('Inputs', _selectedFilter == 'Inputs', _onFilterChanged),
                _buildFilterChip('Sales', _selectedFilter == 'Sales', _onFilterChanged),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        margin: EdgeInsets.only(right: ResponsiveHelper.getCompactSpacing(context, 0.008)), // Reduced spacing
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveWidth(context, 0.03), // Reduced from 0.04
          vertical: ResponsiveHelper.getResponsiveHeight(context, 0.008), // Reduced from 0.01
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: ResponsiveHelper.getCompactFontSize(context, 0.025), // Reduced from 0.03
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(FinancialRecordModel record) {
    final isIncome = record.type == 'income';
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.isSmallScreen(context) ? 8.0 : 12.0),
      child: Card(
        child: Container(
          constraints: BoxConstraints(
            minHeight: 80,
            maxHeight: ResponsiveHelper.isSmallScreen(context) ? 100.0 : 120.0, // Reduced max height for mobile
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(ResponsiveHelper.isSmallScreen(context) ? 8.0 : 12.0),
            leading: Container(
              width: ResponsiveHelper.isSmallScreen(context) ? 40.0 : 48.0,
              height: ResponsiveHelper.isSmallScreen(context) ? 40.0 : 48.0,
              decoration: BoxDecoration(
                color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _getTypeIcon(record.type), 
                  style: TextStyle(fontSize: ResponsiveHelper.isSmallScreen(context) ? 20.0 : 24.0)
                ),
              ),
            ),
            title: Text(
              record.title, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getCompactFontSize(context, 0.025), // Reduced from 14-16
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  record.description,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getCompactFontSize(context, 0.02), // Reduced from 11-12
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 4.0 : 6.0),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isSmallScreen(context) ? 6.0 : 8.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getCompactFontSize(context, 0.018), // Reduced from 9-10
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.isSmallScreen(context) ? 4.0 : 6.0),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isSmallScreen(context) ? 6.0 : 8.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.category,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getCompactFontSize(context, 0.018), // Reduced from 9-10
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.isSmallScreen(context) ? 80.0 : 100.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}₹${record.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getCompactFontSize(context, 0.022), // Reduced from 12-14
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDate(record.date),
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getCompactFontSize(context, 0.018), // Reduced from 9-10
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
            onTap: () => _showRecordDetails(record),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: ResponsiveHelper.getResponsiveIconSize(context) * 2.0, color: AppColors.textHint), // Reduced from 2.5
          SizedBox(height: ResponsiveHelper.getCompactSpacing(context, 0.015)), // Reduced spacing
          Text(
            'No financial records found',
            style: TextStyle(fontSize: ResponsiveHelper.getCompactFontSize(context, 0.035), fontWeight: FontWeight.w600, color: AppColors.textSecondary), // Reduced from 0.045
          ),
          SizedBox(height: ResponsiveHelper.getCompactSpacing(context, 0.008)), // Reduced spacing
          Text('Add your first financial record to get started', style: TextStyle(color: AppColors.textHint)),
          SizedBox(height: ResponsiveHelper.getCompactSpacing(context, 0.02)), // Reduced spacing
          ElevatedButton.icon(
            onPressed: _showAddRecordDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Record'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: ResponsiveHelper.getResponsiveIconSize(context) * 2.0, color: AppColors.error),
          SizedBox(height: ResponsiveHelper.getCompactSpacing(context, 0.015)), // Reduced spacing
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: ResponsiveHelper.getCompactFontSize(context, 0.035), color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.getCompactSpacing(context, 0.02)), // Reduced spacing
          ElevatedButton.icon(
            onPressed: _loadFinancialData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'expense';
    String selectedCategory = 'fertilizer';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Financial Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: ['income', 'expense', 'investment'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                    // Set appropriate default category based on type
                    if (value == 'income') {
                      selectedCategory = 'crop_sales';
                    } else if (value == 'expense') {
                      selectedCategory = 'fertilizer';
                    } else {
                      selectedCategory = 'equipment';
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _getCategoriesForType(selectedType).map((category) {
                  return DropdownMenuItem(value: category, child: Text(_formatCategoryName(category)));
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  try {
                    await _financialService.createFinancialRecord(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      amount: double.parse(amountController.text),
                      type: selectedType,
                      category: selectedCategory,
                      date: DateTime.now(),
                    );
                    
                    // Refresh the data
                    _loadFinancialData();
                    Navigator.pop(context);
                    
                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Financial record added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to add record: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordDetails(FinancialRecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(_getTypeIcon(record.type), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(record.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${record.amount.toStringAsFixed(2)}'),
            Text('Type: ${record.type.toUpperCase()}'),
            Text('Category: ${_formatCategoryName(record.category)}'),
            Text('Date: ${_formatDate(record.date)}'),
            if (record.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Description: ${record.description}'),
            ],
            if (record.paymentMethod != null) ...[
              const SizedBox(height: 8),
              Text('Payment Method: ${_formatPaymentMethod(record.paymentMethod!)}'),
            ],
            if (record.referenceNumber != null) ...[
              const SizedBox(height: 8),
              Text('Reference: ${record.referenceNumber}'),
            ],
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${record.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditRecordDialog(record);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(record);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return '💰';
      case 'expense':
        return '💸';
      case 'investment':
        return '📈';
      default:
        return '💳';
    }
  }

  String _formatPaymentMethod(String method) {
    return method.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  void _showEditRecordDialog(FinancialRecordModel record) {
    final titleController = TextEditingController(text: record.title);
    final amountController = TextEditingController(text: record.amount.toString());
    final descriptionController = TextEditingController(text: record.description);
    final notesController = TextEditingController(text: record.notes ?? '');
    String selectedType = record.type;
    String selectedCategory = record.category;
    String? selectedPaymentMethod = record.paymentMethod;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Financial Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: ['income', 'expense', 'investment'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.toUpperCase()));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                    if (value == 'income') {
                      selectedCategory = 'crop_sales';
                    } else if (value == 'expense') {
                      selectedCategory = 'fertilizer';
                    } else {
                      selectedCategory = 'equipment';
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _getCategoriesForType(selectedType).map((category) {
                  return DropdownMenuItem(value: category, child: Text(_formatCategoryName(category)));
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: selectedPaymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method (Optional)', border: OutlineInputBorder()),
                items: [null, ..._financialService.getPaymentMethods()].map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method != null ? _formatPaymentMethod(method) : 'None'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedPaymentMethod = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  try {
                    await _financialService.updateFinancialRecord(
                      recordId: record.id,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      amount: double.parse(amountController.text),
                      type: selectedType,
                      category: selectedCategory,
                      paymentMethod: selectedPaymentMethod,
                      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    );
                    
                    // Refresh the data
                    _loadFinancialData();
                    Navigator.pop(context);
                    
                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Financial record updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update record: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(FinancialRecordModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete "${record.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _financialService.deleteFinancialRecord(record.id);
                Navigator.pop(context);
                _loadFinancialData();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Record deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete record: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<String> _getCategoriesForType(String type) {
    switch (type) {
      case 'income':
        return ['crop_sales', 'equipment_sales', 'other_income'];
      case 'expense':
        return ['fertilizer', 'pesticides', 'seeds', 'equipment', 'labor', 'fuel', 'maintenance', 'transportation', 'insurance', 'taxes', 'other'];
      case 'investment':
        return ['equipment', 'land', 'buildings', 'technology', 'other'];
      default:
        return ['other'];
    }
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
