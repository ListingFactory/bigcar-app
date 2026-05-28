import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_theme.dart';

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
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const Spacer(),
              ]),
              const SizedBox(height: 20),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.cyan, AppColors.cyanDarker]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text('B', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(height: 24),
              const Text('다시 오신 걸 환영해요', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('계정에 로그인하시면 매물 등록, 찜, 문의 관리가 가능합니다.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              const SizedBox(height: 32),

              const Text('이메일', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
                ),
              ),
              const SizedBox(height: 16),
              const Text('비밀번호', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: passCtrl,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(error!, style: const TextStyle(color: AppColors.red, fontSize: 12)),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _login,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('로그인', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  Icon(Icons.info_outline, color: AppColors.cyan, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(child: Text('데모 계정이 미리 입력되어 있어요', style: TextStyle(color: Colors.white70, fontSize: 11))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
