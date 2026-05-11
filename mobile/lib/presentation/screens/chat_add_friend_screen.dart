import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/explore_model.dart';
import '../../data/services/profile_service.dart';
import 'chat_detail_screen.dart';

class ChatAddFriendScreen extends StatefulWidget {
  const ChatAddFriendScreen({super.key});

  @override
  State<ChatAddFriendScreen> createState() => _ChatAddFriendScreenState();
}

class _ChatAddFriendScreenState extends State<ChatAddFriendScreen> {
  final ProfileService _profileService = ProfileService();
  List<User>? _users;
  bool _isLoading = true;
  String? _error;
  final List<User> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      // For now, reuse ProfileService if it has a way to get all guides/users
      // Or I should add a search/all users method
      // Let's assume we can get guides as potential friends
      // I'll check ProfileService or just use a mock for now if not available
      setState(() {
        _isLoading = false;
        // Mocking for now as I don't have a 'getAllUsers' service yet
        _users = []; 
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutral700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Friends', style: AppTypography.subtitle1.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('DONE', style: AppTypography.subtitle2.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_selectedUsers.isNotEmpty) _buildSelectedUsers(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users!.isEmpty 
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _users!.length,
                        itemBuilder: (context, index) {
                          final user = _users![index];
                          final isSelected = _selectedUsers.contains(user);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                              child: user.avatarUrl == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text('${user.firstName} ${user.lastName}'),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val!) {
                                    _selectedUsers.add(user);
                                  } else {
                                    _selectedUsers.remove(user);
                                  }
                                });
                              },
                              activeColor: AppColors.primary,
                              shape: const CircleBorder(),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Search Friend',
            icon: Icon(Icons.search, color: AppColors.neutral500),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedUsers() {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedUsers.length,
        itemBuilder: (context, index) {
          final user = _selectedUsers[index];
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedUsers.remove(user)),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: Icon(Icons.close, color: Colors.white, size: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
