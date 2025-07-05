import 'package:flutter/material.dart';

void showFilterDialog({
  required BuildContext context,
  required Set<String> selectedColors,
  required Set<String> selectedClasses,
  required List<String> availableColors,
  required List<String> availableClasses,
  required void Function(Set<String>, Set<String>) onApply,
}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 26, 26, 26),
      builder: (context) {
        Set<String> tempSelectedColors = {...selectedColors};
        Set<String> tempSelectedClasses = {...selectedClasses};

        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ExpansionTile(
                              title: const Text('Color', style: TextStyle(color: Colors.white)),
                              initiallyExpanded: true,
                              children: availableColors.map((color) {
                                return CheckboxListTile(
                                  title: Text(color, style: TextStyle(color: (tempSelectedColors.length < 2 || tempSelectedColors.contains(color)) ? Colors.white : Colors.grey)),
                                  value: tempSelectedColors.contains(color),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true && tempSelectedColors.length < 2) {
                                        tempSelectedColors.add(color);
                                      } else {
                                        tempSelectedColors.remove(color);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                );
                              }).toList(),
                            ),
                            ExpansionTile(
                              title: const Text('Card Class', style: TextStyle(color: Colors.white)),
                              initiallyExpanded: true,
                              children: availableClasses.map((cardClass) {
                                return CheckboxListTile(
                                  title: Text(cardClass, style: TextStyle(color: tempSelectedClasses.isEmpty || tempSelectedClasses.contains(cardClass) ? Colors.white : Colors.grey)),
                                  value: tempSelectedClasses.contains(cardClass),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        tempSelectedClasses.add(cardClass);
                                      } else {
                                        tempSelectedClasses.remove(cardClass);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onApply(tempSelectedColors, tempSelectedClasses);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 26, 26, 26),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // 🟢 Rounded corners
                          side: const BorderSide(color: Colors.white, width: 2), // ⚪ Border color & width
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Optional: padding
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }