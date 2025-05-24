import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType; // nuevo parámetro opcional
  final bool isCompact;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double fontSize = isCompact ? 16 : 20;
    final double verticalPadding = isCompact ? 8 : 13;
    final double containerHeight = isCompact ? 40 : 60;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
      ),
      child: TextField(
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: verticalPadding,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
