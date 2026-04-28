import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'chat_detail_screen.dart';

class MessagesTab extends StatelessWidget {
  final bool isNgoMode;

  const MessagesTab({super.key, required this.isNgoMode});

  @override
  Widget build(BuildContext context) {
    // Determine mock data based on mode
    final String chatName = isNgoMode ? 'Alice Johnson' : 'Downtown Shelter';
    final String chatSubtitle = 'Perfect! See you tomorrow.';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildChatTile(
                context: context,
                name: chatName,
                subtitle: chatSubtitle,
                time: 'Just now',
                hasUnread: true,
                isNgoMode: isNgoMode,
              ),
              if (!isNgoMode) ...[
                _buildChatTile(
                  context: context,
                  name: 'Green Earth Foundation',
                  subtitle: 'Thank you for the winter coats!',
                  time: 'Yesterday',
                  hasUnread: false,
                  isNgoMode: isNgoMode,
                ),
              ],
              if (isNgoMode) ...[
                _buildChatTile(
                  context: context,
                  name: 'Marcus Smith',
                  subtitle: 'I can deliver the winter coats tomorrow.',
                  time: 'Yesterday',
                  hasUnread: false,
                  isNgoMode: isNgoMode,
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String subtitle,
    required String time,
    required bool hasUnread,
    required bool isNgoMode,
  }) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetailScreen(chatName: name, isNgoMode: isNgoMode)),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            child: Icon(isNgoMode ? Icons.person : Icons.domain, color: Colors.grey, size: 30),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(name, style: TextStyle(fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: hasUnread ? Colors.black87 : Colors.black54, fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal)),
      trailing: Text(time, style: TextStyle(color: hasUnread ? AppColors.primary : Colors.grey, fontSize: 12, fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal)),
    );
  }
}
