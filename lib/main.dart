import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const PaejaePickApp());
}

class PaejaePickApp extends StatelessWidget {
  const PaejaePickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '배재Pick 2.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

const String officialDietUrl = 'https://www.pcu.ac.kr/kor/29/diet';

Future<void> openOfficialDietPage() async {
  final uri = Uri.parse(officialDietUrl);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class AppColors {
  static const blue = Color(0xFF126DFF);
  static const dark = Color(0xFF07142F);
  static const text = Color(0xFF0F172A);
  static const sub = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);
  static const bg = Color(0xFFF7FAFF);
}

class Assets {
  static const nasemi = 'assets/images/nasemi_main.png';
  static const nasemiWave = 'assets/images/nasemi_wave.png';
  static const nasemiAvatar = 'assets/images/nasemi_avatar.png';
  static const logoP = 'assets/images/logo_p.png';
  static const campus = 'assets/images/campus_bg.png';
  static const citybrain = 'assets/images/card_citybrain.png';
  static const cafeteriaHero = 'assets/images/cafeteria_hero.png';
  static const collection = 'assets/images/card_collection.png';
  static const qr = 'assets/images/card_qr.png';
  static const recruit = 'assets/images/card_recruit.png';
  static const security = 'assets/images/icon_security.png';
}

class EmailAuthStore {
  static const String verifiedKey = 'email_verified';
  static const String verifiedEmailKey = 'verified_email';

  static Future<void> markVerified(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(verifiedKey, true);
    await prefs.setString(verifiedEmailKey, email);
  }

  static Future<bool> isVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(verifiedKey) ?? false;
  }

  static Future<String?> verifiedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(verifiedEmailKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(verifiedKey);
    await prefs.remove(verifiedEmailKey);
  }
}

class EmailAuthApi {
  // Android emulator에서 Mac localhost 접근: 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8001';

  static Future<String> requestCode(String email) async {
    final uri = Uri.parse('$baseUrl/auth/request-code');

    final res = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 8));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map && decoded['message'] != null) {
          return decoded['message'].toString();
        }
      } catch (_) {}
      return '인증번호를 보냈습니다.';
    }

    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is Map && decoded['detail'] != null) {
        throw Exception(decoded['detail'].toString());
      }
    } catch (_) {}

    throw Exception('인증번호 요청 실패 (${res.statusCode})');
  }

  static Future<bool> verifyCode(String email, String code) async {
    final uri = Uri.parse('$baseUrl/auth/verify-code');

    final res = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'code': code}),
        )
        .timeout(const Duration(seconds: 8));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map && decoded['verified'] != null) {
          return decoded['verified'] == true;
        }
      } catch (_) {}
      return true;
    }

    return false;
  }
}

class AppText {
  static const betaNotice =
      '학생 프로젝트 기반 베타 서비스입니다. 아직 학교 공식 앱이 아니며, 일부 기능은 시범 운영될 수 있습니다.';

  static const privacyNotice =
      '학교 이메일 기반 재학생 인증만 진행하며, 학번, 실명·전화번호는 수집하지 않습니다.';

  static const version = 'v5.0-beta';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();

  bool codeSent = false;
  String? errorText;

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    super.dispose();
  }

  void autofillDev() {
    setState(() {
      emailController.text = 'dev@pcu.ac.kr';
      codeController.text = '000000';
      codeSent = true;
      errorText = null;
    });
  }

  Future<void> requestCode() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.endsWith('@pcu.ac.kr')) {
      setState(() {
        errorText = '학교 이메일(@pcu.ac.kr)을 입력해주세요.';
      });
      return;
    }

    // 개발용 mock. 실제 배포 전에는 dev 계정 예외를 제거하는 게 맞습니다.
    if (email == 'dev@pcu.ac.kr') {
      setState(() {
        codeSent = true;
        errorText = '개발 모드 인증코드는 000000 입니다.';
      });
      return;
    }

    setState(() {
      codeSent = false;
      errorText = '인증번호를 요청하는 중입니다.';
    });

    try {
      final message = await EmailAuthApi.requestCode(email);

      if (!mounted) return;

      setState(() {
        codeSent = true;
        errorText = message;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        codeSent = false;
        errorText = '메일 인증 서버에 연결할 수 없습니다. 백엔드 실행 상태를 확인해주세요.';
      });
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final code = codeController.text.trim();

    final isDev = email == 'dev@pcu.ac.kr' && code == '000000';

    if (!isDev) {
      if (!codeSent) {
        setState(() {
          errorText = '먼저 이메일 인증번호를 요청해주세요.';
        });
        return;
      }

      setState(() {
        errorText = '인증번호를 확인하는 중입니다.';
      });

      final verified = await EmailAuthApi.verifyCode(email, code);

      if (!mounted) return;

      if (!verified) {
        setState(() {
          errorText = '인증번호가 올바르지 않거나 만료되었습니다.';
        });
        return;
      }
    }

    await EmailAuthStore.markVerified(email);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const _BrandTitle(center: true),
              const SizedBox(height: 18),
              Container(
                width: 184,
                height: 184,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(46),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18006BFF),
                      blurRadius: 36,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: _AssetImage(path: Assets.nasemi, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '캠퍼스를 더 가깝게',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '나섬이와 함께 스마트한 캠퍼스 생활을 시작해요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.sub,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              _TextInputBox(
                controller: emailController,
                icon: Icons.mail_outline,
                hint: '학교 이메일',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 13),
              _TextInputBox(
                controller: codeController,
                icon: Icons.lock_outline,
                hint: '인증 코드',
                keyboardType: TextInputType.number,
                trailing: codeSent ? '02:59' : null,
              ),
              const SizedBox(height: 17),
              _PrimaryButton(text: '이메일 인증번호 받기', onTap: requestCode),
              const SizedBox(height: 12),
              _SecondaryButton(text: '인증하고 시작하기', onTap: login),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: autofillDev,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '개발자 테스트 자동입력: dev@pcu.ac.kr / 000000',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.blue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE11D48),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              const SizedBox(height: 15),
              const Text(
                AppText.privacyNotice,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.sub,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              const _AssetInfoCard(
                imagePath: Assets.security,
                title: '이메일 인증 후',
                body: '학과 / 도감 / 미션 기능 이용 가능',
              ),
              const SizedBox(height: 12),
              const Text(
                AppText.betaNotice,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    CollectionScreen(),
    MissionScreen(),
    RecruitScreen(),
    MyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: _PillBottomNav(
        selectedIndex: index,
        onTap: (v) => setState(() => index = v),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _TopBar(),
          SizedBox(height: 16),
          _HomeHero(),
          SizedBox(height: 14),
          _HomeCafeteriaPriorityCard(),
          SizedBox(height: 12),
          _HomeGrid(),
          SizedBox(height: 14),
          _LiveStepCounterCard(),
          SizedBox(height: 14),
          _HomeCompactToolsSection(),
          SizedBox(height: 14),
          _CampusAlertCard(),
          SizedBox(height: 14),
          _BetaBanner(),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 206,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17006BFF),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _AssetImage(path: Assets.campus, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blue.withOpacity(.94),
                    AppColors.blue.withOpacity(.64),
                    Colors.black.withOpacity(.10),
                  ],
                  stops: const [0.0, 0.62, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            const Positioned(
              left: 22,
              top: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 배재Pick',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    '필요한 기능부터\n빠르게 확인해요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '학생식당 · 학과백과 · 분실물 · 동아리',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 걸음 수',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '실시간 연동',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                  child: LinearProgressIndicator(
                    value: .75,
                    minHeight: 5,
                    backgroundColor: Color(0xFFE8EEF8),
                    color: AppColors.blue,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  '목표 10,000걸음 · 센서 연동',
                  style: TextStyle(color: AppColors.sub, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 14),
          SizedBox(
            width: 64,
            height: 64,
            child: _AssetImage(path: Assets.nasemi, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _TodaySpawnShortcutCard extends StatelessWidget {
  final bool compact;

  const _TodaySpawnShortcutCard({this.compact = false});

  NasemiQrReward get reward {
    final hour = DateTime.now().hour;

    if (hour >= 19 || hour <= 6) {
      return const NasemiQrReward(
        no: 42,
        name: '야간탐험 나섬이',
        category: '히든',
        rarity: '히든',
        emoji: '🌙',
        message: '밤 시간대 캠퍼스 동선에서 발견했어요.',
        valid: true,
      );
    }

    if (hour >= 11 && hour <= 14) {
      return const NasemiQrReward(
        no: 39,
        name: '학생식당 나섬이',
        category: '장소',
        rarity: '장소',
        emoji: '🍱',
        message: '점심시간 학생식당 주변에서 발견했어요.',
        valid: true,
      );
    }

    return const NasemiQrReward(
      no: 44,
      name: '포트폴리오형 나섬이',
      category: '수업',
      rarity: '희귀',
      emoji: '🎨',
      message: '디자인학부 전시 공간 근처에서 발견했어요.',
      valid: true,
    );
  }

  String get place {
    final r = reward;
    if (r.no == 42) return '중앙도서관 ↔ 기숙사 동선';
    if (r.no == 39) return '학생식당 주변';
    return '디자인학부 전시 공간 근처';
  }

  String get condition {
    final r = reward;
    if (r.no == 42) return '저녁 7시 이후 출현 확률 증가';
    if (r.no == 39) return '점심시간대 출현 확률 증가';
    return '평일 오후 · 전시/작업 공간 주변';
  }

  @override
  Widget build(BuildContext context) {
    final r = reward;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NasemiEncounterPage(
                reward: r,
                place: place,
                condition: condition,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 16 : 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18006BFF),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 62 : 72,
                height: compact ? 62 : 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(.45),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    r.emoji,
                    style: TextStyle(fontSize: compact ? 34 : 40),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compact ? '지금 출현 중' : '지금 캠퍼스에 뜬 나섬이',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      r.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 19 : 21,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      condition,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.94),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '조우',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
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

class _HomeExplorationDashboard extends StatefulWidget {
  const _HomeExplorationDashboard();

  @override
  State<_HomeExplorationDashboard> createState() =>
      _HomeExplorationDashboardState();
}

class _HomeExplorationDashboardState extends State<_HomeExplorationDashboard> {
  int collectedCount = 0;
  int questDone = 0;
  int streakCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final prefs = await SharedPreferences.getInstance();

    final collected = await NasemiCollectionStore.load();
    final questValues =
        prefs.getStringList('daily_quest_progress') ?? <String>[];
    final questSet = questValues
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .where((e) => e >= 1 && e <= 3)
        .toSet();

    final streak = await NasemiStreakStore.load();

    if (!mounted) return;

    setState(() {
      collectedCount = collected.length;
      questDone = questSet.length;
      streakCount = streak;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double questProgress = ((questDone / 3).clamp(0.0, 1.0)).toDouble();
    final double dexProgress = ((collectedCount / 100).clamp(
      0.0,
      1.0,
    )).toDouble();

    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '오늘의 캠퍼스 탐험',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _loadDashboard,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.blue,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '새로고침',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '오늘 뜬 나섬이를 찾고, 퀘스트와 도감을 채워보세요.',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HomeExplorationStatCard(
                icon: Icons.task_alt_rounded,
                title: '오늘 퀘스트',
                value: '$questDone / 3',
                progress: questProgress,
              ),
              const SizedBox(width: 10),
              _HomeExplorationStatCard(
                icon: Icons.auto_awesome_rounded,
                title: '도감',
                value: '$collectedCount / 100',
                progress: dexProgress,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFB45309),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '연속 탐색 ${streakCount}일',
                          style: const TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CollectionScreen(initialTab: 1),
                      ),
                    ).then((_) => _loadDashboard());
                  },
                  icon: const Icon(Icons.map_rounded, size: 20),
                  label: const Text(
                    '맵 열기',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeExplorationStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double progress;

  const _HomeExplorationStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.blue, size: 23),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFE8EEF8),
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementShortcutCard extends StatefulWidget {
  const _AchievementShortcutCard();

  @override
  State<_AchievementShortcutCard> createState() =>
      _AchievementShortcutCardState();
}

class _AchievementShortcutCardState extends State<_AchievementShortcutCard> {
  int unlocked = 0;
  int total = 10;
  String nextTitle = '첫 나섬이 수집';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final collected = await NasemiCollectionStore.load();
    final streak = await NasemiStreakStore.load();
    final prefs = await SharedPreferences.getInstance();

    final questValues =
        prefs.getStringList('daily_quest_progress') ?? <String>[];
    final questDone = questValues
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .where((e) => e >= 1 && e <= 3)
        .toSet()
        .length;

    final items = AchievementBuilder.build(
      collected: collected,
      streak: streak,
      questDone: questDone,
    );

    final done = items.where((e) => e.unlocked).length;
    final next = items.where((e) => !e.unlocked).isNotEmpty
        ? items.firstWhere((e) => !e.unlocked).title
        : '모든 배지 달성';

    if (!mounted) return;
    setState(() {
      unlocked = done;
      total = items.length;
      nextTitle = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlocked / total;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AchievementsPage()),
          ).then((_) => _load());
        },
        child: _Card(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFB45309),
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '탐험 배지',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '획득 $unlocked / $total · 다음 목표: $nextTitle',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE8EEF8),
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  List<_AchievementViewItem> achievements = [];
  int collectedCount = 0;
  int streakCount = 0;
  int questDone = 0;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final collected = await NasemiCollectionStore.load();
    final streak = await NasemiStreakStore.load();
    final prefs = await SharedPreferences.getInstance();

    final questValues =
        prefs.getStringList('daily_quest_progress') ?? <String>[];
    final quest = questValues
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .where((e) => e >= 1 && e <= 3)
        .toSet()
        .length;

    final built = AchievementBuilder.build(
      collected: collected,
      streak: streak,
      questDone: quest,
    );

    if (!mounted) return;
    setState(() {
      achievements = built;
      collectedCount = collected.length;
      streakCount = streak;
      questDone = quest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((e) => e.unlocked).length;
    final progress = achievements.isEmpty
        ? 0.0
        : unlocked / achievements.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DetailTopBar(title: '탐험 배지'),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFFD48A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22FF9800),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 58)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '캠퍼스 탐험 기록',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '배지 $unlocked / ${achievements.length} · 도감 $collectedCount종 · 연속 $streakCount일',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  _AchievementTopStat(
                    icon: Icons.auto_awesome_rounded,
                    label: '도감',
                    value: '$collectedCount종',
                  ),
                  const SizedBox(width: 8),
                  _AchievementTopStat(
                    icon: Icons.task_alt_rounded,
                    label: '오늘 퀘스트',
                    value: '$questDone / 3',
                  ),
                  const SizedBox(width: 8),
                  _AchievementTopStat(
                    icon: Icons.local_fire_department_rounded,
                    label: '연속 탐색',
                    value: '${streakCount}일',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '배지 목록',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            ...achievements.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AchievementCard(item: item),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AchievementBuilder {
  static List<_AchievementViewItem> build({
    required Set<int> collected,
    required int streak,
    required int questDone,
  }) {
    final deptCount = collected.where((e) => e >= 1 && e <= 33).length;
    final styleCount = collected
        .where((e) => e >= 34 && e <= 37 || e == 44)
        .length;
    final placeCount = collected.where((e) => e == 38 || e == 39).length;
    final eventCount = collected.where((e) => e == 40 || e == 41).length;
    final hiddenCount = collected.where((e) => e == 42 || e == 43).length;
    final clubCount = collected.where((e) => e >= 120 && e < 200).length;

    return [
      _AchievementViewItem(
        emoji: '✨',
        title: '첫 발견',
        body: '나섬이를 처음으로 수집했어요.',
        progress: collected.length,
        target: 1,
      ),
      _AchievementViewItem(
        emoji: '🏫',
        title: '학과 탐험 시작',
        body: '학과 나섬이를 1종 이상 수집했어요.',
        progress: deptCount,
        target: 1,
      ),
      _AchievementViewItem(
        emoji: '🧭',
        title: '학과 탐험가',
        body: '학과 나섬이를 5종 수집해보세요.',
        progress: deptCount,
        target: 5,
      ),
      _AchievementViewItem(
        emoji: '👑',
        title: '학과 마스터',
        body: '학과 나섬이 33종 전체 수집 목표.',
        progress: deptCount,
        target: 33,
      ),
      _AchievementViewItem(
        emoji: '💬',
        title: '수업 스타일 발견',
        body: '수업 스타일 나섬이를 1종 이상 발견했어요.',
        progress: styleCount,
        target: 1,
      ),
      _AchievementViewItem(
        emoji: '📍',
        title: '캠퍼스 장소 탐방',
        body: '장소 기반 나섬이를 2종 수집해보세요.',
        progress: placeCount,
        target: 2,
      ),
      _AchievementViewItem(
        emoji: '🌙',
        title: '야간 탐험',
        body: '히든 나섬이를 발견해보세요.',
        progress: hiddenCount,
        target: 1,
      ),
      _AchievementViewItem(
        emoji: '🌸',
        title: '이벤트 참여자',
        body: '이벤트 나섬이를 1종 이상 수집해보세요.',
        progress: eventCount,
        target: 1,
      ),
      _AchievementViewItem(
        emoji: '🏷️',
        title: '동아리 탐험 시작',
        body: '동아리 나섬이를 1종 이상 수집했어요.',
        progress: clubCount,
        target: 1,
      ),
      _AchievementViewItem(
        emoji: '🎪',
        title: '동아리 컬렉터',
        body: '동아리 나섬이를 5종 수집해보세요.',
        progress: clubCount,
        target: 5,
      ),
      _AchievementViewItem(
        emoji: '✅',
        title: '오늘의 탐험 완료',
        body: '일일 탐색 퀘스트 3개를 완료해보세요.',
        progress: questDone,
        target: 3,
      ),
      _AchievementViewItem(
        emoji: '🔥',
        title: '연속 탐색 3일',
        body: '3일 연속으로 나섬이를 수집해보세요.',
        progress: streak,
        target: 3,
      ),
    ];
  }
}

class _AchievementViewItem {
  final String emoji;
  final String title;
  final String body;
  final int progress;
  final int target;

  const _AchievementViewItem({
    required this.emoji,
    required this.title,
    required this.body,
    required this.progress,
    required this.target,
  });

  bool get unlocked => progress >= target;

  double get rate {
    if (target <= 0) return 0;
    return (progress / target).clamp(0.0, 1.0).toDouble();
  }
}

class _AchievementTopStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AchievementTopStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 76,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.blue, size: 21),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _AchievementViewItem item;

  const _AchievementCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.unlocked ? 1 : .58,
      child: _Card(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: item.unlocked
                    ? const Color(0xFFFFF4D6)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(
                        item.unlocked
                            ? Icons.check_circle_rounded
                            : Icons.lock_rounded,
                        color: item.unlocked
                            ? const Color(0xFFB45309)
                            : AppColors.sub,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: item.rate,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE8EEF8),
                            color: item.unlocked
                                ? const Color(0xFFB45309)
                                : AppColors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        '${item.progress.clamp(0, item.target)} / ${item.target}',
                        style: const TextStyle(
                          color: AppColors.sub,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExplorationSettingsStore {
  static const String hapticKey = 'exploration_haptic_enabled';
  static const String soundKey = 'exploration_sound_enabled';
  static const String safetyKey = 'exploration_safety_notice_checked';

  static Future<bool> hapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hapticKey) ?? true;
  }

  static Future<void> setHapticEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hapticKey, value);
  }

  static Future<bool> soundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(soundKey) ?? false;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundKey, value);
  }

  static Future<bool> safetyChecked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(safetyKey) ?? false;
  }

  static Future<void> setSafetyChecked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(safetyKey, value);
  }
}

class GameFeedback {
  static Future<void> selectionClick() async {
    if (await ExplorationSettingsStore.hapticEnabled()) {
      HapticFeedback.selectionClick();
    }
  }

