import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String? hint;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.hint,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.divider.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hint ?? 'Select',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
            validator: validator,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            dropdownColor: AppColors.inputFill,
            borderRadius: BorderRadius.circular(16),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.accent,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
