import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/chat_model.dart';
import '../../data/services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with AutomaticKeepAliveClientMixin {
  final ChatService _chatService = ChatService();
  List<ChatConversation>? _conversations;
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final data = await _chatService.getConversations();
      if (!mounted) return;
      setState(() {
        _conversations = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chat', style: AppTypography.h2),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.neutral700),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _conversations == null || _conversations!.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchConversations,
                      child: ListView.builder(
                        itemCount: _conversations!.length,
                        itemBuilder: (context, index) {
                          final conv = _conversations![index];
                          return _buildChatItem(conv);
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64.sp, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text('No conversations yet', style: AppTypography.subtitle1.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatConversation conv) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            otherUserId: conv.otherUserId,
            otherUserName: conv.otherUserName,
            otherUserAvatar: conv.otherUserAvatar,
          ),
        ),
      ),
      leading: CircleAvatar(
        radius: 28.r,
        backgroundImage: conv.otherUserAvatar != null
            ? NetworkImage(conv.otherUserAvatar!)
            : null,
        child: conv.otherUserAvatar == null
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(conv.otherUserName, style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(
        conv.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption.copyWith(
          color: conv.unreadCount > 0 ? AppColors.neutral900 : AppColors.neutral500,
          fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat('hh:mm a').format(conv.lastMessageTime),
            style: AppTypography.caption.copyWith(color: AppColors.neutral500),
          ),
          if (conv.unreadCount > 0) ...[
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(
                conv.unreadCount.toString(),
                style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 10.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
