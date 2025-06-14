import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String version = '';

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定 / About')),
      body: ListView(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Image.asset(
              'assets/logo_en.png',
              height: 80,
            ),
          ),
          const SizedBox(height: 20),
          const ListTile(
            title: Text('EasyRecipe 簡易食譜'),
            subtitle: Text('你的雲端食譜管理工具'),
          ),
          ListTile(
            title: const Text('版本'),
            subtitle: Text(version.isEmpty ? '-' : version),
          ),
          const Divider(),
          const ListTile(
            title: Text('開發者'),
            subtitle: Text('Cheng Siu Ngong\n\npowered by Flutter, Hive, Firebase, Google Sign-In, Google Fonts.'),
          ),
          const Divider(),
          const ListTile(
            title: Text('隱私權/安全說明'),
            subtitle: Text('所有食譜僅儲存於本機或個人雲端帳戶，資料加密儲存於 Hive，並且可隨時刪除。Google 登入僅用於身份驗證。'),
          ),
        ],
      ),
    );
  }
}
