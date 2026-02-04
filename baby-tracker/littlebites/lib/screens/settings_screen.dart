import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User profile
          _buildSection([
            _buildUserCard(),
          ]),

          // Notifications
          _buildSectionHeader('🔔 Notifications'),
          _buildSection([
            _buildSwitchTile(
              'Daily summary',
              'Receive daily meal summary at 7 PM',
              true,
            ),
            _buildSwitchTile(
              'Reaction alerts',
              'Immediate alerts for severe reactions',
              true,
            ),
            _buildSwitchTile(
              'Family activity',
              'Notifications when family logs meals',
              false,
            ),
          ]),

          // Appearance
          _buildSectionHeader('🎨 Appearance'),
          _buildSection([
            _buildSwitchTile(
              'Dark Mode',
              'Follows system settings',
              true,
            ),
            ListTile(
              title: const Text('Font Size'),
              subtitle: const Text('Medium'),
              trailing: const Icon(Icons.keyboard_arrow_down),
              onTap: () {
                // TODO: Implement font size picker
              },
            ),
          ]),

          // Data
          _buildSectionHeader('💾 Data'),
          _buildSection([
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Data'),
              subtitle: const Text('Download as PDF or CSV'),
              onTap: () {
                // TODO: Implement data export
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Status'),
              subtitle: const Text('✅ Up to date'),
              onTap: () {},
            ),
          ]),

          // About
          _buildSectionHeader('ℹ️ About'),
          _buildSection([
            ListTile(
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Rate this app'),
              onTap: () {
                // TODO: Open App Store/Play Store
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Contact Support'),
              onTap: () {
                // TODO: Open email or support page
              },
            ),
          ]),

          // Sign out
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement sign out
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Bob',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'bob@email.com',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Edit profile
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7F8C8D),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: (newValue) {
        // TODO: Implement toggle
      },
    );
  }
}
