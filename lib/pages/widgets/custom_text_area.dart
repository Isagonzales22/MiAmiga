import 'package:flutter/material.dart';
import 'package:slim_web/components/pallete.dart';

class CustomTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isEnabled;
  final int maxLines;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final IconData? icon;

  const CustomTextArea({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.isEnabled,
    this.maxLines = 5,
    this.keyboardType = TextInputType.multiline,
    this.validator,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEnabled ? Pallete.pink.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          fillColor: Pallete.pink.withOpacity(0.1),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          hintText: hintText,
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          prefixIcon: icon != null ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              icon,
              color: isEnabled ? Colors.blueAccent : Colors.grey,
            ),
          ) : null,
          border: InputBorder.none,
        ),
        enabled: isEnabled,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }
}
