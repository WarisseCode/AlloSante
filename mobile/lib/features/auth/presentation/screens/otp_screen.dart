import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Focus sur le premier champ
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNodes[0].requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length != 6) return;
    try {
      await ref.read(authProvider.notifier).verifyOtp(
            phoneNumber: widget.phoneNumber,
            code: _code,
          );
      if (mounted) context.go('/home');
    } catch (_) {}
  }

  Future<void> _resend() async {
    await ref.read(authProvider.notifier).resendOtp(widget.phoneNumber);
    _startTimer();
    for (final c in _ctrls) { c.clear(); }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vérification'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sms_outlined,
                      size: 40, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text('Code de vérification', style: tt.headlineMedium),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Nous avons envoyé un code à 6 chiffres au ',
                    style: tt.bodyMedium,
                  ),
                  TextSpan(
                    text: widget.phoneNumber,
                    style: tt.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
              const SizedBox(height: 40),

              if (auth.error != null) ...[
                _ErrorBanner(auth.error!),
                const SizedBox(height: 16),
              ],

              // Champs OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _OtpCell(
                  controller: _ctrls[i],
                  focusNode: _focusNodes[i],
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _focusNodes[i + 1].requestFocus();
                    }
                    if (_code.length == 6) _verify();
                  },
                  onBackspace: () {
                    if (_ctrls[i].text.isEmpty && i > 0) {
                      _focusNodes[i - 1].requestFocus();
                    }
                  },
                )),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading || _code.length != 6 ? null : _verify,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Vérifier'),
                ),
              ),
              const SizedBox(height: 24),

              // Renvoi du code
              Center(
                child: _secondsLeft > 0
                    ? Text(
                        'Renvoyer le code dans ${_secondsLeft}s',
                        style: tt.bodyMedium,
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text(
                          'Renvoyer le code',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent &&
              e.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.backgroundLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: AppColors.error, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
