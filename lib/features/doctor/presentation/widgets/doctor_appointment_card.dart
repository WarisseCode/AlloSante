import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DoctorAppointmentCard extends StatelessWidget {
  final String patientName;
  final String time;
  final String type;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;
  final VoidCallback? onVideoCall;

  const DoctorAppointmentCard({
    super.key,
    required this.patientName,
    required this.time,
    required this.type,
    required this.onAccept,
    required this.onRefuse,
    this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$time • $type',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onVideoCall != null)
            IconButton(
              onPressed: onVideoCall,
              icon: const Icon(Icons.videocam, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
            ),
          Row(
            children: [
              IconButton(
                onPressed: onRefuse,
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: 'Refuser',
              ),
              IconButton(
                onPressed: onAccept,
                icon: const Icon(Icons.check, color: Colors.green),
                tooltip: 'Accepter',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
