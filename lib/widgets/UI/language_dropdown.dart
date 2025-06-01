import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final List<Map<String, String>> languageList;
  final void Function(String) onChanged;
  final Color backgroundColor;
  final Color textColor;

  const LanguageDropdown({
      super.key,
      required this.selectedLanguage,
      required this.languageList,
      required this.onChanged,
      required this.backgroundColor,
      required this.textColor
    });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          value: selectedLanguage,
          isExpanded: true,
          underline: const SizedBox(),
          iconEnabledColor: textColor,
          dropdownColor: backgroundColor,
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
          items: languageList.map((lang) {
            final isSelected = lang['code'] == selectedLanguage;
            return DropdownMenuItem(
              value: lang['code'],
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lang['name']!,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
