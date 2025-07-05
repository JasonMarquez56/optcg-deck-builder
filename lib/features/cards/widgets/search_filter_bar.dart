import 'package:flutter/material.dart';
import 'show_filter_dialog.dart';

class SearchFilterBar extends StatelessWidget {
  final BuildContext context;
  final TextEditingController searchController;
  final Set<String> selectedColors;
  final Set<String> selectedClasses;
  final List<String> availableColors;
  final List<String> availableClasses;
  final Function(Set<String>, Set<String>) onApply;

  const SearchFilterBar({
    super.key,
    required this.context,
    required this.searchController,
    required this.selectedColors,
    required this.selectedClasses,
    required this.availableColors,
    required this.availableClasses,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipOval(
            child: Material(
              color: const Color.fromARGB(255, 26, 26, 26),
              child: InkWell(
                splashColor: Colors.white24,
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search cards...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color.fromARGB(255, 0, 0, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ClipOval(
            child: Material(
              color: const Color.fromARGB(255, 26, 26, 26),
              child: InkWell(
                splashColor: Colors.white24,
                onTap: () => showFilterDialog(
                  context: context,
                  selectedColors: selectedColors,
                  selectedClasses: selectedClasses,
                  availableColors: availableColors,
                  availableClasses: availableClasses,
                  onApply: onApply,
                ),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Icons.filter_list, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

