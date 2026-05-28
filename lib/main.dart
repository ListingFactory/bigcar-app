import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api/api_client.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/listings_page.dart';
import 'pages/mypage_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await apiClient.loadToken();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const BigcarApp());
}

class BigcarApp extends StatelessWidget {
  const BigcarApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bigcar',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int currentIndex = 0;

  final pages = const [
    HomePage(),
    ListingsPage(),
    _FavoritesTab(),
    MyPagePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search), activeIcon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: '찜'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('찜한 매물')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppColors.ink400),
            SizedBox(height: 12),
            Text('찜한 매물', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            SizedBox(height: 4),
            Text('매물 카드의 하트를 눌러 찜해보세요', style: TextStyle(color: AppColors.ink400, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
