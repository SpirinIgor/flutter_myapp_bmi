import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final _supabase = Supabase.instance.client;
  double _bmi = 0;
  int _currentIndex = 0;
  bool _showResult = false;
  bool _showError = false;
  bool _isSaving = false;

  Future<void> _calculateBMI() async {
    final height = _heightController.text;
    final weight = _weightController.text;

    if (height.isEmpty || weight.isEmpty) {
      setState(() {
        _showError = true;
        _showResult = false;
      });
      return;
    }

    final heightValue = double.tryParse(height) ?? 0;
    final weightValue = double.tryParse(weight) ?? 0;

    if (heightValue <= 0 || weightValue <= 0) {
      setState(() {
        _showError = true;
        _showResult = false;
      });
      return;
    }

    setState(() {
      _bmi = weightValue / ((heightValue / 100) * (heightValue / 100));
      _showResult = true;
      _showError = false;
      _isSaving = true;
    });

    try {
      // Получаем текущего пользователя
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Сохраняем данные в Supabase
      await _supabase.from('body_mass_index_calculations').insert({
        'height': heightValue.round(),
        'weight': weightValue.round(),
        'body_mass_index': _bmi,
        'recommendation': _getBMICategory(_bmi),
        'user_id': user.id,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения данных: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi <= 16)
      return 'Выраженный дефицит массы тела. Советуем набрать вес для здоровья.';
    if (bmi < 18.5)
      return 'Недостаточная масса тела. Рекомендуется увеличить массу тела.';
    if (bmi < 25)
      return 'Норма. Ваш вес в здоровом диапазоне — поддерживайте его!';
    if (bmi < 30)
      return 'Избыточная масса тела или предожирение. Желательно снизить вес для улучшения самочувствия.';
    if (bmi < 35)
      return 'Ожирение. Рекомендуется уменьшить вес под контролем специалиста.';
    if (bmi < 40)
      return 'Ожирение резкое. Необходимо снижение веса с медицинской поддержкой.';
    return 'Очень резкое ожирение. Требуется срочная коррекция веса под наблюдением врача.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Индекс массы тела',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Персональные данные',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Рост (см)',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Вес (кг)',
                          labelStyle: TextStyle(color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _calculateBMI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'РАССЧИТАТЬ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
                if (_showError) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Заполните все поля',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                if (_showResult) ...[
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ваш индекс массы тела:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _getBMICategory(_bmi),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else {
              setState(() {
                _currentIndex = index;
              });
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
}
