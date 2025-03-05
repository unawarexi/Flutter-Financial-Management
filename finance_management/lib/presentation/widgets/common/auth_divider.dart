import 'package:flutter/material.dart';
import 'package:sign_button/sign_button.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Or divider
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Color(0xFF78839C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 32),

        // Social login buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton.mini(buttonType: ButtonType.google, onPressed: () {}),
            const SizedBox(width: 24),
            SignInButton.mini(
              buttonType: ButtonType.facebook,
              onPressed: () {},
            ),
            const SizedBox(width: 24),
            SignInButton.mini(
              buttonType: ButtonType.microsoft,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
