import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bmi_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _bmiCalculationsFuture;
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _bmiCalculationsFuture = _fetchBMICalculations();
    _userDataFuture = _fetchUserData();
  }

  Future<List<Map<String, dynamic>>> _fetchBMICalculations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('body_mass_index_calculations')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = _supabase.auth.currentUser;
    return {
      'email': user?.email ?? 'user@example.com',
      'displayName': user?.userMetadata?['full_name'] ?? 'Имя Фамилия',
    };
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr).toLocal();
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Сегодня, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'Вчера, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              child: FutureBuilder(
                future: _userDataFuture,
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasError) {
                    return Center(child: Text('Ошибка: ${userSnapshot.error}'));
                  }

                  final userData = userSnapshot.data!;

                  return Column(
                    children: [
                      // Карточка пользователя
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4CAF50),
                                  width: 3,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.transparent,
                                child: FlutterLogo(size: 60),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              userData['displayName'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userData['email'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Карточка активности
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Активность',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // История расчетов
                      FutureBuilder(
                        future: _bmiCalculationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Ошибка: ${snapshot.error}'),
                            );
                          }

                          final calculations = snapshot.data!;

                          if (calculations.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Нет данных о расчетах',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return Column(
                            children: calculations.map((calculation) {
                              return _buildHistoryItem(
                                _formatDateTime(calculation['created_at']),
                                calculation['height'].toString(),
                                calculation['weight'].toString(),
                                calculation['body_mass_index'].toStringAsFixed(
                                  2,
                                ),
                                calculation['recommendation'],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BMIScreen()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Калькулятор',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String time,
    String height,
    String weight,
    String bmi,
    String recommendation,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Рост', style: TextStyle(color: Colors.grey)),
              const Text('Вес', style: TextStyle(color: Colors.grey)),
              const Text('ИМТ', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('$height см'), Text('$weight кг'), Text(bmi)],
          ),
          const SizedBox(height: 10),
          Text(
            recommendation,
            style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
