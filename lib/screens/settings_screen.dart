import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<bool> isDarkMode;
  const SettingsScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.settings ?? '設定',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            title: Text(
              loc.darkMode ?? '夜間模式',
              style: GoogleFonts.nunito(fontSize: 17),
            ),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, value, _) {
                return Switch(
                  value: value,
                  onChanged: (v) => isDarkMode.value = v,
                );
              },
            ),
          ),
          const Divider(),          
        ],
      ),
    );
  }
}
