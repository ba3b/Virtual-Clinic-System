import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/firestore_service.dart';
import '../../components/appointment_card.dart';
import '../../components/custom_app_bar.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../theme/theme.dart';
import '../../localization/app_localizations.dart';
import 'appointment_details_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId?>(context);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).translate('login_view_appointments')),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).translate('my_appointments'),
        showBackButton: false,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: [
                Tab(text: AppLocalizations.of(context).translate('upcoming')),
                Tab(text: AppLocalizations.of(context).translate('completed')),
                Tab(text: AppLocalizations.of(context).translate('rejected')),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              unselectedLabelStyle: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AppointmentModel>>(
              stream: DatabaseService(uid: user.uid)
                  .getPatientAppointments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${AppLocalizations.of(context).translate('error_loading_appointments')}: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyStyle.copyWith(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: Text(AppLocalizations.of(context).translate('retry')),
                        ),
                      ],
                    ),
                  );
                }

                final appointments = snapshot.data ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsListView(appointments
                        .where((app) =>
                            (app.status == AppointmentModel.statusPending ||
                                app.status ==
                                    AppointmentModel.statusApproved) &&
                            app.dateTime.isAfter(DateTime.now()
                                .subtract(const Duration(minutes: 20))))
                        .toList()),

                    _buildAppointmentsListView(appointments
                        .where((app) =>
                            app.status == AppointmentModel.statusCompleted ||
                            (app.status == AppointmentModel.statusApproved &&
                                app.dateTime.isBefore(DateTime.now())))
                        .toList()),

                    _buildAppointmentsListView(appointments
                        .where((app) =>
                            app.status == AppointmentModel.statusRejected)
                        .toList()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsListView(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('no_appointments'),
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];

        if (appointment.type == AppointmentModel.typeVaccination) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: AppointmentCard(
              doctorName: appointment.vaccinationType ?? AppLocalizations.of(context).translate('vaccination'),
              appointmentDate: appointment.dateTime,
              appointmentType: appointment.type,
              status: appointment.status,
              onTap: () => _navigateToAppointmentDetails(
                  appointment, appointment.vaccinationType ?? AppLocalizations.of(context).translate('vaccination')),
            ),
          );
        }

        return FutureBuilder<UserModel?>(
          future: appointment.doctorId != null
              ? DatabaseService(uid: appointment.doctorId!)
                  .getUserDetails(appointment.doctorId!)
              : Future.value(null),
          builder: (context, snapshot) {
            String doctorName;
            if (appointment.doctorId == null) {
              doctorName = AppLocalizations.of(context).translate('awaiting_doctor');
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              doctorName = AppLocalizations.of(context).translate('loading');
            } else if (snapshot.hasError) {
              doctorName = AppLocalizations.of(context).translate('doctor_unavailable');
            } else if (snapshot.hasData) {
              doctorName = '${AppLocalizations.of(context).translate('dr_prefix')} ${snapshot.data!.name}';
            } else {
              doctorName = AppLocalizations.of(context).translate('doctor_assigned');
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppointmentCard(
                doctorName: doctorName,
                appointmentDate: appointment.dateTime,
                appointmentType: appointment.type,
                status: appointment.status,
                onTap: () =>
                    _navigateToAppointmentDetails(appointment, doctorName),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToAppointmentDetails(
      AppointmentModel appointment, String doctorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailsScreen(
          appointmentData: {
            'appointmentId': appointment.appointmentId,
            'doctorName': doctorName,
            'appointmentDate': appointment.dateTime,
            'appointmentType': appointment.type,
            'status': appointment.status,
            'department': appointment.department,
            'vaccinationType': appointment.vaccinationType,
            'doctorId': appointment.doctorId,
            'patientId': appointment.patientId,
          },
        ),
      ),
    );
  }
}
