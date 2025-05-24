import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomStyledPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final bool isCompact; 

  const CustomStyledPasswordField({
    Key? key,
    required this.onChanged,
    this.isCompact = false, 
  }) : super(key: key);

  @override
  State<CustomStyledPasswordField> createState() =>
      _CustomStyledPasswordFieldState();
}

class _CustomStyledPasswordFieldState extends State<CustomStyledPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double fontSize = widget.isCompact ? 16 : 20;
    final double verticalPadding = widget.isCompact ? 8 : 13;
    final double containerHeight = widget.isCompact ? 40 : 60;

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
        onChanged: widget.onChanged,
        obscureText: _obscureText,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Contraseña',
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
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
      ),
    );
  }
}
