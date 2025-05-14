// lib/widgets/role_selector.dart
import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class RoleSelector extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String> onRoleSelected;

  const RoleSelector({
    Key? key,
    required this.selectedRole,
    required this.onRoleSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoleButton(
          label: 'Estudiante',
          isSelected: selectedRole == 'Estudiante',
          onTap: () => onRoleSelected('Estudiante'),
        ),
        const SizedBox(width: 16),
        _RoleButton(
          label: 'Profesor',
          isSelected: selectedRole == 'Profesor',
          onTap: () => onRoleSelected('Profesor'),
        ),
      ],
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightViolet : AppColors.darkBlue,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
