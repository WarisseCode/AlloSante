import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../appointments/presentation/providers/appointment_provider.dart';
import '../widgets/doctor_appointment_card.dart';

class DoctorAgendaScreen extends StatefulWidget {
  const DoctorAgendaScreen({super.key});

  @override
  State<DoctorAgendaScreen> createState() => _DoctorAgendaScreenState();
}

class _DoctorAgendaScreenState extends State<DoctorAgendaScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Refresh appointments when Agenda is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Agenda'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 16),
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Next 2 weeks
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _isSameDay(date, _selectedDate);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E(
                      'fr',
                    ).format(date).toUpperCase().replaceAll('.', ''),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final provider = context.watch<AppointmentProvider>();

    // Filter by selected date
    final dailyAppointments = provider.appointments.where((appt) {
      return _isSameDay(appt.appointmentDate, _selectedDate);
    }).toList();

    dailyAppointments.sort(
      (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
    );

    if (dailyAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Aucun rendez-vous ce jour',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailyAppointments.length,
      itemBuilder: (context, index) {
        final appt = dailyAppointments[index];
        return DoctorAppointmentCard(
          patientName: appt.user != null
              ? '${appt.user!.firstName} ${appt.user!.lastName}'
              : 'Patient Inconnu',
          time: appt.timeSlot,
          type: _translateType(appt.type.name),
          onAccept: () {
            // In Agenda, maybe we just show details or allowed actions depend on status
            if (appt.status.name == 'pending') {
              provider.updateAppointmentStatus(appt.id, 'CONFIRMED');
            }
          },
          onRefuse: () {
            if (appt.status.name == 'pending') {
              provider.updateAppointmentStatus(appt.id, 'CANCELLED');
            }
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _translateType(String type) {
    // Basic translation, could be improved with localization
    switch (type.toUpperCase()) {
      case 'CONSULTATION':
        return 'Consultation';
      case 'FOLLOW_UP':
        return 'Suivi';
      case 'EMERGENCY':
        return 'Urgence';
      case 'TELECONSULTATION':
        return 'Téléconsultation';
      default:
        return type;
    }
  }
}
