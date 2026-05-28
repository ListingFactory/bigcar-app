import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String accountType = 'member';
  bool agree = false;
  bool loading = false;
  String? error;

  Future<void> _register() async {
    if (!agree) { setState(() => error = '약관에 동의해주세요'); return; }
    setState(() { loading = true; error = null; });
    try {
      await apiClient.register(
        nameCtrl.text, emailCtrl.text, passCtrl.text,
        phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
        accountType: accountType,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('30초면 충분해요', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('개인 회원 또는 상사 딜러를 선택하세요', style: TextStyle(color: AppColors.ink400, fontSize: 13)),
              const SizedBox(height: 20),

              // 계정 유형
              Row(children: [
                Expanded(child: _typeCard('member', '👤', '개인 회원', '매물 등록·문의·찜')),
                const SizedBox(width: 10),
                Expanded(child: _typeCard('dealer', '🏢', '상사 딜러', '대량 등록·매입 견적')),
              ]),

              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.ink100),
              const SizedBox(height: 20),

              _field('이름', nameCtrl, hint: '실명'),
              const SizedBox(height: 14),
              _field('이메일', emailCtrl, hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              _field('전화번호 (선택)', phoneCtrl, hint: '010-0000-0000', keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              _field('비밀번호', passCtrl, hint: '8자 이상', obscure: true),

              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                  child: Text(error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ),
              ],

              const SizedBox(height: 16),
              InkWell(
                onTap: () => setState(() => agree = !agree),
                child: Row(children: [
                  Icon(agree ? Icons.check_box : Icons.check_box_outline_blank, color: agree ? AppColors.cyanDark : AppColors.ink400, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('이용약관 및 개인정보처리방침에 동의합니다 (필수)', style: TextStyle(fontSize: 13, color: AppColors.ink800))),
                ]),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _register,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('가입하고 시작하기', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeCard(String type, String emoji, String title, String sub) => GestureDetector(
    onTap: () => setState(() => accountType = type),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accountType == type ? AppColors.cyan.withValues(alpha: 0.08) : Colors.white,
        border: Border.all(color: accountType == type ? AppColors.cyan : AppColors.ink200, width: accountType == type ? 2 : 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.ink400)),
        ],
      ),
    ),
  );

  Widget _field(String label, TextEditingController ctrl, {String? hint, bool obscure = false, TextInputType? keyboardType}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink800)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.ink400)),
      ),
    ],
  );
}
