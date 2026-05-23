import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return AppCard(
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
            child: const Text('혼잡도 여유', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
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

class ClubScreen extends StatelessWidget {
  const ClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(title: '동아리 공고관', subtitle: '익명 게시판이 아닌, 공식형 동아리 모집 공고 모음입니다.'),
          SizedBox(height: 18),
          ClubCard(title: 'SkyEdge', category: '드론 · ROS2 · PX4 · 임베디드', deadline: 'D-3', place: '정보과학관'),
          SizedBox(height: 12),
          ClubCard(title: '배재 방송국', category: '방송 · 영상 제작', deadline: 'D-7', place: '방송센터'),
          SizedBox(height: 12),
          ClubCard(title: 'GoPaejae', category: '봉사 · 지역사회 · 기획', deadline: 'D-5', place: '학생회관'),
        ],
      ),
    );
  }
}

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

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
              children: const [
                ProfileRow(label: '도감 완성도', value: '37%'),
                ProfileRow(label: '획득 카드', value: '45개'),
                ProfileRow(label: '완료 미션', value: '18개'),
                ProfileRow(label: '대표 칭호', value: '신입 탐험가'),
                ProfileRow(label: '관심 동아리', value: '3개'),
              ],
            ),
          ),
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

  const ClubCard({
    super.key,
    required this.title,
    required this.category,
    required this.deadline,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
