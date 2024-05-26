import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final Map<String, dynamic>? items;
  final String? value;
  final String hint;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const SearchableDropdown({
    Key? key,
    required this.items,
    this.value,
    required this.hint,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  late TextEditingController _searchController;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedValue = widget.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.hint),
        SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            suffixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              // Update the displayed items based on the search query
            });
          },
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
              widget.onChanged(newValue);
            });
          },
          items: widget.items?.keys.map((String key) {
            return DropdownMenuItem<String>(
              value: key,
              child: Text(widget.items![key]),
            );
          }).toList(),
          validator: widget.validator,
        ),
      ],
    );
  }
}