import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../models/reaction.dart';
import '../models/food.dart';
import '../services/providers/service_providers.dart';
import '../services/mock_data_service.dart';

class LogReactionScreen extends ConsumerStatefulWidget {
  const LogReactionScreen({super.key});

  @override
  ConsumerState<LogReactionScreen> createState() => _LogReactionScreenState();
}

class _LogReactionScreenState extends ConsumerState<LogReactionScreen> {
  // Selected child profile
  Profile? _selectedProfile;

  // Selected food (optional)
  Food? _selectedFood;

  // Severity level (1-5)
  int _severity = 3;

  // Selected symptoms
  final List<String> _selectedSymptoms = [];
  bool _hasOtherSymptom = false;
  final TextEditingController _otherSymptomController = TextEditingController();

  // Photo upload (placeholder - 0-3 photos)
  final List<String> _photoUrls = [];

  // Time pickers
  DateTime _startTime = DateTime.now();
  DateTime? _endTime;

  // Notes
  final TextEditingController _notesController = TextEditingController();

  // Loading state
  bool _isSaving = false;

  // Available symptoms
  static const List<String> _availableSymptoms = [
    'Rash/hives',
    'Swelling (face, lips)',
    'Vomiting',
    'Diarrhea',
    'Coughing/wheezing',
    'Runny nose',
  ];

  @override
  void initState() {
    super.initState();
    _loadActiveProfile();
  }

