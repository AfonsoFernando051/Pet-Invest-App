import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:petapp_mobile/core/constants/app_colors.dart';
import 'package:petapp_mobile/core/widgets/glass_card.dart';
import 'package:petapp_mobile/features/mentor/domain/entities/chat_message.dart';

/// A single chat bubble: user messages are a solid neon-gradient pill
/// (right-aligned, plain text), mentor replies are a `GlassCard` with
/// markdown rendering (left-aligned) — mirrors this app's existing split
/// between player-action chrome and system/glass surfaces.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: _isUser ? _buildUserBubble() : _buildMentorBubble(),
      ),
    );
  }

  Widget _buildUserBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.neonViolet, AppColors.neonPink],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(
        message.text,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
      ),
    );
  }

  Widget _buildMentorBubble() {
    final borderColor = message.isError
        ? AppColors.warningAmber.withValues(alpha: 0.5)
        : AppColors.neonCyan.withValues(alpha: 0.35);

    return GlassCard(
      borderColor: borderColor,
      borderRadius: 18,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: message.text.isEmpty
          ? const SizedBox(height: 4)
          : MarkdownBody(
              data: message.text,
              selectable: true,
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                em: const TextStyle(color: AppColors.subtleText, fontStyle: FontStyle.italic),
                listBullet: const TextStyle(color: AppColors.neonCyan, fontSize: 14),
                h1: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                h2: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                code: const TextStyle(
                  color: AppColors.neonCyan,
                  fontFamily: 'monospace',
                  backgroundColor: Colors.black26,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                tableBorder: TableBorder.all(color: Colors.white24),
                tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                tableBody: const TextStyle(color: AppColors.subtleText),
              ),
            ),
    );
  }
}
