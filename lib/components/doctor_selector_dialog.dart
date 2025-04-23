import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/theme.dart';

class DoctorSelectorDialog extends StatefulWidget {
  final List<DoctorModel> doctors;
  final Function(DoctorModel) onDoctorSelected;
  
  const DoctorSelectorDialog({
    Key? key,
    required this.doctors,
    required this.onDoctorSelected,
  }) : super(key: key);

  @override
  State<DoctorSelectorDialog> createState() => _DoctorSelectorDialogState();
}

class _DoctorSelectorDialogState extends State<DoctorSelectorDialog> {
  late List<DoctorModel> _filteredDoctors;
  final TextEditingController _searchController = TextEditingController();
  DoctorModel? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    _filteredDoctors = widget.doctors;
    
    _searchController.addListener(() {
      _filterDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDoctors() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredDoctors = widget.doctors;
      } else {
        _filteredDoctors = widget.doctors.where((doctor) {
          return doctor.name.toLowerCase().contains(query) ||
                 doctor.specialty.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Doctor',
              style: AppTheme.headingStyle.copyWith(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _filteredDoctors.isEmpty
                  ? Center(
                      child: Text(
                        'No doctors found',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _filteredDoctors[index];
                        final isSelected = _selectedDoctor?.userId == doctor.userId;
                        
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(
                            doctor.name,
                            style: AppTheme.bodyStyle.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            doctor.specialty,
                            style: AppTheme.bodySmallStyle,
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedDoctor = doctor;
                            });
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 120, // Specify a fixed width for the button
                  child: ElevatedButton(
                    onPressed: _selectedDoctor == null
                        ? null
                        : () {
                            widget.onDoctorSelected(_selectedDoctor!);
                            Navigator.pop(context);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Assign'),
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