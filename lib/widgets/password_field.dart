import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomStyledPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const CustomStyledPasswordField({Key? key, required this.onChanged})
    : super(key: key);

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
    return Container(
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
        border: Border.all(color: Color(0xFFD9D9D9), width: 1),
      ),
      child: TextField(
        onChanged: widget.onChanged,
        obscureText: _obscureText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Contraseña',
          hintStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
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
