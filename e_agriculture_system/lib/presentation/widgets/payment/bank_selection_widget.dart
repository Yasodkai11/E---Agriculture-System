import 'package:e_agriculture_system/data/models/sri_lankan_bank_model.dart';
import 'package:flutter/material.dart';

class BankSelectionWidget extends StatefulWidget {
  final SriLankanBank? selectedBank;
  final Function(SriLankanBank?) onBankSelected;
  final String? title;
  final bool showSearch;
  final bool showBankTypes;

  const BankSelectionWidget({
    super.key,
    this.selectedBank,
    required this.onBankSelected,
    this.title,
    this.showSearch = true,
    this.showBankTypes = true,
  });

  @override
  State<BankSelectionWidget> createState() => _BankSelectionWidgetState();
}

class _BankSelectionWidgetState extends State<BankSelectionWidget> {
  List<SriLankanBank> _filteredBanks = [];
  List<SriLankanBank> _allBanks = [];
  BankType? _selectedBankType;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allBanks = SriLankanBanksData.getActiveBanks();
    _filteredBanks = _allBanks;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBanks() {
    setState(() {
      _filteredBanks = _allBanks.where((bank) {
        final matchesSearch = _searchQuery.isEmpty ||
            bank.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bank.shortName.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesType = _selectedBankType == null || bank.type == _selectedBankType;
        
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Search bar
        if (widget.showSearch) ...[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search banks...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterBanks();
            },
          ),
          const SizedBox(height: 16),
        ],
        
        // Bank type filter
        if (widget.showBankTypes) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBankTypeChip('All', null),
                const SizedBox(width: 8),
                ...BankType.values.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildBankTypeChip(_getBankTypeDisplayName(type), type),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Selected bank display
        if (widget.selectedBank != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.selectedBank!.bankColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.selectedBank!.bankColor,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.selectedBank!.bankIcon,
                  color: widget.selectedBank!.bankColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedBank!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.selectedBank!.bankColor,
                        ),
                      ),
                      Text(
                        widget.selectedBank!.shortName,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.selectedBank!.bankColor.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _getBankTypeDisplayName(widget.selectedBank!.type),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.selectedBank!.bankColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onBankSelected(null),
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Bank list
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _filteredBanks.isEmpty
              ? const Center(
                  child: Text('No banks found'),
                )
              : ListView.builder(
                  itemCount: _filteredBanks.length,
                  itemBuilder: (context, index) {
                    final bank = _filteredBanks[index];
                    final isSelected = widget.selectedBank?.id == bank.id;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: bank.bankColor.withOpacity(0.1),
                        child: Icon(
                          bank.bankIcon,
                          color: bank.bankColor,
                        ),
                      ),
                      title: Text(
                        bank.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? bank.bankColor : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bank.shortName),
                          Text(
                            _getBankTypeDisplayName(bank.type),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: bank.bankColor,
                            )
                          : null,
                      onTap: () => widget.onBankSelected(bank),
                      tileColor: isSelected
                          ? bank.bankColor.withOpacity(0.1)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBankTypeChip(String label, BankType? type) {
    final isSelected = _selectedBankType == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedBankType = selected ? type : null;
        });
        _filterBanks();
      },
      selectedColor: Colors.green.withOpacity(0.2),
      checkmarkColor: Colors.green,
    );
  }

  String _getBankTypeDisplayName(BankType type) {
    switch (type) {
      case BankType.commercial:
        return 'Commercial';
      case BankType.development:
        return 'Development';
      case BankType.specialized:
        return 'Specialized';
      case BankType.foreign:
        return 'Foreign';
      case BankType.cooperative:
        return 'Cooperative';
      case BankType.savings:
        return 'Savings';
    }
  }
}

class BankAccountFormWidget extends StatefulWidget {
  final SriLankanBank? selectedBank;
  final Function(BankAccount?) onAccountSelected;
  final String? title;

  const BankAccountFormWidget({
    super.key,
    this.selectedBank,
    required this.onAccountSelected,
    this.title,
  });

  @override
  State<BankAccountFormWidget> createState() => _BankAccountFormWidgetState();
}

class _BankAccountFormWidgetState extends State<BankAccountFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  String _accountType = 'savings';

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _branchCodeController.dispose();
    _branchNameController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedBank == null) {
      return const Center(
        child: Text('Please select a bank first'),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Bank info display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.selectedBank!.bankColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.selectedBank!.bankColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.selectedBank!.bankIcon,
                  color: widget.selectedBank!.bankColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedBank!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.selectedBank!.bankColor,
                        ),
                      ),
                      Text(
                        widget.selectedBank!.shortName,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.selectedBank!.bankColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Account type dropdown
          DropdownButtonFormField<String>(
            value: _accountType,
            decoration: const InputDecoration(
              labelText: 'Account Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'savings', child: Text('Savings')),
              DropdownMenuItem(value: 'current', child: Text('Current')),
              DropdownMenuItem(value: 'fixed', child: Text('Fixed Deposit')),
            ],
            onChanged: (value) {
              setState(() {
                _accountType = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Account number
          TextFormField(
            controller: _accountNumberController,
            decoration: const InputDecoration(
              labelText: 'Account Number',
              border: OutlineInputBorder(),
              hintText: 'Enter your account number',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account number';
              }
              if (value.length < 8) {
                return 'Account number must be at least 8 digits';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Account holder name
          TextFormField(
            controller: _accountHolderNameController,
            decoration: const InputDecoration(
              labelText: 'Account Holder Name',
              border: OutlineInputBorder(),
              hintText: 'Enter account holder name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account holder name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Branch code
          TextFormField(
            controller: _branchCodeController,
            decoration: const InputDecoration(
              labelText: 'Branch Code',
              border: OutlineInputBorder(),
              hintText: 'Enter branch code',
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter branch code';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Branch name
          TextFormField(
            controller: _branchNameController,
            decoration: const InputDecoration(
              labelText: 'Branch Name',
              border: OutlineInputBorder(),
              hintText: 'Enter branch name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter branch name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // IFSC Code
          TextFormField(
            controller: _ifscCodeController,
            decoration: const InputDecoration(
              labelText: 'IFSC Code',
              border: OutlineInputBorder(),
              hintText: 'Enter IFSC code',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter IFSC code';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.selectedBank!.bankColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Add Bank Account',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final bankAccount = BankAccount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '', // This should be set by the parent
        bankId: widget.selectedBank!.id,
        accountNumber: _accountNumberController.text,
        accountHolderName: _accountHolderNameController.text,
        accountType: _accountType,
        branchCode: _branchCodeController.text,
        branchName: _branchNameController.text,
        ifscCode: _ifscCodeController.text,
        createdAt: DateTime.now(),
      );
      
      widget.onAccountSelected(bankAccount);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bank account added successfully for ${widget.selectedBank!.name}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