  static Future<void> lightImpact() async {
    if (await ExplorationSettingsStore.hapticEnabled()) {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> mediumImpact() async {
    if (await ExplorationSettingsStore.hapticEnabled()) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavyImpact() async {
    if (await ExplorationSettingsStore.hapticEnabled()) {
      HapticFeedback.heavyImpact();
    }
  }
}

class _ExplorationSafetySettingsCard extends StatefulWidget {
  const _ExplorationSafetySettingsCard();

  @override
  State<_ExplorationSafetySettingsCard> createState() =>
      _ExplorationSafetySettingsCardState();
}

class _ExplorationSafetySettingsCardState
    extends State<_ExplorationSafetySettingsCard> {
  bool safetyChecked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final checked = await ExplorationSettingsStore.safetyChecked();
    if (!mounted) return;
    setState(() {
      safetyChecked = checked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExplorationSafetySettingsPage(),
            ),
          ).then((_) => _load());
        },
        child: _Card(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: safetyChecked
                      ? const Color(0xFFE8FFF1)
                      : const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Icon(
                  safetyChecked
                      ? Icons.verified_user_rounded
                      : Icons.health_and_safety_rounded,
                  color: safetyChecked
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFB45309),
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '탐험 안전 · 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      safetyChecked
                          ? '안전 수칙 확인 완료 · 진동/사운드 설정 가능'
                          : '캠퍼스 탐색 전 안전 수칙을 확인하세요.',
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorationSafetySettingsPage extends StatefulWidget {
  const ExplorationSafetySettingsPage({super.key});

  @override
  State<ExplorationSafetySettingsPage> createState() =>
      _ExplorationSafetySettingsPageState();
}

class _ExplorationSafetySettingsPageState
    extends State<ExplorationSafetySettingsPage> {
  bool haptic = true;
  bool sound = false;
  bool safetyChecked = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final h = await ExplorationSettingsStore.hapticEnabled();
    final s = await ExplorationSettingsStore.soundEnabled();
    final checked = await ExplorationSettingsStore.safetyChecked();

    if (!mounted) return;
    setState(() {
      haptic = h;
      sound = s;
      safetyChecked = checked;
    });
  }

  Future<void> _setHaptic(bool value) async {
    await ExplorationSettingsStore.setHapticEnabled(value);
    if (!mounted) return;
    setState(() {
      haptic = value;
    });
  }

  Future<void> _setSound(bool value) async {
    await ExplorationSettingsStore.setSoundEnabled(value);
    if (!mounted) return;
    setState(() {
      sound = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('사운드 효과는 베타 UI 설정만 저장됩니다. 실제 효과음은 추후 적용 예정입니다.'),
      ),
    );
  }

  Future<void> _confirmSafety() async {
    await ExplorationSettingsStore.setSafetyChecked(true);
    if (!mounted) return;
    setState(() {
      safetyChecked = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('탐험 안전 수칙 확인이 완료됐어요.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DetailTopBar(title: '탐험 안전 · 설정'),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🧭', style: TextStyle(fontSize: 58)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '안전한 캠퍼스 탐험',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          '게임처럼 즐기되, 이동 안전과 교수님/학과 공간을 존중하는 방식으로 운영합니다.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '탐색 설정',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingsSwitchRow(
                    icon: Icons.vibration_rounded,
                    title: '진동 피드백',
                    body: '조우, 나섬볼 던지기, 수집 완료 시 짧은 진동',
                    value: haptic,
                    onChanged: _setHaptic,
                  ),
                  const SizedBox(height: 8),
                  _SettingsSwitchRow(
                    icon: Icons.volume_up_rounded,
                    title: '사운드 효과',
                    body: '베타에서는 설정만 저장, 효과음은 추후 적용',
                    value: sound,
                    onChanged: _setSound,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '탐험 안전 수칙',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 10),
            const _SafetyRuleCard(
              icon: Icons.directions_walk_rounded,
              title: '뛰거나 급하게 이동하지 않기',
              body: '복도, 계단, 도로 주변에서는 화면보다 주변을 먼저 확인합니다.',
            ),
            const SizedBox(height: 9),
            const _SafetyRuleCard(
              icon: Icons.meeting_room_rounded,
              title: '교수 연구실 내부 진입 금지',
              body: '학과 나섬이는 연구실 내부가 아니라 학과 공식 거점 QR에서 수집하는 방식이 안전합니다.',
            ),
            const SizedBox(height: 9),
            const _SafetyRuleCard(
              icon: Icons.nightlight_round,
              title: '야간 탐색은 공개 동선만',
              body: '야간 한정 나섬이는 기숙사, 도서관, 학생회관 등 공개 동선 중심으로 제한합니다.',
            ),
            const SizedBox(height: 9),
            const _SafetyRuleCard(
              icon: Icons.no_crash_rounded,
              title: '이동 중 스캔 금지',
              body: '자전거, 킥보드, 차량 이동 중에는 QR 스캔과 조우 화면 이용을 제한합니다.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: safetyChecked ? null : _confirmSafety,
                icon: Icon(
                  safetyChecked
                      ? Icons.verified_rounded
                      : Icons.check_circle_outline_rounded,
                ),
                label: Text(
                  safetyChecked ? '안전 수칙 확인 완료' : '안전 수칙 확인하기',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 8, 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue, size: 25),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SafetyRuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _SafetyRuleCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.blue, size: 29),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DailyExplorationLimitStore {
  static const String countDateKey = 'daily_exploration_count_date';
  static const String countKey = 'daily_exploration_count';
  static const int dailyRewardLimit = 5;

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static Future<int> loadTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(countDateKey);

    if (savedDate != _today()) {
      await prefs.setString(countDateKey, _today());
      await prefs.setInt(countKey, 0);
      return 0;
    }

    return prefs.getInt(countKey) ?? 0;
  }

  static Future<int> markCatchToday() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(countDateKey);

    if (savedDate != _today()) {
      await prefs.setString(countDateKey, _today());
      await prefs.setInt(countKey, 1);
      return 1;
    }

    final current = prefs.getInt(countKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(countKey, next);
    return next;
  }

  static Future<bool> reachedDailyLimit() async {
    final count = await loadTodayCount();
    return count >= dailyRewardLimit;
  }
}

class _ExplorationLimitPolicyCard extends StatefulWidget {
  const _ExplorationLimitPolicyCard();

  @override
  State<_ExplorationLimitPolicyCard> createState() =>
      _ExplorationLimitPolicyCardState();
}

class _ExplorationLimitPolicyCardState
    extends State<_ExplorationLimitPolicyCard> {
  int todayCount = 0;
  int streak = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final count = await DailyExplorationLimitStore.loadTodayCount();
    final loadedStreak = await NasemiStreakStore.load();

    if (!mounted) return;
    setState(() {
      todayCount = count;
      streak = loadedStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    final limit = DailyExplorationLimitStore.dailyRewardLimit;
    final progress = (todayCount / limit).clamp(0.0, 1.0).toDouble();
    final reached = todayCount >= limit;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExplorationPolicyPage()),
          ).then((_) => _load());
        },
        child: _Card(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: reached
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Icon(
                  reached
                      ? Icons.pause_circle_filled_rounded
                      : Icons.shield_rounded,
                  color: reached ? const Color(0xFFE11D48) : AppColors.blue,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '탐색 운영정책',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      reached
                          ? '오늘 보상 한도에 도달했어요. 무리한 탐색은 쉬어가세요.'
                          : '하루 보상 제한 · 수업시간/야간 탐색 안내 포함',
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE8EEF8),
                        color: reached
                            ? const Color(0xFFE11D48)
                            : AppColors.blue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '오늘 수집 보상 $todayCount / $limit · 연속 탐색 ${streak}일',
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorationPolicyPage extends StatefulWidget {
  const ExplorationPolicyPage({super.key});

  @override
  State<ExplorationPolicyPage> createState() => _ExplorationPolicyPageState();
}

class _ExplorationPolicyPageState extends State<ExplorationPolicyPage> {
  int todayCount = 0;
  int collectedCount = 0;
  int streak = 0;

  @override
  void initState() {
    super.initState();
    _loadPolicyState();
  }

  Future<void> _loadPolicyState() async {
    final count = await DailyExplorationLimitStore.loadTodayCount();
    final collected = await NasemiCollectionStore.load();
    final loadedStreak = await NasemiStreakStore.load();

    if (!mounted) return;
    setState(() {
      todayCount = count;
      collectedCount = collected.length;
      streak = loadedStreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    final limit = DailyExplorationLimitStore.dailyRewardLimit;
    final progress = (todayCount / limit).clamp(0.0, 1.0).toDouble();
    final reached = todayCount >= limit;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DetailTopBar(title: '탐색 운영정책'),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🛡️', style: TextStyle(fontSize: 58)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '재미는 유지하고,\n무리한 탐색은 줄입니다',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '캠퍼스 게임 요소는 공개 동선, 보상 제한, 안전 수칙 안에서 운영합니다.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '오늘 보상 제한',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$todayCount / $limit',
                        style: TextStyle(
                          color: reached
                              ? const Color(0xFFE11D48)
                              : AppColors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8EEF8),
                      color: reached ? const Color(0xFFE11D48) : AppColors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reached
                        ? '오늘은 보상 한도에 도달했습니다. 추가 탐색은 가능하지만 보상은 제한하는 운영정책으로 설계합니다.'
                        : '베타 정책상 하루 보상 수집은 $limit회까지 권장합니다.',
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _PolicyStatusChip(
                  icon: Icons.auto_awesome_rounded,
                  label: '도감',
                  value: '$collectedCount종',
                ),
                const SizedBox(width: 9),
                _PolicyStatusChip(
                  icon: Icons.local_fire_department_rounded,
                  label: '연속 탐색',
                  value: '${streak}일',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '운영 원칙',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const _PolicyRuleCard(
              icon: Icons.timer_off_rounded,
              title: '수업 시간 탐색 자제',
              body: '수업 중 앱 이용을 유도하지 않고, 쉬는 시간·점심시간·방과 후 탐색을 기본 전제로 합니다.',
            ),
            const SizedBox(height: 9),
            const _PolicyRuleCard(
              icon: Icons.nightlight_round,
              title: '야간 탐색 제한',
              body: '야간 한정 나섬이는 기숙사, 도서관, 학생회관 등 공개 동선 중심으로만 배치합니다.',
            ),
            const SizedBox(height: 9),
            const _PolicyRuleCard(
              icon: Icons.lock_clock_rounded,
              title: '하루 보상 제한',
              body: '무한 반복 수집을 막기 위해 하루 보상 가능 횟수를 제한하고, 과도한 이동을 줄입니다.',
            ),
            const SizedBox(height: 9),
            const _PolicyRuleCard(
              icon: Icons.meeting_room_rounded,
              title: '연구실 내부 유도 금지',
              body:
                  '학과 나섬이는 교수 연구실 내부가 아니라 학과 사무실 앞, 게시판, 로비 등 공개 거점 QR로 운영합니다.',
            ),
            const SizedBox(height: 9),
            const _PolicyRuleCard(
              icon: Icons.visibility_off_rounded,
              title: '교수님 개인 평가 금지',
              body:
                  '교수님 나섬이는 개인 평가나 희화화가 아니라 수업 방식, 연구 분야, 학습 준비 안내 중심으로 설계합니다.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyStatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PolicyStatusChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyRuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _PolicyRuleCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.blue, size: 29),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepCounterStore {
  static const String baselineDateKey = 'step_baseline_date';
  static const String baselineRawKey = 'step_baseline_raw';
  static const String lastTodayStepsKey = 'step_last_today_steps';
  static const String stepReward1000Key = 'step_reward_1000';
  static const String stepReward3000Key = 'step_reward_3000';
  static const String stepReward5000Key = 'step_reward_5000';
  static const String stepReward10000Key = 'step_reward_10000';

  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  static Future<int> resolveTodaySteps(int rawSteps) async {
    final prefs = await SharedPreferences.getInstance();
    final today = todayKey();
    final savedDate = prefs.getString(baselineDateKey);

    if (savedDate != today) {
      await prefs.setString(baselineDateKey, today);
      await prefs.setInt(baselineRawKey, rawSteps);
      await prefs.setInt(lastTodayStepsKey, 0);
      await prefs.setBool(stepReward1000Key, false);
      await prefs.setBool(stepReward3000Key, false);
      await prefs.setBool(stepReward5000Key, false);
      await prefs.setBool(stepReward10000Key, false);
      return 0;
    }

    final baseline = prefs.getInt(baselineRawKey) ?? rawSteps;
    final todaySteps = rawSteps - baseline;

    final safeSteps = todaySteps < 0 ? 0 : todaySteps;
    await prefs.setInt(lastTodayStepsKey, safeSteps);

    return safeSteps;
  }

  static Future<int> loadLastTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = todayKey();
    final savedDate = prefs.getString(baselineDateKey);

    if (savedDate != today) {
      return 0;
    }

    return prefs.getInt(lastTodayStepsKey) ?? 0;
  }

  static Future<bool> claimRewardIfNeeded(int steps) async {
    final prefs = await SharedPreferences.getInstance();

    if (steps >= 10000 && !(prefs.getBool(stepReward10000Key) ?? false)) {
      await prefs.setBool(stepReward10000Key, true);
      await NasemiCollectionStore.add(97);
      return true;
    }

    if (steps >= 5000 && !(prefs.getBool(stepReward5000Key) ?? false)) {
      await prefs.setBool(stepReward5000Key, true);
      return true;
    }

    if (steps >= 3000 && !(prefs.getBool(stepReward3000Key) ?? false)) {
      await prefs.setBool(stepReward3000Key, true);
      return true;
    }

    if (steps >= 1000 && !(prefs.getBool(stepReward1000Key) ?? false)) {
      await prefs.setBool(stepReward1000Key, true);
      return true;
    }

    return false;
  }
}

class _HomeCafeteriaPriorityCard extends StatelessWidget {
  const _HomeCafeteriaPriorityCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CafeteriaScreen()),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF126DFF), Color(0xFF7CCBFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18006BFF),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.94),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: const _AssetImage(
                      path: Assets.citybrain,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '학생식당',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            height: 1.08,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          '오늘 메뉴와 주간 식단을 먼저 확인해요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '공식 식단 기반',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.today_rounded, color: Colors.white, size: 19),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '오늘 메뉴 미리보기 · 중식/석식은 학생식당에서 확인',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSecondaryFeatureButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  const _HomeSecondaryFeatureButton({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 116,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.blue, size: 28),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveStepCounterCard extends StatefulWidget {
  const _LiveStepCounterCard();

  @override
  State<_LiveStepCounterCard> createState() => _LiveStepCounterCardState();
}

class _LiveStepCounterCardState extends State<_LiveStepCounterCard> {
  StreamSubscription<StepCount>? stepSub;
  StreamSubscription<PedestrianStatus>? statusSub;

  int todaySteps = 0;
  String statusText = '권한 확인 전';
  String walkStatus = '대기 중';
  bool permissionGranted = false;
  bool sensorReady = false;

  static const int goal = 10000;

  @override
  void initState() {
    super.initState();
    _loadCachedSteps();
    _initPedometer();
  }

  Future<void> _loadCachedSteps() async {
    final cached = await StepCounterStore.loadLastTodaySteps();
    if (!mounted) return;
    setState(() {
      todaySteps = cached;
    });
  }

  Future<void> _initPedometer() async {
    final permission = await Permission.activityRecognition.request();

    if (!mounted) return;

    if (!permission.isGranted) {
      setState(() {
        permissionGranted = false;
        sensorReady = false;
        statusText = '활동 인식 권한 필요';
        walkStatus = '권한 필요';
      });
      return;
    }

    setState(() {
      permissionGranted = true;
      statusText = '센서 연결 중';
    });

    stepSub?.cancel();
    statusSub?.cancel();

    stepSub = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepError,
      cancelOnError: false,
    );

    statusSub = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatus,
      onError: (_) {
        if (!mounted) return;
        setState(() {
          walkStatus = '상태 감지 불가';
        });
      },
      cancelOnError: false,
    );
  }

  Future<void> _onStepCount(StepCount event) async {
    final resolved = await StepCounterStore.resolveTodaySteps(event.steps);
    final rewardUnlocked = await StepCounterStore.claimRewardIfNeeded(resolved);

    if (!mounted) return;

    setState(() {
      todaySteps = resolved;
      sensorReady = true;
      statusText = '실시간 측정 중';
    });

    if (rewardUnlocked && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resolved >= 10000
                ? '10,000걸음 달성! 10000걸음 나섬이가 도감에 등록됐어요.'
                : '${resolved}걸음 목표를 달성했어요.',
          ),
        ),
      );
    }
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    if (!mounted) return;

    setState(() {
      if (event.status == 'walking') {
        walkStatus = '걷는 중';
      } else if (event.status == 'stopped') {
        walkStatus = '멈춤';
      } else {
        walkStatus = event.status;
      }
    });
  }

  void _onStepError(Object error) {
    if (!mounted) return;

    setState(() {
      sensorReady = false;
      statusText = '센서 사용 불가';
      walkStatus = '실기기 확인 필요';
    });
  }

  Future<void> debugAddSteps() async {
    final next = todaySteps + 500;
    final rewardUnlocked = await StepCounterStore.claimRewardIfNeeded(next);

    if (!mounted) return;

    setState(() {
      todaySteps = next;
      sensorReady = true;
      permissionGranted = true;
      statusText = '디버그 측정 중';
      walkStatus = '나섬이 걷는 중';
    });

    if (rewardUnlocked && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            next >= 10000
                ? '10,000걸음 달성! 10000걸음 나섬이가 도감에 등록됐어요.'
                : '${next}걸음 목표를 달성했어요.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    stepSub?.cancel();
    statusSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (todaySteps / goal).clamp(0.0, 1.0).toDouble();
    final remain = goal - todaySteps;
    final remainText = remain <= 0 ? '목표 달성' : '${remain}걸음 남음';

    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '오늘의 카운팅',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: permissionGranted
                      ? const Color(0xFFE8FFF1)
                      : const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  permissionGranted ? statusText : '권한 필요',
                  style: TextStyle(
                    color: permissionGranted
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFB45309),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '나섬이가 걷는 만큼 오늘의 캠퍼스 이동량을 채워요.',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          _WalkingNasemiStage(
            progress: progress,
            walking: todaySteps > 0 || walkStatus.contains('걷'),
            steps: todaySteps,
          ),

          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '$todaySteps 걸음',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                remainText,
                style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFE8EEF8),
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StepRewardChip(label: '1천', active: todaySteps >= 1000),
              const SizedBox(width: 7),
              _StepRewardChip(label: '3천', active: todaySteps >= 3000),
              const SizedBox(width: 7),
              _StepRewardChip(label: '5천', active: todaySteps >= 5000),
              const SizedBox(width: 7),
              _StepRewardChip(label: '1만', active: todaySteps >= 10000),
              const Spacer(),
              Text(
                sensorReady ? walkStatus : '실기기 권장',
                style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              if (!permissionGranted)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _initPedometer,
                      icon: const Icon(Icons.directions_walk_rounded),
                      label: const Text(
                        '권한 허용',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              if (!permissionGranted) const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: debugAddSteps,
                    icon: const Icon(Icons.directions_walk_rounded),
                    label: const Text(
                      '나섬이 걷기 +500',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blue,
                      side: const BorderSide(color: AppColors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalkingNasemiStage extends StatefulWidget {
  final double progress;
  final bool walking;
  final int steps;

  const _WalkingNasemiStage({
    required this.progress,
    required this.walking,
    required this.steps,
  });

  @override
  State<_WalkingNasemiStage> createState() => _WalkingNasemiStageState();
}

class _WalkingNasemiStageState extends State<_WalkingNasemiStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _WalkingNasemiStage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.walking && !controller.isAnimating) {
      controller.repeat(reverse: true);
    }

    if (!widget.walking && controller.isAnimating) {
      controller.stop();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeProgress = widget.progress.clamp(0.0, 1.0).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxMove = (constraints.maxWidth - 88).clamp(0.0, 260.0);
        final baseX = maxMove * safeProgress;

        return Container(
          height: 132,
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF3FF), Color(0xFFF8FCFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFBBD7FF)),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 19,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('🏫', style: TextStyle(fontSize: 19)),
                    Text('🌳', style: TextStyle(fontSize: 19)),
                    Text('📍', style: TextStyle(fontSize: 19)),
                    Text('🏁', style: TextStyle(fontSize: 19)),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final bounce = widget.walking ? controller.value * 8 : 0.0;
                  final tilt = widget.walking
                      ? (controller.value - .5) * .10
                      : 0.0;

                  return Positioned(
                    left: baseX,
                    bottom: 30 + bounce,
                    child: Transform.rotate(
                      angle: tilt,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.walking ? '걷는 중' : '대기',
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 74,
                            height: 74,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.92),
                                    shape: BoxShape.circle,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x16006BFF),
                                        blurRadius: 14,
                                        offset: Offset(0, 7),
                                      ),
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: _AssetImage(
                                    path: Assets.nasemi,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 2,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.95),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${(safeProgress * 100).round()}%',
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepRewardChip extends StatelessWidget {
  final String label;
  final bool active;

  const _StepRewardChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8FFF1) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(
            active
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: active ? const Color(0xFF16A34A) : AppColors.sub,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF16A34A) : AppColors.sub,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeClubRecommendationCard extends StatefulWidget {
  const _HomeClubRecommendationCard();

  @override
  State<_HomeClubRecommendationCard> createState() =>
      _HomeClubRecommendationCardState();
}

class _HomeClubRecommendationCardState
    extends State<_HomeClubRecommendationCard> {
  List<String> interestedNames = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await ClubInterestStore.load();
    if (!mounted) return;
    setState(() {
      interestedNames = values;
    });
  }

  _OfficialClubItem? _clubByName(String name) {
    for (final club in _RecruitScreenState.clubs) {
      if (club.name == name) return club;
    }
    return null;
  }

  List<_OfficialClubItem> get interestedClubs {
    return interestedNames
        .map(_clubByName)
        .whereType<_OfficialClubItem>()
        .toList();
  }

  List<_OfficialClubItem> get recommendedClubs {
    final interested = interestedClubs;
    final interestedSet = interested.map((e) => e.name).toSet();

    if (interested.isEmpty) {
      return _RecruitScreenState.clubs.take(3).toList();
    }

    final categories = interested.map((e) => e.category).toSet();
    final sameCategory = _RecruitScreenState.clubs.where((club) {
      return categories.contains(club.category) &&
          !interestedSet.contains(club.name);
    }).toList();

    if (sameCategory.isNotEmpty) {
      return sameCategory.take(3).toList();
    }

    return _RecruitScreenState.clubs
        .where((club) => !interestedSet.contains(club.name))
        .take(3)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final interested = interestedClubs;
    final recommended = recommendedClubs;

    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '동아리 추천',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.blue,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '갱신',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            interested.isEmpty
                ? '아직 관심 동아리가 없어요. 추천 검사로 먼저 찾아보세요.'
                : '관심 동아리 ${interested.length}개를 기준으로 비슷한 동아리를 추천해요.',
            style: const TextStyle(
              color: AppColors.sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),

          if (interested.isEmpty)
            const _HomeClubEmptyPrompt()
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Text(
                    interested.first.emoji,
                    style: const TextStyle(fontSize: 29),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '최근 관심: ${interested.first.name} · ${interested.first.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 13),
          Row(
            children: [
              Text(
                interested.isEmpty ? '먼저 둘러볼 동아리' : '비슷한 추천 동아리',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${recommended.length}개',
                style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),

          ...recommended.map((club) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HomeClubMiniTile(club: club, onReturn: _load),
            );
          }),

          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClubRecommendationPage(),
                        ),
                      ).then((_) => _load());
                    },
                    icon: const Icon(Icons.psychology_alt_rounded),
                    label: const Text(
                      '추천 검사',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.blue,
                      side: const BorderSide(color: AppColors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecruitScreen(),
                        ),
                      ).then((_) => _load());
                    },
                    icon: const Icon(Icons.groups_rounded),
                    label: const Text(
                      '동아리 도감',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeClubMiniTile extends StatelessWidget {
  final _OfficialClubItem club;
  final VoidCallback onReturn;

  const _HomeClubMiniTile({required this.club, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _OfficialClubDetailPage(club: club),
            ),
          ).then((_) => onReturn());
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(club.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      club.category,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeClubEmptyPrompt extends StatelessWidget {
  const _HomeClubEmptyPrompt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb_rounded, color: Color(0xFFB45309), size: 27),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '관심사를 선택하면 스포츠, 공연·문화, 학술, 봉사 동아리를 추천받을 수 있어요.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LostFoundInterestStore {
  static const String key = 'possible_my_lost_found_items';

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(key) ?? <String>[];
    final unique = values.toSet().toList()..sort();
    return unique;
  }

  static Future<bool> contains(String id) async {
    final values = await load();
    return values.contains(id);
  }

  static Future<bool> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final values = (prefs.getStringList(key) ?? <String>[]).toSet();

    if (values.contains(id)) {
      values.remove(id);
      await prefs.setStringList(key, values.toList()..sort());
      return false;
    }

    values.add(id);
    await prefs.setStringList(key, values.toList()..sort());
    return true;
  }
}

class _LostFoundShortcutCard extends StatelessWidget {
  const _LostFoundShortcutCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LostFoundScreen()),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.manage_search_rounded,
                  color: Color(0xFFB45309),
                  size: 35,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '분실물·습득물',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '기숙사, 식당, 강의동 분실물을 안전하게 확인해요.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});

  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  String selected = '전체';

  static const filters = ['전체', '분실', '습득', '기숙사', '식당', '강의동', '전자기기'];

  static const items = [
    _LostFoundItem(
      id: 'LF-001',
      type: '습득',
      title: '검은색 텀블러',
      category: '생활용품',
      place: '학생식당',
      date: '오늘',
      status: '보관중',
      emoji: '🥤',
      description:
          '학생식당 테이블 주변에서 습득된 텀블러입니다. 브랜드, 스티커, 뚜껑 색상 등 세부 특징은 본인 확인 질문으로 확인합니다.',
      tags: ['학생식당', '텀블러', '보관중'],
    ),
    _LostFoundItem(
      id: 'LF-002',
      type: '분실',
      title: '무선 이어폰 케이스',
      category: '전자기기',
      place: '기숙사 로비',
      date: '어제',
      status: '제보접수',
      emoji: '🎧',
      description:
          '기숙사 로비 또는 엘리베이터 주변에서 분실된 것으로 등록된 전자기기입니다. 정확한 모델명과 색상 확인이 필요합니다.',
      tags: ['기숙사', '전자기기', '이어폰'],
    ),
    _LostFoundItem(
      id: 'LF-003',
      type: '습득',
      title: '학생증 카드',
      category: '카드',
      place: '중앙도서관',
      date: '오늘',
      status: '보관중',
      emoji: '💳',
      description: '중앙도서관 주변에서 습득된 카드입니다. 개인정보 보호를 위해 이름과 학번은 공개하지 않습니다.',
      tags: ['도서관', '카드', '개인정보보호'],
    ),
    _LostFoundItem(
      id: 'LF-004',
      type: '분실',
      title: '회색 후드집업',
      category: '의류',
      place: '공학관 강의동',
      date: '이번 주',
      status: '찾는중',
      emoji: '🧥',
      description:
          '공학관 강의실 주변에서 분실한 의류입니다. 사이즈, 로고, 주머니 내용물 등은 본인 확인용으로만 사용합니다.',
      tags: ['강의동', '의류', '공학관'],
    ),
    _LostFoundItem(
      id: 'LF-005',
      type: '습득',
      title: '파란색 우산',
      category: '생활용품',
      place: '학생회관',
      date: '오늘',
      status: '보관중',
      emoji: '☂️',
      description: '학생회관 입구 근처에서 습득된 우산입니다. 손잡이 형태와 우산 안쪽 표시로 본인 확인을 진행합니다.',
      tags: ['학생회관', '우산', '비오는날'],
    ),
    _LostFoundItem(
      id: 'LF-006',
      type: '분실',
      title: '충전기 어댑터',
      category: '전자기기',
      place: '강의동',
      date: '어제',
      status: '찾는중',
      emoji: '🔌',
      description: '강의실 콘센트 주변에 두고 온 것으로 등록된 충전기입니다. 출력 규격과 케이블 종류 확인이 필요합니다.',
      tags: ['강의동', '전자기기', '충전기'],
    ),
  ];

  List<_LostFoundItem> get visibleItems {
    if (selected == '전체') return items;

    return items.where((item) {
      return item.type == selected ||
          item.category.contains(selected) ||
          item.place.contains(selected) ||
          item.tags.any((tag) => tag.contains(selected));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = visibleItems;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(),
            const SizedBox(height: 18),
            const Text(
              '분실물·습득물',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              '잃어버린 물건과 습득된 물건을 개인정보 노출 없이 확인해요',
              style: TextStyle(
                fontSize: 14.5,
                color: AppColors.sub,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            const _LostFoundHero(),
            const SizedBox(height: 16),
            const _DormCctvAssistCard(),
            const SizedBox(height: 16),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final value = filters[index];
                  return _LostFoundFilterChip(
                    text: value,
                    selected: selected == value,
                    onTap: () => setState(() => selected = value),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  selected == '전체' ? '최근 등록' : '$selected 항목',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                Text(
                  '${list.length}건',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...list.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LostFoundCard(item: item),
              );
            }),

            const SizedBox(height: 8),
            const _LostFoundPrivacyNotice(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _LostFoundItem {
  final String id;
  final String type;
  final String title;
  final String category;
  final String place;
  final String date;
  final String status;
  final String emoji;
  final String description;
  final List<String> tags;

  const _LostFoundItem({
    required this.id,
    required this.type,
    required this.title,
    required this.category,
    required this.place,
    required this.date,
    required this.status,
    required this.emoji,
    required this.description,
    required this.tags,
  });
}

class _LostFoundHero extends StatelessWidget {
  const _LostFoundHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16006BFF),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '캠퍼스 분실물 허브',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '잃어버린 물건을\n빠르게 찾아요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.13,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '개인정보는 숨기고, 특징으로 본인 확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text('🔎', style: TextStyle(fontSize: 70)),
        ],
      ),
    );
  }
}

class _LostFoundFilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _LostFoundFilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.blue : AppColors.line),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.sub,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _LostFoundCard extends StatelessWidget {
  final _LostFoundItem item;

  const _LostFoundCard({required this.item});

  Color get statusColor {
    if (item.type == '습득') return AppColors.blue;
    if (item.type == '분실') return const Color(0xFFE11D48);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _LostFoundDetailPage(item: item)),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(item.emoji, style: const TextStyle(fontSize: 33)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.type,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          item.status,
                          style: const TextStyle(
                            color: AppColors.sub,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${item.place} · ${item.date}',
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class _LostFoundAuthRequiredCard extends StatelessWidget {
  const _LostFoundAuthRequiredCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Color(0xFFB45309),
              size: 30,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '본인 확인 요청은 인증 후 가능',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  '분실물 오인 요청과 허위 요청을 줄이기 위해 학교 이메일 인증을 완료한 사용자만 “내 물건일 수도 있어요” 요청을 저장할 수 있습니다.',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LostFoundDetailPage extends StatefulWidget {
  final _LostFoundItem item;

  const _LostFoundDetailPage({required this.item});

  @override
  State<_LostFoundDetailPage> createState() => _LostFoundDetailPageState();
}

class _LostFoundDetailPageState extends State<_LostFoundDetailPage> {
  bool marked = false;
  bool verified = false;
  String? verifiedEmail;
  bool loadingAuth = true;

  @override
  void initState() {
    super.initState();
    _loadMarked();
    _loadAuth();
  }

  Future<void> _loadMarked() async {
    final value = await LostFoundInterestStore.contains(widget.item.id);
    if (!mounted) return;
    setState(() {
      marked = value;
    });
  }

  Future<void> _loadAuth() async {
    final isVerified = await EmailAuthStore.isVerified();
    final email = await EmailAuthStore.verifiedEmail();

    if (!mounted) return;

    setState(() {
      verified = isVerified;
      verifiedEmail = email;
      loadingAuth = false;
    });
  }

  Future<void> _toggleMarked() async {
    if (!verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('학교 이메일 인증 후 본인 확인 요청을 저장할 수 있습니다.')),
      );
      return;
    }

    final value = await LostFoundInterestStore.toggle(widget.item.id);
    if (!mounted) return;

    setState(() {
      marked = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? '본인 확인 요청 목록에 저장했어요.' : '본인 확인 요청을 해제했어요.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(title: item.type),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.id,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${item.place} · ${item.date}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(.35),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 46),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                _LostFoundInfoChip(
                  icon: Icons.category_rounded,
                  label: '종류',
                  value: item.category,
                ),
                const SizedBox(width: 9),
                _LostFoundInfoChip(
                  icon: Icons.inventory_2_rounded,
                  label: '상태',
                  value: item.status,
                ),
              ],
            ),

            const SizedBox(height: 14),
            _LostFoundTagWrap(tags: item.tags),

            const SizedBox(height: 14),
            _Card(
              padding: const EdgeInsets.all(16),
              child: Text(
                item.description,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 14),
            if (!verified && !loadingAuth) const _LostFoundAuthRequiredCard(),

            if (!verified && !loadingAuth) const SizedBox(height: 14),

            if (verified)
              _Card(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF16A34A),
                      size: 27,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '인증된 사용자: ${verifiedEmail ?? '학교 이메일 확인됨'}',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 12.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (verified) const SizedBox(height: 14),

            const _LostFoundPrivacyNotice(),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: loadingAuth ? null : _toggleMarked,
                icon: Icon(
                  !verified
                      ? Icons.lock_rounded
                      : marked
                      ? Icons.check_circle_rounded
                      : Icons.search_rounded,
                ),
                label: Text(
                  !verified
                      ? '학교 이메일 인증 필요'
                      : marked
                      ? '요청 목록에 저장됨'
                      : '내 물건일 수도 있어요',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: !verified
                      ? const Color(0xFF94A3B8)
                      : marked
                      ? const Color(0xFF64748B)
                      : AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LostFoundDetailPageState extends State<_LostFoundDetailPage> {
  bool marked = false;

  @override
  void initState() {
    super.initState();
    _loadMarked();
  }

  Future<void> _loadMarked() async {
    final value = await LostFoundInterestStore.contains(widget.item.id);
    if (!mounted) return;
    setState(() {
      marked = value;
    });
  }

  Future<void> _toggleMarked() async {
    final value = await LostFoundInterestStore.toggle(widget.item.id);
    if (!mounted) return;

    setState(() {
      marked = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? '본인 확인 요청 목록에 저장했어요.' : '본인 확인 요청을 해제했어요.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(title: item.type),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.id,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${item.place} · ${item.date}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(.35),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 46),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                _LostFoundInfoChip(
                  icon: Icons.category_rounded,
                  label: '종류',
                  value: item.category,
                ),
                const SizedBox(width: 9),
                _LostFoundInfoChip(
                  icon: Icons.inventory_2_rounded,
                  label: '상태',
                  value: item.status,
                ),
              ],
            ),

            const SizedBox(height: 14),
            _LostFoundTagWrap(tags: item.tags),

            const SizedBox(height: 14),
            _Card(
              padding: const EdgeInsets.all(16),
              child: Text(
                item.description,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 14),
            if (item.place.contains('기숙사'))
              const _DormCctvAssistCard(compact: true),
            if (item.place.contains('기숙사')) const SizedBox(height: 14),
            const _LostFoundPrivacyNotice(),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _toggleMarked,
                icon: Icon(
                  marked ? Icons.check_circle_rounded : Icons.search_rounded,
                ),
                label: Text(
                  marked ? '요청 목록에 저장됨' : '내 물건일 수도 있어요',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: marked
                      ? const Color(0xFF64748B)
                      : AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LostFoundInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LostFoundInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue, size: 24),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LostFoundTagWrap extends StatelessWidget {
  final List<String> tags;

  const _LostFoundTagWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: tags.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            e,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LostFoundPrivacyNotice extends StatelessWidget {
  const _LostFoundPrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.privacy_tip_rounded, color: AppColors.blue, size: 29),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '개인 이름, 학번, 전화번호는 공개하지 않습니다. 본인 확인은 물건의 세부 특징을 확인하는 방식으로 처리하고, 실제 연락 기능은 운영자 검수 후 연결하는 것이 안전합니다.',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DormCctvAssistPageState extends State<DormCctvAssistPage> {
  String selectedPlace = '기숙사 로비';
  String selectedObject = '무선 이어폰';
  String selectedTime = '오늘 08:00~10:00';
  List<String> requests = [];

  static const places = [
    '기숙사 로비',
    '기숙사 엘리베이터 앞',
    '기숙사 우편함 주변',
    '기숙사 출입구',
    '기숙사 휴게공간',
  ];

  static const objects = ['무선 이어폰', '학생증/카드', '텀블러', '충전기', '우산', '의류', '가방'];

  static const times = [
    '오늘 08:00~10:00',
    '오늘 10:00~12:00',
    '오늘 12:00~15:00',
    '오늘 15:00~18:00',
    '어제 저녁',
    '직접 입력 예정',
  ];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final values = await DormCctvRequestStore.load();
    if (!mounted) return;
    setState(() {
      requests = values;
    });
  }

  Future<void> _submitRequest() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'CCTV/YOLO 분석은 학교 승인 및 지원 서버 확보 후 제공 예정입니다. 현재 2단계 베타에서는 요청 저장을 막아두었습니다.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DetailTopBar(title: '기숙사 AI 확인'),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RTSP + YOLO 지원 필요',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '사람이 아니라\n물건 후보만 찾아요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '학교 승인 · 서버 지원 · 보안 검토 필요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('🎥', style: TextStyle(fontSize: 66)),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const _FeatureLockedFundingCard(
              icon: Icons.videocam_off_rounded,
              title: 'CCTV/YOLO 분석 비활성화',
              body:
                  '영상 분석은 서버 비용, CCTV 접근 권한, 개인정보 검토가 필요합니다. 현재 베타에서는 기능 설명만 제공하고 실제 분석 요청은 저장하지 않습니다.',
              badge: '비활성화',
            ),

            const SizedBox(height: 14),
            _Card(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '확인 요청 만들기',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '분실 위치, 물건 종류, 시간대를 좁혀야 CCTV 확인 요청이 현실적입니다.',
                    style: TextStyle(
                      color: AppColors.sub,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _DormDropdown(
                    label: '장소',
                    value: selectedPlace,
                    values: places,
                    onChanged: (v) => setState(() => selectedPlace = v),
                  ),
                  const SizedBox(height: 10),
                  _DormDropdown(
                    label: '물건',
                    value: selectedObject,
                    values: objects,
                    onChanged: (v) => setState(() => selectedObject = v),
                  ),
                  const SizedBox(height: 10),
                  _DormDropdown(
                    label: '시간대',
                    value: selectedTime,
                    values: times,
                    onChanged: (v) => setState(() => selectedTime = v),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _submitRequest,
                      icon: const Icon(Icons.manage_search_rounded),
                      label: const Text(
                        'AI 확인 요청 저장',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const _DormCctvPipelineCard(),
            const SizedBox(height: 14),
            const _DormCctvPolicyCard(),
            const SizedBox(height: 14),
            _DormCctvRequestHistoryCard(requests: requests),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DormDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _DormDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 5, 11, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: values.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DormCctvRequestStore {
  static const String key = 'dorm_cctv_ai_requests';

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? <String>[];
  }

  static Future<void> add(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(key) ?? <String>[];

    values.insert(0, value);

    await prefs.setStringList(key, values.take(10).toList());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

class _DormCctvAssistCard extends StatelessWidget {
  final bool compact;

  const _DormCctvAssistCard({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DormCctvAssistPage()),
          );
        },
        child: _Card(
          padding: EdgeInsets.all(compact ? 15 : 17),
          child: Row(
            children: [
              Container(
                width: compact ? 56 : 62,
                height: compact ? 56 : 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: AppColors.blue,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compact ? '기숙사 AI 확인 요청' : '기숙사 AI 분실물 확인',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '승인된 CCTV에서 물건 후보만 탐지하는 요청형 기능입니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class DormCctvAssistPage extends StatefulWidget {
  const DormCctvAssistPage({super.key});

  @override
  State<DormCctvAssistPage> createState() => _DormCctvAssistPageState();
}

class _DormCctvPipelineCard extends StatelessWidget {
  const _DormCctvPipelineCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'AI 확인 흐름',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          _DormCctvStepRow(
            icon: Icons.rule_rounded,
            title: '1. 운영자 승인',
            body: '학생 요청만으로 CCTV를 바로 분석하지 않고, 기숙사/학교 운영자가 승인합니다.',
          ),
          SizedBox(height: 9),
          _DormCctvStepRow(
            icon: Icons.videocam_rounded,
            title: '2. 제한된 RTSP 접근',
            body: '허가된 카메라와 시간대만 백엔드에서 접근합니다. 앱에는 RTSP 주소를 노출하지 않습니다.',
          ),
          SizedBox(height: 9),
          _DormCctvStepRow(
            icon: Icons.center_focus_strong_rounded,
            title: '3. YOLO 물건 후보 탐지',
            body: '사람 신원 식별이 아니라 이어폰, 가방, 우산, 텀블러 같은 물건 후보만 탐지합니다.',
          ),
          SizedBox(height: 9),
          _DormCctvStepRow(
            icon: Icons.privacy_tip_rounded,
            title: '4. 결과 요약만 제공',
            body: '얼굴, 동선, 개인 영상이 아니라 “어느 시간대에 유사 물건 후보가 있음” 정도만 안내합니다.',
          ),
        ],
      ),
    );
  }
}

class _DormCctvStepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _DormCctvStepRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.blue, size: 25),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 12.3,
                  fontWeight: FontWeight.w700,
                  height: 1.38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DormCctvPolicyCard extends StatelessWidget {
  const _DormCctvPolicyCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.gpp_maybe_rounded, color: Color(0xFFE11D48), size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '주의: 이 기능은 실제 CCTV를 직접 연결하지 않는 베타 요청 화면입니다. 얼굴 인식, 사람 추적, 개인 동선 분석은 하지 않는 방향이 맞습니다. 실제 연동은 학교/기숙사 승인, 접근 로그, 보관 기간, 목적 제한이 정해진 뒤에만 진행해야 합니다.',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DormCctvRequestHistoryCard extends StatelessWidget {
  final List<String> requests;

  const _DormCctvRequestHistoryCard({required this.requests});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '내 요청 기록',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${requests.length}건',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (requests.isEmpty)
            const Text(
              '아직 AI 확인 요청이 없습니다.',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...requests.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DormCctvRequestTile(text: e),
              );
            }),
        ],
      ),
    );
  }
}

class _DormCctvRequestTile extends StatelessWidget {
  final String text;

  const _DormCctvRequestTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pending_actions_rounded,
            color: AppColors.blue,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NasemiAiSettingsStore {
  static const String endpointKey = 'nasemi_ai_endpoint';

  static Future<String> loadEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(endpointKey) ?? 'http://10.0.2.2:8000/chat';
  }

  static Future<void> saveEndpoint(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(endpointKey, value.trim());
  }
}

class _NasemiAiShortcutCard extends StatelessWidget {
  const _NasemiAiShortcutCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NasemiAiScreen()),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: AppColors.blue,
                  size: 35,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '배재SLM AI 상담',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '학식, 학과, 분실물, 동아리 정보를 AI가 안내하는 모듈입니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class NasemiAiScreen extends StatelessWidget {
  const NasemiAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _DetailTopBar(title: '배재SLM AI 상담'),
            SizedBox(height: 18),
            _FundingLockedNoticeCard(
              icon: Icons.smart_toy_rounded,
              title: '배재SLM AI 상담 잠금',
              body:
                  'AI 상담은 모델 서버, 문서 검색 서버, 운영 로그 관리 비용이 필요합니다. 2단계 사비 베타에서는 실제 AI 응답을 제공하지 않고, 학교 지원 서버 또는 운영 예산 확보 후 활성화합니다.',
              badge: '잠금',
            ),
            SizedBox(height: 12),
            _FundingLockedNoticeCard(
              icon: Icons.hub_rounded,
              title: '확장 예정 구조',
              body:
                  '학생식당, 학과백과, 동아리 도감, 분실물, 나섬이 도감을 자연어로 묶는 캠퍼스 AI 허브로 확장할 예정입니다.',
              badge: '예정',
            ),
            SizedBox(height: 12),
            _FundingLockedNoticeCard(
              icon: Icons.privacy_tip_rounded,
              title: '보안 검토 필요',
              body:
                  'AI 상담 로그, 개인정보 입력, 공식 답변 오해 가능성이 있어 개인정보 처리방침과 학교 검토가 끝난 뒤 제한적으로 열어야 합니다.',
              badge: '검토',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HomeSecondaryFeatureButton(
            icon: Icons.school_rounded,
            title: '학과백과',
            body: '학과 소개',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CollectionScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _HomeSecondaryFeatureButton(
            icon: Icons.manage_search_rounded,
            title: '분실물',
            body: '습득 확인',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LostFoundScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _HomeSecondaryFeatureButton(
            icon: Icons.groups_rounded,
            title: '동아리',
            body: '공식 목록',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecruitScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureLockedFundingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String badge;

  const _FeatureLockedFundingCard({
    required this.icon,
    required this.title,
    required this.body,
    this.badge = '지원 필요',
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFFB45309), size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4D6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage2BetaModeCard extends StatelessWidget {
  const _Stage2BetaModeCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.savings_rounded,
              color: AppColors.blue,
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2단계 베타 운영 모드',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 17.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '사비 운영 가능한 범위로 학생식당, 학과백과, 동아리, 분실물, 이메일 인증을 우선 제공합니다. AI와 영상분석은 지원 확보 전까지 잠금 상태입니다.',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Stage2Pill(text: '월 1~3만 원 목표'),
                    _Stage2Pill(text: 'AI 잠금'),
                    _Stage2Pill(text: 'YOLO 잠금'),
                    _Stage2Pill(text: '기본 기능 우선'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stage2Pill extends StatelessWidget {
  final String text;

  const _Stage2Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.blue,
          fontSize: 10.8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FundingLockedNoticeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String badge;

  const _FundingLockedNoticeCard({
    required this.icon,
    required this.title,
    required this.body,
    this.badge = '지원 필요',
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(icon, color: const Color(0xFFB45309), size: 30),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4D6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCompactToolsSection extends StatelessWidget {
  const _HomeCompactToolsSection();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '보조 기능',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'QR, AI, 캠퍼스맵은 필요할 때만 빠르게 열 수 있게 줄였습니다.',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 12.3,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
            children: [
              _MiniToolButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'QR',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MissionScreen()),
                  );
                },
              ),
              _MiniToolButton(
                icon: Icons.smart_toy_rounded,
                label: 'AI',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('배재SLM AI는 학교 서버/운영 지원 확보 후 제공 예정입니다.'),
                    ),
                  );
                },
              ),
              _MiniToolButton(
                icon: Icons.map_rounded,
                label: '맵',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CollectionScreen(initialTab: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBBD7FF)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.blue, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampusAlertCard extends StatelessWidget {
  const _CampusAlertCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Text('🚨', style: TextStyle(fontSize: 34)),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '캠퍼스 경보',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  '안전 · 날씨 · 공지 정보를 확인하세요',
                  style: TextStyle(color: AppColors.sub, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Color(0xFF64748B)),
        ],
      ),
    );
  }
}

class CafeteriaScreen extends StatelessWidget {
  const CafeteriaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CafeteriaTopBar(),
            SizedBox(height: 18),
            Text(
              '학생식당 / CityBrain',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                height: 1.08,
              ),
            ),
            SizedBox(height: 7),
            Text(
              '메뉴 · 혼잡도 확인하고 스마트하게 이용해요',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.sub,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20),
            _CafeteriaMainHero(),
            SizedBox(height: 14),
            _CafeteriaCrowdStatus(),
            SizedBox(height: 14),
            _CafeteriaFeatureGrid(),
            SizedBox(height: 14),
            _LunchPredictionCard(),
            SizedBox(height: 16),
            const _TodayDietPreviewSection(),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _CafeteriaTopBar extends StatelessWidget {
  const _CafeteriaTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 24),
        ),
        const SizedBox(width: 2),
        const _BrandTitle(),
        const Spacer(),
        const Icon(Icons.notifications_none_rounded, size: 27),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFFFD48A),
          backgroundImage: AssetImage(Assets.nasemiAvatar),
        ),
      ],
    );
  }
}

class _CafeteriaMainHero extends StatelessWidget {
  const _CafeteriaMainHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: _AssetImage(path: Assets.cafeteriaHero, fit: BoxFit.cover),
            ),

            // 왼쪽 텍스트 가독성 보정
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(.92),
                      Colors.white.withOpacity(.72),
                      Colors.white.withOpacity(.12),
                    ],
                    stops: const [0.0, 0.42, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 20,
              top: 22,
              right: 145,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22006BFF),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '오늘의 메뉴',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '현미밥, 김치찌개,\n돈육간장불고기,',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                      height: 1.2,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '오이무침, 배추김치',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.sub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Text(
                    '5,000원',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 13),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 17,
                        color: AppColors.sub,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '알레르기 정보 확인하기',
                        style: TextStyle(
                          color: AppColors.sub,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.sub,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              right: 16,
              top: 16,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.96),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: _AssetImage(path: Assets.logoP, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CafeteriaCrowdStatus extends StatelessWidget {
  const _CafeteriaCrowdStatus();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '실시간 혼잡도',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.sub,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.sub,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '혼잡도 여유',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '보다 쾌적하게 이용할 수 있어요.',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FFF1),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF16A34A),
                  size: 38,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '09:41 기준',
                style: TextStyle(
                  color: AppColors.sub,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayDietPreviewSection extends StatelessWidget {
  const _TodayDietPreviewSection();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '오늘의 메뉴',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CafeteriaWeeklyDietPage(),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      '전체 식단',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.blue,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '배재대학교 공식 식단 기준 · 베타 표시',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.blue,
                  size: 29,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '중식 · 11:00~13:30',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '쌀밥 · 근대된장국 · 묵은지돈사태찜 · 연두부*양념장 · 건파래볶음 · 깍두기',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '940kcal',
                      style: TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CafeteriaWeeklyDietPage extends StatelessWidget {
  const CafeteriaWeeklyDietPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _DetailTopBar(title: '오늘의 메뉴'),
            SizedBox(height: 16),
            Text(
              '이번 주 공식 식단',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                height: 1.08,
              ),
            ),
            SizedBox(height: 7),
            Text(
              '월~금 조식 · 중식 · 석식을 한눈에 확인해요',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.sub,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 18),
            _WeeklyDietSection(),
            SizedBox(height: 12),
            _BetaBanner(),
          ],
        ),
      ),
    );
  }
}

class _WeeklyDietSection extends StatefulWidget {
  const _WeeklyDietSection();

