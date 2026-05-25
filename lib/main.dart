import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.notoSansKrTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
          primary: AppColors.blue,
          secondary: AppColors.green,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const blue = Color(0xFF2563EB);
  static const darkBlue = Color(0xFF0F2F6E);
  static const green = Color(0xFF10B981);
  static const yellow = Color(0xFFFBBF24);
  static const orange = Color(0xFFF97316);
  static const purple = Color(0xFF7C3AED);
  static const red = Color(0xFFEF4444);
  static const bg = Color(0xFFF8FAFC);
  static const text = Color(0xFF111827);
  static const sub = Color(0xFF6B7280);
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const Nasumi(size: 140, label: 'P'),
              const SizedBox(height: 26),
              const Text(
                '배재Pick 2.0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '학교를 더 자주 탐험하고,\n나섬이와 캠퍼스 도감을 수집하는\n배재대학교형 스마트캠퍼스 앱',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.6,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    '배재Pick 시작하기',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Campus Quest · CityBrain · Nasumi Collection',
                style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Nasumi(size: 56, label: 'P'),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '배재Pick',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Smart Campus Quest',
                        style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 34),
              const Text(
                '오늘의 캠퍼스를\nPick 해보세요.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '학교 이메일 인증 기반으로 시작하는\n배재대학교 학생용 스마트캠퍼스 앱입니다.',
                style: TextStyle(
                  color: AppColors.sub,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              const AppInput(label: '학교 이메일', hint: 'example@pcu.ac.kr'),
              const SizedBox(height: 14),
              const AppInput(label: '비밀번호', hint: '비밀번호 입력', obscure: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  },
                  child: const Text(
                    '로그인',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: const BorderSide(color: AppColors.blue, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    );
                  },
                  child: const Text(
                    '이메일 인증 후 시작하기',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyGuideScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text(
                    '개인정보 및 로컬 저장 안내 보기',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const AppCard(
                child: Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppColors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'v0.2에서는 로그인/이메일 인증 UI mock만 제공합니다. 실제 인증은 Firebase 또는 Supabase 연동 단계에서 구현합니다.',
                        style: TextStyle(
                          color: AppColors.sub,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
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

class AppInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.sub),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
            ),
          ),
        ),
      ],
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
    CampusMapScreen(),
    CollectionScreen(),
    ClubScreen(),
    MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: '캠퍼스맵',
          ),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: '도감',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: '동아리',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;

  const AppCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class Nasumi extends StatelessWidget {
  final double size;
  final String label;

  const Nasumi({
    super.key,
    this.size = 72,
    this.label = 'P',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB84D),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.13,
            child: Text(
              '|||',
              style: TextStyle(
                fontSize: size * 0.24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF7C2D12),
                letterSpacing: -4,
              ),
            ),
          ),
          Positioned(top: size * 0.40, left: size * 0.28, child: _eye(size)),
          Positioned(top: size * 0.40, right: size * 0.28, child: _eye(size)),
          Positioned(
            bottom: size * 0.22,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: size * 0.12, vertical: size * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye(double size) {
    return Container(
      width: size * 0.08,
      height: size * 0.08,
      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(title: '안녕하세요, 영준님 👋', subtitle: '오늘도 캠퍼스 탐험 준비됐나요?'),
          const SizedBox(height: 20),
          AppCard(
            color: AppColors.blue,
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('오늘의 Pick', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
                      SizedBox(height: 8),
                      Text('도서관 나섬이 출현 중!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      SizedBox(height: 6),
                      Text('도서관 2층 열람실 · 남은 시간 02:13:45', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Nasumi(size: 92, label: '책'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: CafeteriaMiniCard()),
              SizedBox(width: 12),
              Expanded(child: MissionMiniCard()),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QR·코드 미션',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  '건물이나 행사 현장에서 받은 코드를 입력하고 나섬이 카드를 수집하세요.',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MissionCodeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text(
                      '미션 코드 입력하기',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            color: const Color(0xFFFFFBEB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '학과 나섬이 투어',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  '학과 건물을 돌아다니며 학과별 나섬이를 수집하고 캠퍼스 구조를 익혀보세요.',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DepartmentNasumiTourScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school),
                    label: const Text(
                      '학과 나섬이 보러가기',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: '동아리 모집', action: '전체 보기'),
          const SizedBox(height: 12),
          const ClubCard(title: 'SkyEdge', category: '드론 · ROS2 · PX4 · 임베디드', deadline: 'D-3', place: '정보과학관'),
          const SizedBox(height: 10),
          const ClubCard(title: '배재 방송국', category: '방송 · 영상 제작', deadline: 'D-7', place: '방송센터'),
          const SizedBox(height: 24),
          const SectionTitle(title: '도감 완성도'),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('37%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.blue)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.37,
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.yellow,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 10),
                const Text('45 / 120 카드 수집 완료', style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CafeteriaMiniCard extends StatelessWidget {
  const CafeteriaMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CafeteriaDetailScreen(),
          ),
        );
      },
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('학생식당', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text('오늘 메뉴', style: TextStyle(color: AppColors.sub, fontSize: 12)),
            const SizedBox(height: 2),
            const Text('돈육폭찹 정식', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('혼잡도 보통', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}


class CafeteriaDetailScreen extends StatefulWidget {
  const CafeteriaDetailScreen({super.key});

  @override
  State<CafeteriaDetailScreen> createState() => _CafeteriaDetailScreenState();
}

class _CafeteriaDetailScreenState extends State<CafeteriaDetailScreen> {
  String selectedFeedback = '';
  bool menuCardSaved = false;

  final String menuCardTitle = '돈육폭찹 정식 카드';

  @override
  void initState() {
    super.initState();
    loadMenuCardState();
  }

  Future<void> loadMenuCardState() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList('collected_cards') ?? [];
    setState(() {
      menuCardSaved = current.contains(menuCardTitle);
    });
  }

  Future<void> acquireMenuCard() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList('collected_cards') ?? [];

    if (!current.contains(menuCardTitle)) {
      current.add(menuCardTitle);
      await prefs.setStringList('collected_cards', current);
    }

    setState(() {
      menuCardSaved = true;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('돈육폭찹 정식 카드를 획득했습니다.'),
      ),
    );
  }

  String congestionStatus() {
    final now = DateTime.now();
    final minutes = now.hour * 60 + now.minute;

    final startLunch = 11 * 60 + 30;
    final peakStart = 12 * 60;
    final peakEnd = 12 * 60 + 40;
    final lateLunch = 13 * 60 + 10;

    if (minutes < startLunch) return '준비 중';
    if (minutes >= peakStart && minutes <= peakEnd) return '혼잡';
    if (minutes <= lateLunch) return '보통';
    return '여유';
  }

  Color congestionColor(String status) {
    switch (status) {
      case '혼잡':
        return AppColors.red;
      case '보통':
        return AppColors.orange;
      case '여유':
        return AppColors.green;
      default:
        return AppColors.sub;
    }
  }

  String waitingTime(String status) {
    switch (status) {
      case '혼잡':
        return '약 12~15분';
      case '보통':
        return '약 5~7분';
      case '여유':
        return '거의 없음';
      default:
        return '운영 전';
    }
  }

  String recommendedTime(String status) {
    switch (status) {
      case '혼잡':
        return '12:40 이후 방문 추천';
      case '보통':
        return '지금 방문 가능';
      case '여유':
        return '지금 바로 방문 추천';
      default:
        return '11:30 이후 확인';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = congestionStatus();
    final color = congestionColor(status);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Header(
                      title: '학생식당',
                      subtitle: '오늘 메뉴와 혼잡도를 확인하세요.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppCard(
                color: AppColors.blue,
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 학생식당',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '돈육폭찹 정식',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '운영 시간 11:30 ~ 13:30',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const Nasumi(size: 92, label: '식당'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '현재 혼잡도',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '예상 대기 시간: ${waitingTime(status)}',
                            style: const TextStyle(
                              color: AppColors.sub,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        recommendedTime(status),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '오늘 메뉴 정보',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    const ProfileRow(label: '메뉴', value: '돈육폭찹 정식'),
                    const ProfileRow(label: '예상 가격', value: '학생식당 기준'),
                    const ProfileRow(label: '메뉴 카드', value: '획득 가능'),
                    const ProfileRow(label: '식당 나섬이', value: '출현 중'),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: menuCardSaved ? AppColors.green : AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: menuCardSaved ? null : acquireMenuCard,
                        icon: Icon(menuCardSaved ? Icons.check_circle : Icons.collections_bookmark),
                        label: Text(
                          menuCardSaved ? '메뉴 카드 획득 완료' : '오늘의 메뉴 카드 받기',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '메뉴 만족도',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'v0.5에서는 서버 저장 없이 화면 상태만 반영합니다. 이후 익명 집계 방식으로 확장할 수 있습니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        feedbackChip('맛있어요'),
                        feedbackChip('보통이에요'),
                        feedbackChip('아쉬워요'),
                        feedbackChip('줄이 길어요'),
                        feedbackChip('다시 먹고 싶어요'),
                      ],
                    ),
                    if (selectedFeedback.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '선택한 의견: $selectedFeedback',
                          style: const TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                color: const Color(0xFFFFFBEB),
                child: Row(
                  children: const [
                    Icon(Icons.lightbulb_outline, color: AppColors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '학생식당은 배재Pick을 매일 열게 만드는 핵심 진입점입니다. 이후 CityBrain API와 연결해 실제 혼잡도와 운영 데이터를 반영할 수 있습니다.',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
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

  Widget feedbackChip(String label) {
    final selected = selectedFeedback == label;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: selected ? Colors.white : AppColors.text,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.blue,
      onSelected: (_) {
        setState(() {
          selectedFeedback = label;
        });
      },
    );
  }
}

class MissionMiniCard extends StatelessWidget {
  const MissionMiniCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘의 미션', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('배재관 QR 찾기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.33,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 8),
          const Text('1 / 3 완료', style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class CampusMapScreen extends StatelessWidget {
  const CampusMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(title: '3D 캠퍼스맵', subtitle: '건물, 미션, 나섬이, 학생식당, 흡연구역을 한눈에 확인하세요.'),
          const SizedBox(height: 16),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCEBFA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const Positioned(left: 22, top: 22, child: MapBuilding(label: '배재관', color: AppColors.orange, width: 120, height: 90)),
                  const Positioned(right: 26, top: 40, child: MapBuilding(label: '정보과학관', color: AppColors.blue, width: 110, height: 110)),
                  const Positioned(left: 64, bottom: 120, child: MapBuilding(label: '학생식당', color: AppColors.green, width: 130, height: 70)),
                  const Positioned(right: 58, bottom: 90, child: MapBuilding(label: '도서관', color: AppColors.purple, width: 125, height: 85)),
                  const Positioned(left: 190, top: 210, child: Nasumi(size: 58, label: '책')),
                  Positioned(
                    left: 18,
                    bottom: 18,
                    right: 18,
                    child: AppCard(
                      color: Colors.white.withOpacity(0.94),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('도서관 나섬이', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          SizedBox(height: 4),
                          Text('Rare · 도서관 2층 열람실 · 남은 시간 01:42:10', style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600)),
                          SizedBox(height: 12),
                          Text('위치 보기', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w900)),
                        ],
                      ),
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

class MapBuilding extends StatelessWidget {
  final String label;
  final Color color;
  final double width;
  final double height;

  const MapBuilding({
    super.key,
    required this.label,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.15,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      ['도서관 나섬이', 'Rare', true],
      ['학생식당 나섬이', 'Common', false],
      ['배재관 장소 카드', 'Common', true],
      ['축제 나섬이', 'Limited', false],
      ['IT관 개발자 나섬이', 'Rare', true],
      ['운동장 러너 나섬이', 'Common', false],
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(title: '캠퍼스 도감', subtitle: '완성도 37% · 45 / 120'),
          const SizedBox(height: 18),
          GridView.builder(
            itemCount: cards.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final card = cards[index];
              final owned = card[2] as bool;
              return AppCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    owned
                        ? const Nasumi(size: 86, label: 'P')
                        : Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                            child: const Icon(Icons.lock, color: Colors.white),
                          ),
                    const SizedBox(height: 14),
                    Text(card[0] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(card[1] as String, style: TextStyle(color: owned ? AppColors.blue : AppColors.sub, fontWeight: FontWeight.w800)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


class DepartmentNasumiTourScreen extends StatelessWidget {
  const DepartmentNasumiTourScreen({super.key});

  final List<Map<String, String>> departments = const [
    {
      'name': '컴퓨터공학과 나섬이',
      'code': 'CS-NASUMI',
      'building': '정보과학관',
      'desc': '코딩, 시스템, 앱, 임베디드에 관심 있는 학생들을 위한 학과 나섬이입니다.',
      'office': '학과 사무실은 건물 안내 또는 학과 홈페이지를 참고하세요.',
    },
    {
      'name': '인공지능학과 나섬이',
      'code': 'AI-NASUMI',
      'building': '정보과학관',
      'desc': 'AI, 데이터, 모델링에 관심 있는 학생들을 위한 학과 나섬이입니다.',
      'office': '학과 사무실/연구실 위치는 공식 안내 기준으로 확인합니다.',
    },
    {
      'name': '게임공학과 나섬이',
      'code': 'GAME-NASUMI',
      'building': '콘텐츠 관련 건물',
      'desc': '게임, 그래픽, 인터랙티브 콘텐츠를 좋아하는 학생들을 위한 나섬이입니다.',
      'office': '정확한 위치는 학과 공식 안내를 따릅니다.',
    },
    {
      'name': '경영학과 나섬이',
      'code': 'BUSINESS-NASUMI',
      'building': '경영 관련 건물',
      'desc': '기획, 마케팅, 창업, 운영에 관심 있는 학생들을 위한 나섬이입니다.',
      'office': '학과 사무실 위치는 공식 안내를 따릅니다.',
    },
    {
      'name': '관광축제한류대학 나섬이',
      'code': 'TOURISM-NASUMI',
      'building': '관광축제한류대학 관련 건물',
      'desc': '축제, 관광, 한류 콘텐츠를 좋아하는 학생들을 위한 나섬이입니다.',
      'office': '학과 사무실 위치는 공식 안내를 따릅니다.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Header(
                      title: '학과 나섬이 투어',
                      subtitle: '학과 건물을 탐험하고 나섬이를 수집하세요.',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppCard(
                color: AppColors.darkBlue,
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '캠퍼스 공간 학습',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '다른 학과 건물을\n돌아볼 명분을 만듭니다.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '신입생, 통학생, 기숙사생 모두에게 필요한 캠퍼스 탐험 기능입니다.',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    Nasumi(size: 92, label: '학과'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                color: const Color(0xFFFFFBEB),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'v0.7은 실시간 위치 추적 없이 코드 입력 기반으로 동작합니다. 학생 이동 동선은 서버에 저장하지 않습니다.',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SectionTitle(title: '수집 가능한 학과 나섬이'),
              const SizedBox(height: 12),
              ...departments.map((department) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DepartmentCard(department: department),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class DepartmentCard extends StatelessWidget {
  final Map<String, String> department;

  const DepartmentCard({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    final name = department['name']!;
    final code = department['code']!;
    final building = department['building']!;
    final desc = department['desc']!;
    final office = department['office']!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Nasumi(size: 64, label: '학과'),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(building, style: const TextStyle(color: AppColors.sub, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            desc,
            style: const TextStyle(color: AppColors.sub, fontWeight: FontWeight.w700, height: 1.5),
          ),
          const SizedBox(height: 10),
          Text(
            office,
            style: const TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600, height: 1.5),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '수집 코드: $code',
              style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MissionCodeScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_2),
              label: const Text(
                '코드 입력하러 가기',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClubScreen extends StatelessWidget {
  const ClubScreen({super.key});

  static const List<Map<String, String>> clubs = [
    {
      'title': 'SkyEdge',
      'category': '드론 · ROS2 · PX4 · 임베디드',
      'deadline': 'D-3',
      'place': '정보과학관',
      'period': '5.20 ~ 6.10',
      'target': '1~2학년 우선, 개발·하드웨어 관심자',
      'day': '주 1회 회의 + 프로젝트별 실습',
      'beginner': '가능',
      'skills': '성실함, GitHub 사용 의지, 실습 참여',
      'intro': 'SkyEdge는 드론, ROS2, PX4, 임베디드, 관제 시스템을 다루는 프로젝트형 동아리입니다.',
      'apply': 'Google Form mock',
      'contact': 'Open KakaoTalk mock',
    },
    {
      'title': '배재 방송국',
      'category': '방송 · 영상 제작',
      'deadline': 'D-7',
      'place': '방송센터',
      'period': '5.24 ~ 6.14',
      'target': '영상, 촬영, 편집, 아나운싱에 관심 있는 학생',
      'day': '주 1회 정기 활동',
      'beginner': '가능',
      'skills': '책임감, 행사 참여, 콘텐츠 제작 관심',
      'intro': '교내 행사와 학생 콘텐츠를 기록하고 제작하는 방송·영상 중심 동아리입니다.',
      'apply': 'Instagram DM mock',
      'contact': 'Open KakaoTalk mock',
    },
    {
      'title': 'GoPaejae',
      'category': '봉사 · 지역사회 · 기획',
      'deadline': 'D-5',
      'place': '학생회관',
      'period': '5.22 ~ 6.12',
      'target': '봉사와 행사 기획에 관심 있는 재학생',
      'day': '격주 활동',
      'beginner': '가능',
      'skills': '기획력, 협업, 꾸준한 참여',
      'intro': '지역사회와 학교 행사를 연결하는 봉사·기획 중심 동아리입니다.',
      'apply': 'Google Form mock',
      'contact': 'Club contact mock',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(
            title: '캠퍼스 참여 허브',
            subtitle: '동아리·행사·프로젝트 모집을 한곳에 모으는 참여 공고관입니다.',
          ),
          const SizedBox(height: 18),
          AppCard(
            color: const Color(0xFFEFF6FF),
            child: Row(
              children: const [
                Icon(Icons.campaign_outlined, color: AppColors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '캠퍼스 참여 허브는 행사를 직접 주최하지 않고, 모집·행사·프로젝트 참여 정보를 구조화해 보여주는 인프라입니다.',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '동아리 운영진인가요?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  '공고 등록 요청 mock으로 동아리 모집 공고 등록 흐름을 테스트할 수 있습니다.',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkBlue,
                      side: const BorderSide(color: AppColors.darkBlue, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ClubNoticeSubmitMockScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.post_add_outlined),
                    label: const Text(
                      '공고 등록 요청',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '참여 유형',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                const Text(
                  '초기에는 동아리 모집부터 시작하고, 이후 학과 행사·프로젝트 팀원 모집·봉사·서포터즈 공고까지 확장할 수 있습니다.',
                  style: TextStyle(
                    color: AppColors.sub,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('동아리 모집')),
                    Chip(label: Text('학과/부서 행사')),
                    Chip(label: Text('프로젝트 팀원')),
                    Chip(label: Text('봉사/서포터즈')),
                    Chip(label: Text('공모전 팀원')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            color: AppColors.darkBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '운영 원칙',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '배재Pick은 행사를 주최하지 않습니다. 공고 등록, 노출, 관심 저장, 신청 흐름을 보조하는 참여 인프라입니다.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...clubs.map((club) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClubCard(
                title: club['title']!,
                category: club['category']!,
                deadline: club['deadline']!,
                place: club['place']!,
                club: club,
              ),
            );
          }),
        ],
      ),
    );
  }
}


class ClubNoticeSubmitMockScreen extends StatefulWidget {
  const ClubNoticeSubmitMockScreen({super.key});

  @override
  State<ClubNoticeSubmitMockScreen> createState() => _ClubNoticeSubmitMockScreenState();
}

class _ClubNoticeSubmitMockScreenState extends State<ClubNoticeSubmitMockScreen> {
  final clubNameController = TextEditingController();
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final contactController = TextEditingController();
  final descController = TextEditingController();

  String selectedType = '정기 모집';

  @override
  void dispose() {
    clubNameController.dispose();
    titleController.dispose();
    categoryController.dispose();
    contactController.dispose();
    descController.dispose();
    super.dispose();
  }

  void submitMock() {
    final clubName = clubNameController.text.trim();
    final title = titleController.text.trim();

    if (clubName.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동아리명과 공고 제목은 필수입니다.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('공고 등록 요청 완료'),
        content: Text(
          '$clubName 공고가 등록 요청 mock으로 접수되었습니다.\n\n'
          '실제 출시 전에는 관리자 승인 후 공고관에 노출되는 구조가 필요합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget field({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = ['정기 모집', '프로젝트 모집', '행사 스태프', '신입 부원 모집', '기타'];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              const Header(
                title: '동아리 공고 등록 요청',
                subtitle: '익명 게시판이 아닌 공고형 모집 구조를 테스트합니다.',
              ),
              const SizedBox(height: 18),
              AppCard(
                color: AppColors.darkBlue,
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notice Submit Mock',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '동아리 운영진이\n공고를 요청하는 흐름',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '현재는 서버 저장 없이 화면 흐름만 검증합니다.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Nasumi(size: 84, label: '공고'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '등록 요청 정보',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    field(
                      label: '동아리명',
                      hint: '예: SkyEdge',
                      controller: clubNameController,
                    ),
                    field(
                      label: '공고 제목',
                      hint: '예: 드론/임베디드 프로젝트 팀원 모집',
                      controller: titleController,
                    ),
                    field(
                      label: '분야',
                      hint: '예: 드론 · ROS2 · PX4',
                      controller: categoryController,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        items: types
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => selectedType = value);
                        },
                        decoration: InputDecoration(
                          labelText: '모집 유형',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    field(
                      label: '연락 방법',
                      hint: '예: 인스타 DM, 오픈채팅, 대표 연락처',
                      controller: contactController,
                    ),
                    field(
                      label: '공고 설명',
                      hint: '모집 대상, 활동 내용, 초보 가능 여부 등을 적어주세요.',
                      controller: descController,
                      maxLines: 5,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: submitMock,
                        icon: const Icon(Icons.send_outlined),
                        label: const Text(
                          '공고 등록 요청 mock',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '운영 원칙',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '이 기능은 자유 익명 게시판이 아니라 동아리 모집 정보를 구조화해서 보여주는 공고관을 목표로 합니다. 실제 출시 전에는 관리자 승인, 학교 이메일 인증, 동아리 대표 권한 확인이 필요합니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
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


class ClubDetailScreen extends StatefulWidget {
  final Map<String, String> club;

  const ClubDetailScreen({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadFavorite();
  }

  Future<void> loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_clubs') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.club['title']);
    });
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_clubs') ?? [];
    final title = widget.club['title']!;

    if (favorites.contains(title)) {
      favorites.remove(title);
    } else {
      favorites.add(title);
    }

    await prefs.setStringList('favorite_clubs', favorites);

    setState(() {
      isFavorite = favorites.contains(title);
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite ? '$title 관심 동아리에 저장했습니다.' : '$title 관심 동아리에서 제거했습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              AppCard(
                color: AppColors.blue,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '모집 중',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            club['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            club['category']!,
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const Nasumi(size: 88, label: '동아리'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('모집 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    ProfileRow(label: '모집 기간', value: club['period']!),
                    ProfileRow(label: '모집 대상', value: club['target']!),
                    ProfileRow(label: '활동 장소', value: club['place']!),
                    ProfileRow(label: '활동 요일', value: club['day']!),
                    ProfileRow(label: '초보 가능', value: club['beginner']!),
                    ProfileRow(label: '필요 역량', value: club['skills']!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('동아리 소개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Text(
                      club['intro']!,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                color: const Color(0xFFFFFBEB),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'v0.8에서는 실제 외부 링크 대신 mock 링크로 표시합니다. 실제 출시 전에는 동아리 대표 또는 관리자 승인 방식이 필요합니다.',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: isFavorite ? AppColors.green : AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: toggleFavorite,
                  icon: Icon(isFavorite ? Icons.check_circle : Icons.bookmark_add),
                  label: Text(
                    isFavorite ? '관심 동아리 저장됨' : '관심 동아리 저장',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: const BorderSide(color: AppColors.blue, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('지원 링크: ${club['apply']}')),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text(
                    '지원 링크 열기 mock',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkBlue,
                    side: const BorderSide(color: AppColors.darkBlue, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('문의 링크: ${club['contact']}')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(
                    '문의 링크 열기 mock',
                    style: TextStyle(fontWeight: FontWeight.w900),
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

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  int favoriteClubCount = 0;
  int collectedCardCount = 0;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteClubCount = (prefs.getStringList('favorite_clubs') ?? []).length;
      collectedCardCount = (prefs.getStringList('collected_cards') ?? []).length;
    });
  }

  Future<void> resetLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('favorite_clubs');
    await prefs.remove('collected_cards');

    await loadStats();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('로컬 저장 데이터를 초기화했습니다.'),
      ),
    );
  }

  Future<void> confirmReset() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('로컬 데이터 초기화'),
          content: const Text(
            '이 기기에 저장된 도감 카드와 관심 동아리 정보가 삭제됩니다. 서버 데이터는 사용하지 않으므로 현재는 이 기기에서만 초기화됩니다.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('초기화'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await resetLocalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        children: [
          const Nasumi(size: 96, label: 'P'),
          const SizedBox(height: 14),
          const Text('영준', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('컴퓨터공학과 · 캠퍼스 탐험가', style: TextStyle(color: AppColors.sub, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                const ProfileRow(label: '도감 완성도', value: '로컬 기준'),
                ProfileRow(label: '로컬 획득 카드', value: '$collectedCardCount개'),
                const ProfileRow(label: '완료 미션', value: '코드 기반'),
                const ProfileRow(label: '대표 칭호', value: '신입 탐험가'),
                ProfileRow(label: '관심 동아리', value: '$favoriteClubCount개'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                side: const BorderSide(color: AppColors.blue, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text(
                '로컬 상태 새로고침',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyGuideScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text(
                '개인정보 / 로컬 저장 안내',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: confirmReset,
              icon: const Icon(Icons.delete_outline),
              label: const Text(
                '로컬 데이터 초기화',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class AppStatusRoadmapScreen extends StatelessWidget {
  const AppStatusRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final done = [
      'Splash / Login mock',
      '홈 / 오늘의 Pick',
      '학생식당 상세 / 혼잡도 mock',
      '메뉴 카드 획득',
      'QR 스캔 mock',
      '코드 기반 미션',
      '캠퍼스 도감',
      '학과 나섬이 투어',
      '동아리 공고관',
      '관심 동아리 저장',
      '개인정보 안내',
      '로컬 데이터 초기화',
      '테스터 피드백 허브',
    ];

    final notYet = [
      '실제 학교 이메일 인증',
      '실제 QR 카메라 스캔',
      '실시간 위치 추적',
      '실제 학생식당 데이터 연동',
      '실제 동아리 공고 등록',
      '관리자 콘솔',
      '공식 학교 승인',
      '나섬이 캐릭터 사용 허가 확인',
      'Play Store 정식 배포 signing',
    ];

    final roadmap = [
      {
        'title': '1단계: 내부 테스트',
        'desc': 'APK를 소수 재학생에게 전달해 설치 이유와 재방문 이유를 검증합니다.',
      },
      {
        'title': '2단계: 학생식당 데이터 실험',
        'desc': '메뉴, 혼잡도, 만족도 흐름이 실제 사용 이유가 되는지 확인합니다.',
      },
      {
        'title': '3단계: 나섬이/도감 루프 강화',
        'desc': '학과별 나섬이, 건물 미션, 칭호, 랭킹 등 재방문 요소를 보강합니다.',
      },
      {
        'title': '4단계: 학교/동아리 협의',
        'desc': '학교명, 캐릭터, 동아리 공고 운영 주체, 개인정보 정책을 정리합니다.',
      },
      {
        'title': '5단계: Play Store 내부 테스트',
        'desc': 'AAB, 개인정보처리방침 URL, 앱 아이콘, 스크린샷을 준비해 내부 테스트를 진행합니다.',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              const Header(
                title: '앱 상태 / 로드맵',
                subtitle: '현재 되는 것과 아직 안 되는 것을 명확히 보여줍니다.',
              ),
              const SizedBox(height: 18),
              AppCard(
                color: AppColors.darkBlue,
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '현재 단계',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '내부 테스트 가능한\nFlutter MVP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '공식 학교 앱이 아니라 사용성 검증용 MVP입니다.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Nasumi(size: 84, label: 'MVP'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '현재 구현된 것',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    ...done.map((item) => _StatusLine(icon: Icons.check_circle, text: item)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '아직 구현되지 않은 것',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '아래 기능은 실제 출시 전에 별도 구현, 권한 검토, 학교 협의가 필요합니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...notYet.map((item) => _StatusLine(icon: Icons.pending_outlined, text: item)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...roadmap.map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step['desc']!,
                          style: const TextStyle(
                            color: AppColors.sub,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.sub,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class TesterFeedbackScreen extends StatelessWidget {
  const TesterFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'title': '1. 설치 이유',
        'items': [
          '학생식당 정보 때문에 앱을 열 이유가 있는가?',
          '오늘 메뉴, 혼잡도, 추천 방문 시간이 실제로 필요해 보이는가?',
          '학생식당이 첫 진입점으로 충분한가?',
        ],
      },
      {
        'title': '2. 재방문 이유',
        'items': [
          '나섬이 도감 수집이 다시 들어오게 만드는가?',
          '미션 코드 입력 흐름이 이해하기 쉬운가?',
          'QR 스캔 mock이 실제 기능으로 바뀌면 쓸 것 같은가?',
        ],
      },
      {
        'title': '3. 캠퍼스 탐험',
        'items': [
          '학과 나섬이 투어가 학교 구조를 익히는 데 도움이 되는가?',
          '신입생, 통학생, 기숙사생에게 실제 가치가 있는가?',
          '교수님 연구실/학과 사무실 안내까지 확장할 필요가 있는가?',
        ],
      },
      {
        'title': '4. 동아리 공고관',
        'items': [
          '동아리 모집 정보가 게시판보다 정리되어 보이는가?',
          '익명 댓글 없이 공고형 구조만 있는 것이 더 나은가?',
          '동아리 운영진이 직접 올릴 만한 구조인가?',
        ],
      },
      {
        'title': '5. 신뢰 / 개인정보',
        'items': [
          '서버 없이 로컬 저장 중심이라는 설명이 안심되는가?',
          '학교 이메일 인증은 꼭 필요해 보이는가?',
          '공식 앱이 아니라 MVP라는 점이 명확한가?',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              const Header(
                title: '테스트 피드백',
                subtitle: '내부 테스터가 봐야 할 핵심 질문입니다.',
              ),
              const SizedBox(height: 18),
              AppCard(
                color: AppColors.darkBlue,
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'v1.7 Internal Test Hub',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '완성도보다 중요한 건\n계속 쓸 이유가 있는지입니다.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Nasumi(size: 82, label: 'QA'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '테스트 기준',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '이 앱은 아직 공식 학교 앱이 아닙니다. 실제 학교 데이터와 연동된 완성품도 아닙니다. 지금 확인할 것은 기능의 완성도가 아니라, 배재대 학생이 설치하고 다시 열 이유가 있는지입니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...sections.map((section) {
                final items = section['items'] as List<String>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.w900)),
                                Expanded(
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                      color: AppColors.sub,
                                      fontWeight: FontWeight.w700,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              AppCard(
                color: AppColors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '최종 질문',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '이 앱을 실제로 설치해서 계속 쓸 이유가 있는가?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
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


class PrivacyGuideScreen extends StatelessWidget {
  const PrivacyGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              const Header(
                title: '개인정보 안내',
                subtitle: 'v1.0은 서버 저장 없이 로컬 중심으로 동작합니다.',
              ),
              const SizedBox(height: 20),
              AppCard(
                color: AppColors.darkBlue,
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '최소 수집 원칙',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '먼저 유용성을 증명하고,\n민감한 정보는 나중에 필요한 만큼만.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Nasumi(size: 88, label: '보안'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const PrivacySection(
                title: 'v1.0에서 저장하는 것',
                items: [
                  '이 기기 안의 도감 수집 상태',
                  '이 기기 안의 관심 동아리 상태',
                  '코드 기반 미션 완료 상태',
                  '메뉴 카드 획득 상태',
                ],
              ),
              const SizedBox(height: 14),
              const PrivacySection(
                title: 'v1.0에서 저장하지 않는 것',
                items: [
                  '실명',
                  '정확한 학번',
                  '전화번호',
                  '실시간 위치',
                  '개인별 식당 방문 기록 서버 저장',
                  '시설 신고자 신원',
                  '교수님 개인 연구실 방문 기록',
                ],
              ),
              const SizedBox(height: 14),
              const PrivacySection(
                title: '향후 인증 계획',
                items: [
                  'Firebase 또는 Supabase 인증 검토',
                  '학교 이메일 인증 검토',
                  '닉네임 / 학과 / 학년 중심의 최소 프로필',
                  '서버 동기화는 사용자 반응 확인 후 도입',
                ],
              ),
              const SizedBox(height: 14),
              AppCard(
                color: const Color(0xFFFFFBEB),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: AppColors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '배재대학교 명칭과 나섬이 캐릭터 사용은 공식 출시 전 학교 측 확인이 필요합니다.',
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          height: 1.5,
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

class PrivacySection extends StatelessWidget {
  final String title;
  final List<String> items;

  const PrivacySection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w900)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
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

class Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const Header({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Nasumi(size: 52, label: 'P'),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const SectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        if (action != null) Text(action!, style: const TextStyle(fontSize: 13, color: AppColors.blue, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class ClubCard extends StatelessWidget {
  final String title;
  final String category;
  final String deadline;
  final String place;
  final Map<String, String>? club;

  const ClubCard({
    super.key,
    required this.title,
    required this.category,
    required this.deadline,
    required this.place,
    this.club,
  });

  @override
  Widget build(BuildContext context) {
    final card = AppCard(
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.flight_takeoff, color: AppColors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(category, style: const TextStyle(color: AppColors.sub, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('활동 장소: $place', style: const TextStyle(fontSize: 12, color: AppColors.sub)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(999)),
            child: Text(deadline, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (club == null) {
      return card;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClubDetailScreen(club: club!),
          ),
        );
      },
      child: card,
    );
  }
}

class ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.sub, fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}



class QRMockScreen extends StatelessWidget {
  const QRMockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              const Header(
                title: 'QR 스캔',
                subtitle: 'v1.3에서는 실제 카메라 대신 mock 화면으로 제공합니다.',
              ),
              const SizedBox(height: 20),
              AppCard(
                color: AppColors.darkBlue,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 4),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          const Icon(Icons.qr_code_scanner, color: Colors.white, size: 84),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      '실제 QR 스캐너는 v1.4 이후 연동 예정',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '현재는 내부 테스트를 위해 코드 입력 방식으로 미션을 완료합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '왜 아직 mock인가요?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '실제 QR 스캔은 카메라 권한, 기기 테스트, 개인정보/위치 오해 가능성, 악용 방지 로직이 필요합니다. 내부 테스트 단계에서는 코드 입력으로 사용성을 먼저 검증합니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MissionCodeScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.keyboard),
                        label: const Text(
                          '코드 입력으로 미션 완료',
                          style: TextStyle(fontWeight: FontWeight.w900),
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

class MissionCodeScreen extends StatefulWidget {
  const MissionCodeScreen({super.key});

  @override
  State<MissionCodeScreen> createState() => _MissionCodeScreenState();
}

class _MissionCodeScreenState extends State<MissionCodeScreen> {
  final TextEditingController controller = TextEditingController();
  String? errorMessage;

  final Map<String, Map<String, String>> missionRewards = const {
    'BAEJAE-FOOD': {
      'title': '학생식당 나섬이',
      'rarity': 'Common',
      'desc': '학생식당 방문 미션을 완료해서 획득한 나섬이입니다.',
      'titleReward': '오늘의 식객',
    },
    'LIBRARY-NIGHT': {
      'title': '도서관 나섬이',
      'rarity': 'Rare',
      'desc': '시험기간 도서관 미션을 완료해서 획득한 나섬이입니다.',
      'titleReward': '밤샘 탐험가',
    },
    'IT-CODE': {
      'title': 'IT관 개발자 나섬이',
      'rarity': 'Rare',
      'desc': '정보과학관 개발자 미션을 완료해서 획득한 나섬이입니다.',
      'titleReward': '캠퍼스 빌더',
    },
    'CLUB-HUB': {
      'title': '동아리 헌터 배지',
      'rarity': 'Badge',
      'desc': '동아리 공고관 탐색 미션을 완료해서 획득한 배지입니다.',
      'titleReward': '동아리 탐색자',
    },
    'CLEAN-CAMPUS': {
      'title': '클린캠퍼스 배지',
      'rarity': 'Badge',
      'desc': '캠퍼스 경보와 흡연구역 안내 미션을 완료해서 획득한 배지입니다.',
      'titleReward': '클린캠퍼스 참여자',
    },
    'CS-NASUMI': {
      'title': '컴퓨터공학과 나섬이',
      'rarity': 'Department',
      'desc': '정보과학관에서 만날 수 있는 컴퓨터공학과 나섬이입니다.',
      'titleReward': '코드 빌더',
    },
    'AI-NASUMI': {
      'title': '인공지능학과 나섬이',
      'rarity': 'Department',
      'desc': 'AI와 데이터에 관심 있는 학생을 위한 인공지능학과 나섬이입니다.',
      'titleReward': 'AI 탐험가',
    },
    'GAME-NASUMI': {
      'title': '게임공학과 나섬이',
      'rarity': 'Department',
      'desc': '게임과 인터랙티브 콘텐츠를 좋아하는 학생을 위한 게임공학과 나섬이입니다.',
      'titleReward': '캠퍼스 플레이어',
    },
    'BUSINESS-NASUMI': {
      'title': '경영학과 나섬이',
      'rarity': 'Department',
      'desc': '비즈니스와 기획 감각을 가진 학생을 위한 경영학과 나섬이입니다.',
      'titleReward': '비즈니스 탐험가',
    },
    'TOURISM-NASUMI': {
      'title': '관광축제한류대학 나섬이',
      'rarity': 'Department',
      'desc': '축제, 관광, 한류 콘텐츠를 좋아하는 학생을 위한 학과 나섬이입니다.',
      'titleReward': '캠퍼스 가이드',
    },
  };

  Future<void> submitCode() async {
    final code = controller.text.trim().toUpperCase();

    if (!missionRewards.containsKey(code)) {
      setState(() {
        errorMessage = '등록되지 않은 미션 코드입니다. 테스트 코드 목록을 확인하세요.';
      });
      return;
    }

    final reward = missionRewards[code]!;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList('collected_cards') ?? [];
    final title = reward['title']!;

    if (!current.contains(title)) {
      current.add(title);
      await prefs.setStringList('collected_cards', current);
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MissionCompleteScreen(
          code: code,
          title: title,
          rarity: reward['rarity']!,
          desc: reward['desc']!,
          titleReward: reward['titleReward']!,
        ),
      ),
    );
  }

  void setQuickCode(String code) {
    setState(() {
      controller.text = code;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final codes = missionRewards.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 8),
              const Header(
                title: '미션 코드',
                subtitle: '건물·식당·동아리 미션 코드를 입력하세요.',
              ),
              const SizedBox(height: 18),
              AppCard(
                color: AppColors.blue,
                child: Row(
                  children: const [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '코드 기반 미션',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'QR 없이도 내부 테스트가\n가능한 미션 구조입니다.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Nasumi(size: 86, label: '미션'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('미션 코드 입력', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: '예: BAEJAE-FOOD',
                        errorText: errorMessage,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: submitCode,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          '미션 완료하기',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkBlue,
                          side: const BorderSide(color: AppColors.darkBlue, width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QRMockScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text(
                          'QR 스캔 mock 보기',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('빠른 테스트 코드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    const Text(
                      '내부 테스트에서는 아래 코드를 눌러 바로 입력할 수 있습니다.',
                      style: TextStyle(
                        color: AppColors.sub,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: codes.map((code) {
                        return ActionChip(
                          label: Text(
                            code,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          onPressed: () => setQuickCode(code),
                        );
                      }).toList(),
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

class MissionCompleteScreen extends StatelessWidget {
  final String code;
  final String title;
  final String rarity;
  final String desc;
  final String titleReward;

  const MissionCompleteScreen({
    super.key,
    required this.code,
    required this.title,
    required this.rarity,
    required this.desc,
    required this.titleReward,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Nasumi(size: 148, label: '획득'),
              const SizedBox(height: 24),
              const Text(
                '미션 완료!',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                code,
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.yellow.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        rarity,
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.sub,
                        height: 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '칭호 진행도: $titleReward +1',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    '도감으로 돌아가기',
                    style: TextStyle(fontWeight: FontWeight.w900),
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
