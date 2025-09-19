import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class LanguageToggle extends StatelessWidget {
  final bool showLabel;
  
  const LanguageToggle({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            'Language: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageButton(
                context,
                languageProvider,
                'en',
                'EN',
                languageProvider.isEnglish,
              ),
              _buildLanguageButton(
                context,
                languageProvider,
                'si',
                'සිං',
                languageProvider.isSinhala,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    LanguageProvider languageProvider,
    String languageCode,
    String displayText,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        if (languageCode == 'en') {
          languageProvider.setEnglish();
        } else if (languageCode == 'si') {
          languageProvider.setSinhala();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
