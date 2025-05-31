import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final List<Map<String, String>> languageList;
  final void Function(String) onChanged;
  final Color backgroundColor;

  const LanguageDropdown({
      super.key,
      required this.selectedLanguage,
      required this.languageList,
      required this.onChanged,
      this.backgroundColor = Colors.white
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
          iconEnabledColor: Colors.black,
          dropdownColor: Colors.white,
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
          items: languageList.map((lang) {
            return DropdownMenuItem(
              value: lang['code'],
              child: Text(
                lang['name']!,
                style: const TextStyle(color: Colors.black), // dropdown menu text
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
