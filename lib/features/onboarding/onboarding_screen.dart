import 'package:speakr_app/l10n/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/credentials_store.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/hero_wave.dart';
import '../../widgets/mono_eyebrow.dart';
import '../../widgets/speakr_icons.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _urlCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _connecting = false;
  String? _error;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final url = _urlCtrl.text.trim();
    final token = _tokenCtrl.text.trim();
    if (url.isEmpty || token.isEmpty) {
      setState(() => _error = tr("Server URL and API token are required."));
      return;
    }
    final normalizedUrl = url.endsWith('/')
        ? url.substring(0, url.length - 1)
        : url;
    setState(() {
      _connecting = true;
      _error = null;
    });

    final probeDio =
        Dio(
            BaseOptions(
              baseUrl: '$normalizedUrl/api/v1',
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
            ),
          )
          ..options.headers['X-API-Token'] = token
          ..options.headers['Authorization'] = 'Bearer $token'
          ..options.headers['Accept'] = 'application/json';
    try {
      await probeDio.get<dynamic>('/stats', queryParameters: {'scope': 'user'});
      await ref
          .read(credentialsStoreProvider)
          .write(SpeakrCredentials(baseUrl: normalizedUrl, token: token));
      // Force refresh of cached credentials so listeners pick up the change.
      ref.invalidate(currentCredentialsProvider);
      if (!mounted) return;
      context.go('/library');
    } on DioException catch (e) {
      String msg;
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        msg = tr("Token rejected by the server (HTTP {0}).", [code]);
      } else if (code != null) {
        msg = tr("Server replied with HTTP {0}.", [code]);
      } else {
        msg = tr("Could not reach {0}. Check the URL and network.", [
          normalizedUrl,
        ]);
      }
      if (!mounted) return;
      setState(() => _error = msg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = tr("Unexpected error: {0}", [e]));
    } finally {
      probeDio.close(force: true);
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Scaffold(
      backgroundColor: SpeakrColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressDots(step: _step, total: 3),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _buildSlide(_step),
              ),
            ),
            _Footer(
              step: _step,
              connecting: _connecting,
              onBack: _step > 0 ? () => setState(() => _step--) : null,
              onNext: () {
                if (_step < 2) {
                  setState(() => _step++);
                } else {
                  _connect();
                }
              },
              error: _error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(int step) {
    switch (step) {
      case 0:
        return _Slide(
          key: ValueKey('intro'),
          eyebrow: 'Minutes for Speakr',
          headline: tr("The quiet way to "),
          headlineEm: tr("capture"),
          headlineTail: tr(" a meeting."),
          sub: tr(
            "Hit record. We'll handle the transcript, the summary, and the search.",
          ),
          art: HeroWave(),
        );
      case 1:
        return _Slide(
          key: const ValueKey('selfhost'),
          eyebrow: tr("Self-hosted"),
          headline: tr("Your audio. "),
          headlineEm: tr("Your server."),
          sub: tr(
            "Speakr runs on your own machine. Recordings never leave the box you point it at.",
          ),
          art: _ServerArt(),
        );
      case 2:
      default:
        return _ConnectForm(
          urlCtrl: _urlCtrl,
          tokenCtrl: _tokenCtrl,
          onSubmit: _connect,
        );
    }
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
              height: 2,
              decoration: BoxDecoration(
                color: i <= step ? SpeakrColors.ink : SpeakrColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    super.key,
    required this.eyebrow,
    required this.headline,
    required this.headlineEm,
    this.headlineTail = '',
    required this.sub,
    required this.art,
  });

  final String eyebrow;
  final String headline;
  final String headlineEm;
  final String headlineTail;
  final String sub;
  final Widget art;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
      child: Column(
        children: [
          Expanded(child: Center(child: art)),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonoEyebrow(eyebrow),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: SpeakrText.serif(size: 32, height: 1.15),
                      children: [
                        TextSpan(text: headline),
                        TextSpan(
                          text: headlineEm,
                          style: SpeakrText.serif(
                            size: 32,
                            height: 1.15,
                            style: FontStyle.italic,
                          ),
                        ),
                        if (headlineTail.isNotEmpty)
                          TextSpan(text: headlineTail),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    sub,
                    style: SpeakrText.sans(
                      size: 15,
                      height: 1.5,
                      color: SpeakrColors.ink2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: SpeakrColors.bgAlt,
        border: Border.all(color: SpeakrColors.line),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 30,
            child: Text(
              'localhost:8080',
              style: SpeakrText.mono(size: 11, color: SpeakrColors.muted),
            ),
          ),
          CustomPaint(size: const Size(80, 80), painter: _ServerStackPainter()),
        ],
      ),
    );
  }
}

