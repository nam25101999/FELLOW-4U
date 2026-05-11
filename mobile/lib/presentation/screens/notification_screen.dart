import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notification_service.dart';
import '../widgets/common/dynamic_page_header.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with AutomaticKeepAliveClientMixin {
  final NotificationService _notificationService = NotificationService();
  List<UserNotification>? _notifications;
  bool _isLoading = true;
  String? _error;
  String _currentLocation = "Da Nang";
  String _currentTemp = "26°C";
  String? _currentHeaderImage;

  String _getHeaderImageForLocation(String location) =>
      DynamicPageHeader.getImageForLocation(location);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _currentHeaderImage = _getHeaderImageForLocation(_currentLocation);
  }

  Future<void> _fetchNotifications() async {
    try {
      final data = await _notificationService.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleNotificationTap(UserNotification notification) async {
    // Show detail dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    // Mark as read if not already
    if (!notification.isRead) {
      try {
        await _notificationService.markAsRead(notification.id);
        if (!mounted) return;
        setState(() {
          final index = _notifications!.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            final old = _notifications![index];
            _notifications![index] = UserNotification(
              id: old.id,
              title: old.title,
              message: old.message,
              avatarUrl: old.avatarUrl,
              type: old.type,
              timestamp: old.timestamp,
              isRead: true,
              actionType: old.actionType,
            );
          }
        });
      } catch (e) {
        debugPrint('Failed to mark as read: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 16.h),
                    if (_notifications == null || _notifications!.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: _notifications!.length,
                        separatorBuilder: (context, index) => Divider(height: 1.h, color: AppColors.neutral100),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => _handleNotificationTap(_notifications![index]),
                          child: _buildNotificationItem(_notifications![index]),
                        ),
                      ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return DynamicPageHeader(
      title: 'Notifications',
      imageUrl: _currentHeaderImage,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400.h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64.sp, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text('No notifications', style: AppTypography.subtitle1.copyWith(color: AppColors.neutral500)),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(UserNotification notification) {
    return Container(
      color: notification.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: notification.avatarUrl != null
                    ? NetworkImage(notification.avatarUrl!)
                    : null,
                backgroundColor: notification.avatarUrl == null ? AppColors.primary : Colors.transparent,
                child: notification.avatarUrl == null
                    ? const Icon(Icons.notifications, color: Colors.white)
                    : null,
              ),
              if (!notification.isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    _getBadgeIcon(notification.type),
                    color: _getBadgeColor(notification.type),
                    size: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.message,
                  style: AppTypography.body2.copyWith(
                    color: notification.isRead ? AppColors.neutral600 : AppColors.neutral900,
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('MMM dd, yyyy - HH:mm').format(notification.timestamp),
                  style: AppTypography.caption.copyWith(color: AppColors.neutral500),
                ),
                if (notification.actionType == 'LEAVE_REVIEW') ...[
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: const Text('Leave Review'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(String type) {
    switch (type) {
      case 'TRIP_ACCEPTED':
        return Colors.green;
      case 'OFFER_RECEIVED':
        return Colors.amber;
      case 'TRIP_FINISHED':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  IconData _getBadgeIcon(String type) {
    switch (type) {
      case 'TRIP_ACCEPTED':
        return Icons.check_circle;
      case 'OFFER_RECEIVED':
        return Icons.local_offer;
      case 'TRIP_FINISHED':
        return Icons.edit;
      default:
        return Icons.notifications;
    }
  }
}
