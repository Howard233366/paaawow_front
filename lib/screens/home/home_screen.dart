// 🔵 PetTalk 主屏幕 - 完全匹配旧Android项目的HomeScreen.kt
import 'package:flutter/material.dart';
// 导入Riverpod状态管理库（类似React的状态管理）
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 导入应用自定义颜色主题
import 'package:pet_talk/theme/app_colors.dart';

// 导入蓝牙相关数据模型
import 'package:pet_talk/models/bluetooth_models.dart';
// 导入项圈详情页面
// collar detail routed by GoRouter
import 'package:go_router/go_router.dart';
import 'package:pet_talk/models/screen_routes.dart';
// 导入健康信息相关页面
import 'package:pet_talk/screens/health/health_information_screen.dart';
import 'package:pet_talk/screens/health/health_data_screen.dart';
import 'package:pet_talk/screens/health/health_calendar_screen.dart';
// 导入主屏幕的业务逻辑管理器（ViewModel）
import 'package:pet_talk/riverpod/home_screen_viewmodel.dart';


/// 主屏幕组件类 - 完全匹配旧项目HomeScreen
/// ConsumerStatefulWidget是Riverpod提供的有状态组件，可以监听状态变化
class HomeScreen extends ConsumerStatefulWidget {
  // 构造函数，super.key传递给父类用于组件标识
  const HomeScreen({super.key});

  // 重写createState方法，返回状态管理类的实例
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// 私有状态类，下划线开头表示私有（类似其他语言的private）
class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 声明两个double类型的私有变量，存储健康值和情绪值
  // double是Dart的浮点数类型，_开头表示私有变量
  double _healthValue = 0.75;  // 健康值，范围0.0-1.0
  double _moodValue = 0.60;    // 情绪值，范围0.0-1.0

