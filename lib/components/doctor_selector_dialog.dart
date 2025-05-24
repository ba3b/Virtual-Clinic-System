import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/theme.dart';

class DoctorSelectorDialog extends StatefulWidget {
  final List<DoctorModel> doctors;
  final Function(DoctorModel) onDoctorSelected;
  final String? requiredSpecialty;

  const DoctorSelectorDialog({
    Key? key,
    required this.doctors,
    required this.onDoctorSelected,
    this.requiredSpecialty,
  }) : super(key: key);

  @override
  State<DoctorSelectorDialog> createState() => _DoctorSelectorDialogState();
}

class _DoctorSelectorDialogState extends State<DoctorSelectorDialog> {
  DoctorModel? _selectedDoctor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person_add_alt_1,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Doctor',
                          style: AppTheme.headingStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.requiredSpecialty != null)
                          Text(
                            'Specialty: ${widget.requiredSpecialty}',
                            style: AppTheme.bodySmallStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.backgroundColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.requiredSpecialty != null && widget.doctors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing only ${widget.requiredSpecialty} specialists',
                          style: AppTheme.bodySmallStyle.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Flexible(
                child: Container(
                  height: 350,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.dividerColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: widget.doctors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 48,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No doctors found',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.requiredSpecialty != null
                                    ? 'No ${widget.requiredSpecialty} specialists available'
                                    : 'No doctors available at the moment',
                                style: AppTheme.bodySmallStyle.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: widget.doctors.length,
                          itemBuilder: (context, index) {
                            final doctor = widget.doctors[index];
                            final isSelected =
                                _selectedDoctor?.userId == doctor.userId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedDoctor = doctor;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: AppTheme.primaryColor,
                                              width: 2,
                                            )
                                          : Border.all(
                                              color: AppTheme.dividerColor
                                                  .withOpacity(0.5),
                                            ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.medical_services,
                                            color: AppTheme.primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doctor.name,
                                                style:
                                                    AppTheme.bodyStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                doctor.specialty,
                                                style: AppTheme.bodySmallStyle
                                                    .copyWith(
                                                  color: AppTheme.primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                doctor.email,
                                                style: AppTheme.bodySmallStyle
                                                    .copyWith(
                                                  color: AppTheme
                                                      .textSecondaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppTheme.dividerColor),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _selectedDoctor == null
                          ? null
                          : () {
                              widget.onDoctorSelected(_selectedDoctor!);
                              // Remove Navigator.pop(context) from here since we handle it in the parent
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment_ind, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Assign Doctor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
