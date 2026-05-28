import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';

class MyPagePage extends StatefulWidget {
  const MyPagePage({super.key});
  @override
  State<MyPagePage> createState() => _MyPagePageState();
}

class _MyPagePageState extends State<MyPagePage> {
  Map<String, dynamic>? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await apiClient.me();
    if (mounted) setState(() { user = u; loading = false; });
  }

  Future<void> _logout() async {
    await apiClient.logout();
    if (mounted) setState(() => user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: AppColors.cyanDark));

    if (user == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.ink100, shape: BoxShape.circle), child: const Icon(Icons.person, size: 40, color: AppColors.ink400)),
                const SizedBox(height: 16),
                const Text('로그인이 필요합니다', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('매물 등록, 찜, 문의 관리는 로그인 후 가능해요', style: TextStyle(color: AppColors.ink400, fontSize: 13)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                      if (ok == true) _load();
                    },
                    child: const Text('로그인 / 회원가입'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stats = user?['stats'] as Map<String, dynamic>?;
    final roles = (user?['roles'] as List?) ?? [];
    final isDealer = roles.contains('dealer');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Center(child: Text(user!['name']?[0] ?? '?', style: const TextStyle(color: AppColors.cyanDark, fontSize: 22, fontWeight: FontWeight.w900))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(user!['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: isDealer ? Colors.purple.withValues(alpha: 0.1) : AppColors.cyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: Text(isDealer ? 'PRO 딜러' : '개인', style: TextStyle(color: isDealer ? Colors.purple : AppColors.cyanDark, fontSize: 10, fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          const SizedBox(height: 2),
                          Text(user!['email'] ?? '', style: const TextStyle(color: AppColors.ink400, fontSize: 12)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // 통계
                  Row(children: [
                    _statTile('내 매물', '${stats?['listings'] ?? 0}'),
                    _statTile('전체 조회', '${stats?['views'] ?? 0}'),
                    _statTile('역할', roles.length.toString()),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _section('마이메뉴', [
              _item(Icons.list_alt, '내 매물', () {}),
              _item(Icons.favorite_border, '찜한 매물', () {}),
              _item(Icons.history, '최근 본 매물', () {}),
              _item(Icons.chat_bubble_outline, '받은 문의', () {}),
              _item(Icons.shopping_cart_outlined, '내 매입 요청', () {}),
            ]),
            const SizedBox(height: 8),
            _section('설정', [
              _item(Icons.person_outline, '회원정보 수정', () {}),
              _item(Icons.notifications_none, '알림 설정', () {}),
              _item(Icons.help_outline, '고객센터', () {}),
              _item(Icons.logout, '로그아웃', _logout, danger: true),
            ]),
            const SizedBox(height: 24),
            Center(child: Text('bigcar v1.0', style: TextStyle(color: AppColors.ink400.withValues(alpha: 0.6), fontSize: 11))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.ink50, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.cyanDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.ink400)),
      ]),
    ),
  );

  Widget _section(String title, List<Widget> items) => Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 4), child: Text(title, style: const TextStyle(color: AppColors.ink400, fontSize: 11, fontWeight: FontWeight.w700))),
      ...items,
    ]),
  );

  Widget _item(IconData icon, String label, VoidCallback? onTap, {bool danger = false}) => ListTile(
    leading: Icon(icon, color: danger ? AppColors.red : AppColors.ink600, size: 22),
    title: Text(label, style: TextStyle(fontSize: 14, color: danger ? AppColors.red : AppColors.ink, fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.ink400, size: 20),
    onTap: onTap,
    visualDensity: VisualDensity.compact,
  );
}
