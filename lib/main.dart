import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http; // 💡 인터넷 통신 패키지 추가
import 'dart:convert'; // 💡 JSON 변환 패키지 추가

// 💡 앱이 켜진 순간의 시간을 기록
final DateTime appStartTime = DateTime.now();

// 💡 증거 제출 팝업이 한 번이라도 떴는지 체크하는 전역 변수
bool hasShownAnswerPopup = false;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '34 Detective from another World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.blue),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          centerTitle: true,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LockScreen(),
        '/home': (context) => const HomeScreen(),
        '/call': (context) => const IncomingCallScreen(),
        '/messages': (context) => const MessageListScreen(),
        '/answer': (context) => const AnswerScreen(),
        '/chat': (context) => const ChatRoomScreen(),
        '/library': (context) => const LibraryScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/contacts': (context) => const ContactsScreen(),
        '/map': (context) => const MapScreen(),
        '/fortune': (context) => const FortuneScreen(),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}

// ==========================================
// 1. 잠금 화면 (Lock Screen)
// ==========================================
class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String pin = "";

  String _getKoreanWeekday(int weekday) {
    switch (weekday) {
      case 1: return '월요일';
      case 2: return '화요일';
      case 3: return '수요일';
      case 4: return '목요일';
      case 5: return '금요일';
      case 6: return '토요일';
      case 7: return '일요일';
      default: return '';
    }
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (value == '<') {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else {
        if (pin.length < 4) pin += value;

        if (pin.length == 4) {
          if (pin == "0304") {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            pin = "";
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('비밀번호가 일치하지 않습니다.'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      }
    });
  }

  // 💡 GridView를 대체하는 완벽한 반응형 키패드 줄(Row) 생성 함수
  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) {
          if (key.isEmpty) {
            return const Expanded(child: SizedBox.shrink());
          }
          return Expanded(
            child: GestureDetector(
              onTap: () => _onKeypadTap(key),
              child: Container(
                margin: const EdgeInsets.all(8), // 버튼 간의 간격
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                alignment: Alignment.center,
                child: key == '<'
                    ? const Icon(Icons.backspace_outlined, color: Colors.white)
                    : Text(key, style: const TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String timeString = "03:04";
    DateTime now = DateTime.now();
    String dateString = "${now.month}월 ${now.day}일 ${_getKoreanWeekday(now.weekday)}";

    return Scaffold(
      backgroundColor: Colors.blueGrey[300],
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Icon(Icons.lock, color: Colors.white),
            const SizedBox(height: 10),
            Text(timeString, style: const TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.w300)),
            Text(dateString, style: const TextStyle(fontSize: 16, color: Colors.white)),

            const Spacer(flex: 2),

            const Text('암호 입력', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < pin.length ? Colors.white : Colors.transparent,
                  border: Border.all(color: Colors.white),
                ),
              )),
            ),
            const SizedBox(height: 15),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('힌트: 변하지 않는 것'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                '힌트 보기',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // 💡 GridView 대신 Row와 Column의 조합으로 변경
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    _buildKeypadRow(['4', '5', '6']),
                    _buildKeypadRow(['7', '8', '9']),
                    _buildKeypadRow(['', '0', '<']),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. 홈 화면 (Home Screen)
// ==========================================
// 💡 타이머가 없어졌으므로 가벼운 StatelessWidget으로 다시 변경했습니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Center(child: Text('인터넷', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        content: const Text("최근 검색 기록은 '개인수영장 이용료'이다.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
        contentPadding: const EdgeInsets.only(top: 15, bottom: 20, left: 20, right: 20),
        actionsPadding: EdgeInsets.zero,
        actions: [
          const Divider(height: 1, thickness: 1),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Colors.blue, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 시간을 '03:04'로 고정(하드코딩)했습니다.
    String timeString = "03:04";

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5FF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(timeString, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: const [
                      Icon(Icons.signal_cellular_4_bar, size: 16),
                      SizedBox(width: 5),
                      Icon(Icons.battery_full, size: 16),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(20),
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                children: [
                  _buildAppIcon(context, '증거 제출', Colors.redAccent, Icons.my_library_books_outlined, '/answer'),
                  _buildAppIcon(context, '캘린더', Colors.grey, Icons.calendar_today, '/calendar'),
                  _buildAppIcon(context, '리디', Colors.blue, Icons.menu_book, '/library'),
                  _buildAppIcon(context, '갤러리', Colors.deepOrangeAccent, Icons.photo, '/gallery'),
                  _buildAppIcon(context, '지도', Colors.green[200]!, Icons.map, '/map'),
                  _buildAppIcon(context, '오늘의 운세', Colors.purple, Icons.star, '/fortune'),
                  _buildAppIcon(context, '인터넷', Colors.blueGrey, Icons.language, null, onTapOverride: () => _showInternetDialog(context)),
                  _buildAppIcon(context, '픽시위키', Colors.cyan, Icons.laptop_chromebook, null),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('외계인 되는 주파수', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('다음 곡: 연애하는 주파수', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_arrow),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDockIcon(context, '통화', Colors.green, Icons.call, '/contacts'),
                  _buildDockIcon(context, '메시지', Colors.green[400]!, Icons.chat_bubble, '/messages'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(BuildContext context, String title, Color color, IconData icon, String? route, {VoidCallback? onTapOverride}) {
    return GestureDetector(
      onTap: onTapOverride ?? () async {
        if (route != null) {
          final result = await Navigator.pushNamed(context, route);

          if (result != null && result is Map && result['action'] == 'trigger_ending') {
            String detectiveName = result['name'] ?? '탐정';
            String evidenceCount = result['count'] ?? '0개';

            Future.delayed(const Duration(seconds: 3), () {
              if (context.mounted) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => EndingScreen(detectiveName: detectiveName, evidenceCount: evidenceCount),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          }
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(child: Icon(icon, color: color == Colors.white ? Colors.black : Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDockIcon(BuildContext context, String title, Color color, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ==========================================
// 3. 캘린더 화면 (Calendar Screen)
// ==========================================
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,

        leading: const BackButton(color: Colors.blue),

        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('9월', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(width: 5),
            Text('2026', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: const [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 15),
          Icon(Icons.add, color: Colors.blue),
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('월', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('화', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('수', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('목', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('금', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('토', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('일', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                _buildCalendarRow(['31', '1', '2', '3', '4', '5', '6'], isPrevMonth: [true, false, false, false, false, false, false]),
                _buildCalendarRow(['7', '8', '9', '10', '11', '12', '13']),
                _buildCalendarRow(['14', '15', '16', '17', '18', '19', '20']),
                _buildCalendarRow(['21', '22', '23', '24', '25', '26', '27']),
                _buildCalendarRow(['28', '29', '30', '1', '2', '3', '4'], isNextMonth: [false, false, false, true, true, true, true]),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('다가오는 일정', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 0, bottom: 20),
              children: [
                _buildEventItem('2026년 9월 2일', '중요', Colors.blue),
                _buildEventItem('2026년 9월 7일', '오마카세', Colors.blue),
                _buildEventItem('2026년 9월 13일', '인천 앞바다', Colors.blue),
                _buildEventItem('2026년 9월 15일', '헌터협회 방문', Colors.blue),
                _buildEventItem('2026년 9월 20일', '영화관', Colors.blue),
                _buildEventItem('2026년 9월 25일', '수영장', Colors.blue),
                _buildEventItem('2026년 9월 30일', '일정 비우기', Colors.blue),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: '인박스'),
        ],
      ),
    );
  }

  Widget _buildEventItem(String date, String subtitle, Color dotColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)
          ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8, height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCalendarRow(
      List<String> days, {
        List<bool>? isPrevMonth,
        List<bool>? isNextMonth,
      }) {
    List<String> dotDays = ['2', '7', '13', '15', '20', '25', '30'];

    final now = DateTime.now();

    int selectedDay;

    if (now.year == 2026 && now.month == 9) {
      selectedDay = now.day;
    } else if (now.year == 2026 && now.month >= 10) {
      selectedDay = 12;
    } else {
      selectedDay = 12;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          bool isGrey =
              (isPrevMonth != null && isPrevMonth[index]) ||
                  (isNextMonth != null && isNextMonth[index]);

          bool isSelected =
              days[index] == selectedDay.toString() && !isGrey;

          bool hasDot = dotDays.contains(days[index]) && !isGrey;

          return Container(
            width: 35,
            height: 35,
            decoration: isSelected
                ? const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            )
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  days[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isGrey ? Colors.grey[300] : Colors.black),
                    fontWeight:
                    isSelected || hasDot
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (hasDot)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }}

// ==========================================
// 4. 연락처 화면 (Contacts Screen)
// ==========================================
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showKangOnly =
        _searchText.contains('애인') ||
            _searchText.contains('연인') ||
            _searchText.contains('남친');

    return Scaffold(
      appBar: AppBar(
        title: const Text('연락처'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: '검색',
                border: InputBorder.none,
              ),
            ),
          ),

          if (showKangOnly) ...[
            _buildGroupTitle('ㄱ'),
            _buildContactCard(
              context,
              '강창호',
              '010-XXXX-XXXX',
              Colors.deepPurple,
              true,
              true,
            ),
          ] else ...[
            _buildGroupTitle('ㄱ'),
            _buildContactCard(
              context,
              '강창호',
              '010-XXXX-XXXX',
              Colors.deepPurple,
              true,
              false,
            ),

            _buildGroupTitle('ㅅ'),
            _buildContactCard(
              context,
              '서에스더',
              '010-XXXX-XXXX',
              Colors.pink,
              false,
              false,
            ),
            _buildContactCard(
              context,
              '선우연',
              '010-XXXX-XXXX',
              Colors.lightBlue,
              false,
              false,
            ),

            _buildGroupTitle('ㅇ'),
            _buildContactCard(
              context,
              '안윤승',
              '010-XXXX-XXXX',
              Colors.blueGrey,
              false,
              false,
            ),

            _buildGroupTitle('ㅈ'),
            _buildContactCard(
              context,
              '정하성',
              '010-XXXX-XXXX',
              Colors.redAccent,
              false,
              false,
            ),
          ],

          const SizedBox(height: 30),

          if (showKangOnly)
            const Center(
              child: Text(
                '1명의 연락처',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            const Center(
              child: Text(
                '5명의 연락처',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGroupTitle(String letter) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 15, bottom: 5),
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactCard(
      BuildContext context,
      String name,
      String phone,
      Color color,
      bool isKang,
      bool isHiddenEnding,
      ) {
    return GestureDetector(
      onTap: isKang
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingCallScreen(
              isHiddenEnding: isHiddenEnding,
            ),
          ),
        );
      }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 25,
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  phone,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
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

// ==========================================
// 5. 전화 수신 화면 (Incoming Call Screen)
// ==========================================
class IncomingCallScreen extends StatelessWidget {
  final bool isHiddenEnding;

  const IncomingCallScreen({
    Key? key,
    this.isHiddenEnding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text('수신 전화', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text('강창호', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('휴대전화', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.blueGrey[100],
              child: const Icon(Icons.person, size: 80, color: Colors.blueGrey),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueAccent),
              ),
              child:
              Text(
                isHiddenEnding
                    ? '강창호에게 전화가 걸려왔다.\n비밀리에 특별한 애칭으로 저장되었다니...\n이번에는 받아보는 게 좋을 것 같다.'
                    : '강창호에게 전화가 걸려왔다.\n받을 때까지 계속 하려는 것 같다...',
                textAlign: TextAlign.center,
                style: const TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallButton(context, Colors.red, Icons.call_end, '거절', () {
                  Navigator.pop(context);
                }),
                _buildCallButton(
                  context,
                  Colors.green,
                  Icons.call,
                  '수락',
                      () {
                    if (isHiddenEnding) {
                      // 히든엔딩 조건을 만족한 경우에만 히든엔딩으로 이동
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EndingScreen(
                            detectiveName: '당신',
                            evidenceCount: '히든엔딩',
                            isHiddenEnding: true,
                          ),
                        ),
                      );
                    } else {
                      // 일반적인 경우
                      // 기존에는 아무 동작도 하지 않았으므로 그대로 유지
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(BuildContext context, Color color, IconData icon, String text, VoidCallback onTap) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: text,
          backgroundColor: color,
          onPressed: onTap,
          elevation: 0,
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(text),
      ],
    );
  }
}

// ==========================================
// 6. 메시지 목록 화면 (Message List Screen)
// ==========================================
class MessageListScreen extends StatelessWidget {
  const MessageListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('메시지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          _buildChatItem(context, '강창호', '방금 통화한 분, 휴대폰을 주인에게 돌려주기 싫다면 내 번호 쪽으로 언제든 편하게 연락 주세요.', false, true, Colors.deepPurple),
          _buildChatItem(context, '선우연', '네', false, true, Colors.lightBlue),
          _buildChatItem(context, '정하성', '연락처 저장 전에 마지막으로 확인차 문자드립니다.', false, true, Colors.redAccent),
          _buildChatItem(context, '서에스더', '큰 사거리에서 만나요!', false, true, Colors.pink),
          _buildChatItem(context, '국세청_고지', '꿈인가...?', false, true, Colors.grey),
          _buildChatItem(context, '안윤승', '좋아', false, true, Colors.blueGrey),
          _buildChatItem(context, '112', '[접수 완료, 출동에 다소 시간이 걸릴 수 있습니다.]', false, true, Colors.red),
          _buildChatItem(context, '긴급 재난 문자', '[Web 발신] 긴급 재난 문자 [던전 브레이크]', false, true, Colors.red),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String name, String message, bool hasBlueDot, bool isTarget, Color avatarColor) {
    return ListTile(
      onTap: isTarget ? () => Navigator.pushNamed(context, '/chat', arguments: name) : null,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor.withOpacity(0.2),
            child: Text(name.substring(0, 1), style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold)),
          ),
          if (hasBlueDot)
            Positioned(
              top: 0, left: 0,
              child: Container(
                width: 12, height: 12,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              ),
            )
        ],
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}

// ==========================================
// 7. 채팅방 화면 (Chat Room Screen)
// ==========================================
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({Key? key}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  // 💡 스크롤 위치를 제어하기 위한 컨트롤러 생성
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 💡 화면이 전부 그려진 직후에 맨 아래로 스크롤을 내리도록 예약합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 💡 스크롤을 맨 아래로 즉시 이동시키는 함수
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  List<Widget> _getChatHistory(String name) {
    switch (name) {
      case '서에스더':
        return [
          _buildOtherMessage('기려 씨, 식사 안 하셨으면 오늘 점심이나 같이 할래요? 제가 좋은 한정식집을 아는데요!'),
          _buildMyMessage('죄송합니다. 지금 경찰 조사로 바빠서....'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('안녕하세요! 어느덧 날씨가 선선해지고 있네요. ^^ 문득 기려 씨 생각이 나서 연락해봤어요. 혹시 식사는 하셨나요?'),
          _buildMyMessage('방금 먹었어요'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('김기려 헌터님! 오늘은 뭐 해요~~? 설마 이 시간에 벌써 저녁 먹었다고 할 건 아니죠? ㅎㅎㅎ'),
          _buildMyMessage('네 지금 지인이랑 초밥 먹는 중'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('기려 씨~~ 어제 경매는 재밌으셨어요? 제가 이번엔 다른 구경도 시켜 드리고 싶은데 혹시 이번 주에 시간 나요?'),
          _buildMyMessage('아뇨'),
          _buildOtherMessage('안 된다는 뜻이에요? 이번 주는 어디 게이트라도 들어가요? 바쁜가?'),
          _buildMyMessage('네'),
          _buildOtherMessage('그럼 언제가 괜찮아요? 일정 빠질 때까지 기다릴게요. ㅎㅎ'),
          _buildMyMessage('한 3달 뒤쯤이요'),
          _buildMyMessage('아무튼 지금은 답신하기가 어려우니 나중에 다시 연락 바랍니다.'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('기려 씨! 지금 잠깐 만날 수 있어요?'),
          _buildMyMessage('네'),
          _buildOtherMessage('큰 사거리에서 만나요!'),
        ];
      case '안윤승':
        return [
          _buildMyMessage('윤승아 나 기려인데 미안하지만 지금 납치됐다. 그런데 여기가 어딘지 몰라서 연락했어. 혹시 협회에 선우연 같은 사람 알면 나 좀 찾아달라고 해줄래? 너는 A급이라 협회랑 연락이 될 거 같아서 물어봤어.'),
          _buildDateDivider('20XX. XX. XX'),
          _buildMyMessage('윤승아, 오늘 약속 알지? F급 게이트는 시간도 얼마 안 걸린다니까 그냥 앞에서 기다려라'),
          _buildOtherMessage('넵!'),
          _buildMyMessage('일 끝나면 바로 스킬 마저 봐줄게'),
          _buildOtherMessage('넵! 진짜 고마워요 형'),
          _buildMyMessage('ㅇㅇ'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('형! 이따 같이 밥 먹을까요? 돼지갈비 어때요!'),
          _buildMyMessage('좋아'),
        ];
      case '국세청_고지':
        return [
          _buildOtherMessage('[Web발신](광고)\n[국세청]▶최종납부고지◀\n귀하(주민번호 뒤 ***일치) 명의 미납 국세 3,400만원 확인. 통지서는 자동폐기 예정.\n\n☆즉시확인☆ 안내문을 확인해 주세요.\n※오늘 18시까지 미입금 시 압류·출국금지 조치. 이의없음.\n\n㈜남포동 위탁발송'),
          _buildMyMessage('꿈인가...?'),
        ];
      case '112':
        return [
          _buildOtherMessage('[접수 완료, 출동에 다소 시간이 걸릴 수 있습니다. 긴급상황 시 112로 즉시 연락 주세요.]'),
          _buildMyMessage('여기까지 오는데 몇 분 정도 걸리죠? 저 그냥 가만히 있는 게 안전할까요?'),
          _buildOtherMessage('[접수 완료, 출동에 다소 시간이 걸릴 수 있습니다. 긴급상황 시 112로 즉시 연락 주세요.]'),
        ];
      case '긴급 재난 문자':
        return [
          _buildOtherMessage('[Web 발신] 긴급 재난 문자 [던전 브레이크]\n9월 12일 12:30 서울 마포구 인근 레드 게이트 발생 B급 마수 출현 경보 / 몬스터 이동경로 확인 후 대피'),
        ];
      case '선우연':
        return [
          _buildOtherMessage('9월 30일에 헌터협회 방문하시나요?'),
          _buildMyMessage('아뇨. 그날은 선약이 있어요.'),
          _buildOtherMessage('알겠습니다. 그러면 다음날에 들러주세요. 전달드릴 게 있어서요.'),
          _buildMyMessage('네.'),
        ];
      case '정하성':
        return [
          _buildOtherMessage('이쪽이 김기려 헌터님의 번호가 맞습니까?\n연락처 저장 전에 마지막으로 확인차 문자드립니다.'),
        ];
      case '강창호':
      default:
        return [
          _buildMyMessage('수영장 놀러가도 돼요?'),
          _buildOtherMessage('오늘은 안 돼.'),
          _buildMyMessage('영화보러 가는 날 가도 돼요?'),
          _buildOtherMessage('안 돼.'),
          _buildMyMessage('그럼 언제 가도 돼요?'),
          _buildOtherMessage('9월 25일.'),
          _buildDateDivider('20XX. XX. XX'),
          _buildMyMessage('오마카세 맛있었어요. 다음에도 데려가주세요.'),
          _buildOtherMessage('그래.'),
          _buildDateDivider('20XX. XX. XX'),
          _buildMyMessage('사주신 책 읽고 있는데요, 이거 제목이 왜 이래요?'),
          _buildOtherMessage('제목이 뭐.'),
          _buildMyMessage('저 외계인 아니에요. 외계인 되는 주파수도 듣고 있는데...'),
          _buildMyMessage('저기요?'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('9월 30일에 일정 비워둬.'),
          _buildMyMessage('왜요?'),
          _buildDateDivider('20XX. XX. XX'),
          _buildMyMessage('마탑 길드에 생긴 블루 게이트를 잠깐 보고 올게요. F급이니까 따로 와보실 필요는 없어요.'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('그러고 보니 김기려 헌터는 초밥을 종류 안 가리고 잘 먹네.'),
          _buildMyMessage('죄송한데 혹시 아직 화나신 상태면 미리 신호 좀 주실 수 있나요'),
          _buildDateDivider('20XX. XX. XX'),
          _buildOtherMessage('통화 거절?'),
          _buildOtherMessage('실수한 거겠지.'),
          _buildOtherMessage('괜찮아. 다시 걸어줄게.'),
          _buildOtherMessage('방금 통화한 분, 휴대폰을 주인에게 돌려주기 싫다면 내 번호 쪽으로 언제든 편하게 연락주세요.'),
        ];
    }
  }
  @override
  Widget build(BuildContext context) {
    final String contactName = ModalRoute.of(context)!.settings.arguments as String? ?? '강창호';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(contactName, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController, // 💡 ListView에 스크롤 컨트롤러를 연결합니다.
              padding: const EdgeInsets.all(15),
              children: _getChatHistory(contactName),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildMyMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 50),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(15)),
        child: Text(text, style: const TextStyle(color: Colors.white, height: 1.4)),
      ),
    );
  }

  Widget _buildOtherMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!)
        ),
        child: Text(text, style: const TextStyle(color: Colors.black, height: 1.4)),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(hintText: '텍스트 메시지', border: InputBorder.none),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // 💡 (선택 사항) 보내기 버튼을 누르면 부드럽게 스크롤을 맨 아래로 내리도록 추가 가능
              /*
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
              */
            },
            child: const Text('보내기', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 8. 서재 화면 (Library Screen)
// ==========================================
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('내 서재', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: (){})
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _buildBookItem('노동의 종말', Colors.grey, 1),
          _buildBookItem('키오스크 사용 설명서', Colors.blue[100]!, 1),
          _buildBookItem('웃으면 복이 와요', Colors.orange[200]!, 1),
          _buildBookItem('그 외계인이 사랑하는 법', Colors.pink[200]!, 34),
        ],
      ),
    );
  }

  Widget _buildBookItem(String title, Color coverColor, int bookCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 100, height: 140,
            decoration: BoxDecoration(color: coverColor, borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Icon(Icons.book, color: Colors.white, size: 40)),
          ),
          const SizedBox(width: 20),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('총 $bookCount권 >', style: const TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 9. 맛집/지도 화면 (Map Screen)
// ==========================================
class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('맛집'),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: '검색',
                border: InputBorder.none,
              ),
            ),
          ),
          _buildRestaurantItem('순희네 국밥', '단골 맛집', Colors.brown[200]!),
          _buildRestaurantItem('칼국수', '찐만두 같이 시키기', Colors.orange[100]!),
          _buildRestaurantItem('AB 카페', '커피를 뺀 바닐라 라테', Colors.brown[100]!),
          _buildRestaurantItem('중식당', '탕수육 맛있음', Colors.red[100]!),
          _buildRestaurantItem('선릉 갈비', '윤승이랑 갔던 돼지고기집', Colors.deepOrange[200]!),
          _buildRestaurantItem('오마카세', '다 맛있음', Colors.deepPurple[200]!),
          _buildRestaurantItem('수영장', '수영장 주인이 이제 돈을 내라고 했다... 농담이겠지?', Colors.lightBlue[200]!),
        ],
      ),
    );
  }

  Widget _buildRestaurantItem(String title, String subtitle, Color imgColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: imgColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 10. 운세 화면 (Fortune Screen)
// ==========================================
class FortuneScreen extends StatelessWidget {
  const FortuneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF280068),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('오늘의 운세', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 100),
            const SizedBox(height: 20),
            Container(
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                  color: const Color(0xFF6B1B9A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15),
                  ]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text('34', style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
                      Text('점', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellowAccent)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('좋은 것만 보고 살고 싶어', style: TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 11. 증거 제출 화면 (Answer Screen)
// ==========================================

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({Key? key}) : super(key: key);

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  late Timer _timer;
  Duration _elapsedTime = Duration.zero;

  // 💡 사용자가 입력한 글자를 가져오기 위한 컨트롤러
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();

  // 💡 전송 중 중복 클릭을 막기 위한 상태 변수
  bool _isSubmitting = false;
  String? _loverName;

  @override
  void initState() {
    super.initState();
    _elapsedTime = DateTime.now().difference(appStartTime);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(appStartTime);
      });
    });

    if (!hasShownAnswerPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInstructionDialog();
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _nameController.dispose();
    _countController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  void _showInstructionDialog() {
    hasShownAnswerPopup = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: const Text(
            '헌페스 경력 34년차 탐정인 당신.\n어느 날 김기려 헌터가 누군가와 열애 중이라는 사실을 직감했고, 우연히 그의 폰을 입수했다.\n잠시 뒤에 그가 찾으러 온다고 했지만...\n그전에 김 헌터의 연인을 찾아보자.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          contentPadding: const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
          actionsPadding: EdgeInsets.zero,
          actions: [
            const Divider(height: 1, thickness: 1),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인', style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
              ),
            )
          ],
        );
      },
    );
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      String hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  // 💡 구글 폼으로 데이터를 전송하는 로직
  Future<void> _submitAnswer() async {
    // 1. 빈 칸 검사
    if (_nameController.text.isEmpty || _countController.text.isEmpty || _evidenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요!')));
      return;
    }

    setState(() { _isSubmitting = true; });

    // 🚨 TODO 1: 알아낸 구글 폼의 전송 주소(formResponse로 끝나는 주소)를 넣으세요!
    final String googleFormUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSebkWBoazWllW2YS8IBAh5VC5giFy5DmxfyNsSdvaKCv62yuw/formResponse';

    String timeTaken = _formatTime(_elapsedTime);

    try {
      // 💡 구글 폼 전용 전송 방식 (x-www-form-urlencoded)
      var response = await http.post(
        Uri.parse(googleFormUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          // 🚨 TODO 2: 아까 찾아둔 각각의 entry.번호를 정확히 매칭해서 넣어주세요!
          "entry.1124993795": _nameController.text,      // 탐정 성명
          "entry.897792721": _countController.text,      // 증거 개수
          "entry.1055879719": _evidenceController.text,  // 증거 내용
          "entry.1600065158": timeTaken,                 // 소요 시간
        },
      );

      // 통신 성공 (구글 폼은 리다이렉트 등으로 200번대가 아닐 수도 있으므로 넓게 잡습니다)
      if (response.statusCode >= 200 && response.statusCode < 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('증거가 성공적으로 제출되었습니다. (소요 시간: $timeTaken)')),
        );
        Navigator.pop(context, {
          'action': 'trigger_ending',
          'name': _nameController.text,
          'count': _countController.text,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제출에 실패했습니다. 다시 시도해주세요.')));
      }
    } catch (e) {
      // 💡 웹 브라우저의 CORS 에러로 이곳에 빠지더라도, 구글 서버에는 데이터가 정상적으로 들어갑니다!
      print("CORS 우회 완료 및 전송 성공: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('증거가 성공적으로 제출되었습니다. (소요 시간: $timeTaken)')),
      );

      // 정상적으로 엔딩 화면으로 릴레이
      Navigator.pop(context, {
        'action': 'trigger_ending',
        'name': _nameController.text,
        'count': _countController.text,
      });
    } finally {
      if (mounted) {
        setState(() { _isSubmitting = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('증거 제출', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildQuestionItem('1. 탐정 성명', '이름을 입력하세요', 1, _nameController),
          _buildFixedNameItem(),
          _buildEvidenceCountItem(),
          _buildQuestionItem('4. 찾은 증거를 모두 작성하십시오', '찾은 증거를 상세히 적어주세요', 5, _evidenceController),

          _buildTimerItem('5. 증거 제출까지 걸린 시간', _formatTime(_elapsedTime)),

          const SizedBox(height: 20),

          ElevatedButton(
            // 전송 중일 땐 버튼을 막아줍니다
            onPressed: _isSubmitting || _loverName == null
                ? null
                : _submitAnswer,            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('제출하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildFixedNameItem() {
    const fixedName = '강창호';

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2. 김기려 헌터의 연인',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _loverName,
            items: const [
              DropdownMenuItem<String>(
                value: fixedName,
                child: Text(fixedName),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _loverName = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildEvidenceCountItem() {
    const options = ['0개', '1~10개', '11~20개', '34개'];

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. 찾은 증거의 개수',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          ...options.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _countController.text.isEmpty ? null : _countController.text,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _countController.text = value;
                });
              },
              activeColor: Colors.blueAccent,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(String question, String hint, int maxLines, TextEditingController controller, {bool isNumber = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 12),
          TextField(
            controller: controller, // 💡 컨트롤러 연결
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerItem(String title, String timeText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: Text(
              timeText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 12. 갤러리 목록 화면 (Gallery Screen)
// ==========================================
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  final List<String> galleryImages = const [
    'assets/meal.jpg',
    'assets/hand.jpg',
    'assets/pool.jpg',
    'assets/dirt.jpg',
    'assets/sushi.jpg',
    'assets/iam.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('사진'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GalleryDetailScreen(
                  imageIndex: index,
                  imagePath: galleryImages[index],
                ),
              ));
            },
            child: Image.asset(
              galleryImages[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.ios_share), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.delete_outline), label: ''),
        ],
      ),
    );
  }
}

// ==========================================
// 13. 갤러리 상세 화면 (Gallery Detail Screen)
// ==========================================
class GalleryDetailScreen extends StatefulWidget {
  final int imageIndex;
  final String imagePath;

  const GalleryDetailScreen({
    Key? key,
    required this.imageIndex,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<GalleryDetailScreen> createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  bool _showTooltip = false;

  String _getDescription(int index) {
    switch (index) {
      case 0:
        return '처음 한 식사.\n뜨겁지만 맛있다!';
      case 1:
        return '길쭉한 단백질 덩어리.';
      case 2:
        return '좋아하는 장소.';
      case 3:
        return '이 귀한 걸 알아보지 못하다니\n그건 원시적이라고 말할 수밖에...';
      case 4:
        return '진짜 맛있다!\n남이 사줘서 그런가...';
      case 5:
        return '세상이 전기 속성 투성이';
      default:
        return '$index번 사진이다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('사진', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showTooltip = !_showTooltip;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 400,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: Text('이미지를 불러올 수 없습니다.', style: TextStyle(color: Colors.white))),
                  ),
                ),
              ),

              if (_showTooltip)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _getDescription(widget.imageIndex),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        unselectedItemColor: Colors.blueAccent,
        selectedItemColor: Colors.blueAccent,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.ios_share), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.delete_outline), label: ''),
        ],
      ),
    );
  }
}

// ==========================================
// 14. 엔딩 화면 (Ending Screen)
// ==========================================
class EndingScreen extends StatefulWidget {
  final String detectiveName;
  final String evidenceCount;
  final bool isHiddenEnding;

  const EndingScreen({Key? key, required this.detectiveName, required this.evidenceCount, this.isHiddenEnding = false,}) : super(key: key);

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> {
  int _currentStep = 0;
  final ScrollController _scrollController = ScrollController(); // 💡 1. 스크롤 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    _playEndingStory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 💡 2. 단계가 넘어갈 때마다 렌더링 후 스크롤을 맨 아래로 내리는 함수
  void _advanceStep(int step) {
    if (mounted) {
      setState(() {
        _currentStep = step;
      });
      // 화면이 그려진 직후에 스크롤 애니메이션 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // 💡 불필요하게 반복되던 딜레이 코드를 간결하게 정리
  List<String> _getEndingStory() {
    if (widget.isHiddenEnding) {
      return [
        '전화가 연결된다.',
        '- 드디어 받는,',
        '"여보세요? 이 휴대폰 주인의 애인 맞으세요?"',
        '수화기 너머가 잠시 조용해진다.',
        '- ... 내가?',
        '"네. 연락처에 애인이라고 저장되어 있으시던데요."',
        '- .......',
        '남자는 침묵하다가, 이내 기분을 알 수 없는 목소리로 말한다.',
        '- 이봐, 탐정님. 오늘은 이만 그 휴대폰은 내려놓고 떠나는 게 좋겠어.',
        '"네?"',
        '- 아, 그리고 이건,',
        '"고마움의 표시야."',
        '등뒤에서 목소리가 들린다.',
        '뒤를 돌아보기도 전에 눈앞에 별이 튄다.',
        '정신이 들자 이미 며칠이 지난 뒤였다.',
        '길을 가다 게이트에 빠진 당신을 강창호 헌터가 구해주었다고 한다.',
        '아무것도 기억나지 않아 그 말을 믿기 어렵지만...',
        '병원에 맡겨질 때 같이 전달된 수표 여러 장과 얼얼한 뒤통수만이 당신의 곁을 지킬 뿐이다.',
      ];
    }

    switch (widget.evidenceCount) {
      case '0개':
        return [
          '"${widget.detectiveName}?"',
          '분명히 김기려 헌터가 나오기로 했는데, 어째서인지 약속장소에는 강창호 헌터가 나타났다.',
          '"헌터들 뒷조사하기로 유명한 당신이 김기려 헌터의 휴대폰을 \'우연히\' 주우셨다고."',
          '신체강화자의 주먹에 힘이 들어가는 게 보인다. 생사의 갈림길 앞에서 당신은 묻는다.',
          '"두 분 안 사귀시죠? 사귀는 걸로 안 보이던데요."',
          '"내가? 김기려 헌터랑?"',
          '강창호는 웃음을 터뜨린다.',
          '"하하, 마음대로 생각해."',
          'S급의 주먹은 흉기나 다름없었다. 당신은 바닥에 나뒹군다.',
          '"탐정 말고 다른 직업도 좀 알아보시고."',
        ];
      case '1~10개':
        return [
          '"${widget.detectiveName}?"',
          '분명히 김기려 헌터가 나오기로 했는데, 어째서인지 약속장소에는 강창호 헌터가 나타났다.',
          '"헌터들 뒷조사하기로 유명한 당신이 김기려 헌터의 휴대폰을 \'우연히\' 주우셨다고."',
          '신체강화자의 주먹에 힘이 들어가는 게 보인다. 생사의 갈림길 앞에서 당신은 묻는다.',
          '"두 분 사귀시죠?!"',
          '"내가? 김기려 헌터랑?"',
          '당신은 자신있게 조사한 내용을 꺼내 보인다. 얇디얇은 수첩을 순식간에 훑어보더니 강창호는 입꼬리를 당기며 웃는다.',
          '"상상력도 풍부하시긴."',
          'S급의 주먹은 흉기나 다름없었다. 당신은 바닥에 나뒹군다.',
          '"뭐, 그래도 촉은 나쁘지 않네."',
        ];
      case '11~20개':
        return [
          '"${widget.detectiveName}?"',
          '분명히 김기려 헌터가 나오기로 했는데, 어째서인지 약속장소에는 강창호 헌터가 나타났다.',
          '"헌터들 뒷조사하기로 유명한 당신이 김기려 헌터의 휴대폰을 \'우연히\' 주우셨다고."',
          '신체강화자의 주먹에 힘이 들어가는 게 보인다. 생사의 갈림길 앞에서 당신은 묻는다.',
          '"두 분 사귀시죠?"',
          '"내가? 김기려 헌터랑?"',
          '당신은 자신있게 조사한 내용을 꺼내 보인다. 백과사전처럼 두꺼운 노트를 잠시 훑어보던 강창호는 이윽고 웃음을 터뜨린다.',
          '"그럴 리가. 우린 그런 사이가 아니야."',
          'S급의 주먹은 흉기나 다름없었다. 당신은 바닥에 나뒹군다.',
          '"... 아직은."',
        ];
      case '34개':
        return [
          '"${widget.detectiveName}?"',
          '분명히 김기려 헌터가 나오기로 했는데, 어째서인지 약속장소에는 강창호 헌터가 나타났다.',
          '"헌터들 뒷조사하기로 유명한 당신이 김기려 헌터의 휴대폰을 \'우연히\' 주우셨다고."',
          '신체강화자의 주먹에 힘이 들어가는 게 보인다. 생사의 갈림길 앞에서 당신은 말한다.',
          '"두 분 사귀시는 것 다 압니다."',
          '"내가? 김기려 헌터랑?"',
          '당신은 명료한 목소리로 조사한 내용을 읊는다. 변하지 않는 시간, 가위에 있던 숫자.......',
          '"세상만물이 강창호 헌터와 김기려 헌터가 사귄다는 걸 가리키고 있습니다."',
          '흔들림 없는 탐정의 눈을 보며, 강창호의 입가에서 미소가 사라진다.',
          '"... 흥미로운 가설이었어."',
          'S급의 주먹은 흉기나 다름없었다. 당신은 바닥에 나뒹군다.',
          '"탐정의 촉이란... 김기려보다 눈치가 빠른걸...."',
        ];
      default:
        return [
          '"${widget.detectiveName}?"',
          '당신은 약속장소에 도착했다.',
          '하지만 무언가 이상했다.',
          '"두 분 사귀시죠?!"',
          '상대방은 대답하지 않았다.',
          '긴 침묵이 이어졌다.',
          '그리고...',
          '당신은 무언가 잘못되었다는 것을 깨달았다.',
          '이미 늦은 것 같았다.',
          '모든 진실은 밝혀지지 않았다.',
        ];
    }
  }

  String _getEndingMessage() {
    if (widget.isHiddenEnding) {
      return '사랑의 큐피드';
    }

    switch (widget.evidenceCount) {
      case '0개':
        return '똥촉의 결말';

      case '1~10개':
        return '한 끗 차이';

      case '11~20개':
        return '진정한 탐정';

      case '34개':
        return '궁극의 짱려러';

      default:
        return '';
    }
  }

  Future<void> _playEndingStory() async {
    final endingStory = _getEndingStory();

    await Future.delayed(const Duration(milliseconds: 1500));
    _advanceStep(1);

    for (int i = 2; i <= endingStory.length; i++) {
      await Future.delayed(const Duration(milliseconds: 2500));
      _advanceStep(i);
    }

    // FIN
    await Future.delayed(const Duration(milliseconds: 3500));
    _advanceStep(endingStory.length + 1);

    // 작은 멀티엔딩 문구
    await Future.delayed(const Duration(milliseconds: 2000));
    _advanceStep(endingStory.length + 2);
  }

  // 💡 3. 애니메이션 및 텍스트 렌더링을 담당하는 위젯 빌더
  Widget _buildStoryLine(String text, int step, {bool isFin = false}) {
    // 현재 단계보다 높으면 공간을 아예 차지하지 않도록 shrink 처리 (자연스러운 자동 스크롤을 위해)
    if (_currentStep < step) return const SizedBox.shrink();

    // TweenAnimationBuilder를 사용하여 위젯이 추가될 때 페이드인 효과를 줍니다.
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(seconds: isFin ? 2 : 1),
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: isFin ? 20.0 : 30.0), // Spacer를 대신할 여백
        child: isFin
            ? Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 8.0, fontWeight: FontWeight.w300),
          ),
        )
            : Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18, height: 2.0),
        ),
      ),
    );
  }

  Widget _buildEndingMessage() {
    final showMessage = _currentStep >= _getEndingStory().length + 2;

    return AnimatedOpacity(
      opacity: showMessage ? 1.0 : 0.0,
      duration: const Duration(seconds: 2),
      child: Text(
        _getEndingMessage(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 완벽한 암전
      body: SafeArea(
        // 💡 4. 기기 화면 크기를 넘어가더라도 스크롤이 될 수 있도록 ListView 사용
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          children: [
            ..._getEndingStory().asMap().entries.map((entry) {
              final index = entry.key;
              final text = entry.value;
              return _buildStoryLine(text, index + 1);
            }),
            _buildStoryLine(
              'FIN',
              _getEndingStory().length + 1,
              isFin: true,
            ),

            const SizedBox(height: 5),

            _buildEndingMessage(),
          ],
        ),
      ),
    );
  }
}