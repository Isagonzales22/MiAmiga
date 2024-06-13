import 'package:flutter/material.dart';
import 'package:slim_web/components/pallete.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.label,
    super.key,
    this.controller,
    this.obscureText = false,
    this.icon,
    this.onChanged,
    this.enabled = true,
    this.type = TextInputType.text,
    this.validator,
    this.onSaved,
    this.colored = false,
  });
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? icon;
  final void Function(String?)? onChanged;
  final bool enabled;
  final TextInputType type;
  final String? Function(String?)? validator;
  final bool colored;
  final void Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        keyboardType: type,
        decoration: InputDecoration(
          filled: true,
          fillColor: Pallete.pink.withOpacity(0.1),
          labelText: label,
          labelStyle: const TextStyle(
            
            fontSize: 15,
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Pallete.pink,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).cardColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
            ),
          ),
        ),
        enabled: enabled,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}