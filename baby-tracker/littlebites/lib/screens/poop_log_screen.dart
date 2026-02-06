import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/poop_log.dart';
import '../models/profile.dart';
import '../services/providers/service_providers.dart';

class PoopLogScreen extends ConsumerStatefulWidget {
  const PoopLogScreen({super.key});

  @override
  ConsumerState<PoopLogScreen> createState() => _PoopLogScreenState();
}

class _PoopLogScreenState extends ConsumerState<PoopLogScreen> {
  Profile? _selectedProfile;
  String? _selectedColor;
  String? _selectedConsistency;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedPhoto;
  bool _isSaving = false;

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
    _loadActiveProfile();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveProfile() async {
    final profileServiceAsync = ref.read(profileServiceProvider);
    final profileService = profileServiceAsync.value;
    if (profileService != null) {
      final profile = await profileService.getActiveProfile();
      if (mounted) {
        setState(() {
          _selectedProfile = profile;
        });
      }
    }
  }

  bool _isConcerningColor(String color) {
    return color.toLowerCase() == 'red' || color.toLowerCase() == 'black';
  }

  bool _isConcerningConsistency(String consistency) {
    return consistency.toLowerCase() == 'hard' || consistency.toLowerCase() == 'watery';
  }

  @override
  Widget build(BuildContext context) {
    final isConcerning = _isConcerningColor(_selectedColor ?? '') ||
                      _isConcerningConsistency(_selectedConsistency ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poop Log'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Recent logs (streamed)
                _buildRecentLogsSection(),
                const SizedBox(height: 24),

                // Log form
                Card(
                  color: isConcerning
                      ? const Color(0xFFF5A623).withValues(alpha: 0.1)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile selector
                        _buildProfileSelector(),
                        const SizedBox(height: 16),

                        // Color picker
                        _buildColorPicker(),
                        const SizedBox(height: 16),

                        // Consistency picker
                        _buildConsistencyPicker(),
                        const SizedBox(height: 16),

                        // Photo upload
                        _buildPhotoSection(),
                        const SizedBox(height: 16),

                        // Notes
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Notes (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_selectedColor == null ||
                                    _selectedConsistency == null)
                                ? null
                                : _saveLog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isConcerning
                                  ? const Color(0xFFF5A623)
                                  : const Color(0xFF4A90E2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save Log',
                                    style: TextStyle(color: Colors.white),
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

  Widget _buildRecentLogsSection() {
    final poopServiceAsync = ref.watch(poopServiceProvider);

    return poopServiceAsync.when(
      data: (poopService) {
        final Stream<List<PoopLog>> stream;
        if (_selectedProfile != null) {
          stream = poopService.streamPoopLogs(_selectedProfile!.id);
        } else {
          stream = const Stream.empty();
        }

        return StreamBuilder<List<PoopLog>>(
          stream: stream,
          builder: (context, snapshot) {
            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Logs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                ...logs.take(5).map((log) => _buildLogCard(log)),
              ],
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLogCard(PoopLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getColorValue(log.color),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getEmojiForColor(log.color),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.timeDisplay,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    '${log.color}, ${log.consistency}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  Widget _buildProfileSelector() {
    final profileServiceAsync = ref.watch(profileServiceProvider);

    return profileServiceAsync.when(
      data: (profileService) {
        return StreamBuilder<List<Profile>>(
          stream: profileService.streamProfiles(),
          builder: (context, snapshot) {
            final profiles = snapshot.data ?? [];

            if (profiles.isEmpty) {
              return const Text('No profiles available. Please create a profile first.');
            }

            return DropdownButtonFormField<Profile>(
              hint: const Text('Select child'),
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              items: profiles.map((profile) {
                return DropdownMenuItem(
                  value: profile,
                  child: Text(profile.name),
                );
              }).toList(),
              value: _selectedProfile,
              onChanged: (Profile? profile) {
                setState(() {
                  _selectedProfile = profile;
                });
              },
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading profiles'),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _colorOptions.map((option) {
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = option['name'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedColor == option['name']
                      ? const Color(0xFF4A90E2)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option['emoji'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option['name'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConsistencyPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consistency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _consistencyOptions.map((option) {
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedConsistency = option['name'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedConsistency == option['name']
                      ? const Color(0xFF4A90E2)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option['name'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photo (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            // TODO: Implement photo picker
            setState(() {
              _selectedPhoto = 'placeholder_photo';
            });
          },
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: _selectedPhoto != null
                  ? Colors.grey[300]
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: _selectedPhoto != null
                ? Stack(
                    children: [
                      const Icon(Icons.image, size: 48),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedPhoto = null;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 48,
                            color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photo',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveLog() async {
    if (_selectedColor == null || _selectedConsistency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select color and consistency'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    if (_selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a profile first'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create poop log object
      final newLog = PoopLog(
        id: '', // Will be generated by Firebase
        profileId: _selectedProfile!.id,
        timestamp: DateTime.now(),
        color: _selectedColor!,
        consistency: _selectedConsistency!,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photoUrls: _selectedPhoto != null ? [_selectedPhoto!] : null,
      );

      // Save to Firebase
      final poopServiceAsync = ref.read(poopServiceProvider);
      final poopService = poopServiceAsync.value;
      if (poopService != null) {
        await poopService.addPoopLog(newLog);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log saved successfully!'),
              backgroundColor: Color(0xFF50E3C2),
            ),
          );

          // Navigate back
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save log: $e'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Color _getColorValue(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'black':
        return const Color(0xFF000000);
      case 'brown':
        return const Color(0xFF8B4513);
      case 'green':
        return const Color(0xFF50C878);
      case 'yellow':
        return const Color(0xFFFFD700);
      case 'red':
        return const Color(0xFFE74C3C);
      case 'grey':
        return const Color(0xFFA0A0A0);
      default:
        return Colors.grey;
    }
  }

  String _getEmojiForColor(String? colorName) {
    final option = _colorOptions.firstWhere(
      (opt) => opt['name'] == colorName,
      orElse: () => _colorOptions[1],
    );
    return option['emoji'] as String;
  }
}
