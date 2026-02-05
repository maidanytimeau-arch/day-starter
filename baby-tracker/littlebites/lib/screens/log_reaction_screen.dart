import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/reaction.dart';
import '../models/food.dart';
import '../services/mock_data_service.dart';

class LogReactionScreen extends StatefulWidget {
  const LogReactionScreen({super.key});

  @override
  State<LogReactionScreen> createState() => _LogReactionScreenState();
}

class _LogReactionScreenState extends State<LogReactionScreen> {
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
    _selectedProfile = MockDataService.getActiveProfile();
  }

  @override
  void dispose() {
    _otherSymptomController.dispose();
    _notesController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
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

            // Photo upload placeholder
            _buildPhotoUpload(),
            const SizedBox(height: 24),

            // Time pickers
            _buildTimePickers(),
            const SizedBox(height: 24),

            // Notes field
            _buildNotesField(),
            const SizedBox(height: 32),

            // Save and Cancel buttons
            _buildActionButtons(),
            
            const SizedBox(height: 16),

            // Medical disclaimer
            _buildMedicalDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.child_care,
              size: 32,
              color: Color(0xFF4A90E2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Profile>(
                  value: _selectedProfile,
                  isExpanded: true,
                  items: MockDataService.profiles.map((profile) {
                    return DropdownMenuItem<Profile>(
                      value: profile,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            profile.ageDisplay,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (profile) {
                    setState(() {
                      _selectedProfile = profile;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodSelector() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Suspected Food',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFECF0F1)),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Food>(
                  value: _selectedFood,
                  hint: const Text('Tap to select or skip'),
                  isExpanded: true,
                  items: MockDataService.foods.map((food) {
                    return DropdownMenuItem<Food>(
                      value: food,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          if (food.hasAllergens) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: Colors.orange[700],
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (food) {
                    setState(() {
                      _selectedFood = food;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeveritySection(Color severityColor) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: severityColor,
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 20),

            // Severity slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isSelected = level == _severity;
                final levelColor = _getSeverityColor(level);

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _severity = level;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? levelColor : Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: levelColor,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            level.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Connector line (except for last)
                    if (index < 4)
                      Container(
                        width: 40,
                        height: 2,
                        color: isSelected && level < _severity ? levelColor : Colors.grey[300],
                      ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 20),

            // Severity labels
            ...List.generate(5, (index) {
              final level = index + 1;
              final levelColor = _getSeverityColor(level);
              final label = _getSeverityLabel(level);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: levelColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          level.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: _severity == level ? levelColor : Colors.grey[700],
                        fontWeight: _severity == level ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection(Color severityColor) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  color: severityColor,
                ),
                const SizedBox(width: 8),
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

            // Symptom checkboxes
            ..._availableSymptoms.map((symptom) {
              return CheckboxListTile(
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
                title: Text(
                  symptom,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: severityColor,
              );
            }),

            // Other symptom
            CheckboxListTile(
              value: _hasOtherSymptom,
              onChanged: (value) {
                setState(() {
                  _hasOtherSymptom = value ?? false;
                  if (!_hasOtherSymptom) {
                    _otherSymptomController.clear();
                  }
                });
              },
              title: const Text(
                'Other...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: severityColor,
            ),

            if (_hasOtherSymptom)
              Padding(
                padding: const EdgeInsets.only(left: 44, top: 8),
                child: TextField(
                  controller: _otherSymptomController,
                  decoration: InputDecoration(
                    hintText: 'Enter other symptom...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFECF0F1)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.photo_camera_outlined,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_photoUrls.length}/3',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Photo grid (placeholder)
            if (_photoUrls.isEmpty)
              InkWell(
                onTap: () {
                  // TODO: Implement photo upload
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo upload coming soon!'),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFECF0F1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Color(0xFF7F8C8D),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to add photos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoUrls.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index < _photoUrls.length) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[300],
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _photoUrls.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (_photoUrls.length < 3) {
                      return InkWell(
                        onTap: () {
                          // TODO: Implement photo upload
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo upload coming soon!'),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFECF0F1),
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 32,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickers() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Time',
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
            InkWell(
              onTap: () => _selectTime(context, isStartTime: true),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFECF0F1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_arrow,
                      color: Color(0xFF50E3C2),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Started:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTime(_startTime),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF7F8C8D),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // End time
            InkWell(
              onTap: () => _selectTime(context, isStartTime: false),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFECF0F1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stop,
                      color: Color(0xFFE74C3C),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ended:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _endTime != null ? _formatTime(_endTime!) : 'Ongoing',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF7F8C8D),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.note_outlined,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any additional notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFECF0F1)),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(
                color: Color(0xFF4A90E2),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveReaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '⚠️ This app does not replace medical advice. If your child is having a severe reaction, seek emergency medical help immediately.',
        style: TextStyle(
          fontSize: 12,
          color: Colors.orange[700],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : (_endTime ?? _startTime)),
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = DateTime(
            _startTime.year,
            _startTime.month,
            _startTime.day,
            picked.hour,
            picked.minute,
          );
        } else {
          _endTime = DateTime(
            _startTime.year,
            _startTime.month,
            _startTime.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  void _saveReaction() {
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

    // Create the reaction object
    final reaction = Reaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      profileId: _selectedProfile?.id ?? '',
      foodId: _selectedFood?.id,
      severity: _severity,
      symptoms: symptoms,
      startTime: _startTime,
      endTime: _endTime,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      photoUrls: _photoUrls.isEmpty ? null : _photoUrls,
    );

    // Save to mock data service
    MockDataService.addReaction(reaction);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reaction saved successfully! Severity: ${reaction.severityText}'),
        backgroundColor: _getSeverityColor(_severity),
      ),
    );

    // Navigate back
    Navigator.pop(context, reaction);
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 2) return const Color(0xFF50E3C2); // Green
    if (severity == 3) return const Color(0xFFF5A623); // Yellow/Orange
    return const Color(0xFFE74C3C); // Red
  }

  String _getSeverityLabel(int severity) {
    switch (severity) {
      case 1:
        return 'Very mild (rash)';
      case 2:
        return 'Mild (slight swelling)';
      case 3:
        return 'Moderate (hives)';
      case 4:
        return 'Severe (vomiting)';
      case 5:
        return 'Very severe (anaphylaxis)';
      default:
        return '';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
