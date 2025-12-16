import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DoctorMessagesScreen extends StatelessWidget {
  const DoctorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return _buildChatTile(index);
        },
      ),
    );
  }

  Widget _buildChatTile(int index) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.person, color: AppColors.primary),
      ),
      title: Text(
        'Patient ${index + 1}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        index == 0
            ? 'Merci docteur, à demain !'
            : 'Pouvez-vous confirmer le RDV ?',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            '10:30',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (index == 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '1',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: () {
        // Navigate to Chat Detail
      },
    );
  }
}