  // 重写initState生命周期方法，相当于Android的onCreate或React的componentDidMount
  @override
  void initState() {
    // 调用父类的initState，这是必须的
    super.initState();
    
    // 页面初始化完成后执行的回调
    // WidgetsBinding.instance.addPostFrameCallback确保在UI渲染完成后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ref是ConsumerState提供的，用于访问Riverpod的状态
      // .read()获取Provider，.notifier获取状态管理器，调用页面进入方法
      ref.read(homeScreenViewModelProvider.notifier).onPageEntered();
    });
  }

  // 重写dispose生命周期方法，相当于Android的onDestroy或React的componentWillUnmount
  @override
  void dispose() {
    // 页面销毁时的清理工作，用try-catch包裹防止异常
    try {
      // 通知ViewModel页面即将离开，用于停止定时器等清理工作
      ref.read(homeScreenViewModelProvider.notifier).onPageLeft();
    } catch (e) {
      // debugPrint是Flutter的调试打印，只在调试模式下输出
      debugPrint('HomeScreen dispose错误: $e');
    }
    // 调用父类的dispose，释放资源
    super.dispose();
  }

  // 重写build方法，这是Flutter组件的核心方法，用于构建UI
  // Widget是Flutter中所有UI组件的基类，BuildContext提供组件树的上下文信息
  @override
  Widget build(BuildContext context) {
    // 使用ref.watch监听ViewModel状态变化，当状态改变时会自动重新构建UI
    // final关键字表示这是一个不可变的变量（类似const，但可以在运行时赋值）
    final homeUiState = ref.watch(homeScreenViewModelProvider);
    final currentPetAction = ref.watch(currentPetActionDataProvider);
    // ref.read用于一次性读取状态，不会监听变化
    final homeViewModel = ref.read(homeScreenViewModelProvider.notifier);

    // 从ViewModel获取真实的项圈数据
    final realCollarData = homeViewModel.getCurrentCollarData();

    // 返回Scaffold组件，这是Flutter页面的基础骨架（类似HTML的body）
    return Scaffold(
      // 设置页面背景色为白色
      backgroundColor: Colors.white,
      // body是页面的主要内容区域
      body: ListView(  // ListView是可滚动的列表组件
        children: [    // children是一个Widget数组，包含所有子组件
          // 调用私有方法构建宠物动画展示区域
          // 传递当前动作、健康值、情绪值和蓝牙连接状态作为参数
          _buildRealTimePetAnimationSection(
            currentAction: currentPetAction,      // 当前宠物动作数据
            healthValue: _healthValue,            // 健康值
            moodValue: _moodValue,                // 情绪值
            connectionState: homeUiState.bluetoothConnectionState,  // 蓝牙连接状态
          ),
          
          // 调用私有方法构建宠物状态信息区域
          _buildPetStatusSection(),
          
          // 调用私有方法构建项圈信息区域
          _buildCollarInfoSection(
            collar: realCollarData,  // 项圈数据
            // onCollarClick是一个回调函数，当用户点击项圈信息时执行
            onCollarClick: () {
              context.push(AppRoutes.createCollarDetailRoute(realCollarData.id));
            },
          ),
        ],
      ),
    );
  }

  /// 私有方法：构建实时宠物动画展示区域
  /// 使用required关键字表示这些参数是必需的，不能为null
  Widget _buildRealTimePetAnimationSection({
    required PetActionData currentAction,        // 必需参数：当前宠物动作数据
    required double healthValue,                 // 必需参数：健康值
    required double moodValue,                   // 必需参数：情绪值
    required BluetoothConnectionState connectionState,  // 必需参数：蓝牙连接状态
  }) {
    // 返回Container组件，这是一个通用的容器组件
    return Container(
      height: 300,               // 设置固定高度为300像素
      width: double.infinity,    // 宽度占满父容器（double.infinity表示无限大）
      child: Container(          // 嵌套Container用于添加装饰
        decoration: BoxDecoration( // BoxDecoration用于设置容器的视觉效果
          // Theme.of(context)获取当前主题，colorScheme.surface是主题中定义的表面颜色
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(           // Padding组件用于添加内边距
          padding: const EdgeInsets.all(16.0),  // 四周各16像素的内边距
          child: Row(             // Row组件用于水平排列子组件
            crossAxisAlignment: CrossAxisAlignment.center,  // 子组件在垂直方向居中对齐
            children: [           // children数组包含Row的所有子组件
              // 左侧区域：健康值进度条
              Expanded(                    // Expanded让子组件在Row中按比例分配空间
                flex: 15,                  // flex值表示占用空间的比例，这里占15份
                child: _buildHealthProgressBar(healthValue),  // 调用构建健康进度条的方法
              ),
              
              // 中间区域：宠物动画展示
              Expanded(
                flex: 70,                  // 占用70份空间，是主要显示区域
                child: Container(
                  height: double.infinity, // 高度占满父容器
                  child: Stack(            // Stack组件用于层叠布局，子组件可以重叠
                    alignment: Alignment.center,  // 子组件在Stack中居中对齐
                    children: [            // Stack的子组件数组
                      // 条件渲染：只有在蓝牙未连接时才显示这个提示
                      // if语句在Dart中可以直接用于Widget列表中进行条件渲染
                      if (connectionState != BluetoothConnectionState.connected)
                        Container(
                          width: double.infinity,        // 宽度占满父容器
                          padding: const EdgeInsets.all(16),  // 内边距16像素
                          child: Card(                   // Card组件提供Material Design卡片样式
                            color: const Color(0xFFFEF2F2),  // 设置卡片背景色（浅红色）
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(             // Column组件用于垂直排列子组件
                                mainAxisSize: MainAxisSize.min,  // Column的主轴大小适应内容
                                mainAxisAlignment: MainAxisAlignment.center,  // 子组件在主轴上居中
                                children: [
                                  Icon(                  // Icon组件显示图标
                                    Icons.bluetooth_disabled,  // Material Design的蓝牙禁用图标
                                    color: const Color(0xFFEF4444),  // 图标颜色（红色）
                                    size: 48,            // 图标大小48像素
                                  ),
                                  const SizedBox(height: 8),  // SizedBox用于添加间距
                                  Text(                  // Text组件显示文本
                                    'Collar Disconnected',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: const Color(0xFFEF4444),  // 文本颜色
                                      fontWeight: FontWeight.bold,     // 字体粗细
                                    ),
                                  ),
                                  Text(
                                    'Showing Default Animation',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,  // 灰色文本
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      
                      // 宠物动画显示区域
                      // Builder组件用于在需要新BuildContext时创建子组件
                      Builder(builder: (context) {
                        // 从ViewModel获取当前宠物图片资源路径
                        final petAsset = ref.read(homeScreenViewModelProvider.notifier).getCurrentPetImageAsset();
                        // 判断是否显示真实宠物图片（连接状态正常且有图片资源）
                        final showRealPet = connectionState != BluetoothConnectionState.disconnected && petAsset.isNotEmpty;
                        
                        return ClipRRect(           // ClipRRect用于裁剪子组件为圆角矩形
                          borderRadius: BorderRadius.circular(16),  // 设置圆角半径为16像素
                          child: Image.asset(      // Image.asset用于显示本地资源图片
                            // 三元运算符：如果有真实宠物图片就显示，否则显示当前动作的GIF
                            showRealPet ? petAsset : currentAction.getFullGifPath(),
                            fit: BoxFit.contain,   // 图片适应方式：保持比例，完整显示
                            // errorBuilder是图片加载失败时的回调函数
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(         // 加载失败时显示宠物图标
                                Icons.pets,        // Material Design的宠物图标
                                size: 60,          // 图标大小60像素
                                // withValues(alpha: 0.4)设置透明度为40%
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                              );
                            },
                          ),
                        );
                      }),
                      
                      // 动作名称叠加显示（只在蓝牙连接时显示）
                      if (connectionState == BluetoothConnectionState.connected)
                        Positioned(              // Positioned用于在Stack中定位子组件
                          bottom: 16,            // 距离底部16像素
                          left: 16,              // 距离左边16像素
                          right: 16,             // 距离右边16像素
                          child: Card(           // 使用Card组件作为背景
                            // 设置半透明黑色背景
                            color: Colors.black.withValues(alpha: 0.7),
                            child: Padding(
                              // symmetric表示水平和垂直方向使用不同的内边距
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text(
                                currentAction.actionName,  // 显示当前动作名称
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,     // 白色文字
                                ),
                                textAlign: TextAlign.center,  // 文本居中对齐
                              ),
                            ),
                          ),
                        ),
                    ],  // Stack的children结束
                  ),
                ),
              ),
              
              // 右侧区域：情绪值进度条
              Expanded(
                flex: 15,                        // 占用15份空间，与左侧健康值进度条对称
                child: _buildMoodProgressBar(moodValue),  // 调用构建情绪进度条的方法
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 私有方法：构建健康值进度条组件
  // 参数value是0.0到1.0之间的double值，表示健康值百分比
  Widget _buildHealthProgressBar(double value) {
    return Container(
      height: double.infinity,      // 高度占满父容器
      // 只设置垂直方向的内边距，上下各20像素
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(                // 垂直排列子组件
        mainAxisAlignment: MainAxisAlignment.center,  // 子组件在主轴上居中
        children: [
          Text(                     // 显示"Health"标签
            'Health',
            style: TextStyle(
              fontSize: 12,          // 字体大小12像素
              fontWeight: FontWeight.w600,  // 字体粗细（w600是半粗体）
              color: AppColors.textSecondary,  // 使用应用定义的次要文本颜色
            ),
          ),
          const SizedBox(height: 8),  // 添加8像素的垂直间距
          Expanded(                 // Expanded让进度条占用剩余空间
            child: RotatedBox(      // RotatedBox用于旋转子组件
              quarterTurns: 3,      // 逆时针旋转3个90度（即270度），让进度条变成垂直
              child: LinearProgressIndicator(  // 线性进度条组件
                value: value,       // 进度值（0.0-1.0）
                backgroundColor: Colors.grey.shade300,  // 背景色（浅灰色）
                // AlwaysStoppedAnimation确保颜色不会动画变化
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,  // 进度条颜色使用应用主色调红色
                ),
                minHeight: 8,       // 进度条最小高度8像素
              ),
            ),
          ),
          const SizedBox(height: 8),  // 添加8像素间距
          Text(
            // 将0.0-1.0的值转换为0-100的百分比显示
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,          // 字体大小
              fontWeight: FontWeight.bold,  // 粗体
              color: AppColors.primary,     // 使用主色调红色
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  // 私有方法：构建情绪值进度条组件
  // 结构与健康进度条完全相同，只是标签文本不同
  Widget _buildMoodProgressBar(double value) {
    return Container(
      height: double.infinity,      // 高度占满父容器
      padding: const EdgeInsets.symmetric(vertical: 20),  // 垂直内边距
      child: Column(                // 垂直排列子组件
        mainAxisAlignment: MainAxisAlignment.center,  // 居中对齐
        children: [
          Text(                     // 显示"Mood"标签
            'Mood',
            style: TextStyle(
              fontSize: 12,          // 字体大小
              fontWeight: FontWeight.w600,  // 字体粗细
              color: AppColors.textSecondary,  // 次要文本颜色
            ),
          ),
          const SizedBox(height: 8),  // 垂直间距
          Expanded(                 // 进度条占用剩余空间
            child: RotatedBox(      // 旋转组件使进度条垂直显示
              quarterTurns: 3,      // 旋转270度
              child: LinearProgressIndicator(  // 线性进度条
                value: value,       // 情绪值（0.0-1.0）
                backgroundColor: Colors.grey.shade300,  // 背景色
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,  // 使用应用主色调红色
                ),
                minHeight: 8,       // 进度条高度
              ),
            ),
          ),
          const SizedBox(height: 8),  // 间距
          Text(
            // 显示百分比数值
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,          // 字体大小
              fontWeight: FontWeight.bold,  // 粗体
              color: AppColors.primary,     // 主色调红色
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }



  // 私有方法：构建宠物状态信息区域
  Widget _buildPetStatusSection() {
    return Container(
      width: double.infinity,        // 宽度占满父容器
      margin: const EdgeInsets.all(16),  // 四周外边距16像素
      child: Card(                   // Card组件提供阴影和圆角效果
        elevation: 4,                // 阴影高度4像素
        shape: RoundedRectangleBorder(  // 自定义Card形状
          borderRadius: BorderRadius.circular(12),  // 圆角半径12像素
        ),
        color: const Color(0xFFF5F5F5),  // 浅灰色背景
        child: Padding(
          padding: const EdgeInsets.all(16),  // 内边距16像素
          child: Column(             // 垂直排列子组件
            crossAxisAlignment: CrossAxisAlignment.start,  // 子组件左对齐
            children: [
              Text(                  // 标题文本
                'Health Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,  // 粗体标题
                ),
              ),
              const SizedBox(height: 12),  // 标题下方间距
              Row(                   // 水平排列三个健康信息按钮
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,  // 子组件均匀分布
                children: [
                  // 第一个健康信息按钮：基本信息
                  Expanded(                  // Expanded让按钮平均分配空间
                    child: _buildHealthInfoItem(
                      Icons.folder,          // 文件夹图标
                      'BASIC INFORMATION',   // 按钮文本
                      const Color(0xFFFFB3BA),  // 按钮背景色（浅粉色）
                      () {                   // 点击回调函数
                        Navigator.of(context).push(  // 导航到健康信息页面
                          MaterialPageRoute(
                            builder: (context) => const HealthInformationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  // 第二个健康信息按钮：数据分析
                  Expanded(
                    child: _buildHealthInfoItem(
                      Icons.bar_chart,       // 柱状图图标
                      'DATA ANALYSIS',       // 按钮文本
                      const Color(0xFFFFB3BA),  // 相同的背景色
                      () {                   // 点击回调
                        Navigator.of(context).push(  // 导航到健康数据页面
                          MaterialPageRoute(
                            builder: (context) => const HealthDataScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  // 第三个健康信息按钮：健康日历
                  Expanded(
                    child: _buildHealthInfoItem(
                      Icons.calendar_month,  // 日历图标
                      'HEALTH CALENDAR',     // 按钮文本
                      const Color(0xFFFFB3BA),  // 相同的背景色
                      () {                   // 点击回调
                        Navigator.of(context).push(  // 导航到健康日历页面
                          MaterialPageRoute(
                            builder: (context) => const HealthCalendarScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 私有方法：构建健康信息按钮组件
  // 这是一个通用的按钮构建器，接收图标、文本、颜色和点击回调作为参数
  Widget _buildHealthInfoItem(
    IconData icon,        // 图标数据（Material Design图标）
    String label,         // 按钮显示的文本标签
    Color color,          // 按钮背景颜色
    VoidCallback onTap,   // 点击事件回调函数（VoidCallback表示无参数无返回值的函数）
  ) {
    return GestureDetector(  // GestureDetector用于检测手势事件
      onTap: onTap,          // 设置点击回调
      child: Padding(        // 添加水平内边距
        padding: const EdgeInsets.symmetric(horizontal: 4),  // 左右各4像素间距
        child: Column(       // 垂直排列图标和文本
          mainAxisAlignment: MainAxisAlignment.center,  // 居中对齐
          children: [
            Container(       // 图标容器
              width: 60,     // 固定宽度60像素
              height: 60,    // 固定高度60像素
              decoration: BoxDecoration(  // 容器装饰
                color: color,            // 使用传入的背景颜色
                borderRadius: BorderRadius.circular(12),  // 圆角12像素
              ),
              child: Icon(   // 图标组件
                icon,        // 使用传入的图标
                color: Colors.white,  // 白色图标
                size: 30,    // 图标大小30像素
              ),
            ),
            const SizedBox(height: 8),  // 图标和文本之间的间距
            Text(           // 文本标签
              label,        // 显示传入的文本
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.black,     // 黑色文字
                fontWeight: FontWeight.w500,  // 中等粗细
              ),
              textAlign: TextAlign.center,  // 文本居中对齐
            ),
          ],
        ),
      ),
    );
  }

  /// 私有方法：构建项圈信息区域
  /// 显示项圈的电量、宝石状态、连接状态等信息
  Widget _buildCollarInfoSection({
    required PetCollar collar,        // 必需参数：项圈数据对象
    required VoidCallback onCollarClick,  // 必需参数：点击回调函数
  }) {
    return Container(
      width: double.infinity,          // 宽度占满父容器
      margin: const EdgeInsets.all(16),  // 四周外边距16像素
      child: Card(                     // Card组件提供阴影效果
        elevation: 4,                  // 阴影高度4像素
        shape: RoundedRectangleBorder( // 自定义Card形状
          borderRadius: BorderRadius.circular(12),  // 圆角12像素
        ),
        child: InkWell(               // InkWell提供点击水波纹效果
          onTap: onCollarClick,       // 设置点击回调
          borderRadius: BorderRadius.circular(12),  // 水波纹效果的圆角
          child: Padding(
            padding: const EdgeInsets.all(16),  // 内边距16像素
            child: Column(            // 垂直排列所有内容
              children: [
                // 标题行：显示"Collar Status"和右箭头
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 两端对齐
                  children: [
                    Text(             // 标题文本
                      'Collar Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,  // 粗体标题
                      ),
                    ),
                    Icon(             // 右箭头图标，提示可点击
                      Icons.keyboard_arrow_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 第一行：电量和宝石概况 - 严格匹配旧项目布局
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 电量状态 - 严格匹配旧项目
                    Row(
                      children: [
                        Icon(
                          _getBatteryIcon(collar.batteryLevel),
                          color: _getBatteryColor(collar.batteryLevel),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${collar.batteryLevel}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getBatteryColor(collar.batteryLevel),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    
                    // 宝石概况 - 严格匹配旧项目
                    Row(
                      children: [
                        Icon(
                          Icons.diamond,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${collar.gems.where((g) => g.isConnected).length}/4 Gems',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 第二行：网络连接状态 - 严格匹配旧项目
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildConnectionStatus(
                        'Bluetooth',
                        collar.bluetoothConnected,
                      ),
                    ),
                    Expanded(
                      child: _buildConnectionStatus(
                        'WiFi',
                        collar.wifiConnected,
                      ),
                    ),
                    Expanded(
                      child: _buildConnectionStatus(
                        'Safe Zone',
                        collar.isInSafeZone,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 第三行：状态模式 - 严格匹配旧项目
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          collar.powerMode == PowerMode.performance 
                            ? Icons.speed 
                            : Icons.battery_alert,
                          color: collar.powerMode == PowerMode.performance
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          collar.powerMode.displayName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // 在线状态指示器 - 严格匹配旧项目
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: collar.isOnline 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          collar.isOnline ? 'Online' : 'Offline',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: collar.isOnline 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 提示文本 - 严格匹配旧项目
                Text(
                  'Tap to manage collar settings and view detailed information',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 连接状态组件 - 严格匹配旧项目ConnectionStatus
  Widget _buildConnectionStatus(String label, bool isConnected) {
    return Column(
      children: [
        Icon(
          isConnected ? Icons.check_circle : Icons.cancel,
          color: isConnected ? const Color(0xFF10B981) : const Color(0xFFF87171),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 私有方法：根据电池电量获取对应的图标
  /// 参数level是电池电量百分比（0-100）
  IconData _getBatteryIcon(int level) {
    // 使用if语句链判断电量范围，返回对应的Material Design电池图标
    if (level >= 90) return Icons.battery_full;      // 90%以上：满电图标
    if (level >= 75) return Icons.battery_6_bar;     // 75-89%：6格电量图标
    if (level >= 50) return Icons.battery_4_bar;     // 50-74%：4格电量图标
    if (level >= 25) return Icons.battery_2_bar;     // 25-49%：2格电量图标
    if (level >= 10) return Icons.battery_1_bar;     // 10-24%：1格电量图标
    return Icons.battery_alert;                      // 10%以下：电量警告图标
  }

  /// 私有方法：根据电池电量获取对应的颜色
  /// 参数level是电池电量百分比（0-100）
  Color _getBatteryColor(int level) {
    // 根据电量范围返回不同颜色，用于电池图标和文字显示
    if (level >= 50) return const Color(0xFF10B981); // 50%以上：绿色（正常）
    if (level >= 20) return const Color(0xFFF59E0B); // 20-49%：橙色（警告）
    return const Color(0xFFEF4444);                  // 20%以下：红色（危险）
  }
}