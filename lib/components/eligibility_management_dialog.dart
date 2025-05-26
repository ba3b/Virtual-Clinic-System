import 'package:flutter/material.dart';
import '../../api/firestore_service.dart';
import '../../constants/departments.dart';
import '../../theme/theme.dart';

class EligibilityManagementDialog extends StatefulWidget {
  final String patientId;
  final String patientName;
  final List<String> currentEligibility;

  const EligibilityManagementDialog({
    Key? key,
    required this.patientId,
    required this.patientName,
    required this.currentEligibility,
  }) : super(key: key);

  @override
  State<EligibilityManagementDialog> createState() => _EligibilityManagementDialogState();
}

class _EligibilityManagementDialogState extends State<EligibilityManagementDialog> {
  late Set<String> _selectedDepartments;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedDepartments = Set<String>.from(widget.currentEligibility);
  }

  Future<void> _updateEligibility() async {
    if (_selectedDepartments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one department'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await DatabaseService(uid: widget.patientId).updatePatientEligibility(
        patientId: widget.patientId,
        eligibility: _selectedDepartments.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient eligibility updated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating eligibility: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildDepartmentTile(String department) {
    final bool isSelected = _selectedDepartments.contains(department);
    final bool wasOriginallySelected = widget.currentEligibility.contains(department);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppTheme.primaryColor 
              : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected 
            ? AppTheme.primaryColor.withOpacity(0.1) 
            : Colors.transparent,
      ),
      child: CheckboxListTile(
        title: Text(
          department,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: wasOriginallySelected && !isSelected
            ? Text(
                'Will be removed',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              )
            : !wasOriginallySelected && isSelected
                ? Text(
                    'Will be added',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : null,
        value: isSelected,
        onChanged: _isUpdating ? null : (bool? value) {
          setState(() {
            if (value == true) {
              _selectedDepartments.add(department);
            } else {
              _selectedDepartments.remove(department);
            }
          });
        },
        activeColor: AppTheme.primaryColor,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int addedCount = _selectedDepartments
        .where((dept) => !widget.currentEligibility.contains(dept))
        .length;
    final int removedCount = widget.currentEligibility
        .where((dept) => !_selectedDepartments.contains(dept))
        .length;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manage Patient Eligibility',
                              style: AppTheme.subheadingStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'For: ${widget.patientName}',
                              style: AppTheme.bodySmallStyle.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: AppTheme.textSecondaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Select departments this patient is eligible to book appointments for.',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Changes Summary (if any)
            if (addedCount > 0 || removedCount > 0)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.change_circle_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Changes: ${addedCount > 0 ? '+$addedCount' : ''} ${removedCount > 0 ? '-$removedCount' : ''} departments',
                        style: AppTheme.bodySmallStyle.copyWith(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Departments List
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Departments (${_selectedDepartments.length}/${DepartmentConstants.allDepartments.length} selected)',
                      style: AppTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: DepartmentConstants.allDepartments.length,
                        itemBuilder: (context, index) {
                          return _buildDepartmentTile(
                            DepartmentConstants.allDepartments[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUpdating ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.textSecondaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _updateEligibility,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Update Eligibility',
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
}