class _ServerStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = SpeakrColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 0; i < 3; i++) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(14, 18.0 + i * 18, 52, 14),
        const Radius.circular(2),
      );
      canvas.drawRRect(r, stroke);
      final dotColor = i == 2 ? const Color(0xFF3DDC97) : SpeakrColors.ink;
      canvas.drawCircle(
        Offset(20, 25.0 + i * 18),
        1.5,
        Paint()..color = dotColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectForm extends StatelessWidget {
  const _ConnectForm({
    required this.urlCtrl,
    required this.tokenCtrl,
    required this.onSubmit,
  });

  final TextEditingController urlCtrl;
  final TextEditingController tokenCtrl;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoEyebrow(tr("Get started")),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: SpeakrText.serif(size: 32, height: 1.15),
              children: [
                TextSpan(text: tr("Let's connect to ")),
                TextSpan(
                  text: tr("your Speakr."),
                  style: SpeakrText.serif(
                    size: 32,
                    height: 1.15,
                    style: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tr(
              "Paste your server URL and an API token from Settings → API Tokens.",
            ),
            style: SpeakrText.sans(
              size: 15,
              height: 1.5,
              color: SpeakrColors.ink2,
            ),
          ),
          const SizedBox(height: 28),
          MonoEyebrow(tr("Server URL")),
          const SizedBox(height: 8),
          TextField(
            controller: urlCtrl,
            autocorrect: false,
            keyboardType: TextInputType.url,
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            style: SpeakrText.mono(
              size: 14,
              color: SpeakrColors.ink2,
              letterSpacing: 0,
              weight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              hintText: 'https://speakr.local',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          MonoEyebrow(tr("API Token")),
          const SizedBox(height: 8),
          TextField(
            controller: tokenCtrl,
            autocorrect: false,
            obscureText: true,
            style: SpeakrText.mono(
              size: 14,
              color: SpeakrColors.ink,
              letterSpacing: 0,
              weight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              hintText: '••••••••••••••••••••',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.step,
    required this.connecting,
    required this.onBack,
    required this.onNext,
    this.error,
  });

  final int step;
  final bool connecting;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String? error;

  @override
  Widget build(BuildContext context) {
    LanguageScope.watch(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            if (error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SpeakrColors.danger.withValues(alpha: 0.06),
                  border: Border.all(
                    color: SpeakrColors.danger.withValues(alpha: 0.4),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  error!,
                  style: SpeakrText.sans(size: 13, color: SpeakrColors.danger),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onBack,
                  style: TextButton.styleFrom(
                    foregroundColor: onBack == null
                        ? Colors.transparent
                        : SpeakrColors.ink2,
                  ),
                  child: Text(tr("Back")),
                ),
                FilledButton(
                  onPressed: connecting ? null : onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: SpeakrColors.ink,
                    foregroundColor: SpeakrColors.bg,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  child: connecting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SpeakrColors.bg,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              step < 2 ? tr("Next") : tr("Connect"),
                              style: SpeakrText.sans(
                                size: 14,
                                weight: FontWeight.w500,
                                color: SpeakrColors.bg,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const SpeakrIconView(
                              SpeakrIcon.chev,
                              size: 16,
                              color: SpeakrColors.bg,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
