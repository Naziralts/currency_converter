import 'package:flutter/material.dart';
import 'converter_page.dart';

class ConverterPageWithThemeToggle extends StatelessWidget {
  final VoidCallback toggleTheme;
  const ConverterPageWithThemeToggle({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SafeArea(
        child: Stack(
          children: [
            const ConverterPage(),

        
            Positioned(
              top: 12,
              right: 12,
              child: FloatingActionButton.small(
                onPressed: toggleTheme,
                backgroundColor: Theme.of(context).colorScheme.primary,
                tooltip: 'Switch Theme',
                child: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_round,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
