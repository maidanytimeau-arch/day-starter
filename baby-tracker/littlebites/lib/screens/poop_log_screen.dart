import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import '../models/poop_log.dart';
import '../models/profile.dart';

class PoopLogScreen extends StatefulWidget {
  const PoopLogScreen({super.key});

  @override
  State<PoopLogScreen> createState() => _PoopLogScreenState();
}

class _PoopLogScreenState extends State<PoopLogScreen> {
  Profile? _selectedProfile;
  String? _selectedColor;
  String? _selectedConsistency;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedPhoto;
  final List<PoopLog> _recentLogs = [];

  final List<Map<String, String>> _colorOptions = [
    {'name': 'Black', 'emoji': '⚫', 'color': '#000000'},
    {'name': 'Brown', 'emoji': '🟤', 'color': '#8B4513'},
    {'name': 'Green', 'emoji': '🟢', 'color': '#50C878'},
    {'name': 'Yellow', 'emoji': '🟡', 'color': '#FFD700'},
    {'name': 'Red', 'emoji': '🔴', 'color': '#E74C3C'},
    {'name': 'Grey', 'emoji': '🩵', 'color': '#A0A0A0'},
  ];

  final List<Map<String, dynamic>> _consistencyOptions = [
    {'name': 'Hard', 'icon': '💎'},
    {'name': 'Formed (normal)', 'icon': '🍫'},
    {'name': 'Soft', 'icon': '🫧'},
    {'name': 'Loose', 'icon': '💦'},
    {'name': 'Watery', 'icon': '💧'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedProfile = MockDataService.getActiveProfile();
    _loadRecentLogs();
  }

  void _loadRecentLogs() {
    final logs = MockDataService.getRecentPoopLogs();
    setState(() {
      _recentLogs.clear();
      _recentLogs.addAll(logs.take(5));
    });
  }

  bool _isConcerningColor(String color) {
    return color.toLowerCase() == 'red' || color.toLowerCase() == 'black';
  }

  bool _isConcerningConsistency(String consistency) {
    return consistency.toLowerCase() == 'hard' || consistency.toLowerCase() == 'watery';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveLog() {
    if (_selectedColor == null || _selectedConsistency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select color and consistency'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    // In a real app, this would save to Firebase
    // For now, just show success and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Poop log saved!'),
        backgroundColor: Color(0xFF50E3C2),
      ),
    );

    // Simulate adding to recent logs
    final newLog = PoopLog(
      id: 'poop_${DateTime.now().millisecondsSinceEpoch}',
      profileId: _selectedProfile!.id,
      timestamp: DateTime.now(),
      color: _selectedColor!,
      consistency: _selectedConsistency!,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      photoUrls: _selectedPhoto != null ? [_selectedPhoto!] : null,
    );

    setState(() {
      _recentLogs.insert(0, newLog);
      if (_recentLogs.length > 5) {
        _recentLogs.removeLast();
      }
    });

    _resetForm();
  }

  void _resetForm() {
    setState(() {
      _selectedColor = null;
      _selectedConsistency = null;
      _selectedPhoto = null;
    });
    _notesController.clear();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poop Log'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _cancel,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancel,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Child selector
          _buildChildSelector(),
          const SizedBox(height: 20),

          // Color selector
          _buildColorSelector(),
          const SizedBox(height: 20),

          // Consistency selector
          _buildConsistencySelector(),
          const SizedBox(height: 20),

          // Photo upload placeholder
          _buildPhotoUpload(),
          const SizedBox(height: 20),

          // Notes field
          _buildNotesField(),
          const SizedBox(height: 20),

          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: 30),

          // Recent logs section
          _buildRecentLogsSection(),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    final profiles = MockDataService.profiles;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Profile>(
            value: _selectedProfile,
            isExpanded: true,
            hint: const Text('Select child'),
            icon: const Icon(Icons.expand_more),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
            items: profiles.map((profile) {
              return DropdownMenuItem<Profile>(
                value: profile,
                child: Row(
                  children: [
                    const Icon(Icons.child_care, size: 20, color: Color(0xFF4A90E2)),
                    const SizedBox(width: 8),
                    Text(profile.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Profile? profile) {
              setState(() {
                _selectedProfile = profile;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎨 Color',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _colorOptions.length,
              itemBuilder: (context, index) {
                final option = _colorOptions[index];
                final isSelected = _selectedColor == option['name'];
                final isConcerning = _isConcerningColor(option['name']!);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = option['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A90E2).withOpacity(0.2)
                          : isConcerning
                              ? const Color(0xFFE74C3C).withOpacity(0.1)
                              : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A90E2)
                            : isConcerning
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFFECF0F1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option['emoji']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['name']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        if (isConcerning && !isSelected)
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: Color(0xFFE74C3C),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConsistencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🫧 Consistency',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: _consistencyOptions.map((option) {
                final isSelected = _selectedConsistency == option['name'];
                final isConcerning = _isConcerningConsistency(option['name']!);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedConsistency = option['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A90E2).withOpacity(0.1)
                          : isConcerning
                              ? const Color(0xFFE74C3C).withOpacity(0.05)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        bottom: BorderSide(
                          color: option == _consistencyOptions.last
                              ? Colors.transparent
                              : const Color(0xFFECF0F1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected
                              ? const Color(0xFF4A90E2)
                              : isConcerning
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFFBDC3C7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          option['icon'],
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            option['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                        if (isConcerning && !isSelected)
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Color(0xFFE74C3C),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement photo picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo upload coming soon!')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4A90E2),
            width: 1,
          ),
        ),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: _selectedPhoto != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _selectedPhoto!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPhotoPlaceholder();
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPhoto = null;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _buildPhotoPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 40,
            color: const Color(0xFF4A90E2).withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Add Photo',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF4A90E2).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '(optional)',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📝 Notes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Any additional notes...',
              hintStyle: TextStyle(color: Color(0xFFBDC3C7)),
              border: OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(16),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF4A90E2)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A90E2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveLog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentLogsSection() {
    if (_recentLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Poop Logs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        ..._recentLogs.map((log) => _buildRecentLogCard(log)).toList(),
      ],
    );
  }

  Widget _buildRecentLogCard(PoopLog log) {
    final isConcerningColor = log.isConcerningColor;
    final isConcerningConsistency = log.isConcerningConsistency;

    Color logColor;
    switch (log.color.toLowerCase()) {
      case 'black':
        logColor = Colors.black;
        break;
      case 'brown':
        logColor = Colors.brown;
        break;
      case 'green':
        logColor = Colors.green;
        break;
      case 'yellow':
        logColor = Colors.yellow;
        break;
      case 'red':
        logColor = Colors.red;
        break;
      case 'grey':
        logColor = Colors.grey;
        break;
      default:
        logColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: logColor,
                shape: BoxShape.circle,
                border: isConcerningColor
                    ? Border.all(color: const Color(0xFFE74C3C), width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  log.colorEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        log.timeDisplay,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isConcerningColor || isConcerningConsistency)
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Color(0xFFE74C3C),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${log.color.capitalize()}, ${log.consistency.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  if (log.notes != null && log.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      log.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF95A5A6),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (log.photoUrls != null && log.photoUrls!.isNotEmpty)
              const Icon(
                Icons.photo_outlined,
                size: 20,
                color: Color(0xFFBDC3C7),
              ),
          ],
        ),
      ),
    );
  }
}

// Extension for capitalizing first letter
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
