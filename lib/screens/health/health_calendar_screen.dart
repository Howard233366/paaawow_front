import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_talk/theme/app_colors.dart';

/// 健康日历屏幕 - 显示宠物的健康数据日历
/// Health Calendar Screen - Displays pet health data in calendar format
class HealthCalendarScreen extends ConsumerStatefulWidget {
  const HealthCalendarScreen({super.key});

  @override
  ConsumerState<HealthCalendarScreen> createState() => _HealthCalendarScreenState();
}

class _HealthCalendarScreenState extends ConsumerState<HealthCalendarScreen> {
  /// 当前选中的日期 / Currently selected date
  DateTime _selectedDate = DateTime.now();
  
  /// 当前聚焦的日期（用于月份导航）/ Currently focused date (for month navigation)
  DateTime _focusedDate = DateTime.now();

  /// 获取月份名称 / Get month name from month number
  /// [month] 月份数字 (1-12) / Month number (1-12)
  /// 返回英文月份名称 / Returns English month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  /// 构建主界面 / Build main UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 应用栏 / App bar
      appBar: AppBar(
        title: const Text(
          'Health Calendar',
          style: TextStyle(
            fontFamily: 'PaaaWow',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 日历头部 - 月份导航 / Calendar Header - Month navigation
            Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 上一月按钮 / Previous month button
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  // 当前月份显示 / Current month display
                  Text(
                    '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PaaaWow',
                    ),
                  ),
                  // 下一月按钮 / Next month button
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            
            // 日历网格 / Calendar Grid
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildCalendarGrid(),
            ),
            
            const SizedBox(height: 16),
            
            // 选中日期信息显示区域 / Selected Date Info Display Area
            if (_hasHealthData(_selectedDate))
              // 有健康数据时显示详细信息 / Show detailed info when health data exists
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildHealthDataForDate(_selectedDate),
              )
            else
              // 无健康数据时显示空状态 / Show empty state when no health data
              Container(
                height: 200, // 给空状态一个固定高度 / Give empty state a fixed height
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No health data for this date',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建日历网格 / Build calendar grid
  /// 创建一个月份的日历网格，包含日期选择和健康数据指示器
  /// Creates a monthly calendar grid with date selection and health data indicators
  Widget _buildCalendarGrid() {
    // 计算当月天数 / Calculate days in current month
    final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    // 获取当月第一天 / Get first day of current month
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    // 计算第一天是星期几（转换为0=Sunday格式）/ Calculate first weekday (convert to 0=Sunday format)
    final firstWeekday = firstDayOfMonth.weekday % 7; // Monday = 1, Sunday = 0

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 星期标题行 / Weekday headers
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // 日历日期网格 / Calendar days grid
          // 生成最多6周的日期行 / Generate up to 6 weeks of date rows
          ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                // 计算当前格子对应的日期数字 / Calculate day number for current cell
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                // 如果日期超出当月范围，显示空白 / Show empty space if day is outside current month
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }
                
                // 创建完整日期对象 / Create complete date object
                final date = DateTime(_focusedDate.year, _focusedDate.month, dayNumber);
                // 判断是否为选中日期 / Check if this is the selected date
                final isSelected = _isSameDay(date, _selectedDate);
                // 判断是否为今天 / Check if this is today
                final isToday = _isSameDay(date, DateTime.now());
                // 判断是否有健康数据 / Check if has health data
                final hasData = _hasHealthData(date);
                
                // 日期单元格 / Date cell
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        // 根据状态设置背景色 / Set background color based on state
                        color: isSelected 
                            ? AppColors.primary  // 选中状态：主色调 / Selected: primary color
                            : isToday 
                                ? AppColors.primary.withOpacity(0.2)  // 今天：浅主色调 / Today: light primary
                                : hasData 
                                    ? AppColors.success.withOpacity(0.1)  // 有数据：浅成功色 / Has data: light success
                                    : null,  // 普通日期：无背景 / Normal date: no background
                        borderRadius: BorderRadius.circular(8),
                        // 今天且未选中时显示边框 / Show border for today when not selected
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      child: Stack(
                        children: [
                          // 日期数字 / Date number
                          Center(
                            child: Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white  // 选中：白色文字 / Selected: white text
                                    : isToday 
                                        ? AppColors.primary  // 今天：主色调文字 / Today: primary color text
                                        : Colors.black87,  // 普通：深灰文字 / Normal: dark gray text
                                fontWeight: isSelected || isToday 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          // 健康数据指示点 / Health data indicator dot
                          if (hasData && !isSelected)
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }).where((row) => 
            // 过滤掉完全空白的行 / Filter out completely empty rows
            row.children.any((child) => 
              child is Expanded && child.child is! SizedBox
            )
          ),
        ],
      ),
    );
  }

  /// 构建选中日期的健康数据显示 / Build health data display for selected date
  /// [date] 选中的日期 / Selected date
  /// 返回包含健康指标的详细信息卡片 / Returns detailed info card with health metrics
  Widget _buildHealthDataForDate(DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题 / Title
        Text(
          '${_getMonthName(date.month)} ${date.day} Health Data',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'PaaaWow',
          ),
        ),
        const SizedBox(height: 16),
        
        // 健康指标第一行 / Health metrics first row
        Row(
          children: [
            // 步数指标 / Steps metric
            Expanded(
              child: _buildHealthMetric(
                'Steps',
                '8,342',
                Icons.directions_walk,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            // 卡路里指标 / Calories metric
            Expanded(
              child: _buildHealthMetric(
                'Calories',
                '245',
                Icons.local_fire_department,
                AppColors.warning,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 健康指标第二行 / Health metrics second row
        Row(
          children: [
            // 活跃时间指标 / Active time metric
            Expanded(
              child: _buildHealthMetric(
                'Active Time',
                '2.5 hours',
                Icons.timer,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            // 睡眠时长指标 / Sleep duration metric
            Expanded(
              child: _buildHealthMetric(
                'Sleep Duration',
                '7.8 hours',
                Icons.bedtime,
                AppColors.info,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 情绪状态指示器 / Mood status indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              // 情绪图标 / Mood icon
              Icon(
                Icons.mood,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              // 情绪描述文本 / Mood description text
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Feeling great today, lively and active 😊',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建健康指标卡片 / Build health metric card
  /// [label] 指标标签 / Metric label
  /// [value] 指标数值 / Metric value  
  /// [icon] 指标图标 / Metric icon
  /// [color] 主题颜色 / Theme color
  /// 返回一个带有图标、数值和标签的指标卡片 / Returns a metric card with icon, value and label
  Widget _buildHealthMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),  // 浅色背景 / Light background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),  // 浅色边框 / Light border
        ),
      ),
      child: Column(
        children: [
          // 指标图标 / Metric icon
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          // 指标数值 / Metric value
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          // 指标标签 / Metric label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 判断两个日期是否为同一天 / Check if two dates are the same day
  /// [date1] 第一个日期 / First date
  /// [date2] 第二个日期 / Second date
  /// 返回是否为同一天 / Returns whether they are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// 检查指定日期是否有健康数据 / Check if specified date has health data
  /// [date] 要检查的日期 / Date to check
  /// 返回是否有健康数据 / Returns whether has health data
  /// 目前使用模拟数据：最近10天有数据 / Currently uses mock data: last 10 days have data
  bool _hasHealthData(DateTime date) {
    // 模拟数据：最近10天有数据 / Mock data: last 10 days have data
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    return difference >= 0 && difference <= 10;
  }

  /// 选择日期 / Select date
  /// [date] 要选择的日期 / Date to select
  /// 更新选中日期状态并刷新界面 / Update selected date state and refresh UI
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  /// 切换到上一个月 / Switch to previous month
  /// 更新聚焦日期到上一个月并刷新日历显示 / Update focused date to previous month and refresh calendar
  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  /// 切换到下一个月 / Switch to next month
  /// 更新聚焦日期到下一个月并刷新日历显示 / Update focused date to next month and refresh calendar
  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }
}