  @override
  void dispose() {
    _otherSymptomController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(_severity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Reaction'),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child selector
                  _buildChildSelector(),
                  const SizedBox(height: 24),

                  // Food selector (optional)
                  _buildFoodSelector(),
                  const SizedBox(height: 24),

                  // Severity slider
                  _buildSeveritySection(severityColor),
                  const SizedBox(height: 24),

                  // Symptoms checklist
                  _buildSymptomsSection(severityColor),
                  const SizedBox(height: 24),

                  // Timing
                  _buildTimingSection(),
                  const SizedBox(height: 24),

                  // Photo upload
                  _buildPhotoSection(),
                  const SizedBox(height: 24),

                  // Notes
                  _buildNotesSection(),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveReaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: severityColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Reaction', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChildSelector() {
    return Card(
      child: InkWell(
        onTap: _showChildSelectorDialog,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.child_care, color: Color(0xFF4A90E2)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedProfile?.name ?? 'No child selected',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      _selectedProfile?.ageDisplay ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Color(0xFF4A90E2)),
                const SizedBox(width: 12),
                const Text(
                  'Food (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Food>(
              decoration: InputDecoration(
                hintText: 'Select food',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: MockDataService.foods.map((food) {
                return DropdownMenuItem(
                  value: food,
                  child: Text(food.name),
                );
              }).toList(),
              value: _selectedFood,
              onChanged: (value) {
                setState(() {
                  _selectedFood = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySection(Color severityColor) {
    return Card(
      color: severityColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: severityColor),
                const SizedBox(width: 12),
                const Text(
                  'Severity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: severityColor,
                thumbColor: severityColor,
                inactiveTrackColor: severityColor.withValues(alpha: 0.3),
              ),
              child: Slider(
                value: _severity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _getSeverityLabel(_severity),
                onChanged: (value) {
                  setState(() {
                    _severity = value.toInt();
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final severity = index + 1;
                return Text(
                  _getSeverityLabel(severity),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _severity == severity ? FontWeight.bold : FontWeight.normal,
                    color: severityColor,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection(Color severityColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Color(0xFF4A90E2)),
                const SizedBox(width: 12),
                const Text(
                  'Symptoms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._availableSymptoms.map((symptom) => CheckboxListTile(
                  title: Text(symptom),
                  value: _selectedSymptoms.contains(symptom),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                )),
            CheckboxListTile(
              title: TextField(
                controller: _otherSymptomController,
                decoration: const InputDecoration(
                  hintText: 'Other symptom',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              value: _hasOtherSymptom && _otherSymptomController.text.isNotEmpty,
              onChanged: (value) {
                setState(() {
                  _hasOtherSymptom = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFF4A90E2)),
                const SizedBox(width: 12),
                const Text(
                  'Timing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Start time
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Start Time'),
              subtitle: Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_startTime),
                );
                if (time != null && mounted) {
                  setState(() {
                    _startTime = DateTime(
                      _startTime.year,
                      _startTime.month,
                      _startTime.day,
                      time!.hour,
                      time!.minute,
                    );
                  });
                }
              },
            ),
            const Divider(),
            // End time (optional)
            ListTile(
              leading: const Icon(Icons.stop_circle_outlined),
              title: const Text('End Time (Optional)'),
              subtitle: Text(_endTime != null
                  ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                  : 'Still ongoing'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _endTime != null
                      ? TimeOfDay.fromDateTime(_endTime!)
                      : TimeOfDay.now(),
                );
                if (time != null && mounted) {
                  setState(() {
                    _endTime = DateTime(
                      _startTime.year,
                      _startTime.month,
                      _startTime.day,
                      time!.hour,
                      time!.minute,
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.camera_alt, color: Color(0xFF4A90E2)),
                const SizedBox(width: 12),
                const Text(
                  'Photos (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(3, (index) {
                if (index < _photoUrls.length) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _photoUrls.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement photo picker
                        setState(() {
                          _photoUrls.add('placeholder_$index');
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Icon(Icons.add_photo_alternate),
                      ),
                    ),
                  );
                }
              }),
            ),
            Text('${_photoUrls.length}/3 photos', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Color(0xFF4A90E2)),
                const SizedBox(width: 12),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add notes (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveReaction() async {
    // Validate profile
    if (_selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a profile first'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    // Validate at least one symptom is selected
    final symptoms = [..._selectedSymptoms];
    if (_hasOtherSymptom && _otherSymptomController.text.isNotEmpty) {
      symptoms.add(_otherSymptomController.text);
    }

    if (symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom'),
          backgroundColor: Color(0xFFE74C3C),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create reaction object
      final reaction = Reaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        profileId: _selectedProfile!.id,
        foodId: _selectedFood?.id,
        foodName: _selectedFood?.name,
        severity: _severity,
        symptoms: symptoms,
        startTime: _startTime,
        endTime: _endTime,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        photoUrls: _photoUrls.isEmpty ? null : _photoUrls,
      );

      // Save to Firebase
      final reactionServiceAsync = ref.read(reactionServiceProvider);
      final reactionService = reactionServiceAsync.value;
      if (reactionService != null) {
        await reactionService.addReaction(reaction);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reaction saved successfully! Severity: ${reaction.severityText}'),
              backgroundColor: _getSeverityColor(_severity),
            ),
          );

          // Navigate back
          Navigator.pop(context, reaction);
        }
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save reaction: $e'),
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

  Future<void> _showChildSelectorDialog() async {
    // TODO: Implement child selector dialog with real profiles
    // For now, use mock data
    final profiles = MockDataService.profiles;
    if (!mounted) return;

    final selected = await showDialog<Profile>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Child'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: profiles.map((profile) {
            return ListTile(
              leading: CircleAvatar(
                child: Text(profile.name[0]),
              ),
              title: Text(profile.name),
              subtitle: Text(profile.ageDisplay),
              trailing: _selectedProfile?.id == profile.id ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.pop(context, profile);
              },
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedProfile = selected;
      });
    }
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 2) return const Color(0xFF50E3C2); // Green
    if (severity == 3) return const Color(0xFFF5A623); // Yellow/Orange
    return const Color(0xFFE74C3C); // Red
  }

  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 1:
        return 'Very Mild';
      case 2:
        return 'Mild';
      case 3:
        return 'Moderate';
      case 4:
        return 'Severe';
      case 5:
        return 'Very Severe';
      default:
        return 'Unknown';
    }
  }
}
