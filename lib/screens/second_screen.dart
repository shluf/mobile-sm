import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../data/models/user_model.dart';
import 'third_screen.dart';

class SecondScreen extends StatefulWidget {
  final String userName;

  const SecondScreen({super.key, required this.userName});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  User? _selectedUser;

  Future<void> _onChooseUser() async {
    final User? result = await Navigator.push<User>(
      context,
      MaterialPageRoute(builder: (_) => const ThirdScreen()),
    );
    if (result != null) {
      setState(() => _selectedUser = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Second Screen'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            Expanded(
              child: Center(
                child: _selectedUser == null
                    ? const Text(
                        'Selected User Name',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      )
                    : Text(
                        _selectedUser!.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: ElevatedButton(
                onPressed: _onChooseUser,
                child: const Text('Choose a User'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