  @override
  State<_WeeklyDietSection> createState() => _WeeklyDietSectionState();
}

class _WeeklyDietSectionState extends State<_WeeklyDietSection> {
  int selectedDay = 1;

  static const days = ['월', '화', '수', '목', '금'];

  static const menus = {
    0: {
      '조식': ['석가탄신일 대체휴일'],
      '중식': ['메뉴 준비중입니다.'],
      '석식': ['메뉴 준비중입니다.'],
    },
    1: {
      '조식': ['쌀밥', '감자수제비국', '깐풍치킨볼', '고추장쥐어채볶음', '맛김치', '도시락김', '1050kcal'],
      '중식': ['쌀밥', '근대된장국', '묵은지돈사태찜', '연두부*양념장', '건파래볶음', '깍두기', '940kcal'],
      '석식': [
        '쌀밥',
        '등촌샤브샤브국',
        '슈프림탕수육',
        '청포묵무침',
        '치커리무침',
        '맛김치',
        '야채샐러드',
        '1180kcal',
      ],
    },
    2: {
      '조식': ['간장계란밥', '새알심단호박죽', '비엔나야채볶음', '참나물겉절이', '맛김치', '짜요짜요', '970kcal'],
      '중식': [
        '쌀밥',
        '쫄데기고추장찌개',
        '명란떡갈비',
        '죽순표고버섯볶음',
        '오이탕탕이무침',
        '맛김치',
        '880kcal',
      ],
      '석식': [
        '[볶음밥DAY]',
        '시래기국',
        '닭살데리야끼볶음밥',
        '피쉬앤칩스',
        '단무지부추무침',
        '맛김치',
        '야채샐러드',
        '1190kcal',
      ],
    },
    3: {
      '조식': ['쌀밥', '큰)들깨순대국밥', '잡채어묵조림', '양념깻잎지', '깍두기', '요거톡', '1140kcal'],
      '중식': [
        '쌀밥',
        '떙초바지락탕',
        '안동식순살찜닭*당면',
        '맛살겨자냉채',
        '마늘쫑무침',
        '맛김치',
        '1120kcal',
      ],
      '석식': [
        '쌀밥',
        '콩나물국',
        '바몬드카레라이스',
        '네기타코야끼',
        '미역초무침',
        '맛김치',
        '야채샐러드',
        '1090kcal',
      ],
    },
    4: {
      '조식': [
        '[배재배이커리]',
        '콘푸라이트씨리얼',
        '이삭st햄치즈토스트',
        '흰우유',
        '복숭아워터젤리',
        '야채샐러드',
        '810kcal',
      ],
      '중식': ['쌀밥', '미소장국', '돈육두부두루치기', '사모사튀김', '상추겉절이', '맛김치', '1040kcal'],
      '석식': [
        '[누들day]',
        '적은쌀밥',
        '한신ST유부우동',
        '오징어핫바&칠리S',
        '양념고추지',
        '맛김치',
        '음료',
        '860kcal',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final dayMenus = menus[selectedDay] ?? menus[1]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        Row(
          children: [
            const Text(
              '이번 주 공식 식단',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: openOfficialDietPage,
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text(
                '원문',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '배재대학교 금주의 식단 기준 · 매주 월요일 갱신',
          style: TextStyle(
            color: AppColors.sub,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(days.length, (i) {
            final selected = selectedDay == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDay = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: EdgeInsets.only(right: i == days.length - 1 ? 0 : 8),
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selected ? AppColors.blue : AppColors.line,
                    ),
                    boxShadow: selected
                        ? const [
                            BoxShadow(
                              color: Color(0x1A006BFF),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      days[i],
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.sub,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        _DietMealCard(
          title: '조식',
          time: '08:00~09:00',
          items: dayMenus['조식']!,
          icon: Icons.wb_sunny_rounded,
        ),
        const SizedBox(height: 10),
        _DietMealCard(
          title: '중식',
          time: '11:00~13:30',
          items: dayMenus['중식']!,
          icon: Icons.restaurant_rounded,
        ),
        const SizedBox(height: 10),
        _DietMealCard(
          title: '석식',
          time: '17:30~19:00',
          items: dayMenus['석식']!,
          icon: Icons.nightlight_round,
        ),
      ],
    );
  }
}

class _DietMealCard extends StatelessWidget {
  final String title;
  final String time;
  final List<String> items;
  final IconData icon;

  const _DietMealCard({
    required this.title,
    required this.time,
    required this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final kcal = items.isNotEmpty && items.last.contains('kcal')
        ? items.last
        : null;
    final menuItems = kcal == null ? items : items.sublist(0, items.length - 1);

    return _Card(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.blue, size: 28),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.sub,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (kcal != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4D6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          kcal,
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  menuItems.join(' · '),
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CafeteriaFeatureGrid extends StatelessWidget {
  const _CafeteriaFeatureGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 11,
      crossAxisSpacing: 11,
      childAspectRatio: 1.42,
      children: [
        _CafeteriaFeatureCard(
          title: '오늘의 메뉴',
          body: '일자별 메뉴와 영양 정보를\n확인해 보세요.',
          icon: Icons.restaurant_menu_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CafeteriaWeeklyDietPage(),
              ),
            );
          },
        ),
        _CafeteriaFeatureCard(
          title: '혼잡도 추정',
          body: '오늘의 시간대별 혼잡도를\n예측해 드려요.',
          icon: Icons.bar_chart_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CafeteriaSubPage(
                  title: '혼잡도 추정',
                  subtitle: '시간대별 학생 체감 혼잡도를 확인하는 화면입니다.',
                  icon: Icons.bar_chart_rounded,
                ),
              ),
            );
          },
        ),
        _CafeteriaFeatureCard(
          title: '만족도 투표',
          body: '오늘 메뉴가 어땠나요?\n의견을 들려주세요.',
          icon: Icons.chat_bubble_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CafeteriaSubPage(
                  title: '만족도 투표',
                  subtitle: '오늘 메뉴에 대한 학생 의견을 남기는 화면입니다.',
                  icon: Icons.chat_bubble_rounded,
                ),
              ),
            );
          },
        ),
        _CafeteriaFeatureCard(
          title: '운영 리포트 미리보기',
          body: '주간 운영 현황과 데이터를\n한눈에 확인하세요.',
          icon: Icons.pie_chart_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CafeteriaSubPage(
                  title: '운영 리포트 미리보기',
                  subtitle: '학생식당 운영 데이터와 시범 통계를 보는 화면입니다.',
                  icon: Icons.pie_chart_rounded,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CafeteriaFeatureCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final VoidCallback? onTap;

  const _CafeteriaFeatureCard({
    required this.title,
    required this.body,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEAF0FA), width: .8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                right: 54,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        height: 1.13,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      body,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.2,
                        fontWeight: FontWeight.w700,
                        height: 1.34,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08006BFF),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: AppColors.blue, size: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LunchPredictionCard extends StatelessWidget {
  const _LunchPredictionCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '점심시간 혼잡도 예측',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              Spacer(),
              Text(
                '자세히 보기',
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.blue,
                size: 18,
              ),
            ],
          ),
          SizedBox(height: 18),
          _CrowdTimeline(),
        ],
      ),
    );
  }
}

class _CrowdTimeline extends StatelessWidget {
  const _CrowdTimeline();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('11시', '여유', const Color(0xFFA7E6A1)),
      ('11:30', '', const Color(0xFFA7E6A1)),
      ('12시', '혼잡', const Color(0xFFFF7A1A)),
      ('12:30', '', const Color(0xFFFFD45A)),
      ('13시', '', const Color(0xFFFFD45A)),
      ('13:30', '여유', const Color(0xFFA7E6A1)),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Column(
            children: [
              Text(
                item.$1,
                style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              Container(
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: item.$3,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.$2,
                style: TextStyle(
                  color: item.$2 == '혼잡'
                      ? const Color(0xFFFF7A1A)
                      : const Color(0xFF16A34A),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _OfficialDietButton extends StatelessWidget {
  const _OfficialDietButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: openOfficialDietPage,
        icon: const Icon(Icons.open_in_new_rounded, size: 25),
        label: const Text(
          '공식 식단 보기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  final String title;

  const _DetailTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 24),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CafeteriaSubPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const CafeteriaSubPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(title: title),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.9),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(icon, color: AppColors.blue, size: 38),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _Card(
              child: Text(
                '현재는 v5.0-beta 시범 화면입니다. 실제 데이터 연동 전까지는 UI 흐름 확인용으로 사용합니다.',
                style: TextStyle(
                  color: AppColors.sub,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionScreen extends StatefulWidget {
  final int initialTab;

  const CollectionScreen({super.key, this.initialTab = 0});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late int tab;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(),
            const SizedBox(height: 18),

            const Text(
              '캠퍼스 도감',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              '학과백과와 캠퍼스맵을 통해 나섬이를 수집해요',
              style: TextStyle(
                fontSize: 14.5,
                color: AppColors.sub,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  _CollectionSegmentButton(
                    text: '학과백과',
                    selected: tab == 0,
                    onTap: () => setState(() => tab = 0),
                  ),
                  _CollectionSegmentButton(
                    text: '캠퍼스맵',
                    selected: tab == 1,
                    onTap: () => setState(() => tab = 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            if (tab == 0) const _DepartmentEncyclopediaTab(),
            if (tab == 1) const _CampusMapDiscoveryTab(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CollectionSegmentButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _CollectionSegmentButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 42,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x12006BFF),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? AppColors.blue : AppColors.sub,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DepartmentEncyclopediaTab extends StatelessWidget {
  const _DepartmentEncyclopediaTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CollectionHero(),
        const SizedBox(height: 16),

        Row(
          children: const [
            Text(
              '학과백과',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            Spacer(),
            Text(
              '우선 구축',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _DepartmentCard(
          title: '디자인학부',
          subtitle: '작품 · 실습실 · 전시 · 진로 정보를 한눈에',
          tags: ['작품', '전시', '포트폴리오'],
          imagePath: Assets.collection,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DepartmentEncyclopediaDetailPage(
                  title: '디자인학부',
                  oneLine: '시각적 문제 해결과 창의적 표현을 배우는 학과',
                  keywords: ['디자인', '작품', '전시', '브랜딩', 'UX/UI'],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        _DepartmentCard(
          title: '컴퓨터공학과',
          subtitle: '소프트웨어 · 임베디드 · AI · 프로젝트 중심 소개',
          tags: ['개발', 'AI', '임베디드'],
          imagePath: Assets.nasemi,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DepartmentEncyclopediaDetailPage(
                  title: '컴퓨터공학과',
                  oneLine: '소프트웨어와 시스템 구현 역량을 기르는 학과',
                  keywords: ['프로그래밍', '백엔드', '앱', '임베디드', 'AI'],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),

        _DepartmentCard(
          title: '학과 추가 예정',
          subtitle: '교수님 인터뷰와 학과 자료를 바탕으로 순차 확장',
          tags: ['인터뷰', '검수', '확장'],
          imagePath: Assets.logoP,
          onTap: () {},
        ),

        const SizedBox(height: 20),
        Row(
          children: const [
            Text(
              '학과별 나섬이',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            Spacer(),
            Text(
              '1~33번',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: .74,
          children: const [
            _NasemiCollectionTile(
              name: '디자인학부',
              imagePath: Assets.collection,
              owned: true,
            ),
            _NasemiCollectionTile(
              name: '컴퓨터공학과',
              imagePath: Assets.nasemi,
              owned: true,
            ),
            _NasemiCollectionTile(
              name: 'AI·SW',
              imagePath: Assets.nasemi,
              owned: true,
            ),
            _NasemiCollectionTile(
              name: '게임공학',
              imagePath: Assets.recruit,
              owned: false,
            ),
            _NasemiCollectionTile(
              name: '간호학과',
              imagePath: Assets.logoP,
              owned: false,
            ),
            _NasemiCollectionTile(
              name: '추가 예정',
              imagePath: Assets.nasemi,
              owned: false,
            ),
          ],
        ),

        const SizedBox(height: 16),
        const _CollectionNoticeCard(),
      ],
    );
  }
}

class _CampusMapDiscoveryTab extends StatelessWidget {
  const _CampusMapDiscoveryTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _MapDiscoveryHero(),
        SizedBox(height: 16),
        _DailyCampusQuestSection(),
        SizedBox(height: 16),
        _TodaySpawnShortcutCard(compact: true),
        SizedBox(height: 20),
        _NasemiTodayHintSection(),
        SizedBox(height: 20),
        _MapSpawnPanel(),
        SizedBox(height: 20),
        _ProfessorNasemiSection(),
      ],
    );
  }
}

class _MapDiscoveryHero extends StatelessWidget {
  const _MapDiscoveryHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 182,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F6BFF), Color(0xFF8DD7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16006BFF),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '캠퍼스맵 탐색',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '지금 뜬\n나섬이를 찾아요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '시간 · 날씨 · 위치 조건으로 출현',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 104,
            height: 104,
            child: _AssetImage(path: Assets.nasemi, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _MapSpawnPanel extends StatelessWidget {
  const _MapSpawnPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              '근처 출현 이벤트',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            Spacer(),
            Text(
              'mock map',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const _CampusMapMock(),
        const SizedBox(height: 12),
        const _NearbySpawnCard(
          emoji: '🌙',
          title: '야간탐험 나섬이',
          place: '중앙도서관 ↔ 기숙사 동선',
          condition: '저녁 7시 이후 출현 확률 증가',
          rarity: '히든',
        ),
        const SizedBox(height: 10),
        const _NearbySpawnCard(
          emoji: '🎨',
          title: '포트폴리오형 나섬이',
          place: '디자인학부 전시 공간 근처',
          condition: '평일 오후 · 전시 기간 힌트 등장',
          rarity: '희귀',
        ),
        const SizedBox(height: 10),
        const _NearbySpawnCard(
          emoji: '📚',
          title: '이론정리형 나섬이',
          place: '도서관 열람실 주변',
          condition: '시험기간 출현 확률 증가',
          rarity: '희귀',
        ),
      ],
    );
  }
}

class _CampusMapMock extends StatefulWidget {
  const _CampusMapMock();

  @override
  State<_CampusMapMock> createState() => _CampusMapMockState();
}

class _CampusMapMockState extends State<_CampusMapMock> {
  LatLng? myLocation;
  String locationStatus = '내 위치를 확인하면 근처 나섬이 수집 가능 여부를 볼 수 있어요.';

  static final campusCenter = LatLng(36.3219, 127.3679);

  static final spawnMarkers = [
    _SpawnMapMarker(
      point: LatLng(36.3224, 127.3674),
      label: '도서관',
      emoji: '📚',
      active: true,
      nasemiName: '이론정리형 나섬이',
      condition: '도서관 주변 80m 이내',
    ),
    _SpawnMapMarker(
      point: LatLng(36.3215, 127.3687),
      label: '디자인',
      emoji: '🎨',
      active: true,
      nasemiName: '포트폴리오형 나섬이',
      condition: '디자인학부 거점 80m 이내',
    ),
    _SpawnMapMarker(
      point: LatLng(36.3212, 127.3676),
      label: '식당',
      emoji: '🍱',
      active: false,
      nasemiName: '학생식당 나섬이',
      condition: '식당 운영 시간대',
    ),
    _SpawnMapMarker(
      point: LatLng(36.3231, 127.3669),
      label: '기숙사',
      emoji: '🌙',
      active: true,
      nasemiName: '야간탐험 나섬이',
      condition: '저녁 7시 이후 + 기숙사 동선',
    ),
  ];

  Future<void> checkMyLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationStatus = '위치 서비스가 꺼져 있어요. 에뮬레이터/기기 위치 설정을 켜주세요.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          locationStatus = '위치 권한이 거부되어 거리 계산을 할 수 없어요.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationStatus = '위치 권한이 영구 거부됐어요. 앱 설정에서 권한을 허용해야 해요.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final loc = LatLng(pos.latitude, pos.longitude);

      final nearest = _nearestSpawn(loc);

      setState(() {
        myLocation = loc;
        if (nearest == null) {
          locationStatus = '근처 출현 지점을 계산했어요.';
        } else {
          final distance = _distanceMeters(loc, nearest.point);
          final canCollect = distance <= 80;
          locationStatus = canCollect
              ? '${nearest.nasemiName} 수집 가능 · 약 ${distance.round()}m'
              : '가장 가까운 나섬이: ${nearest.nasemiName} · 약 ${distance.round()}m';
        }
      });
    } catch (e) {
      setState(() {
        locationStatus =
            '위치 확인 중 오류가 발생했어요. 에뮬레이터 위치 설정을 확인하거나 지도 마커를 직접 눌러보세요.';
      });
    }
  }

  _SpawnMapMarker? _nearestSpawn(LatLng loc) {
    if (spawnMarkers.isEmpty) return null;

    _SpawnMapMarker nearest = spawnMarkers.first;
    double best = _distanceMeters(loc, nearest.point);

    for (final marker in spawnMarkers.skip(1)) {
      final d = _distanceMeters(loc, marker.point);
      if (d < best) {
        best = d;
        nearest = marker;
      }
    }

    return nearest;
  }

  double _distanceMeters(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  bool _canCollect(_SpawnMapMarker marker) {
    if (myLocation == null) return false;
    return _distanceMeters(myLocation!, marker.point) <= 80;
  }

  NasemiQrReward _rewardFromSpawnMarker(_SpawnMapMarker marker) {
    if (marker.nasemiName.contains('야간탐험')) {
      return const NasemiQrReward(
        no: 42,
        name: '야간탐험 나섬이',
        category: '히든',
        rarity: '히든',
        emoji: '🌙',
        message: '밤 시간대 캠퍼스 동선에서 발견했어요.',
        valid: true,
      );
    }

    if (marker.nasemiName.contains('포트폴리오')) {
      return const NasemiQrReward(
        no: 44,
        name: '포트폴리오형 나섬이',
        category: '수업',
        rarity: '희귀',
        emoji: '🎨',
        message: '디자인학부 전시 공간 근처에서 발견했어요.',
        valid: true,
      );
    }

    if (marker.nasemiName.contains('이론정리')) {
      return const NasemiQrReward(
        no: 37,
        name: '이론정리형 나섬이',
        category: '수업',
        rarity: '희귀',
        emoji: '📚',
        message: '도서관 주변 학습 구역에서 발견했어요.',
        valid: true,
      );
    }

    if (marker.nasemiName.contains('학생식당')) {
      return const NasemiQrReward(
        no: 39,
        name: '학생식당 나섬이',
        category: '장소',
        rarity: '장소',
        emoji: '🍱',
        message: '학생식당 주변에서 발견했어요.',
        valid: true,
      );
    }

    return NasemiQrReward(
      no: 99,
      name: marker.nasemiName,
      category: '이벤트',
      rarity: '희귀',
      emoji: marker.emoji,
      message: '${marker.label} 주변에서 발견했어요.',
      valid: true,
    );
  }

  void _openEncounterFromMarker(_SpawnMapMarker marker) {
    final reward = _rewardFromSpawnMarker(marker);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NasemiEncounterPage(
          reward: reward,
          place: marker.label,
          condition: marker.condition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = myLocation ?? campusCenter;

    return Container(
      height: 315,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDEBFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: 17,
                minZoom: 15,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.gxmzung.paejaepick',
                ),
                MarkerLayer(
                  markers: [
                    ...spawnMarkers.map((m) {
                      final canCollect = _canCollect(m);

                      return Marker(
                        point: m.point,
                        width: 118,
                        height: 58,
                        child: GestureDetector(
                          onTap: () => _openEncounterFromMarker(m),
                          child: _MapPinBubble(
                            label: canCollect ? '수집 가능' : m.label,
                            emoji: m.emoji,
                            active: m.active || canCollect,
                          ),
                        ),
                      );
                    }),
                    if (myLocation != null)
                      Marker(
                        point: myLocation!,
                        width: 52,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33006BFF),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_rounded,
                      color: AppColors.blue,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '배재 캠퍼스 탐색',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              right: 14,
              top: 14,
              child: GestureDetector(
                onTap: checkMyLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22006BFF),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '내 위치',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.96),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  locationStatus,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpawnMapMarker {
  final LatLng point;
  final String label;
  final String emoji;
  final bool active;
  final String nasemiName;
  final String condition;

  const _SpawnMapMarker({
    required this.point,
    required this.label,
    required this.emoji,
    required this.active,
    required this.nasemiName,
    required this.condition,
  });
}

class _MapPinBubble extends StatefulWidget {
  final String label;
  final String emoji;
  final bool active;

  const _MapPinBubble({
    required this.label,
    required this.emoji,
    required this.active,
  });

  @override
  State<_MapPinBubble> createState() => _MapPinBubbleState();
}

class _MapPinBubbleState extends State<_MapPinBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;
  late final Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );

    scale = Tween<double>(
      begin: .92,
      end: 1.12,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    opacity = Tween<double>(
      begin: .18,
      end: .42,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    if (widget.active) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _MapPinBubble oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active && !controller.isAnimating) {
      controller.repeat(reverse: true);
    } else if (!widget.active && controller.isAnimating) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return _StaticMapPinBubble(
        label: widget.label,
        emoji: widget.emoji,
        active: false,
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: scale.value,
              child: Container(
                width: 86,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(opacity.value),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -2 * (scale.value - 1)),
              child: _StaticMapPinBubble(
                label: widget.label,
                emoji: widget.emoji,
                active: true,
              ),
            ),
            Positioned(
              top: -18,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A1A),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  '출현',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StaticMapPinBubble extends StatelessWidget {
  final String label;
  final String emoji;
  final bool active;

  const _StaticMapPinBubble({
    required this.label,
    required this.emoji,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 7, 10, 7),
      decoration: BoxDecoration(
        color: active ? AppColors.blue : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: active ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 17)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.sub,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbySpawnCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String place;
  final String condition;
  final String rarity;

  const _NearbySpawnCard({
    required this.emoji,
    required this.title,
    required this.place,
    required this.condition,
    required this.rarity,
  });

  NasemiQrReward get reward {
    if (title.contains('야간탐험')) {
      return const NasemiQrReward(
        no: 42,
        name: '야간탐험 나섬이',
        category: '히든',
        rarity: '히든',
        emoji: '🌙',
        message: '밤 시간대 캠퍼스 동선에서 발견했어요.',
        valid: true,
      );
    }

    if (title.contains('포트폴리오')) {
      return const NasemiQrReward(
        no: 44,
        name: '포트폴리오형 나섬이',
        category: '수업',
        rarity: '희귀',
        emoji: '🎨',
        message: '디자인학부 전시 공간 근처에서 발견했어요.',
        valid: true,
      );
    }

    if (title.contains('이론정리')) {
      return const NasemiQrReward(
        no: 37,
        name: '이론정리형 나섬이',
        category: '수업',
        rarity: '희귀',
        emoji: '📚',
        message: '도서관 주변 학습 구역에서 발견했어요.',
        valid: true,
      );
    }

    return NasemiQrReward(
      no: 99,
      name: title,
      category: '이벤트',
      rarity: rarity,
      emoji: emoji,
      message: '캠퍼스맵 출현 이벤트에서 발견했어요.',
      valid: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NasemiEncounterPage(
                reward: reward,
                place: place,
                condition: condition,
              ),
            ),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      rarity,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.touch_app_rounded,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DepartmentEncyclopediaDetailPage extends StatelessWidget {
  final String title;
  final String oneLine;
  final List<String> keywords;

  const DepartmentEncyclopediaDetailPage({
    super.key,
    required this.title,
    required this.oneLine,
    required this.keywords,
  });

  _DepartmentProfile get profile {
    if (title.contains('디자인')) {
      return const _DepartmentProfile(
        title: '디자인학부',
        subtitle: '시각적 문제 해결과 창의적 표현을 배우는 학과',
        badge: '학과 검수 필요',
        emoji: '🎨',
        nasemiNo: 9,
        nasemiName: '디자인학부 나섬이',
        acquireHint: '디자인학부 전시 공간 또는 학과 게시판 근처 QR',
        keywords: ['디자인', '작품', '전시', '브랜딩', 'UX/UI', '포트폴리오'],
        learning: [
          '시각적으로 문제를 해석하고 표현하는 방법',
          '브랜드, 포스터, 편집, 콘텐츠, UX/UI 등 디자인 결과물 제작',
          '작품 기획부터 발표, 피드백, 수정까지 이어지는 작업 과정',
          '개인 포트폴리오와 전시 중심의 결과물 정리',
        ],
        spaces: ['전시/게시 공간', '디자인 실습실', '작업실/프로젝트 공간', '작품 촬영 및 포트폴리오 정리 공간'],
        careers: [
          '그래픽 디자이너',
          '브랜드 디자이너',
          'UX/UI 디자이너',
          '편집 디자이너',
          '콘텐츠 디자이너',
          '디자인 기획자',
        ],
        recommendedFor: [
          '결과물을 직접 만들고 보여주는 활동을 좋아하는 학생',
          '피드백을 받고 수정하면서 완성도를 높이는 과정에 익숙한 학생',
          '그림 실력만이 아니라 관찰, 기획, 표현에 관심 있는 학생',
        ],
        caution: '학생 작품을 앱에 넣을 경우 저작권, 학생 동의, 작품 선정 기준, 업데이트 주기를 반드시 확인해야 합니다.',
      );
    }

    if (title.contains('컴퓨터')) {
      return const _DepartmentProfile(
        title: '컴퓨터공학과',
        subtitle: '소프트웨어와 시스템 구현 역량을 기르는 학과',
        badge: '베타 초안',
        emoji: '💻',
        nasemiNo: 1,
        nasemiName: '컴퓨터공학과 나섬이',
        acquireHint: '컴퓨터공학과 학과 거점 또는 공학관 주변 QR',
        keywords: ['프로그래밍', '앱', '백엔드', 'AI', '임베디드', '프로젝트'],
        learning: [
          '프로그래밍 언어와 자료구조, 알고리즘 등 CS 기초',
          '앱, 웹, 서버, 데이터베이스를 활용한 소프트웨어 구현',
          'AI, 임베디드, 시스템, 네트워크 등 확장 분야 탐색',
          '팀 프로젝트와 포트폴리오 중심의 개발 경험 축적',
        ],
        spaces: ['강의실', '컴퓨터 실습실', '프로젝트 작업 공간', '동아리/팀 개발 공간'],
        careers: [
          '소프트웨어 개발자',
          '백엔드 개발자',
          '앱 개발자',
          '임베디드 개발자',
          'AI 개발자',
          '시스템 엔지니어',
        ],
        recommendedFor: [
          '문제를 코드로 해결하는 과정에 흥미가 있는 학생',
          '혼자 공부하는 시간과 팀 프로젝트를 모두 감당할 수 있는 학생',
          '앱, 로봇, AI, 서버 등 여러 분야를 직접 만들어보고 싶은 학생',
        ],
        caution: '기술 분야가 넓기 때문에 1학년 때부터 작은 프로젝트와 기초 CS를 함께 쌓는 것이 중요합니다.',
      );
    }

    return _DepartmentProfile(
      title: title,
      subtitle: oneLine,
      badge: '추가 예정',
      emoji: '🏫',
      nasemiNo: 0,
      nasemiName: '$title 나섬이',
      acquireHint: '학과 공식 거점 QR 등록 예정',
      keywords: keywords,
      learning: const [
        '학과 공식 자료와 교수님 인터뷰를 바탕으로 내용을 채울 예정입니다.',
        '전공 분야, 수업 특징, 실습 공간, 진로 정보를 학생 눈높이로 정리합니다.',
      ],
      spaces: const ['학과 사무실', '강의실', '실습 공간', '게시판/로비'],
      careers: const ['학과별 진로 정보 추가 예정'],
      recommendedFor: const ['학과 인터뷰 후 추천 성향을 정리할 예정입니다.'],
      caution: '현재는 베타 초안이며, 학과 확인 후 공개하는 것을 원칙으로 합니다.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = profile;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(title: data.title),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF94D8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.22),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(.28),
                            ),
                          ),
                          child: Text(
                            data.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          data.subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(.35),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        data.emoji,
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _DepartmentKeywordWrap(values: data.keywords),

            const SizedBox(height: 16),
            Row(
              children: [
                _DepartmentQuickFactChip(
                  icon: Icons.auto_awesome_rounded,
                  label: '나섬이',
                  value: data.nasemiNo > 0
                      ? "#${data.nasemiNo.toString().padLeft(3, '0')}"
                      : '예정',
                ),
                const SizedBox(width: 9),
                _DepartmentQuickFactChip(
                  icon: Icons.verified_rounded,
                  label: '정보 상태',
                  value: data.badge,
                ),
              ],
            ),

            const SizedBox(height: 16),
            _DepartmentContentBlock(
              title: '무엇을 배우나요?',
              icon: Icons.school_rounded,
              items: data.learning,
            ),
            const SizedBox(height: 10),
            _DepartmentContentBlock(
              title: '어떤 공간을 쓰나요?',
              icon: Icons.location_city_rounded,
              items: data.spaces,
            ),
            const SizedBox(height: 10),
            _DepartmentCareerGrid(careers: data.careers),
            const SizedBox(height: 10),
            _DepartmentContentBlock(
              title: '이런 학생에게 추천',
              icon: Icons.person_search_rounded,
              items: data.recommendedFor,
            ),
            const SizedBox(height: 10),
            _DepartmentNasemiAcquireCard(
              no: data.nasemiNo,
              name: data.nasemiName,
              hint: data.acquireHint,
              emoji: data.emoji,
            ),
            const SizedBox(height: 10),
            _DepartmentInterviewPreview(departmentName: data.title),
            const SizedBox(height: 10),

            _Card(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFB45309),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.caution,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const _BetaBanner(),
          ],
        ),
      ),
    );
  }
}

class _DepartmentProfile {
  final String title;
  final String subtitle;
  final String badge;
  final String emoji;
  final int nasemiNo;
  final String nasemiName;
  final String acquireHint;
  final List<String> keywords;
  final List<String> learning;
  final List<String> spaces;
  final List<String> careers;
  final List<String> recommendedFor;
  final String caution;

  const _DepartmentProfile({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.emoji,
    required this.nasemiNo,
    required this.nasemiName,
    required this.acquireHint,
    required this.keywords,
    required this.learning,
    required this.spaces,
    required this.careers,
    required this.recommendedFor,
    required this.caution,
  });
}

class _DepartmentKeywordWrap extends StatelessWidget {
  final List<String> values;

  const _DepartmentKeywordWrap({required this.values});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            e,
            style: const TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DepartmentQuickFactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DepartmentQuickFactChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue, size: 25),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentContentBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _DepartmentContentBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.blue, size: 27),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ...items.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DepartmentCareerGrid extends StatelessWidget {
  final List<String> careers;

  const _DepartmentCareerGrid({required this.careers});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.work_rounded, color: AppColors.blue, size: 27),
              SizedBox(width: 9),
              Text(
                '졸업 후 진로',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: careers
                .map((e) => _DepartmentCareerPill(text: e))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCareerPill extends StatelessWidget {
  final String text;

  const _DepartmentCareerPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DepartmentNasemiAcquireCard extends StatelessWidget {
  final int no;
  final String name;
  final String hint;
  final String emoji;

  const _DepartmentNasemiAcquireCard({
    required this.no,
    required this.name,
    required this.hint,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  no > 0 ? '#${no.toString().padLeft(3, '0')} $name' : name,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hint,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.qr_code_2_rounded, color: AppColors.blue, size: 28),
        ],
      ),
    );
  }
}

class _DepartmentInterviewPreview extends StatelessWidget {
  final String departmentName;

  const _DepartmentInterviewPreview({required this.departmentName});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.forum_rounded, color: AppColors.blue, size: 27),
              SizedBox(width: 9),
              Text(
                '인터뷰로 채울 항목',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const _DepartmentQuestionTile(text: '학과를 한 문장으로 소개한다면?'),
          const _DepartmentQuestionTile(text: '신입생이 가장 먼저 알아야 할 점은?'),
          const _DepartmentQuestionTile(text: '학과를 대표하는 공간이나 활동은?'),
          const _DepartmentQuestionTile(text: '학과 나섬이 캐릭터에 어울리는 상징은?'),
        ],
      ),
    );
  }
}

class _DepartmentQuestionTile extends StatelessWidget {
  final String text;

  const _DepartmentQuestionTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.help_outline_rounded,
            color: AppColors.blue,
            size: 18,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentInfoBlock extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _DepartmentInfoBlock({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.blue, size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionHero extends StatelessWidget {
  const _CollectionHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 194,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16006BFF),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '학과백과 우선 구축',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '학과를 알고,\n캠퍼스를 모으다',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '학과 소개 + 학과별 나섬이 + 수업 스타일 나섬이',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 104,
            height: 104,
            child: _AssetImage(path: Assets.collection, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> tags;
  final String imagePath;
  final VoidCallback onTap;

  const _DepartmentCard({
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: _Card(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: _AssetImage(path: imagePath, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            e,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class _NasemiCollectionTile extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool owned;

  const _NasemiCollectionTile({
    required this.name,
    required this.imagePath,
    required this.owned,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: owned ? 1 : .42,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: owned ? const Color(0xFFEAF0FA) : const Color(0xFFE2E8F0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 62,
              height: 56,
              child: _AssetImage(path: imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 7),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              owned ? '수집 완료' : '미수집',
              style: TextStyle(
                color: owned ? AppColors.blue : AppColors.sub,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyCampusQuestSection extends StatefulWidget {
  const _DailyCampusQuestSection();

  @override
  State<_DailyCampusQuestSection> createState() =>
      _DailyCampusQuestSectionState();
}

class _DailyCampusQuestSectionState extends State<_DailyCampusQuestSection> {
  static const String dateKey = 'daily_quest_date';
  static const String progressKey = 'daily_quest_progress';
  static const String claimedKey = 'daily_quest_claimed';

  Set<int> progress = {};
  bool claimed = false;

  String get todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  @override
  void initState() {
    super.initState();
    _loadQuest();
  }

  Future<void> _loadQuest() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(dateKey);

    if (savedDate != todayKey) {
      await prefs.setString(dateKey, todayKey);
      await prefs.setStringList(progressKey, ['1']);
      await prefs.setBool(claimedKey, false);

      if (!mounted) return;
      setState(() {
        progress = {1};
        claimed = false;
      });
      return;
    }

    final values = prefs.getStringList(progressKey) ?? ['1'];
    final loaded = values.map((e) => int.tryParse(e)).whereType<int>().toSet();

    if (!mounted) return;
    setState(() {
      progress = loaded.isEmpty ? {1} : loaded;
      claimed = prefs.getBool(claimedKey) ?? false;
    });
  }

  Future<void> _toggleStep(int step) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (progress.contains(step)) {
        progress.remove(step);
      } else {
        progress.add(step);
      }
    });

    await prefs.setStringList(
      progressKey,
      progress.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _claimReward() async {
    if (progress.length < 3 || claimed) return;

    await NasemiCollectionStore.add(98);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claimedKey, true);

    if (!mounted) return;

    setState(() {
      claimed = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('오늘의 탐험가 나섬이가 도감에 등록됐어요.')));
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = progress.length.clamp(0, 3);
    final completed = doneCount >= 3;

    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '오늘의 탐색 퀘스트',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFE8FFF1)
                      : const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$doneCount / 3',
                  style: TextStyle(
                    color: completed ? const Color(0xFF16A34A) : AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '하루 한 번 캠퍼스를 탐색하고 보상 나섬이를 얻어요.',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          _DailyQuestRow(
            checked: progress.contains(1),
            title: '캠퍼스맵 열기',
            body: '오늘의 출현 지점을 확인했어요.',
            onTap: () => _toggleStep(1),
          ),
          const SizedBox(height: 9),
          _DailyQuestRow(
            checked: progress.contains(2),
            title: '근처 출현 이벤트 확인',
            body: '지도 위에 뜬 나섬이 힌트를 확인해요.',
            onTap: () => _toggleStep(2),
          ),
          const SizedBox(height: 9),
          _DailyQuestRow(
            checked: progress.contains(3),
            title: '나섬이 1종 수집',
            body: 'QR 스캔 또는 조우 화면으로 수집해요.',
            onTap: () => _toggleStep(3),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: completed && !claimed ? _claimReward : null,
              icon: Icon(
                claimed
                    ? Icons.check_circle_rounded
                    : Icons.card_giftcard_rounded,
                size: 22,
              ),
              label: Text(
                claimed
                    ? '오늘 보상 수령 완료'
                    : completed
                    ? '오늘의 탐험가 나섬이 받기'
                    : '퀘스트 완료 후 보상 수령',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuestRow extends StatelessWidget {
  final bool checked;
  final String title;
  final String body;
  final VoidCallback onTap;

  const _DailyQuestRow({
    required this.checked,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: checked ? const Color(0xFFEAF3FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: checked
                  ? const Color(0xFFBBD7FF)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                checked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: checked ? AppColors.blue : AppColors.sub,
                size: 24,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NasemiTodayHintSection extends StatelessWidget {
  const _NasemiTodayHintSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    final isNight = hour >= 19 || hour <= 6;
    final isWeekend =
        weekday == DateTime.saturday || weekday == DateTime.sunday;

    final mainHint = isNight
        ? '야간탐험 나섬이가 나타날 가능성이 있어요.'
        : isWeekend
        ? '주말에는 캠퍼스 장소 나섬이 발견 확률이 올라가요.'
        : '평일 수업 시간대에는 수업 스타일 나섬이를 찾아볼 수 있어요.';

    final recommended = isNight
        ? _NasemiSpawnRule(
            name: '야간탐험 나섬이',
            category: '히든',
            condition: '저녁 7시 이후 · 캠퍼스 주요 동선',
            emoji: '🌙',
          )
        : isWeekend
        ? _NasemiSpawnRule(
            name: '중앙도서관 나섬이',
            category: '장소',
            condition: '주말 · 도서관 주변 QR',
            emoji: '🏛️',
          )
        : _NasemiSpawnRule(
            name: '프로젝트형 나섬이',
            category: '수업',
            condition: '평일 · 학과 건물 주변 · 프로젝트 수업 키워드',
            emoji: '🚀',
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              '오늘의 발견 힌트',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            Spacer(),
            Text(
              '조건부 출현',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F6BFF), Color(0xFF8DD7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16006BFF),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _HintChip(text: '${hour.toString().padLeft(2, '0')}:00 기준'),
                  _HintChip(text: isWeekend ? '주말' : '평일'),
                  const _HintChip(text: '날씨 연동 예정'),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                mainHint,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.94),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Row(
                  children: [
                    Text(
                      recommended.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommended.name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            recommended.condition,
                            style: const TextStyle(
                              color: AppColors.sub,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        recommended.category,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NasemiSpawnRule {
  final String name;
  final String category;
  final String condition;
  final String emoji;

  const _NasemiSpawnRule({
    required this.name,
    required this.category,
    required this.condition,
    required this.emoji,
  });
}

class _HintChip extends StatelessWidget {
  final String text;

  const _HintChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.28)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ProfessorNasemiSection extends StatefulWidget {
  const _ProfessorNasemiSection();

  @override
  State<_ProfessorNasemiSection> createState() =>
      _ProfessorNasemiSectionState();
}

class _ProfessorNasemiSectionState extends State<_ProfessorNasemiSection> {
  String selected = '전체';
  String statusFilter = '전체';
  String rarityFilter = '전체';

  Set<int> collectedNumbers = {};

  static const categories = ['전체', '학과', '수업', '장소', '이벤트', '히든', '동아리'];
  static const statusFilters = ['전체', '수집완료', '미수집'];
  static const rarityFilters = ['전체', '기본', '희귀', '장소', '한정', '히든', '전설'];

  static const items = [
    // 1~33: 학과 기본 나섬이. 학과 공식 거점 QR로 확정 수집.
    _NasemiDexItem(
      no: 1,
      name: '컴퓨터공학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '컴퓨터공학과 학과 거점 QR',
      emoji: '💻',
      owned: true,
    ),
    _NasemiDexItem(
      no: 2,
      name: 'AI소프트웨어공학부 나섬이',
      category: '학과',
      rarity: '기본',
      hint: 'AI·SW 학과 거점 QR',
      emoji: '🤖',
      owned: true,
    ),
    _NasemiDexItem(
      no: 3,
      name: '게임공학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '게임/콘텐츠 실습 공간 QR',
      emoji: '🎮',
      owned: false,
    ),
    _NasemiDexItem(
      no: 4,
      name: '전기전자공학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '공학 계열 학과 거점 QR',
      emoji: '⚡',
      owned: false,
    ),
    _NasemiDexItem(
      no: 5,
      name: '드론철도건설공학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '드론·건설 계열 학과 거점 QR',
      emoji: '🚁',
      owned: false,
    ),
    _NasemiDexItem(
      no: 6,
      name: '스마트배터리학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '에너지/배터리 학과 거점 QR',
      emoji: '🔋',
      owned: false,
    ),
    _NasemiDexItem(
      no: 7,
      name: '건축학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '건축학과 학과 거점 QR',
      emoji: '🏗️',
      owned: false,
    ),
    _NasemiDexItem(
      no: 8,
      name: '실내건축학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '실내건축 관련 실습 공간 QR',
      emoji: '🛋️',
      owned: false,
    ),

    _NasemiDexItem(
      no: 9,
      name: '디자인학부 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '디자인학부 전시/게시 공간 QR',
      emoji: '🎨',
      owned: true,
    ),
    _NasemiDexItem(
      no: 10,
      name: '아트앤웹툰학부 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '작품 전시/실습 공간 QR',
      emoji: '🖌️',
      owned: false,
    ),
    _NasemiDexItem(
      no: 11,
      name: '공연예술학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '공연·연습 공간 QR',
      emoji: '🎭',
      owned: false,
    ),
    _NasemiDexItem(
      no: 12,
      name: '레저스포츠학부 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '운동장/스포츠 관련 거점 QR',
      emoji: '⚽',
      owned: false,
    ),

    _NasemiDexItem(
      no: 13,
      name: '간호학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '간호학과 실습/학과 거점 QR',
      emoji: '🩺',
      owned: false,
    ),
    _NasemiDexItem(
      no: 14,
      name: '바이오의약학부 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '바이오·의약 관련 학과 거점 QR',
      emoji: '🧬',
      owned: false,
    ),
    _NasemiDexItem(
      no: 15,
      name: '식품영양학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '식품영양학과 학과 거점 QR',
      emoji: '🥗',
      owned: false,
    ),
    _NasemiDexItem(
      no: 16,
      name: '원예산림학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '원예·산림 관련 학과 거점 QR',
      emoji: '🌱',
      owned: false,
    ),

    _NasemiDexItem(
      no: 17,
      name: '경영학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '경영학과 학과 거점 QR',
      emoji: '📊',
      owned: false,
    ),
    _NasemiDexItem(
      no: 18,
      name: '무역물류경영학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '무역·물류 학과 거점 QR',
      emoji: '🚢',
      owned: false,
    ),
    _NasemiDexItem(
      no: 19,
      name: '관광경영학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '관광경영학과 학과 거점 QR',
      emoji: '✈️',
      owned: false,
    ),
    _NasemiDexItem(
      no: 20,
      name: '호텔항공경영학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '호텔·항공 관련 학과 거점 QR',
      emoji: '🏨',
      owned: false,
    ),
    _NasemiDexItem(
      no: 21,
      name: '항공서비스학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '항공서비스 학과 거점 QR',
      emoji: '🛫',
      owned: false,
    ),

    _NasemiDexItem(
      no: 22,
      name: '경찰법학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '경찰법학과 학과 거점 QR',
      emoji: '⚖️',
      owned: false,
    ),
    _NasemiDexItem(
      no: 23,
      name: '행정학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '행정학과 학과 거점 QR',
      emoji: '🏛️',
      owned: false,
    ),
    _NasemiDexItem(
      no: 24,
      name: '심리상담학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '심리상담학과 학과 거점 QR',
      emoji: '🧠',
      owned: false,
    ),
    _NasemiDexItem(
      no: 25,
      name: '사회복지학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '사회복지학과 학과 거점 QR',
      emoji: '🤝',
      owned: false,
    ),
    _NasemiDexItem(
      no: 26,
      name: '유아교육과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '유아교육과 학과 거점 QR',
      emoji: '🧸',
      owned: false,
    ),

    _NasemiDexItem(
      no: 27,
      name: '국어국문한국어교육학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '국어·한국어교육 학과 거점 QR',
      emoji: '📖',
      owned: false,
    ),
    _NasemiDexItem(
      no: 28,
      name: '영어과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '영어과 학과 거점 QR',
      emoji: '🗣️',
      owned: false,
    ),
    _NasemiDexItem(
      no: 29,
      name: '중국통상학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '중국통상학과 학과 거점 QR',
      emoji: '🌏',
      owned: false,
    ),
    _NasemiDexItem(
      no: 30,
      name: '일본학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '일본학과 학과 거점 QR',
      emoji: '🗾',
      owned: false,
    ),
    _NasemiDexItem(
      no: 31,
      name: '기독교사회복지학과 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '학과 공식 거점 QR',
      emoji: '🕊️',
      owned: false,
    ),

    _NasemiDexItem(
      no: 32,
      name: '글로벌자율융합학부 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '융합학부 학과 거점 QR',
      emoji: '🧩',
      owned: false,
    ),
    _NasemiDexItem(
      no: 33,
      name: '자유전공학부 나섬이',
      category: '학과',
      rarity: '기본',
      hint: '자유전공학부 학과 거점 QR',
      emoji: '🧭',
      owned: false,
    ),

    // 34번 이후: 교수님/수업 스타일, 장소, 이벤트, 히든 나섬이.
    _NasemiDexItem(
      no: 34,
      name: '실습형 나섬이',
      category: '수업',
      rarity: '희귀',
      hint: '손으로 만들고 확인하는 수업 스타일',
      emoji: '🛠️',
      owned: true,
    ),
    _NasemiDexItem(
      no: 35,
      name: '피드백형 나섬이',
      category: '수업',
      rarity: '희귀',
      hint: '수정 방향과 코멘트 중심',
      emoji: '💬',
      owned: false,
    ),
    _NasemiDexItem(
      no: 36,
      name: '프로젝트형 나섬이',
      category: '수업',
      rarity: '희귀',
      hint: '팀 작업과 결과물 중심',
      emoji: '🚀',
      owned: false,
    ),
    _NasemiDexItem(
      no: 37,
      name: '이론정리형 나섬이',
      category: '수업',
      rarity: '희귀',
      hint: '개념을 차근차근 정리',
      emoji: '📚',
      owned: false,
    ),
    _NasemiDexItem(
      no: 38,
      name: '중앙도서관 나섬이',
      category: '장소',
      rarity: '장소',
      hint: '도서관 방문 QR',
      emoji: '🏛️',
      owned: true,
    ),
    _NasemiDexItem(
      no: 39,
      name: '학생식당 나섬이',
      category: '장소',
      rarity: '장소',
      hint: '식당 이용 시간대',
      emoji: '🍱',
      owned: true,
    ),
    _NasemiDexItem(
      no: 40,
      name: '벚꽃 나섬이',
      category: '이벤트',
      rarity: '한정',
      hint: '봄 시즌 캠퍼스 산책로',
      emoji: '🌸',
      owned: false,
    ),
    _NasemiDexItem(
      no: 41,
      name: '시험기간 나섬이',
      category: '이벤트',
      rarity: '한정',
      hint: '시험기간 도서관 주변',
      emoji: '✏️',
      owned: false,
    ),
    _NasemiDexItem(
      no: 42,
      name: '야간탐험 나섬이',
      category: '히든',
      rarity: '히든',
      hint: '저녁 시간대 특정 장소',
      emoji: '🌙',
      owned: false,
    ),
    _NasemiDexItem(
      no: 43,
      name: '캠퍼스왕 나섬이',
      category: '히든',
      rarity: '전설',
      hint: '학과 나섬이 33종 수집',
      emoji: '👑',
      owned: false,
    ),
  ];

  List<_NasemiDexItem> _clubNasemiItems() {
    return _RecruitScreenState.clubs.map((club) {
      return _NasemiDexItem(
        no: club.nasemiNo,
        name: club.nasemiName,
        category: '동아리',
        rarity: club.category == '스포츠'
            ? '장소'
            : club.category == '학술'
            ? '희귀'
            : club.category == '봉사·종교'
            ? '한정'
            : '기본',
        hint: '${club.name} 상세 페이지에서 동아리 나섬이를 조우할 수 있어요.',
        emoji: club.emoji,
        owned: false,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCollectedNumbers();
  }

  Future<void> _loadCollectedNumbers() async {
    final values = await NasemiCollectionStore.load();
    if (!mounted) return;
    setState(() {
      collectedNumbers = values;
    });
  }

  bool _matchesStatus(_NasemiDexItem item) {
    if (statusFilter == '전체') return true;
    if (statusFilter == '수집완료') return item.owned;
    if (statusFilter == '미수집') return !item.owned;
    return true;
  }

  bool _matchesRarity(_NasemiDexItem item) {
    if (rarityFilter == '전체') return true;
    return item.rarity == rarityFilter;
  }

  @override
  Widget build(BuildContext context) {
    final baseItems = [...items, ..._clubNasemiItems()];

    final displayItems = baseItems.map((item) {
      return collectedNumbers.contains(item.no)
          ? item.copyWith(owned: true)
          : item;
    }).toList();

    final ownedCount = displayItems.where((e) => e.owned).length;
    final totalCount = displayItems.length;
    final progress = totalCount == 0 ? 0.0 : ownedCount / totalCount;

    final filtered = displayItems.where((item) {
      final categoryMatch = selected == '전체' || item.category == selected;
      return categoryMatch && _matchesStatus(item) && _matchesRarity(item);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '나섬이 도감',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _loadCollectedNumbers,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: AppColors.blue,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '갱신',
                      style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          '학과 나섬이는 QR로 확정 수집하고, 수업·장소·이벤트·히든 나섬이는 조건부로 발견합니다.',
          style: TextStyle(
            color: AppColors.sub,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        _Card(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '도감 현황',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$ownedCount / $totalCount',
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE8EEF8),
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        const Text(
          '분류',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        _DexFilterRow(
          values: categories,
          selected: selected,
          onSelected: (v) => setState(() => selected = v),
        ),

        const SizedBox(height: 12),
        const Text(
          '수집 상태',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        _DexFilterRow(
          values: statusFilters,
          selected: statusFilter,
          onSelected: (v) => setState(() => statusFilter = v),
        ),

        const SizedBox(height: 12),
        const Text(
          '희귀도',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        _DexFilterRow(
          values: rarityFilters,
          selected: rarityFilter,
          onSelected: (v) => setState(() => rarityFilter = v),
        ),

        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              '검색 결과 ${filtered.length}종',
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            if (filtered.isEmpty)
              const Text(
                '조건을 바꿔보세요',
                style: TextStyle(
                  color: AppColors.sub,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          const _Card(
            padding: EdgeInsets.all(18),
            child: Text(
              '해당 조건의 나섬이가 아직 없습니다. 다른 필터를 선택해보세요.',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          )
        else
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: .88,
            children: filtered.map((item) {
              return _NasemiDexCard(item: item);
            }).toList(),
          ),
      ],
    );
  }
}

class _DexFilterRow extends StatelessWidget {
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  const _DexFilterRow({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = values[index];
          final isSelected = selected == value;

          return GestureDetector(
            onTap: () => onSelected(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blue : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? AppColors.blue : AppColors.line,
                ),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.sub,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NasemiDexItem {
  final int no;
  final String name;
  final String category;
  final String rarity;
  final String hint;
  final String emoji;
  final bool owned;

  const _NasemiDexItem({
    required this.no,
    required this.name,
    required this.category,
    required this.rarity,
    required this.hint,
    required this.emoji,
    required this.owned,
  });

  _NasemiDexItem copyWith({bool? owned}) {
    return _NasemiDexItem(
      no: no,
      name: name,
      category: category,
      rarity: rarity,
      hint: hint,
      emoji: emoji,
      owned: owned ?? this.owned,
    );
  }
}

class _NasemiDexCard extends StatelessWidget {
  final _NasemiDexItem item;

  const _NasemiDexCard({required this.item});

  Color get rarityColor {
    switch (item.rarity) {
      case '전설':
        return const Color(0xFFFF7A1A);
      case '히든':
        return const Color(0xFF7C3AED);
      case '한정':
        return const Color(0xFFDB2777);
      case '희귀':
        return AppColors.blue;
      case '장소':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF475569);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.owned ? 1 : .58,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: item.owned
                ? const Color(0xFFBBD7FF)
                : const Color(0xFFEAF0FA),
            width: item.owned ? 1.4 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 31)),
                const SizedBox(width: 6),
                Text(
                  "#${item.no.toString().padLeft(3, '0')}",
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.rarity,
                    style: TextStyle(
                      color: rarityColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              item.hint,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: item.owned
                    ? const Color(0xFFEAF3FF)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.owned
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    size: 15,
                    color: item.owned ? AppColors.blue : AppColors.sub,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    item.owned ? '수집 완료' : '미수집',
                    style: TextStyle(
                      color: item.owned ? AppColors.blue : AppColors.sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionNoticeCard extends StatelessWidget {
  const _CollectionNoticeCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Icon(Icons.qr_code_2_rounded, color: AppColors.blue, size: 34),
          SizedBox(width: 13),
          Expanded(
            child: Text(
              '각 학과 건물의 QR을 찍으면 학과별 나섬이를 수집하고, 인터뷰와 공식 자료를 바탕으로 수업 스타일 나섬이도 함께 확장할 예정입니다.',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NasemiCollectionStore {
  static const String key = 'collected_nasemi_numbers';

  static Future<Set<int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(key) ?? <String>[];
    return values.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  static Future<bool> contains(int no) async {
    final values = await load();
    return values.contains(no);
  }

  static Future<void> add(int no) async {
    if (no <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(key) ?? <String>[];
    final set = values.toSet();
    set.add(no.toString());

    final sorted = set.map((e) => int.tryParse(e)).whereType<int>().toList()
      ..sort();

    await prefs.setStringList(key, sorted.map((e) => e.toString()).toList());
  }

  static Future<void> clearForDebug() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(),
            const SizedBox(height: 18),
            const Text(
              'QR 미션',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              '학과 거점과 캠퍼스 곳곳의 QR을 스캔해 나섬이를 수집해요',
              style: TextStyle(
                fontSize: 14.5,
                color: AppColors.sub,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            const _QrMissionHero(),
            const SizedBox(height: 16),
            _QrPrimaryScanCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrScannerPage()),
                );
              },
            ),
            const SizedBox(height: 14),
            const _QrRuleCard(),
            const SizedBox(height: 14),
            const _QrSampleList(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _QrMissionHero extends StatelessWidget {
  const _QrMissionHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16006BFF),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QR 수집 모드',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '현장에서 찍고\n나섬이를 모아요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '학과 나섬이 1~33번은 QR 확정 수집',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 104,
            height: 104,
            child: _AssetImage(path: Assets.qr, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _QrPrimaryScanCard extends StatelessWidget {
  final VoidCallback onTap;

  const _QrPrimaryScanCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: _Card(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.blue,
                  size: 36,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR 스캔 시작',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '학과 거점 QR 또는 이벤트 QR을 인식합니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrRuleCard extends StatelessWidget {
  const _QrRuleCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '수집 규칙',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 10),
          _QrRuleRow(text: '학과 나섬이 1~33번은 학과 공식 거점 QR로 확정 수집'),
          SizedBox(height: 7),
          _QrRuleRow(text: '34번 이후는 시간, 날씨, 위치, 날짜 조건으로 발견'),
          SizedBox(height: 7),
          _QrRuleRow(text: '교수님 관련 나섬이는 개인 평가가 아닌 수업 스타일 기반'),
        ],
      ),
    );
  }
}

class _QrRuleRow extends StatelessWidget {
  final String text;

  const _QrRuleRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.blue, size: 18),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.sub,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _QrSampleList extends StatelessWidget {
  const _QrSampleList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '테스트 QR 예시',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 10),
        _QrSampleCard(
          code: 'paejaepick://nasemi/department/001',
          title: '컴퓨터공학과 나섬이',
          emoji: '💻',
        ),
        SizedBox(height: 9),
        _QrSampleCard(
          code: 'paejaepick://nasemi/department/009',
          title: '디자인학부 나섬이',
          emoji: '🎨',
        ),
      ],
    );
  }
}

class _QrSampleCard extends StatelessWidget {
  final String code;
  final String title;
  final String emoji;

  const _QrSampleCard({
    required this.code,
    required this.title,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  code,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool scanned = false;

  void handleCode(String rawValue) {
    if (scanned) return;

    setState(() {
      scanned = true;
    });

    final reward = NasemiQrReward.fromRawValue(rawValue);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NasemiCatchResultPage(rawValue: rawValue, reward: reward),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final codes = capture.barcodes;
              if (codes.isEmpty) return;

              final raw = codes.first.rawValue;
              if (raw == null || raw.isEmpty) return;

              handleCode(raw);
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black.withOpacity(.45),
                    width: 34,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 58,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'QR을 화면 중앙에 맞춰주세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 248,
              height: 248,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 42,
            child: Column(
              children: [
                const Text(
                  '에뮬레이터에서는 카메라 테스트가 어려울 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      handleCode('paejaepick://nasemi/department/001');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      '테스트 QR로 수집하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NasemiEncounterPage extends StatefulWidget {
  final NasemiQrReward reward;
  final String place;
  final String condition;

  const NasemiEncounterPage({
    super.key,
    required this.reward,
    required this.place,
    required this.condition,
  });

  @override
  State<NasemiEncounterPage> createState() => _NasemiEncounterPageState();
}

class _NasemiEncounterPageState extends State<NasemiEncounterPage> {
  bool throwing = false;
  bool ballFlying = false;
  bool shaking = false;

  @override
  void initState() {
    super.initState();
    GameFeedback.selectionClick();
  }

  Future<void> catchNasemi() async {
    if (throwing) return;

    GameFeedback.mediumImpact();

    setState(() {
      throwing = true;
      ballFlying = true;
    });

    await Future.delayed(const Duration(milliseconds: 420));

    if (!mounted) return;
    setState(() {
      ballFlying = false;
      shaking = true;
    });

    GameFeedback.lightImpact();

    await Future.delayed(const Duration(milliseconds: 520));

    if (!mounted) return;
    setState(() {
      shaking = false;
    });

    GameFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 220));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NasemiCatchResultPage(
          rawValue: 'paejaepick://encounter/${widget.reward.no}',
          reward: widget.reward,
        ),
      ),
    );
  }

  Color get rarityColor {
    switch (widget.reward.rarity) {
      case '전설':
        return const Color(0xFFFF7A1A);
      case '히든':
        return const Color(0xFF7C3AED);
      case '희귀':
        return AppColors.blue;
      default:
        return const Color(0xFF475569);
    }
  }

  String get catchStatus {
    if (!throwing) return '나섬볼을 던져 수집하세요';
    if (ballFlying) return '나섬볼을 던지는 중...';
    if (shaking) return '나섬이가 반응하고 있어요...';
    return '수집 처리 중...';
  }

  @override
  Widget build(BuildContext context) {
    final reward = widget.reward;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(title: '나섬이 조우'),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(34),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A006BFF),
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.22),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(.28),
                          ),
                        ),
                        child: const Text(
                          '근처 출현',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.94),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          reward.rarity,
                          style: TextStyle(
                            color: rarityColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 360),
                          curve: Curves.easeOutBack,
                          bottom: ballFlying ? 92 : 0,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 280),
                            scale: ballFlying ? 1.12 : 1.0,
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.blue,
                                  width: 5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 15,
                                    offset: Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: const BoxDecoration(
                                    color: AppColors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 120),
                          offset: shaking ? const Offset(.035, 0) : Offset.zero,
                          child: AnimatedScale(
                            scale: throwing ? .92 : 1,
                            duration: const Duration(milliseconds: 260),
                            child: Container(
                              width: 158,
                              height: 158,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.24),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(.45),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  reward.emoji,
                                  style: const TextStyle(fontSize: 82),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '야생의 나섬이가 나타났다!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reward.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.place,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.condition,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    catchStatus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Card(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(
                    Icons.vibration_rounded,
                    color: AppColors.blue,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '조우 화면에는 진동과 짧은 애니메이션이 적용됩니다. 실제 AR 카메라는 추후 권한/성능 검토 후 붙이는 것이 안전합니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton.icon(
                onPressed: throwing ? null : catchNasemi,
                icon: Icon(
                  throwing
                      ? Icons.sync_rounded
                      : Icons.radio_button_checked_rounded,
                  size: 25,
                ),
                label: Text(
                  throwing ? '수집 중...' : '나섬볼 던지기',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NasemiStreakStore {
  static const String lastCatchDateKey = 'nasemi_last_catch_date';
  static const String streakCountKey = 'nasemi_streak_count';

  static String _dateKey(DateTime d) {
    return '${d.year}-${d.month}-${d.day}';
  }

  static Future<int> markCatchToday() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final today = _dateKey(now);
    final yesterday = _dateKey(now.subtract(const Duration(days: 1)));

    final last = prefs.getString(lastCatchDateKey);
    final current = prefs.getInt(streakCountKey) ?? 0;

    if (last == today) {
      final safe = current <= 0 ? 1 : current;
      await prefs.setInt(streakCountKey, safe);
      return safe;
    }

    final next = last == yesterday ? current + 1 : 1;

    await prefs.setString(lastCatchDateKey, today);
    await prefs.setInt(streakCountKey, next);

    return next;
  }

  static Future<int> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(streakCountKey) ?? 0;
  }
}

class NasemiQrReward {
  final int no;
  final String name;
  final String category;
  final String rarity;
  final String emoji;
  final String message;
  final bool valid;

  const NasemiQrReward({
    required this.no,
    required this.name,
    required this.category,
    required this.rarity,
    required this.emoji,
    required this.message,
    required this.valid,
  });

  factory NasemiQrReward.fromRawValue(String raw) {
    if (raw.contains('/department/001')) {
      return const NasemiQrReward(
        no: 1,
        name: '컴퓨터공학과 나섬이',
        category: '학과',
        rarity: '기본',
        emoji: '💻',
        message: '컴퓨터공학과 학과 거점 QR을 인식했어요.',
        valid: true,
      );
    }

    if (raw.contains('/department/009')) {
      return const NasemiQrReward(
        no: 9,
        name: '디자인학부 나섬이',
        category: '학과',
        rarity: '기본',
        emoji: '🎨',
        message: '디자인학부 학과 거점 QR을 인식했어요.',
        valid: true,
      );
    }

    if (raw.contains('/place/library')) {
      return const NasemiQrReward(
        no: 38,
        name: '중앙도서관 나섬이',
        category: '장소',
        rarity: '장소',
        emoji: '📚',
        message: '도서관 주변 QR을 인식했어요.',
        valid: true,
      );
    }

    return const NasemiQrReward(
      no: 0,
      name: '알 수 없는 QR',
      category: '확인 필요',
      rarity: '미등록',
      emoji: '❔',
      message: '배재Pick에 등록되지 않은 QR입니다.',
      valid: false,
    );
  }
}

class NasemiCatchResultPage extends StatefulWidget {
  final String rawValue;
  final NasemiQrReward reward;

  const NasemiCatchResultPage({
    super.key,
    required this.rawValue,
    required this.reward,
  });

  @override
  State<NasemiCatchResultPage> createState() => _NasemiCatchResultPageState();
}

class _NasemiCatchResultPageState extends State<NasemiCatchResultPage> {
  bool? alreadyCollected;
  int collectedCount = 0;
  int streakCount = 0;

  @override
  void initState() {
    super.initState();
    _saveReward();
  }

  Future<void> _saveReward() async {
    if (!widget.reward.valid) {
      final values = await NasemiCollectionStore.load();
      final streak = await NasemiStreakStore.load();

      if (!mounted) return;
      setState(() {
        alreadyCollected = false;
        collectedCount = values.length;
        streakCount = streak;
      });
      return;
    }

    final before = await NasemiCollectionStore.contains(widget.reward.no);
    await NasemiCollectionStore.add(widget.reward.no);
    await _markDailyQuestCatch();

    if (!before) {
      await DailyExplorationLimitStore.markCatchToday();
    }

    final streak = await NasemiStreakStore.markCatchToday();
    final values = await NasemiCollectionStore.load();

    if (!mounted) return;
    setState(() {
      alreadyCollected = before;
      collectedCount = values.length;
      streakCount = streak;
    });
  }

  Future<void> _markDailyQuestCatch() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList('daily_quest_progress') ?? <String>[];
    final set = values.toSet();
    set.add('3');
    await prefs.setStringList('daily_quest_progress', set.toList());
  }

  @override
  Widget build(BuildContext context) {
    final reward = widget.reward;
    final isNew = reward.valid && alreadyCollected == false;
    final isDuplicate = reward.valid && alreadyCollected == true;
    final progress = (collectedCount / 100).clamp(0.0, 1.0);

    final title = !reward.valid
        ? 'QR 확인 필요'
        : isDuplicate
        ? '이미 수집한 나섬이'
        : '신규 나섬이 발견';

    final subMessage = !reward.valid
        ? reward.message
        : isDuplicate
        ? '이미 도감에 등록된 나섬이입니다.'
        : '도감에 새롭게 등록됐어요.';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(title: title),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: reward.valid
                      ? const [Color(0xFF126DFF), Color(0xFF8DD7FF)]
                      : const [Color(0xFF64748B), Color(0xFFCBD5E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.24),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(.28),
                          ),
                        ),
                        child: Text(
                          isNew
                              ? 'NEW'
                              : isDuplicate
                              ? 'OWNED'
                              : 'CHECK',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (reward.valid)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.95),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "#${reward.no.toString().padLeft(3, '0')}",
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AnimatedScale(
                    scale: isNew ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutBack,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.24),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(.46),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          reward.emoji,
                          style: const TextStyle(fontSize: 76),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    reward.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (reward.valid)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.96),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${reward.category} · ${reward.rarity}',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _FundingLockedNoticeCard(
              icon: Icons.videocam_off_rounded,
              title: 'CCTV/YOLO 분석 잠금',
              body:
                  '영상 분석은 서버 비용, CCTV 접근 권한, 개인정보 검토가 필요합니다. 2단계 사비 베타에서는 기능 설명만 제공하고 실제 분석 요청은 수행하지 않습니다.',
              badge: '잠금',
            ),
            const SizedBox(height: 14),
            _Card(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '도감 진행도',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$collectedCount / 100',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE8EEF8),
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ResultStatChip(
                        icon: Icons.local_fire_department_rounded,
                        label: '연속 탐색',
                        value: '${streakCount}일',
                      ),
                      const SizedBox(width: 9),
                      _ResultStatChip(
                        icon: Icons.card_giftcard_rounded,
                        label: '퀘스트',
                        value: reward.valid ? '반영됨' : '제외',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _Card(
              padding: const EdgeInsets.all(15),
              child: Text(
                '인식된 값\\n${widget.rawValue}\\n\\n수집 기록은 현재 기기 로컬 저장소에 저장됩니다. 추후 학교 이메일 계정 기준 서버 동기화로 확장할 수 있습니다.',
                style: const TextStyle(
                  color: AppColors.sub,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  '계속 탐색하기',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResultStatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3FF),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue, size: 21),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecruitScreen extends StatefulWidget {
  const RecruitScreen({super.key});

  @override
  State<RecruitScreen> createState() => _RecruitScreenState();
}

class _RecruitScreenState extends State<RecruitScreen> {
  String selected = '전체';

  static const filters = ['전체', '스포츠', '공연·문화', '학술', '봉사·종교', '기타'];

  static const clubs = [
    _OfficialClubItem(
      name: '프레임',
      category: '공연·문화',
      emoji: '🖼️',
      keywords: ['문화', '창작'],
    ),
    _OfficialClubItem(
      name: '네비게이토',
      category: '학술',
      emoji: '🧭',
      keywords: ['학술', '탐구'],
    ),
    _OfficialClubItem(
      name: '네오',
      category: '공연·문화',
      emoji: '🎵',
      keywords: ['문화', '공연'],
    ),
    _OfficialClubItem(
      name: '넵튠',
      category: '기타',
      emoji: '🌊',
      keywords: ['동아리'],
    ),
    _OfficialClubItem(
      name: '다운',
      category: '기타',
      emoji: '🌙',
      keywords: ['동아리'],
    ),
    _OfficialClubItem(
      name: '라이브',
      category: '공연·문화',
      emoji: '🎤',
      keywords: ['공연', '문화'],
    ),
    _OfficialClubItem(
      name: '로테이션',
      category: '공연·문화',
      emoji: '🔄',
      keywords: ['문화', '활동'],
    ),
    _OfficialClubItem(
      name: '모션',
      category: '공연·문화',
      emoji: '🎬',
      keywords: ['문화', '활동'],
    ),
    _OfficialClubItem(
      name: '문항',
      category: '학술',
      emoji: '📚',
      keywords: ['학술', '스터디'],
    ),
    _OfficialClubItem(
      name: '보드카',
      category: '기타',
      emoji: '🎲',
      keywords: ['동아리'],
    ),
    _OfficialClubItem(
      name: '빌런',
      category: '기타',
      emoji: '🦹',
      keywords: ['동아리'],
    ),
    _OfficialClubItem(
      name: '상상 네이버스',
      category: '봉사·종교',
      emoji: '🤝',
      keywords: ['봉사', '대외활동'],
    ),
    _OfficialClubItem(
      name: '스트라이크',
      category: '스포츠',
      emoji: '🎳',
      keywords: ['스포츠'],
    ),
    _OfficialClubItem(
      name: '신선놀음',
      category: '공연·문화',
      emoji: '🌿',
      keywords: ['문화', '취미'],
    ),
    _OfficialClubItem(
      name: '야생마',
      category: '스포츠',
      emoji: '🐎',
      keywords: ['스포츠', '활동'],
    ),
    _OfficialClubItem(
      name: '오선회',
      category: '공연·문화',
      emoji: '🎼',
      keywords: ['음악', '문화'],
    ),
    _OfficialClubItem(
      name: '위더스',
      category: '봉사·종교',
      emoji: '🫶',
      keywords: ['봉사', '교류'],
    ),
    _OfficialClubItem(
      name: '저거넛',
      category: '스포츠',
      emoji: '🏀',
      keywords: ['농구', '스포츠'],
    ),
    _OfficialClubItem(
      name: '지니어스',
      category: '학술',
      emoji: '🧠',
      keywords: ['학술', '스터디'],
    ),
    _OfficialClubItem(
      name: '청춘',
      category: '공연·문화',
      emoji: '🌱',
      keywords: ['문화', '교류'],
    ),
    _OfficialClubItem(
      name: '체나',
      category: '공연·문화',
      emoji: '🎻',
      keywords: ['문화', '예술'],
    ),
    _OfficialClubItem(
      name: '크로우즈',
      category: '스포츠',
      emoji: '⚾',
      keywords: ['야구', '스포츠'],
    ),
    _OfficialClubItem(
      name: '프리마',
      category: '공연·문화',
      emoji: '🎭',
      keywords: ['공연', '문화'],
    ),
    _OfficialClubItem(
      name: '플레이어',
      category: '공연·문화',
      emoji: '🎮',
      keywords: ['문화', '활동'],
    ),
    _OfficialClubItem(
      name: '한울회',
      category: '봉사·종교',
      emoji: '🌐',
      keywords: ['봉사', '교류'],
    ),
    _OfficialClubItem(
      name: 'ABIS',
      category: '학술',
      emoji: '🧩',
      keywords: ['학술', '영문약칭'],
    ),
    _OfficialClubItem(
      name: 'CCC',
      category: '봉사·종교',
      emoji: '☁️',
      keywords: ['종교', '봉사'],
    ),
    _OfficialClubItem(
      name: 'DFC',
      category: '봉사·종교',
      emoji: '🌊',
      keywords: ['종교', '봉사'],
    ),
    _OfficialClubItem(
      name: 'M.A.C',
      category: '기타',
      emoji: '💿',
      keywords: ['동아리', '영문약칭'],
    ),
    _OfficialClubItem(
      name: 'oao/농구',
      category: '스포츠',
      emoji: '🏀',
      keywords: ['농구', '스포츠'],
    ),
    _OfficialClubItem(
      name: 'prh',
      category: '기타',
      emoji: '🐰',
      keywords: ['동아리', '영문약칭'],
    ),
    _OfficialClubItem(
      name: 'VOLLEY',
      category: '스포츠',
      emoji: '🏐',
      keywords: ['배구', '스포츠'],
    ),
  ];

  List<_OfficialClubItem> get visibleClubs {
    if (selected == '전체') return clubs;
    return clubs.where((e) => e.category == selected).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = visibleClubs;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TopBar(),
            const SizedBox(height: 18),
            const Text(
              '동아리 도감',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
                height: 1.08,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              '배재대학교 공식 동아리 목록을 한눈에 확인해요',
              style: TextStyle(
                fontSize: 14.5,
                color: AppColors.sub,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            const _OfficialClubHero(),
            const SizedBox(height: 16),
            const _ClubRecommendationShortcutCard(),
            const SizedBox(height: 16),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final value = filters[index];
                  return _OfficialClubFilterChip(
                    text: value,
                    selected: selected == value,
                    onTap: () => setState(() => selected = value),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  selected == '전체' ? '공식 동아리 목록' : '$selected 동아리',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                Text(
                  '${list.length}개',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ...list.map((club) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OfficialClubCard(club: club),
              );
            }),

            const SizedBox(height: 8),
            const _OfficialClubNoticeCard(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class ClubInterestStore {
  static const String key = 'interested_official_clubs';

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(key) ?? <String>[];
    final unique = values.toSet().toList()..sort();
    return unique;
  }

  static Future<bool> contains(String name) async {
    final values = await load();
    return values.contains(name);
  }

  static Future<bool> toggle(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final values = (prefs.getStringList(key) ?? <String>[]).toSet();

    if (values.contains(name)) {
      values.remove(name);
      await prefs.setStringList(key, values.toList()..sort());
      return false;
    }

    values.add(name);
    await prefs.setStringList(key, values.toList()..sort());
    return true;
  }

  static Future<void> remove(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final values = (prefs.getStringList(key) ?? <String>[]).toSet();
    values.remove(name);
    await prefs.setStringList(key, values.toList()..sort());
  }
}

class _InterestedClubSection extends StatefulWidget {
  const _InterestedClubSection();

  @override
  State<_InterestedClubSection> createState() => _InterestedClubSectionState();
}

class _InterestedClubSectionState extends State<_InterestedClubSection> {
  List<String> interestedNames = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await ClubInterestStore.load();
    if (!mounted) return;
    setState(() {
      interestedNames = values;
    });
  }

  _OfficialClubItem _clubByName(String name) {
    for (final club in _RecruitScreenState.clubs) {
      if (club.name == name) return club;
    }

    return _OfficialClubItem(
      name: name,
      category: '기타',
      emoji: '⭐',
      keywords: const ['관심', '동아리'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubs = interestedNames.map(_clubByName).toList();

    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '관심 동아리',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.blue,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '갱신',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            clubs.isEmpty
                ? '동아리 도감에서 관심 동아리를 등록하면 여기에 표시됩니다.'
                : '등록한 관심 동아리 ${clubs.length}개',
            style: const TextStyle(
              color: AppColors.sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),
          if (clubs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.bookmark_border_rounded,
                    color: AppColors.sub,
                    size: 27,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '아직 관심 등록한 동아리가 없습니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...clubs.map((club) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _InterestedClubCard(club: club, onRemoved: _load),
              );
            }),
        ],
      ),
    );
  }
}

class _InterestedClubCard extends StatelessWidget {
  final _OfficialClubItem club;
  final VoidCallback onRemoved;

  const _InterestedClubCard({required this.club, required this.onRemoved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Text(club.emoji, style: const TextStyle(fontSize: 29)),
          const SizedBox(width: 11),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _OfficialClubDetailPage(club: club),
                  ),
                ).then((_) => onRemoved());
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    club.category,
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              await ClubInterestStore.remove(club.name);
              onRemoved();

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('${club.name} 관심 해제')));
              }
            },
            icon: const Icon(
              Icons.bookmark_remove_rounded,
              color: AppColors.sub,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubRecommendationShortcutCard extends StatelessWidget {
  const _ClubRecommendationShortcutCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClubRecommendationPage()),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.blue,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나에게 맞는 동아리 찾기',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '관심사와 활동 성향을 선택하면 공식 동아리 목록에서 추천해요.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class ClubRecommendationPage extends StatefulWidget {
  const ClubRecommendationPage({super.key});

  @override
  State<ClubRecommendationPage> createState() => _ClubRecommendationPageState();
}

class _ClubRecommendationPageState extends State<ClubRecommendationPage> {
  final Set<String> selectedPrefs = {};

  static const preferences = [
    '운동',
    '공연',
    '음악',
    '창작',
    '스터디',
    '봉사',
    '교류',
    '게임',
    '가볍게',
    '포트폴리오',
  ];

  List<_OfficialClubItem> get recommended {
    if (selectedPrefs.isEmpty) {
      return _RecruitScreenState.clubs.take(8).toList();
    }

    final scored =
        _RecruitScreenState.clubs.map((club) {
          var score = 0;

          for (final pref in selectedPrefs) {
            final p = pref.toLowerCase();

            if (club.name.toLowerCase().contains(p)) score += 3;
            if (club.category.toLowerCase().contains(p)) score += 4;

            for (final keyword in club.keywords) {
              if (keyword.toLowerCase().contains(p) ||
                  p.contains(keyword.toLowerCase())) {
                score += 3;
              }
            }

            if (p == '운동' && club.category == '스포츠') score += 5;
            if (p == '공연' && club.category == '공연·문화') score += 4;
            if (p == '음악' && club.keywords.any((e) => e.contains('음악')))
              score += 5;
            if (p == '창작' && club.category == '공연·문화') score += 3;
            if (p == '스터디' && club.category == '학술') score += 5;
            if (p == '봉사' && club.category == '봉사·종교') score += 5;
            if (p == '교류' && club.keywords.any((e) => e.contains('교류')))
              score += 4;
            if (p == '게임' &&
                (club.name.contains('플레이어') ||
                    club.keywords.any((e) => e.contains('게임'))))
              score += 5;
            if (p == '가볍게' && club.category == '기타') score += 2;
            if (p == '포트폴리오' &&
                (club.category == '학술' || club.category == '공연·문화'))
              score += 2;
          }

          return MapEntry(club, score);
        }).toList()..sort((a, b) {
          final cmp = b.value.compareTo(a.value);
          if (cmp != 0) return cmp;
          return a.key.name.compareTo(b.key.name);
        });

    final result = scored.where((e) => e.value > 0).map((e) => e.key).toList();

    if (result.isEmpty) {
      return _RecruitScreenState.clubs.take(8).toList();
    }

    return result.take(10).toList();
  }

  void togglePref(String value) {
    setState(() {
      if (selectedPrefs.contains(value)) {
        selectedPrefs.remove(value);
      } else {
        selectedPrefs.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = recommended;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DetailTopBar(title: '동아리 추천'),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '신입생용 탐색 도우미',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '내 성향에 맞는\n동아리를 찾아요',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            height: 1.14,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '선택한 관심사 기반 공식 동아리 추천',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('🧭', style: TextStyle(fontSize: 62)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              '관심사 선택',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preferences.map((pref) {
                return _ClubPreferenceChip(
                  text: pref,
                  selected: selectedPrefs.contains(pref),
                  onTap: () => togglePref(pref),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  selectedPrefs.isEmpty ? '추천 예시' : '추천 결과',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  '${list.length}개',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (list.isEmpty)
              const _RecommendationEmptyCard()
            else
              ...list.map((club) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RecommendedClubCard(club: club),
                );
              }),

            const SizedBox(height: 8),
            const _Card(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, color: AppColors.blue, size: 27),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      '추천은 공식 동아리명, 분류, 키워드를 바탕으로 한 베타 기능입니다. 실제 분위기와 모집 여부는 동아리 대표 확인 후 보완해야 합니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubPreferenceChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ClubPreferenceChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.blue : AppColors.line),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.sub,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RecommendedClubCard extends StatelessWidget {
  final _OfficialClubItem club;

  const _RecommendedClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _OfficialClubDetailPage(club: club),
            ),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Text(club.emoji, style: const TextStyle(fontSize: 35)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      club.category,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      club.shortIntro,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationEmptyCard extends StatelessWidget {
  const _RecommendationEmptyCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      padding: EdgeInsets.all(17),
      child: Text(
        '추천 결과가 없습니다. 관심사를 다시 선택해보세요.',
        style: TextStyle(
          color: AppColors.sub,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }
}

class _OfficialClubItem {
  final String name;
  final String category;
  final String emoji;
  final List<String> keywords;

  const _OfficialClubItem({
    required this.name,
    required this.category,
    required this.emoji,
    required this.keywords,
  });

  int get nasemiNo {
    final index = _RecruitScreenState.clubs.indexWhere((e) => e.name == name);
    if (index >= 0) return 120 + index;

    final sum = name.codeUnits.fold<int>(0, (prev, cur) => prev + cur);
    return 120 + (sum % 80);
  }

  String get nasemiName => '$name 나섬이';

  String get shortIntro {
    if (category == '스포츠') {
      return '$name은 운동, 팀워크, 정기 활동을 중심으로 참여할 수 있는 스포츠 동아리입니다.';
    }

    if (category == '공연·문화') {
      return '$name은 공연, 문화, 창작, 취미 활동을 중심으로 캠퍼스 생활을 넓혀주는 동아리입니다.';
    }

    if (category == '학술') {
      return '$name은 관심 분야를 함께 공부하고 탐구하는 학술·스터디 성격의 동아리입니다.';
    }

    if (category == '봉사·종교') {
      return '$name은 교류, 봉사, 공동체 활동을 중심으로 운영되는 동아리입니다.';
    }

    return '$name은 배재대학교 공식 동아리 목록에 등록된 동아리입니다.';
  }

  List<String> get activityPoints {
    if (category == '스포츠') {
      return [
        '정기 연습이나 경기 참여를 통해 실전 경험을 쌓을 수 있어요.',
        '동아리원과 팀워크를 맞추며 캠퍼스 생활의 소속감을 만들 수 있어요.',
        '장비, 장소, 안전 수칙은 동아리 운영 기준에 따라 확인해야 해요.',
      ];
    }

    if (category == '공연·문화') {
      return [
        '공연, 전시, 취미, 창작 활동을 통해 결과물을 만들 수 있어요.',
        '학과와 다른 사람들과 자연스럽게 교류할 수 있어요.',
        '활동 사진이나 작품을 앱에 올릴 경우 동의와 저작권 확인이 필요해요.',
      ];
    }

    if (category == '학술') {
      return [
        '관심 분야를 함께 공부하고 정리하는 활동에 적합해요.',
        '스터디, 발표, 프로젝트형 활동으로 포트폴리오를 만들 수 있어요.',
        '세부 활동 주제는 동아리 대표나 공식 소개를 통해 확인해야 해요.',
      ];
    }

    if (category == '봉사·종교') {
      return [
        '공동체 활동, 봉사, 교류 중심의 활동을 경험할 수 있어요.',
        '정기 모임 여부와 참여 조건은 동아리별 확인이 필요해요.',
        '종교·봉사 성격의 동아리는 소개 문구와 참여 안내를 신중하게 다뤄야 해요.',
      ];
    }

    return [
      '공식 동아리 목록에 등록된 항목입니다.',
      '세부 활동, 모집 기간, 대표 연락 방식은 추후 검수 후 추가합니다.',
      '관심 등록을 통해 나중에 다시 확인할 수 있어요.',
    ];
  }

  List<String> get recommendedFor {
    if (category == '스포츠') {
      return [
        '운동을 꾸준히 하고 싶은 학생',
        '팀 활동과 경기 분위기를 좋아하는 학생',
        '수업 외에 몸을 움직이는 루틴을 만들고 싶은 학생',
      ];
    }

    if (category == '공연·문화') {
      return [
        '무대, 창작, 취미 활동에 관심 있는 학생',
        '새로운 사람들과 가볍게 교류하고 싶은 학생',
        '캠퍼스 생활을 수업 밖으로 넓히고 싶은 학생',
      ];
    }

    if (category == '학술') {
      return [
        '스터디나 발표 활동을 해보고 싶은 학생',
        '전공 외 관심 분야를 깊게 파보고 싶은 학생',
        '포트폴리오나 학습 기록을 만들고 싶은 학생',
      ];
    }

    if (category == '봉사·종교') {
      return [
        '봉사나 공동체 활동에 관심 있는 학생',
        '정기적인 교류 모임을 찾는 학생',
        '가치관 기반 활동을 조심스럽게 탐색하고 싶은 학생',
      ];
    }

    return [
      '공식 동아리 목록을 둘러보고 싶은 학생',
      '아직 관심 분야를 정하지 못한 신입생',
      '여러 동아리를 비교해보고 싶은 학생',
    ];
  }

  String get recruitGuide {
    if (category == '스포츠') {
      return '모집 여부, 연습 요일, 장비 필요 여부, 부상 안전 수칙은 동아리 대표 확인 후 안내하는 것이 좋습니다.';
    }

    if (category == '공연·문화') {
      return '모집 여부, 정기 모임, 공연/전시 일정, 초보자 참여 가능 여부를 확인하면 좋습니다.';
    }

    if (category == '학술') {
      return '스터디 주제, 난이도, 정기 모임, 신입 부원 참여 방식을 확인하면 좋습니다.';
    }

    if (category == '봉사·종교') {
      return '활동 목적, 참여 조건, 정기 모임, 외부 단체 연계 여부를 명확히 확인해야 합니다.';
    }

    return '상세 모집 정보는 동아리 대표 또는 운영자 확인 후 추가하는 것이 안전합니다.';
  }
}

class _OfficialClubHero extends StatelessWidget {
  const _OfficialClubHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16006BFF),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '캠퍼스 참여 허브',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '우리 학교\n동아리를 모아요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.13,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '공식 동아리 목록 · 분야별 분류 · 상세 정보',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 106,
            height: 106,
            child: _AssetImage(path: Assets.recruit, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _OfficialClubFilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OfficialClubFilterChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.blue : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.blue : AppColors.line),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.sub,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _OfficialClubCard extends StatelessWidget {
  final _OfficialClubItem club;

  const _OfficialClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _OfficialClubDetailPage(club: club),
            ),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(club.emoji, style: const TextStyle(fontSize: 33)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      club.category,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _OfficialClubTagWrap(tags: club.keywords),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.sub),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficialClubDetailPage extends StatefulWidget {
  final _OfficialClubItem club;

  const _OfficialClubDetailPage({required this.club});

  @override
  State<_OfficialClubDetailPage> createState() =>
      _OfficialClubDetailPageState();
}

class _OfficialClubDetailPageState extends State<_OfficialClubDetailPage> {
  bool interested = false;

  @override
  void initState() {
    super.initState();
    _loadInterest();
  }

  Future<void> _loadInterest() async {
    final value = await ClubInterestStore.contains(widget.club.name);
    if (!mounted) return;
    setState(() {
      interested = value;
    });
  }

  Future<void> _toggleInterest() async {
    final value = await ClubInterestStore.toggle(widget.club.name);

    if (!mounted) return;

    setState(() {
      interested = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? '${widget.club.name} 관심 등록 완료' : '${widget.club.name} 관심 해제',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _Page(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(title: club.name),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF126DFF), Color(0xFF8DD7FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16006BFF),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.22),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(.28),
                            ),
                          ),
                          child: Text(
                            club.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          club.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          club.shortIntro,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(.35),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        club.emoji,
                        style: const TextStyle(fontSize: 46),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                _OfficialClubInfoChip(
                  icon: Icons.verified_rounded,
                  label: '상태',
                  value: '공식 동아리',
                ),
                const SizedBox(width: 9),
                _OfficialClubInfoChip(
                  icon: Icons.category_rounded,
                  label: '분류',
                  value: club.category,
                ),
              ],
            ),

            const SizedBox(height: 14),
            _OfficialClubTagWrap(tags: club.keywords),

            const SizedBox(height: 14),
            _OfficialClubDetailSection(
              icon: Icons.local_activity_rounded,
              title: '주요 활동',
              child: _OfficialClubBulletList(items: club.activityPoints),
            ),

            const SizedBox(height: 10),
            _OfficialClubDetailSection(
              icon: Icons.person_search_rounded,
              title: '이런 학생에게 추천',
              child: _OfficialClubBulletList(items: club.recommendedFor),
            ),

            const SizedBox(height: 10),
            _OfficialClubRecruitBox(club: club),

            const SizedBox(height: 10),
            _OfficialClubNasemiCard(club: club),

            const SizedBox(height: 10),
            _Card(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.blue,
                    size: 27,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      '동아리 상세 소개, 모집 기간, 활동 장소, 대표 연락 방식은 동아리 대표 또는 운영자 확인 후 추가하는 구조가 안전합니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _toggleInterest,
                icon: Icon(
                  interested
                      ? Icons.bookmark_remove_rounded
                      : Icons.bookmark_add_rounded,
                ),
                label: Text(
                  interested ? '관심 해제하기' : '관심 등록하기',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: interested
                      ? const Color(0xFF64748B)
                      : AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficialClubDetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _OfficialClubDetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.blue, size: 27),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}

class _OfficialClubBulletList extends StatelessWidget {
  final List<String> items;

  const _OfficialClubBulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '•',
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  e,
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _OfficialClubRecruitBox extends StatelessWidget {
  final _OfficialClubItem club;

  const _OfficialClubRecruitBox({required this.club});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign_rounded, color: AppColors.blue, size: 29),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              club.recruitGuide,
              style: const TextStyle(
                color: AppColors.sub,
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficialClubNasemiCard extends StatelessWidget {
  final _OfficialClubItem club;

  const _OfficialClubNasemiCard({required this.club});

  NasemiQrReward get reward {
    return NasemiQrReward(
      no: club.nasemiNo,
      name: club.nasemiName,
      category: '동아리',
      rarity: club.category == '스포츠'
          ? '장소'
          : club.category == '학술'
          ? '희귀'
          : '기본',
      emoji: club.emoji,
      message: '${club.name} 상세 페이지에서 동아리 나섬이를 발견했어요.',
      valid: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NasemiEncounterPage(
                reward: reward,
                place: '${club.name} 동아리 상세',
                condition: '동아리 도감 상세 페이지에서 발견',
              ),
            ),
          );
        },
        child: _Card(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(club.emoji, style: const TextStyle(fontSize: 35)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${club.nasemiNo.toString().padLeft(3, '0')} ${club.nasemiName}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '상세 페이지에서 조우할 수 있는 동아리 나섬이입니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.touch_app_rounded,
                color: AppColors.blue,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficialClubInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OfficialClubInfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.blue, size: 24),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfficialClubTagWrap extends StatelessWidget {
  final List<String> tags;

  const _OfficialClubTagWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: tags.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            e,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _OfficialClubNoticeCard extends StatelessWidget {
  const _OfficialClubNoticeCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(
            Icons.admin_panel_settings_rounded,
            color: AppColors.blue,
            size: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '공식 동아리명은 등록되어 있으며, 상세 소개·모집 여부·대표 연락 방식은 동아리 대표 또는 운영자 확인 후 업데이트합니다.',
              style: TextStyle(
                color: AppColors.sub,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyEmailAuthStatusCard extends StatefulWidget {
  const _MyEmailAuthStatusCard();

  @override
  State<_MyEmailAuthStatusCard> createState() => _MyEmailAuthStatusCardState();
}

class _MyEmailAuthStatusCardState extends State<_MyEmailAuthStatusCard> {
  bool verified = false;
  String? email;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final isVerified = await EmailAuthStore.isVerified();
    final savedEmail = await EmailAuthStore.verifiedEmail();

    if (!mounted) return;

    setState(() {
      verified = isVerified;
      email = savedEmail;
      loading = false;
    });
  }

  Future<void> _clearAuth() async {
    await EmailAuthStore.clear();

    if (!mounted) return;

    setState(() {
      verified = false;
      email = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('학교 이메일 인증 상태를 해제했습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _Card(
        padding: EdgeInsets.all(16),
        child: Text(
          '인증 상태를 확인하는 중...',
          style: TextStyle(
            color: AppColors.sub,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return _Card(
      padding: const EdgeInsets.all(17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: verified
                  ? const Color(0xFFE8FFF1)
                  : const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              verified
                  ? Icons.verified_user_rounded
                  : Icons.mark_email_unread_rounded,
              color: verified
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFB45309),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verified ? '학교 이메일 인증 완료' : '학교 이메일 인증 필요',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  verified
                      ? '인증 이메일: ${email ?? '확인됨'}'
                      : '학교 이메일 인증을 완료하면 학생 전용 기능을 더 안전하게 사용할 수 있습니다.',
                  style: const TextStyle(
                    color: AppColors.sub,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                    height: 1.42,
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: verified
                            ? const Color(0xFFE8FFF1)
                            : const Color(0xFFFFF4D6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        verified ? 'verified' : 'not verified',
                        style: TextStyle(
                          color: verified
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFB45309),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (verified)
                      TextButton.icon(
                        onPressed: _clearAuth,
                        icon: const Icon(Icons.logout_rounded, size: 17),
                        label: const Text(
                          '인증 해제',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                        ),
                      )
                    else
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '앱 재실행 후 로그인 화면에서 학교 이메일 인증을 진행해주세요.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.mail_rounded, size: 17),
                        label: const Text(
                          '인증 안내',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.blue,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLostFoundClaimsSection extends StatefulWidget {
  const _MyLostFoundClaimsSection();

  @override
  State<_MyLostFoundClaimsSection> createState() =>
      _MyLostFoundClaimsSectionState();
}

class _MyLostFoundClaimsSectionState extends State<_MyLostFoundClaimsSection> {
  List<String> claimIds = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await LostFoundInterestStore.load();

    if (!mounted) return;

    setState(() {
      claimIds = values;
    });
  }

  _LostFoundItem? _itemById(String id) {
    for (final item in _LostFoundScreenState.items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _clearMissingItems() async {
    final validIds = _LostFoundScreenState.items.map((e) => e.id).toSet();
    final current = await LostFoundInterestStore.load();
    final filtered = current.where(validIds.contains).toList();

    if (filtered.length == current.length) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(LostFoundInterestStore.key, filtered);

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = claimIds.map(_itemById).whereType<_LostFoundItem>().toList();

    return _Card(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '내 분실물 확인 요청',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await _clearMissingItems();
                  await _load();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppColors.blue,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '갱신',
                        style: TextStyle(
                          color: AppColors.blue,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            items.isEmpty
                ? '분실물 상세에서 “내 물건일 수도 있어요”를 누르면 여기에 표시됩니다.'
                : '본인 확인 요청 ${items.length}건',
            style: const TextStyle(
              color: AppColors.sub,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 13),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.manage_search_rounded,
                    color: AppColors.sub,
                    size: 27,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '아직 저장된 본인 확인 요청이 없습니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _MyLostFoundClaimTile(item: item, onReturn: _load),
              );
            }),
        ],
      ),
    );
  }
}

class _MyLostFoundClaimTile extends StatelessWidget {
  final _LostFoundItem item;
  final VoidCallback onReturn;

  const _MyLostFoundClaimTile({required this.item, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final isFound = item.type == '습득';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _LostFoundDetailPage(item: item)),
          ).then((_) => onReturn());
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${item.place} · ${item.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: isFound
                      ? const Color(0xFFEAF3FF)
                      : const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.type,
                  style: TextStyle(
                    color: isFound ? AppColors.blue : const Color(0xFFB45309),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
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

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Page(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(),
          SizedBox(height: 14),
          _MyEmailAuthStatusCard(),
          const SizedBox(height: 14),
          const _InterestedClubSection(),
          const SizedBox(height: 14),
          const _MyLostFoundClaimsSection(),
          const SizedBox(height: 14),
          SizedBox(height: 22),
          Text(
            '마이',
            style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14),
          _AssetInfoCard(
            imagePath: Assets.security,
            title: '학교 이메일 인증',
            body: '재학생 인증 완료',
          ),
          _MenuTile(title: '문의하기'),
          _MenuTile(title: '오류 제보'),
          _MenuTile(title: '정보 수정 요청'),
          _MenuTile(title: '개인정보 처리방침'),
          _MenuTile(title: '운영정책 안내'),
          _MenuTile(title: '앱 버전 v5.0-beta'),
          SizedBox(height: 12),
          _BetaBanner(),
        ],
      ),
    );
  }
}

class _PillBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _PillBottomNav({required this.selectedIndex, required this.onTap});

  static const items = [
    (Icons.home_rounded, '홈'),
    (Icons.menu_book_rounded, '도감'),
    (Icons.qr_code_scanner_rounded, '미션'),
    (Icons.campaign_rounded, '모집'),
    (Icons.person_rounded, '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFEAF0FA), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 26,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final selected = selectedIndex == i;
            final item = items[i];

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 56,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFEAF3FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        size: selected ? 25 : 23,
                        color: selected
                            ? AppColors.blue
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: selected
                              ? AppColors.blue
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  final Widget child;
  const _Page({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        child: child,
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  final bool center;
  const _BrandTitle({this.center = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
      children: const [
        Text(
          '배재Pick ',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
          ),
        ),
        Text(
          '2.0',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.blue,
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _BrandTitle(),
        Spacer(),
        Icon(Icons.notifications_none, size: 27, color: Colors.black87),
        SizedBox(width: 12),
        CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFFFD48A),
          backgroundImage: AssetImage(Assets.nasemiAvatar),
        ),
      ],
    );
  }
}

class _TextInputBox extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;
  final String? trailing;

  const _TextInputBox({
    required this.controller,
    required this.icon,
    required this.hint,
    required this.keyboardType,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Icon(icon, color: const Color(0xFF718096), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          if (trailing != null) ...[
            Text(
              trailing!,
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 15),
          ],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.blue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(17)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AssetInfoCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String body;

  const _AssetInfoCard({
    required this.imagePath,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _AssetImage(path: imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(color: AppColors.sub, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetFeatureCard extends StatelessWidget {
  final String title;
  final String body;
  final String imagePath;
  final VoidCallback? onTap;

  const _AssetFeatureCard({
    required this.title,
    required this.body,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: _Card(
          padding: const EdgeInsets.fromLTRB(15, 15, 13, 10),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.2,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      body,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: SizedBox(
                  width: 94,
                  height: 82,
                  child: _AssetImage(path: imagePath, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMini extends StatelessWidget {
  final String title;
  final String imagePath;
  const _HeroMini({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
          SizedBox(
            width: 74,
            height: 74,
            child: _AssetImage(path: imagePath, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  final List<String> items;
  const _Chips({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: items.map((e) {
        final selected = e == items.first;
        return Chip(
          label: Text(e),
          backgroundColor: selected ? AppColors.blue : Colors.white,
          labelStyle: TextStyle(
            color: selected ? Colors.white : const Color(0xFF334155),
            fontWeight: FontWeight.w800,
          ),
          side: BorderSide(color: selected ? AppColors.blue : AppColors.line),
        );
      }).toList(),
    );
  }
}

class _MissionItem extends StatelessWidget {
  final String title;
  final String state;
  final String point;

  const _MissionItem({
    required this.title,
    required this.state,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _Card(
        child: Row(
          children: [
            const SizedBox(
              width: 52,
              height: 52,
              child: _AssetImage(path: Assets.nasemi, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '⭐ $point',
                    style: const TextStyle(color: AppColors.sub, fontSize: 13),
                  ),
                ],
              ),
            ),
            Chip(label: Text(state)),
          ],
        ),
      ),
    );
  }
}

class _RecruitItem extends StatelessWidget {
  final String title;
  final String meta;
  final String dday;
  final String button;

  const _RecruitItem({
    required this.title,
    required this.meta,
    required this.dday,
    required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: _Card(
        child: Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: _AssetImage(path: Assets.recruit, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        dday,
                        style: const TextStyle(
                          color: Color(0xFFE74B72),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(86, 34),
                      ),
                      child: Text(button),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionItem extends StatelessWidget {
  final String name;
  final String imagePath;

  const _CollectionItem({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 55,
            child: _AssetImage(path: imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 7),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5),
          ),
          const SizedBox(height: 4),
          const Text(
            '보유 중',
            style: TextStyle(
              color: AppColors.blue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  const _MenuTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: _Card(
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _BetaBanner extends StatelessWidget {
  const _BetaBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        AppText.betaNotice,
        style: TextStyle(color: Color(0xFF92400E), fontSize: 12, height: 1.4),
      ),
    );
  }
}

class _AssetImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const _AssetImage({required this.path, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.blue,
          ),
        );
      },
    );
  }
}
