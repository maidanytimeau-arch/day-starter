import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/food.dart';
import '../services/mock_data_service.dart';
import '../routes/app_routes.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  Profile? _selectedProfile;
  List<Food> _selectedFoods = [];
  String? _preparation;
  List<String> _photoUrls = [];
  String _notes = '';
  final TextEditingController _foodSearchController = TextEditingController();
  List<Food> _filteredFoods = [];

  final List<String> _preparationMethods = [
    'Pureed',
    'Finger Food',
    'Chopped',
    'Mashed',
    'Roasted',
    'Steamed',
  ];

  @override
  void initState() {
    super.initState();
    _selectedProfile = MockDataService.getActiveProfile();
    _filteredFoods = MockDataService.foods;
    _foodSearchController.addListener(_filterFoods);
  }

  @override
  void dispose() {
    _foodSearchController.dispose();
    super.dispose();
  }

  void _filterFoods() {
    setState(() {
      if (_foodSearchController.text.isEmpty) {
        _filteredFoods = MockDataService.foods;
      } else {
        _filteredFoods = MockDataService.foods
            .where((food) => food.name.toLowerCase().contains(_foodSearchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  void _addFood(Food food) {
    if (!_selectedFoods.any((f) => f.id == food.id)) {
      setState(() {
        _selectedFoods.add(food);
      });
    }
  }

  void _removeFood(Food food) {
    setState(() {
      _selectedFoods.removeWhere((f) => f.id == food.id);
    });
  }

  List<String> _getAllergens() {
    final allergens = <String>{};
    for (var food in _selectedFoods) {
      allergens.addAll(food.allergens);
    }
    return allergens.toList();
  }

  void _saveMeal() {
    // TODO: Implement Firebase save
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Child selector
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(_selectedProfile?.name[0] ?? 'B'),
              ),
              title: Text(_selectedProfile?.name ?? 'No child selected'),
              subtitle: Text(_selectedProfile?.ageDisplay ?? ''),
              trailing: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
          const SizedBox(height: 20),

          // Foods section
          _buildSectionHeader('🍽️ Foods'),
          const SizedBox(height: 12),

          // Selected foods
          if (_selectedFoods.isNotEmpty) ...[
            ..._selectedFoods.map((food) => Card(
              child: ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(food.name),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeFood(food),
                ),
              ),
            )),
            const SizedBox(height: 12),
          ],

          // Food search
          TextField(
            controller: _foodSearchController,
            decoration: const InputDecoration(
              hintText: 'Search foods...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),

          // Food suggestions
          ..._filteredFoods.take(5).map((food) => ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(food.name),
            onTap: () => _addFood(food),
          )),

          const SizedBox(height: 20),

          // Preparation method
          _buildSectionHeader('Preparation Method'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _preparation,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select preparation',
            ),
            items: _preparationMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _preparation = value;
              });
            },
          ),

          const SizedBox(height: 20),

          // Allergens detected
          if (_getAllergens().isNotEmpty) ...[
            _buildSectionHeader('⚠️ Allergens Detected'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getAllergens().map((allergen) => Chip(
                label: Text(allergen),
                backgroundColor: const Color(0xFFF5A623).withOpacity(0.2),
                avatar: const Icon(Icons.warning_amber_outlined, size: 16),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Photo upload
          _buildSectionHeader('📸 Add Photos'),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (index) {
              if (index < _photoUrls.length) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
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
                  padding: const EdgeInsets.only(right: 8),
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

          const SizedBox(height: 20),

          // Notes
          _buildSectionHeader('📝 Notes'),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add notes (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _notes = value;
              });
            },
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedFoods.isEmpty ? null : _saveMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                  ),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C3E50),
      ),
    );
  }
}
