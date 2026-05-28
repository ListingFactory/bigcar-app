import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController(text: 'hongcs1018@gmail.com');
  final passCtrl = TextEditingController(text: 'cbr6008285!@#');
  bool loading = false;
  String? error;

  Future<void> _login() async {
    setState(() { loading = true; error = null; });
    try {
      await apiClient.login(emailCtrl.text, passCtrl.text);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.ink100),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.cyanDarker]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.cyan.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Center(child: Text('B', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(height: 24),
              const Text('다시 오신 걸 환영해요', style: TextStyle(color: AppColors.ink, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('계정에 로그인하시면 매물 등록, 찜, 문의 관리가 가능합니다.', style: TextStyle(color: AppColors.ink600, fontSize: 13)),
              const SizedBox(height: 32),

              const Text('이메일', style: TextStyle(color: AppColors.ink800, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'you@example.com', hintStyle: TextStyle(color: AppColors.ink400)),
              ),
              const SizedBox(height: 16),
              const Text('비밀번호', style: TextStyle(color: AppColors.ink800, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 입력', hintStyle: TextStyle(color: AppColors.ink400)),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.red.withValues(alpha: 0.2))),
                  child: Text(error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyanDark, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('로그인', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () async {
                    final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                    if (ok == true && mounted) Navigator.pop(context, true);
                  },
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '아직 회원이 아니신가요? ', style: TextStyle(color: AppColors.ink600, fontSize: 13)),
                        TextSpan(text: '회원가입', style: TextStyle(color: AppColors.cyanDark, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.ink50, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.ink100)),
                child: Row(children: [
                  Icon(Icons.info_outline, color: AppColors.cyanDark, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('데모 계정이 미리 입력되어 있어요', style: TextStyle(color: AppColors.ink600, fontSize: 11))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
