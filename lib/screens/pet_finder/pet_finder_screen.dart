// === 导入语句部分 ===
// 在Dart语言中，import语句用于引入外部库和模块
// 'dart:' 前缀表示Dart内置库
// 'package:' 前缀表示第三方包或内部项目模块

// 导入Dart异步库，用于Timer和其他异步操作
import 'dart:async';

// 导入Flutter的Material Design组件库
// Material Design是Google的UI设计语言
// 该库包含常用的UI组件，如按钮、卡片、对话框等
import 'package:flutter/material.dart';

// 导入Riverpod状态管理库
// Riverpod是用于在Flutter中管理应用状态的第三方库
// 它帮助我们在不同组件之间共享和管理数据
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 导入自定义跨平台地图组件
// 这是项目中编写的自定义地图组件，封装了Android和iOS地图功能
// 允许相同代码在两个平台上运行
import 'package:pet_talk/widgets/standard_baidu_map_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 导入宠物寻找相关数据模型
// 数据模型定义应用中使用的数据结构，如宠物信息、位置信息等
// 模型确保数据类型安全和结构一致性
import 'package:pet_talk/models/pet_finder_models.dart';

// 导入导航服务工厂 - 自动适配平台选择合适的导航服务
import 'package:pet_talk/services/map/navigation_service_factory.dart';

// 导入宠物寻找API服务
// 这是与后端服务器通信的服务类，用于发送和接收宠物相关数据
import 'package:pet_talk/services/virtual_fence/pet_finder_api_service.dart';

// 导入真实定位服务
// 用于获取用户真实GPS位置信息
import 'package:pet_talk/services/map/location_service.dart';


// 导入虚拟围栏API服务
import 'package:pet_talk/services/virtual_fence/virtual_fence_api_service.dart';

// 导入虚拟围栏数据模型
import 'package:pet_talk/models/virtual_fence_models.dart';
// 本地存储
import 'package:pet_talk/services/virtual_fence/virtual_fence_local_store.dart';
// 导入新的预览管理器
import 'package:pet_talk/services/virtual_fence/virtual_fence_preview.dart';

// === 类定义部分 ===
/// 在Dart中，以///开头的注释是文档注释，可以被工具自动提取生成API文档
/// ConsumerStatefulWidget是Riverpod库提供的有状态组件基类
/// StatefulWidget意味着这个组件有内部状态，状态改变时UI会重新构建
class PetFinderScreen extends ConsumerStatefulWidget {
  // 构造函数，super.key传递给父类
  // const表示这是编译时常量构造函数，提高性能
  // {super.key}是命名参数语法，super.key调用父类构造函数
  // Key是Flutter用来识别组件的唯一标识符
  const PetFinderScreen({super.key});

  // 创建状态对象，返回对应的State类实例
  // @override表示重写父类方法，这是面向对象编程中多态的概念
  // ConsumerState是泛型状态类，<PetFinderScreen>指定对应的组件类型
  @override
  ConsumerState<PetFinderScreen> createState() => _PetFinderScreenState();
}

// === 状态类定义 ===
// 管理宠物寻找界面状态和逻辑的私有状态类
// 下划线前缀表示私有，只能在当前文件中访问，这是Dart的命名约定
// ConsumerState是Riverpod的状态类，可以监听和使用Providers
// <PetFinderScreen>是泛型类型，指定这个状态类对应的组件类型
class _PetFinderScreenState extends ConsumerState<PetFinderScreen> {
  
  // === 服务实例部分 ===
  // 在Dart中，final表示变量只能赋值一次，但对象内容可以改变
  // 这些是用于处理业务逻辑和数据操作的服务层对象
  
  // 导航服务实例，根据平台自动选择百度地图或Google Maps
  // NavigationServiceFactory.getInstance()自动适配平台
  final _navigationService = NavigationServiceFactory.getInstance();
  
  // 宠物寻找API服务实例，用于与后端通信
  // 负责发送HTTP请求，获取和提交宠物相关数据
  final _apiService = PetFinderApiService();
  
  // 真实定位服务实例，用于获取用户GPS位置
  // 负责处理位置权限、GPS定位等
  final _locationService = LocationService();
  
  // 虚拟围栏API服务实例，用于管理虚拟围栏
  final _fenceApiService = VirtualFenceApiService();
  // 本地围栏存储
  final _localFenceStore = VirtualFenceLocalStore();
  
  // 虚拟围栏列表
  List<StandardCircle> _virtualFences = [];
  
  // 围栏列表数据
  List<VirtualFence> _fenceList = [];
  
  // 使用新的预览管理器替代原有的围栏创建状态
  final VirtualFencePreview _fencePreview = VirtualFencePreview();
  String _newFenceName = 'My Fence'; // 新围栏名称
  String _newFenceIcon = '🏠'; // 新围栏图标
  bool _newFenceActivateImmediately = true; // 新围栏是否立即激活
  
  // 半径输入控制器（替换滑块为用户输入）
  late TextEditingController _radiusController;
  
  // 防抖定时器，避免输入时过于频繁更新
  Timer? _radiusDebounceTimer;
  
  // 🔧 防止重复保存的标志
  bool _isSavingFence = false;

  // === 性能监控变量部分 ===
  // 用于监控 build 方法调用次数和性能
  // static int _buildCallCount = 0;
  // static DateTime? _lastBuildTime;
  // static final List<DateTime> _buildTimes = [];
  
  // === 数据状态变量部分 ===
  // 这些变量存储组件的状态数据，当它们改变时，UI会重新构建
  
  // 宠物位置数据，?表示可以为null（初始时还没有数据）
  // Dart中的null safety特性，?表示这个变量可以为空
  // PetLocationData是自定义的数据模型类，包含宠物的位置信息
  PetLocationData? _petData;
  
  // 用户位置数据，late表示延迟初始化但保证在使用前被赋值
  // late关键字告诉Dart这个变量会在使用前被初始化，但不是在声明时
  // 如果在初始化前使用会抛出运行时错误
  late UserLocationData _userData;
  
  // 当前导航路径，可为空
  // NavigationRoute包含导航的路径点、距离、时间等信息
  NavigationRoute? _currentRoute;
  
  // 是否正在导航的状态标志
  // bool是布尔类型，只能是true或false
  // 用于控制UI显示不同的导航状态
  bool _isNavigating = false;
  
  // 是否正在加载路径的状态标志
  // 当用户点击导航按钮后，在获取路径期间显示加载状态
  bool _isLoadingRoute = false;
  
  // 选择的导航类型：walking(步行)、cycling(骑行)、driving(驾车)
  // String是字符串类型，存储当前选择的导航方式
  String _selectedRouteType = 'walking'; // 默认步行导航

  // === 生命周期方法部分 ===
  // 重写initState方法，组件初始化时调用
  // initState是StatefulWidget的生命周期方法，在组件创建时只调用一次
  // 这里适合做一些初始化工作，如网络请求、数据初始化等
  @override
  void initState() {
    // 必须先调用父类的initState，这是Flutter的规定
    // super关键字用于调用父类的方法
    super.initState();
    // 初始化半径输入框，默认取预览管理器半径
    _radiusController = TextEditingController(
      text: _fencePreview.radius.toStringAsFixed(0),
    );
    // 初始化数据
    _initializeData();
  }

  // 释放资源
  @override
  void dispose() {
    // 在页面销毁前打印统计信息
    // _printBuildStatistics();
    
    _radiusController.dispose();
    _radiusDebounceTimer?.cancel();
    super.dispose();
  }



  // === 数据初始化方法部分 ===
  /// async表示这是异步函数，用于处理异步操作如网络请求、定位等
  /// Future<void>表示这个方法返回一个Future对象，但不返回具体值
  /// 方法名前的下划线表示这是私有方法，只能在当前类中调用
  Future<void> _initializeData() async {
    // 先尝试获取用户真实位置，失败则使用默认位置
    await _getUserRealLocation();
    
    // 基于用户位置生成模拟宠物数据
    _generateMockPetLocation();

    // 加载虚拟围栏
    await _loadVirtualFences();
  }

  /// 获取用户真实位置
  Future<void> _getUserRealLocation() async {
    try {
      final locationResult = await _locationService.getLocation(
        timeout: const Duration(seconds: 10),
        highAccuracy: true,
      );

      if (locationResult.isSuccess && locationResult.position != null) {
        setState(() {
          _userData = UserLocationData(
            location: locationResult.position!,
            address: 'My Location',
          );
        });
      } else {
        String errorMessage = _getLocationErrorMessage(locationResult);
        
        if (mounted) {
          setState(() {
            _userData = const UserLocationData(
              location: StandardLatLng(39.9200, 116.4074),
              address: 'Default Location (Location Failed)',
            );
          });
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location failed: $errorMessage', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _getUserRealLocation,
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _userData = const UserLocationData(
          location: StandardLatLng(39.9200, 116.4074),
          address: 'Default Location (Location Exception)',
        );
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location service error, using default location', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    }
  }

  /// 根据定位结果状态获取用户友好的错误信息
  String _getLocationErrorMessage(LocationResult result) {
    switch (result.status) {
      case LocationServiceStatus.permissionDenied:
        return 'Location permission required to show your location';
      case LocationServiceStatus.permissionDeniedForever:
        return 'Location permission permanently denied, please enable manually in settings';
      case LocationServiceStatus.serviceDisabled:
        return 'Please enable location services in settings';
      case LocationServiceStatus.timeout:
        return 'Location timeout, please check GPS signal';
      case LocationServiceStatus.error:
      default:
        return result.errorMessage ?? 'Unknown error';
    }
  }

  /// 加载虚拟围栏
  Future<void> _loadVirtualFences() async {
    debugPrint('🔄 [FENCE] 开始加载虚拟围栏...');
    debugPrint('🔄 [FENCE] 当前围栏列表长度: ${_fenceList.length}');
    debugPrint('🔄 [FENCE] 当前圆圈列表长度: ${_virtualFences.length}');
    
    try {
      const String userId = 'mock_user_123';
      final localFencesFuture = _localFenceStore.loadFences();
      final remoteFencesFuture = _fenceApiService.getUserFences(userId);
      final results = await Future.wait<List<VirtualFence>>([
        localFencesFuture,
        remoteFencesFuture,
      ]);
      
      debugPrint('🔄 [FENCE] 本地围栏数量: ${results[0].length}');
      debugPrint('🔄 [FENCE] 远程围栏数量: ${results[1].length}');
      
      // 🔧 修复重复问题：使用Map去重，确保相同ID的围栏不会重复
      final Map<String, VirtualFence> fenceMap = {};
      
      // 先添加本地围栏
      for (final fence in results[0]) {
        fenceMap[fence.id] = fence;
      }
      
      // 再添加远程围栏（如果本地没有相同ID的围栏）
      for (final fence in results[1]) {
        if (!fenceMap.containsKey(fence.id)) {
          fenceMap[fence.id] = fence;
        }
      }
      
      final List<VirtualFence> fences = fenceMap.values.toList();
      debugPrint('🔄 [FENCE] 去重后围栏数量: ${fences.length}');
      
      // 🔧 修复重复问题：清空现有圆圈列表，重新构建
      final List<StandardCircle> circles = [];
      for (int i = 0; i < fences.length; i++) {
        final fence = fences[i];
        final circle = StandardCircle(
          id: 'fence_${fence.id}',
          center: StandardLatLng(fence.center.latitude, fence.center.longitude),
          radius: fence.radius,
          fillColor: Colors.green.withOpacity(0.2),
          strokeColor: Colors.green,
          strokeWidth: 2.0,
        );
        circles.add(circle);
        debugPrint('🔄 [FENCE] 添加围栏圆圈: ${fence.name} (ID: ${fence.id}, 半径: ${fence.radius}m)');
      }
      
      setState(() {
        _fenceList = fences;
        _virtualFences = circles; // 🔧 完全替换，不是追加
      });
      
      debugPrint('🔄 [FENCE] 围栏加载完成，当前显示 ${circles.length} 个圆圈');
    } catch (e) {
      debugPrint('🔄 [FENCE] 远程加载失败，尝试本地加载: $e');
      try {
        final localOnly = await _localFenceStore.loadFences();
        debugPrint('🔄 [FENCE] 本地围栏数量: ${localOnly.length}');
        
        final circles = localOnly
            .map((fence) {
              debugPrint('🔄 [FENCE] 本地围栏: ${fence.name} (ID: ${fence.id})');
              return StandardCircle(
                id: 'fence_${fence.id}',
                center: StandardLatLng(
                    fence.center.latitude, fence.center.longitude),
                radius: fence.radius,
                fillColor: Colors.green.withOpacity(0.2),
                strokeColor: Colors.green,
                strokeWidth: 2.0,
              );
            })
            .toList();
        
        if (mounted) {
          setState(() {
            _fenceList = localOnly;
            _virtualFences = circles; // 🔧 完全替换，不是追加
          });
        }
        
        debugPrint('🔄 [FENCE] 本地围栏加载完成，当前显示 ${circles.length} 个圆圈');
      } catch (e2) {
        debugPrint('🔄 [FENCE] 本地加载也失败: $e2');
        // 🔧 确保即使加载失败也清空列表，避免显示过时数据
        if (mounted) {
          setState(() {
            _fenceList = [];
            _virtualFences = [];
          });
        }
      }
    }
  }

  /// 处理地图标记点击事件
  void _handleMarkerTap(StandardMarker marker) {
    switch (marker.id) {
      case 'pet_location':
        _drawRouteToPet(marker);
        break;
      case 'user_location':
        _getUserRealLocation();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Refreshing your location...', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        }
        break;
    }
  }

  /// 绘制到宠物位置的导航路径
  Future<void> _drawRouteToPet(StandardMarker petMarker) async {
    try {      
      final route = await _navigationService.getWalkingRoute(
        origin: _userData.location,
        destination: petMarker.position,
      );
      
      if (route != null) {
        setState(() {
          _currentRoute = route;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Route planned to ${_petData?.name ?? "pet"}! Distance: ${(route.totalDistance * 1000).toInt()}m', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Route planning failed, please check network connection', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Route planning failed: ${e.toString()}', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    }
  }



  /// 基于用户位置生成模拟宠物位置
  void _generateMockPetLocation() {
    final userLat = _userData.location.latitude;
    final userLng = _userData.location.longitude;
    
    final petLat = userLat + 0.01;  // 向北偏移约1.1km
    final petLng = userLng + 0.005; // 向东偏移约0.55km
    
    _petData = PetLocationData(
      id: 'pet_001',
      name: 'Mr.Mittens',
      imageUrl: 'assets/images/profile/adding-pets.png',
      location: StandardLatLng(petLat, petLng),
      address: '1357 Jackson Street',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      batteryLevel: 85,
      isOnline: true,
    );
    
    setState(() {});
  }



  // === 导航方法部分 ===
  /// 这是一个异步函数，会调用地图API获取路径并开始导航
  /// Future<void>表示这是一个异步方法，返回一个Future对象
  Future<void> _startNavigation() async {
    if (_petData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Pet location information unavailable', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 20,
            right: 20,
          ),
        ),
      );
      return;
    }

    // 直接在应用内规划路径，不询问用户
    await _planRouteInternally();
  }

  /// 在应用内规划并绘制路径到宠物位置
  Future<void> _planRouteInternally() async {
    setState(() {
      _isLoadingRoute = true;
    });
    
    // 显示开始规划路径的提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Planning route to pet...', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 20,
            right: 20,
          ),
        ),
      );
    }
    
    try {
      // 1. 优先按用户选择类型
      NavigationRoute? route = await _navigationService.getNavigationRoute(
        origin: _userData.location,
        destination: _petData!.location,
        routeType: _selectedRouteType,
      );

      // 2. 若失败，按常用顺序尝试其他类型
      if (route == null && _selectedRouteType != 'driving') {
        route = await _navigationService.getNavigationRoute(
          origin: _userData.location,
          destination: _petData!.location,
          routeType: 'driving',
        );
      }
      if (route == null && _selectedRouteType != 'walking') {
        route = await _navigationService.getNavigationRoute(
          origin: _userData.location,
          destination: _petData!.location,
          routeType: 'walking',
        );
      }
      if (route == null && _selectedRouteType != 'cycling') {
        route = await _navigationService.getNavigationRoute(
          origin: _userData.location,
          destination: _petData!.location,
          routeType: 'cycling',
        );
      }

      if (route != null && route.points.isNotEmpty) {
        setState(() {
          _currentRoute = route;
          _isNavigating = true;
        });
        
        
        // 提交后端记录
        try {
          await _apiService.submitNavigationRequest(
            petId: _petData!.id,
            userLocation: _userData.location,
            routeType: _selectedRouteType,
          );
        } catch (e) {
          // 后端提交失败不影响路径显示
        }
      } else {
        // 路径规划失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Route planning failed, please check network connection', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // 异常处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Route planning failed: ${e.toString()}', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  /// 停止导航
  void _stopNavigation() {
    // 重置导航相关的状态变量
    setState(() {
      _isNavigating = false;  // 标记不再导航
      _currentRoute = null;   // 清空当前路径数据
    });
  }

  /// 切换导航类型
  /// 用户选择不同的导航方式（步行/骑行/驾车）时调用
  /// routeType参数：新选择的导航类型字符串
  void _changeRouteType(String routeType) {
    // 检查新选择的类型是否与当前类型不同
    // != 是不等于比较操作符
    if (_selectedRouteType != routeType) {
      // 更新选择的导航类型
      setState(() {
        _selectedRouteType = routeType;  // 保存新的导航类型
        // 如果正在导航，需要停止当前导航
        // 因为不同导航类型的路径可能不同
        if (_isNavigating) {
          _stopNavigation();  // 调用停止导航方法
        }
      });
    }
  }



  // === UI Building Methods Section ===
  // 构建UI
  @override
  Widget build(BuildContext context) {
    // === 性能监控开始 ===
    // final now = DateTime.now();
    // _buildCallCount++;
    // _buildTimes.add(now);
    
    // // 计算与上次构建的时间间隔
    // final timeSinceLastBuild = _lastBuildTime != null 
    //     ? now.difference(_lastBuildTime!).inMilliseconds 
    //     : 0;
    
    // // 详细日志
    // debugPrint('🔄 [BUILD] ==========================================');
    debugPrint('🔄 [BUILD] 构建开始');
    debugPrint('🔄 [BUILD] 当前围栏数量: ${_fenceList.length}');
    debugPrint('🔄 [BUILD] 当前圆圈数量: ${_virtualFences.length}');
    debugPrint('🔄 [BUILD] 预览状态: ${_fencePreview.isActive}');
    // debugPrint('🔄 [BUILD] 当前时间: ${now.toString()}');
    // debugPrint('🔄 [BUILD] 距离上次: ${timeSinceLastBuild}ms');
    // debugPrint('🔄 [BUILD] 围栏状态: ${_fencePreview.isActive ? "创建中" : "正常"}');
    // debugPrint('🔄 [BUILD] 宠物数据: ${_petData != null ? "已加载" : "未加载"}');
    
    // // 性能警告
    // if (timeSinceLastBuild > 0 && timeSinceLastBuild < 100) {
    //   debugPrint('⚠️  [WARNING] 构建频率过高！间隔仅 ${timeSinceLastBuild}ms');
    // }
    
    // _lastBuildTime = now;
    
    // 开始计时构建耗时
    // final stopwatch = Stopwatch()..start();
    
    // === 构建UI组件 ===
    // 🎯 生产级键盘优化：完全禁用系统自动调整，使用手动控制
    final widget = Scaffold(
      // 🚫 关键优化：完全禁用键盘弹出时的系统页面调整
      resizeToAvoidBottomInset: false,
      body: Stack( // Stack布局允许子组件重叠显示，类似于CSS的absolute定位
        children: [
          // 第1层：地图背景（最底层）- 🛡️ RepaintBoundary完全隔离重建
          RepaintBoundary(
            key: const ValueKey('static_map_view'),
            child: _buildMapView(),
          ),
          
          // 第2层：顶部状态栏（悬浮在地图上方）- 🛡️ RepaintBoundary完全隔离重建
          RepaintBoundary(
            key: const ValueKey('static_top_bar'),
            child: _buildTopStatusBar(),
          ),
          
          // 第3层：底部信息卡片（悬浮在地图上方）- 🎯 智能键盘响应区域
          _buildKeyboardAwareBottomCard(),
          
          // 第4层：返回按钮（脱离文档流，独立定位）- 🛡️ RepaintBoundary完全隔离重建
          RepaintBoundary(
            key: const ValueKey('static_back_button'),
            child: _buildBackButton(),
          ),
        ],
      ),
    );
    
    // === 性能监控结束 ===
    // stopwatch.stop();
    // debugPrint('🔄 [BUILD] 构建耗时: ${stopwatch.elapsedMilliseconds}ms');
    // debugPrint('🔄 [BUILD] ==========================================');
    
    return widget;
  }

  /// 打印构建统计信息
  /// 分析构建频率和性能数据
  // void _printBuildStatistics() {
  //   if (_buildTimes.length < 2) return;
    
  //   final intervals = <int>[];
  //   for (int i = 1; i < _buildTimes.length; i++) {
  //     intervals.add(_buildTimes[i].difference(_buildTimes[i-1]).inMilliseconds);
  //   }
    
  //   final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
  //   final minInterval = intervals.reduce((a, b) => a < b ? a : b);
  //   final maxInterval = intervals.reduce((a, b) => a > b ? a : b);
    
  //   // 统计高频构建（间隔<100ms）
  //   final highFrequencyBuilds = intervals.where((interval) => interval < 100).length;
  //   final highFrequencyPercentage = (highFrequencyBuilds / intervals.length * 100);
    
  //   debugPrint('📊 [STATS] ==========================================');
  //   debugPrint('📊 [STATS] 总调用次数: $_buildCallCount');
  //   debugPrint('📊 [STATS] 平均间隔: ${avgInterval.toStringAsFixed(1)}ms');
  //   debugPrint('📊 [STATS] 最短间隔: ${minInterval}ms');
  //   debugPrint('📊 [STATS] 最长间隔: ${maxInterval}ms');
  //   debugPrint('📊 [STATS] 高频构建: $highFrequencyBuilds 次 (${highFrequencyPercentage.toStringAsFixed(1)}%)');
  //   debugPrint('📊 [STATS] 性能评估: ${_getPerformanceRating(avgInterval, highFrequencyPercentage)}');
  //   debugPrint('📊 [STATS] ==========================================');
  // }

  // /// 获取性能评级
  // String _getPerformanceRating(double avgInterval, double highFrequencyPercentage) {
  //   if (avgInterval > 500 && highFrequencyPercentage < 10) {
  //     return '🟢 优秀 - 构建频率合理';
  //   } else if (avgInterval > 200 && highFrequencyPercentage < 30) {
  //     return '🟡 良好 - 构建频率适中';
  //   } else if (avgInterval > 100 && highFrequencyPercentage < 50) {
  //     return '🟠 一般 - 构建频率偏高';
  //   } else {
  //     return '🔴 需要优化 - 构建频率过高，可能影响性能';
  //   }
  // }

  // /// 重置构建统计数据
  // /// 用于调试时重新开始统计
  // /// 使用方式：在需要的地方调用 _resetBuildStatistics()
  // // ignore: unused_element
  // void _resetBuildStatistics() {
  //   _buildCallCount = 0;
  //   _lastBuildTime = null;
  //   _buildTimes.clear();
  //   debugPrint('📊 [RESET] 构建统计数据已重置');
  // }

  /// 手动触发统计打印
  /// 可以在调试时随时调用查看当前统计
  /// 使用方式：在需要的地方调用 _triggerStatisticsPrint()
  // ignore: unused_element
  // void _triggerStatisticsPrint() {
  //   debugPrint('📊 [MANUAL] 手动触发统计打印');
  //   _printBuildStatistics();
  // }

  /// 构建返回按钮（脱离文档流）
  Widget _buildBackButton() {
    if (_petData == null) return const SizedBox.shrink();
    
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10, // 状态栏高度 + 16像素
      left: 16, // 左边距16像素
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建顶部状态栏
  Widget _buildTopStatusBar() {
    if (_petData == null) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Container(
            color: const Color(0xFFFEFEFE),
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 35),
            child: Row(
              children: [
                // 移除返回按钮，只保留标题
                const Spacer(),
                const Text(
                  'LOOKING FOR A PET',
                  style: TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.w200,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建地图视图
  Widget _buildMapView() {
    if (_petData == null) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
              SizedBox(height: 16),
              Text(
                'Loading pet location...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    final polylines = _currentRoute != null && _currentRoute!.points.isNotEmpty ? {_buildRoutePolyline()} : <StandardPolyline>{};
    
    return Stack(
      children: [
        // 底层地图 - 使用标准百度地图组件
        StandardBaiduMapWidget(
          initialPosition: StandardLatLng(
            _petData?.location.latitude ?? 39.915,
            _petData?.location.longitude ?? 116.404,
          ),
          initialZoom: 16.0,
          markers: _buildMapMarkers(), // 构建标记点
          circles: _buildMapCircles(), // 构建圆圈
          polylines: polylines,
          onTap: _handleMapTap,
          onMarkerTap: _handleMarkerTap,
        ),
        
        // 定位按钮 - 悬浮在地图右下角
        Positioned(
          right: 16,
          bottom: 120, // 避免与底部卡片重叠
          child: _buildLocationButton(),
        ),
      ],
    );
  }


  /// ,悬浮按钮，用于刷新用户位置
  Widget _buildLocationButton() {
    return FloatingActionButton(
      // 小尺寸的悬浮按钮
      mini: true,
      // 按钮背景色
      backgroundColor: Colors.white,
      // 按钮前景色（图标颜色）
      foregroundColor: Colors.blue,
      // 按钮阴影高度
      elevation: 4,
      onPressed: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Getting location...', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
        
        await _getUserRealLocation();
        
        if (mounted) {
          _generateMockPetLocation();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location updated: ${_userData.address}', style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        }
      },
      // 按钮图标
      child: const Icon(
        Icons.my_location, // GPS定位图标
        size: 20,
      ),
    );
  }

  /// 🎯 构建键盘感知的底部卡片
  /// 智能响应键盘弹出，只有这个组件会根据键盘状态调整位置
  Widget _buildKeyboardAwareBottomCard() {
    // 🎯 关键：只在这里获取键盘高度，其他组件完全不受影响
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Positioned(
      left: 0,    // 左边距0，占据全宽
      right: 0,   // 右边距0，占据全宽
      bottom: keyboardHeight,  // 🎯 关键：根据键盘高度动态调整底部位置
      child: AnimatedContainer(
        // 🎬 平滑动画：键盘弹出/收起时的过渡效果
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: _buildBottomInfoCard(),
      ),
    );
  }

  /// 构建底部操作区（静态内容）
  /// 显示宠物信息、导航控制和虚拟围栏管理
  Widget _buildBottomInfoCard() {
    // 直接返回内容容器，不再使用Positioned
    return Container(
        // BoxDecoration设置容器的装饰效果
        decoration: const BoxDecoration(
          color: Colors.white,  // 背景色白色
          // BorderRadius.vertical只设置垂直方向的圆角
          // top: Radius.circular(20)只设置顶部圆角20像素
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column( // Column垂直排列子组件
          // MainAxisSize.min使Column只占用必要的高度
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器 - 用户界面中常见的可拖拽提示元素
            Container(
              width: 40,   // 宽度40像素
              height: 4,   // 高度4像素（形成一个扁平的条状）
              // EdgeInsets.symmetric设置对称的外边距
              // vertical: 12表示上下各12像素边距
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,      // 浅灰色背景
                borderRadius: BorderRadius.circular(2), // 圆角2像素
              ),
            ),
            
            // 宠物信息卡片 - 调用私有方法构建,非围栏构建状态时显示
            if (!_fencePreview.isActive) _buildPetInfoCard(),
            
            // 注释掉的垂直间距，根据UI设计可能不需要
            // const SizedBox(height: 16),
            
            // 虚拟围栏部分 - 调用私有方法构建
            _buildVirtualFencesSection(),
            
            // 底部安全区域 - 为底部系统导航栏留出空间
            const SizedBox(height: 20),
          ],
        ),
    );
  }

  /// 构建宠物头像
  Widget _buildPetAvatar(double size) {

    return Container(
      width: size,   // 头像容器宽度60像素
      height: size,  // 头像容器高度60像素
      // BoxDecoration设置头像容器的装饰
      decoration: BoxDecoration(
        shape: BoxShape.circle,  // 设置为圆形
        // Border.all创建边框，根据宠物在线状态设置不同颜色
        border: Border.all(
          // 三元运算符：在线时绿色，离线时橙色
          color: _petData!.isOnline ? const Color(0xFF4CAF50) : Colors.orange,
          width: 3,  // 边框宽度3像素
        ),
      ),
      child: ClipRRect( // ClipRRect用于裁剪子组件为圆角矩形
        borderRadius: BorderRadius.circular(30), // 圆角半径30像素（形成圆形）
        child: Image.asset( // Image.asset加载本地资源图片
          _petData!.imageUrl,  // 宠物头像图片路径
          fit: BoxFit.cover,   // 图片填充方式：覆盖整个容器，保持宽高比
          // errorBuilder是图片加载失败时的回调函数
          errorBuilder: (context, error, stackTrace) {
            // 图片加载失败时显示默认的宠物图标
            return Container(
              color: Colors.grey.shade200, // 浅灰色背景
              child: Icon(
                Icons.pets,                 // Material Design的宠物图标
                size: 30,                   // 图标大小30像素
                color: Colors.grey.shade400, // 深一些的灰色
              ),
            );
          },
        ),
      ),
    );
  }

  
  /// 构建宠物信息卡片
  /// 显示宠物头像、基本信息和导航按钮
  /// 返回值：Widget - 宠物信息卡片组件
  Widget _buildPetInfoCard() {
    // 如果宠物数据为空，返回不占空间的空组件
    if (_petData == null) return const SizedBox.shrink();
    
    // 返回一个带阴影的白色卡片容器
    return Container(
      // EdgeInsets.symmetric(horizontal: 20)设置左右各20像素的外边距
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      // EdgeInsets.all(16)设置四周各16像素的内边距
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      // BoxDecoration设置容器的装饰效果
      decoration: BoxDecoration(
        color: Colors.white,                    // 背景色白色
        borderRadius: BorderRadius.circular(12), // 圆角12像素
        boxShadow: [                            // 阴影效果列表
          BoxShadow(
            // Colors.grey.withValues(alpha: 0.1)创建10%透明度的灰色阴影
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,                      // 阴影模糊半径8像素
            offset: const Offset(0, 2),         // 阴影偏移：向下2像素
          ),
        ],
      ),
      child: Row( // Row水平排列子组件
        children: [
          // 宠物头像容器
          _buildPetAvatar(50),
          
          // SizedBox创建固定宽度的空白间距
          const SizedBox(width: 16),
          
          // 宠物信息区域 - 使用Expanded占据剩余的水平空间
          Expanded(
            child: Column( // Column垂直排列宠物的各项信息
              // CrossAxisAlignment.start使所有子组件左对齐
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：宠物名称和在线状态指示器
                Row( // Row水平排列名称和状态点
                  children: [
                    // 宠物名称文本
                    Text(
                      _petData!.name,  // 显示宠物名称
                      style: const TextStyle(
                        fontSize: 14,                   // 字体大小14像素
                        fontWeight: FontWeight.w300,    // 字体粗细：600（半粗体）
                        color: Colors.black,            // 字体颜色黑色
                      ),
                    ),
                    const SizedBox(width: 8), // 名称和状态点之间的间距
                    // 在线状态指示器 - 小圆点
                    Container(
                      width: 8,   // 圆点宽度8像素
                      height: 8,  // 圆点高度8像素
                      decoration: BoxDecoration(
                        // 根据在线状态设置颜色：在线绿色，离线橙色
                        color: _petData!.isOnline ? const Color(0xFF4CAF50) : Colors.orange,
                        shape: BoxShape.circle, // 设置为圆形
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4), // 行间距4像素
                
                // 第二行：位置信息
                Row( // Row水平排列位置图标和地址文本
                  children: [
                    // 位置图标
                    Icon(
                      Icons.location_on,        // Material Design的位置图标
                      size: 14,                 // 图标大小12像素
                      color: const Color.fromARGB(250, 250, 5, 5), // 灰色图标
                    ),
                    const SizedBox(width: 2), // 图标和文本间距
                    // 地址文本 - 使用Expanded防止文本溢出
                    Expanded(
                      child: Text(
                        _petData!.address,      // 显示宠物位置地址
                        style: TextStyle(
                          fontSize: 10,                 // 字体大小12像素
                          color: Colors.grey.shade600,  // 灰色字体
                        ),
                        // TextOverflow.ellipsis当文本过长时显示省略号
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4), // 行间距4像素
                
                // 第三行：电池电量信息
                Row( // Row水平排列电池图标和电量文本
                  children: [
                    // 电池图标
                    Icon(
                      Icons.battery_charging_full, // 充电电池图标
                      size: 16,                     // 图标大小16像素
                      // 根据电量设置图标颜色：大于20%绿色，否则橙色（低电量警告）
                      color: _petData!.batteryLevel > 20 ? const Color(0xFF4CAF50) : Colors.orange,
                    ),
                    const SizedBox(width: 2), // 图标和文本间距
                    // 电量百分比文本
                    Text(
                      '${_petData!.batteryLevel}%', // 显示电量百分比
                      style: TextStyle(
                        fontSize: 12,                 // 字体大小12像素
                        color: Colors.grey.shade600,  // 灰色字体
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 导航按钮区域 - 右侧的导航控制部分
          Column( // Column垂直排列导航相关的UI元素
            children: [
              // 导航类型选择器 - 只在未导航时显示
              // if statement for conditional rendering, !_isNavigating means "not navigating"
              // ...[]语法是展开操作符，将列表中的元素展开插入
              if (!_isNavigating) ...[
                Row( // Row水平排列三个导航类型按钮
                  // MainAxisSize.min使Row只占用必要的宽度
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 步行导航按钮
                    _buildRouteTypeButton('walking', Icons.directions_walk),
                    const SizedBox(width: 4), // 按钮间距4像素
                    // 骑行导航按钮
                    _buildRouteTypeButton('cycling', Icons.directions_bike),
                    const SizedBox(width: 4), // 按钮间距4像素
                    // 驾车导航按钮
                    _buildRouteTypeButton('driving', Icons.directions_car),
                  ],
                ),
                const SizedBox(height: 8), // 选择器和主按钮间距8像素
              ],
              
              // 主要导航按钮 - 开始/停止导航
              ElevatedButton(
                // onPressed设置按钮点击事件
                // 三元运算符嵌套：加载中时禁用，否则根据导航状态调用不同方法
                onPressed: _isLoadingRoute ? null : (_isNavigating ? _stopNavigation : _startNavigation),
                // ElevatedButton.styleFrom设置按钮样式
                style: ElevatedButton.styleFrom(
                  // 根据导航状态设置背景色：导航中橙色，未导航红色
                  backgroundColor: _isNavigating ? Colors.orange : const Color(0xFFE53935),
                  foregroundColor: Colors.white,  // 前景色（文字和图标）白色
                  // EdgeInsets.symmetric设置按钮内边距
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  // RoundedRectangleBorder设置按钮形状为圆角矩形
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // 圆角半径20像素
                  ),
                ),
                // 按钮内容 - 根据状态显示不同内容
                child: _isLoadingRoute
                    // 加载状态：显示进度指示器
                    ? const SizedBox(
                        width: 16,   // 进度指示器宽度16像素
                        height: 16,  // 进度指示器高度16像素
                        child: CircularProgressIndicator(
                          color: Colors.white,  // 进度指示器颜色白色
                          strokeWidth: 2,       // 进度指示器线条宽度2像素
                        ),
                      )
                    // 非加载状态：显示文本
                    : Text(
                        // 根据导航状态显示不同文本
                        _isNavigating ? 'STOP' : 'GO HERE',
                        style: const TextStyle(
                          fontSize: 12,                 // 字体大小12像素
                          fontWeight: FontWeight.w300,  // 字体粗细600（半粗体）
                        ),
                      ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  /// 构建导航类型选择按钮
  /// 创建一个可点击的圆形按钮，用于选择不同的导航类型
  /// routeType参数：导航类型字符串（'walking'、'cycling'、'driving'）
  /// icon参数：按钮显示的图标
  /// 返回值：Widget - 导航类型选择按钮组件
  Widget _buildRouteTypeButton(String routeType, IconData icon) {
    // 判断当前按钮是否被选中
    // == 是相等比较操作符，比较当前选择的导航类型和按钮代表的类型
    final isSelected = _selectedRouteType == routeType;
    
    // 返回一个可检测手势的容器
    return GestureDetector(
      // onTap设置点击事件回调函数
      // () => 是箭头函数语法，调用切换导航类型的方法
      onTap: () => _changeRouteType(routeType),
      child: Container(
        width: 32,   // 按钮宽度32像素
        height: 32,  // 按钮高度32像素（形成正方形）
        // BoxDecoration设置容器的装饰效果
        decoration: BoxDecoration(
          // 根据选中状态设置背景色：选中红色，未选中白色
          color: isSelected ? const Color(0xFFE53935) : Colors.white,
          // BorderRadius.circular(16)设置圆角，16像素圆角使32x32的容器变成圆形
          borderRadius: BorderRadius.circular(16),
          // Border.all设置边框
          border: Border.all(
            // 根据选中状态设置边框颜色：选中红色，未选中浅灰色
            color: isSelected ? const Color(0xFFE53935) : Colors.grey.shade300,
            width: 1, // 边框宽度1像素
          ),
        ),
        child: Icon(
          icon, // 显示传入的图标（步行、骑行或驾车图标）
          size: 18, // 图标大小18像素
          // 根据选中状态设置图标颜色：选中白色，未选中深灰色
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  /// 构建虚拟围栏操作区域
  /// 显示虚拟围栏管理界面，根据状态显示不同内容
  /// 返回值：Widget - 虚拟围栏管理组件
  Widget _buildVirtualFencesSection() {
    return Container(
      // EdgeInsets.symmetric(horizontal: 20)设置左右各20像素的外边距
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column( // Column垂直排列虚拟围栏相关的UI元素
        children: [
          // 虚拟围栏标题行 - 包含图标、标题文字和添加按钮
          Container(
            height: 20,
            margin: const EdgeInsets.only(bottom: 5),
            child: Row( // Row水平排列标题栏的各个元素
              children: [
                // 围栏图标
                Icon(
                  Icons.fence,                  // Material Design的围栏图标
                  size: 16,                     // 图标大小16像素
                  color: const Color.fromARGB(250, 250, 5, 5),  // 深灰色图标
                ),
                const SizedBox(width: 8), // 图标和文字间距8像素
                // 标题文字
                const Text(
                  'Virtual Fences', // 英文标题
                  style: TextStyle(
                    fontSize: 14,                 // 字体大小14像素
                    fontWeight: FontWeight.w200,  // 字体粗细400（半粗体）
                    color: Colors.black,          // 字体颜色黑色
                  ),
                ),
                // Spacer占据剩余空间，将添加按钮推到右侧
                const Spacer(),
                // 添加按钮 - 进入/取消创建模式
                TextButton(
                  onPressed: () {
                    if (_fencePreview.isActive) {
                      _fencePreview.endPreview();
                      setState(() {
                        _newFenceName = 'My Fence';
                        _newFenceActivateImmediately = true;
                        _radiusController.text = _fencePreview.radius.toStringAsFixed(0);
                      });
                      
                    } else {
                      _fencePreview.startPreview();
                      setState(() {
                        _radiusController.text = _fencePreview.radius.toStringAsFixed(0);
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Please tap the map to select fence center position', style: TextStyle(color: Colors.white)),
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height - 150,
                            left: 20,
                            right: 20,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _fencePreview.isActive ? 'Cancel' : 'Add >',  // 根据状态显示不同文本
                    style: TextStyle(
                      fontSize: 14,                 // 字体大小14像素
                      color: Colors.grey.shade500,  // 中等灰色字体
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 12), // 标题和内容区间距12像素
          
          // 根据状态显示不同内容
          _fencePreview.isActive ? _buildFenceCreationPanel() : _buildFenceListPanel(),
        ],
      ),
    );
  }

  /// 构建地图圆圈集合（包括已有围栏和预览圆圈）
  Set<StandardCircle> _buildMapCircles() {
    // 🔧 修复重复问题：使用Map按ID去重，确保不会有重复的圆圈
    final Map<String, StandardCircle> circleMap = {};
    
    debugPrint('🔄 [FENCE] 开始构建地图圆圈...');
    debugPrint('🔄 [FENCE] _virtualFences数量: ${_virtualFences.length}');
    
    // 添加所有虚拟围栏圆圈
    for (final circle in _virtualFences) {
      if (circleMap.containsKey(circle.id)) {
        debugPrint('🚨 [FENCE] 发现重复圆圈ID: ${circle.id}');
      } else {
        debugPrint('🔄 [FENCE] 添加围栏圆圈: ${circle.id} (半径: ${circle.radius}m)');
      }
      circleMap[circle.id] = circle;
    }
    
    // 添加预览圆圈（如果存在）
    final previewCircle = _fencePreview.getCurrentCircle();
    if (previewCircle != null) {
      if (circleMap.containsKey(previewCircle.id)) {
        debugPrint('🚨 [FENCE] 预览圆圈ID重复: ${previewCircle.id}');
      } else {
        debugPrint('🔄 [FENCE] 添加预览圆圈: ${previewCircle.id} (半径: ${previewCircle.radius}m)');
      }
      circleMap[previewCircle.id] = previewCircle;
    }
    
    final result = circleMap.values.toSet();
    debugPrint('🔄 [FENCE] 地图圆圈最终数量: ${result.length}');
    debugPrint('🔄 [FENCE] 圆圈ID列表: ${result.map((c) => c.id).join(", ")}');
    
    return result;
  }

  /// 构建围栏列表面板（查看模式）
  Widget _buildFenceListPanel() {
    if (_fenceList.isEmpty) {
      // 添加围栏按钮 - 大的可点击区域，用于添加新的虚拟围栏
      return GestureDetector(
        onTap: () {
          _fencePreview.startPreview();
          setState(() {
            _radiusController.text = _fencePreview.radius.toStringAsFixed(0);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please tap the map to select fence center position', style: TextStyle(color: Colors.white)),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 150,
                left: 20,
                right: 20,
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,  // 宽度占据全部可用空间
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,       // 浅灰色背景
            borderRadius: BorderRadius.circular(12), // 圆角12像素
            border: Border.all(
              color: Colors.grey.shade200,    // 浅灰色边框
              style: BorderStyle.solid,       // 实线边框样式
            ),
          ),
          child: Row( // Row水平排列添加按钮的图标和文字
            children: [
              // 圆形添加图标容器
              Container(
                width: 25,   // 容器宽度25像素
                height: 25,  // 容器高度25像素（形成正方形）
                decoration: BoxDecoration(
                  color: Colors.white,          // 背景色白色
                  shape: BoxShape.circle,       // 设置为圆形
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.add,      // Material Design的加号图标
                  size: 14,       // 图标大小14像素
                  color: Colors.grey, // 图标颜色灰色
                ),
              ),
              const SizedBox(width: 12), // 图标和文字间距12像素
              // "Add"文字
              Text(
                'Add',  // 添加按钮的文字标签
                style: TextStyle(
                  fontSize: 14,                 // 字体大小14像素
                  color: const Color.fromARGB(250, 250, 5, 5),  // 深灰色字体
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // 显示围栏列表
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: _fenceList.map((fence) => _buildFenceListItem(fence)).toList(),
        ),
      );
    }
  }

  /// 构建单个围栏列表项
  Widget _buildFenceListItem(VirtualFence fence) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 围栏图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                fence.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 围栏信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fence.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${fence.center.latitude.toStringAsFixed(4)}, ${fence.center.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // 删除按钮
          IconButton(
            onPressed: () async {
              await _localFenceStore.deleteFence(fence.id);
              // ignore: unawaited_futures
              _fenceApiService.deleteFence(fence.id);
              await _loadVirtualFences();

            },
            icon: Icon(
              Icons.delete_outline,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建围栏创建面板（创建模式）
  Widget _buildFenceCreationPanel() {
    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称设置
          _buildFenceNameSetting(),
          
          // 分隔线
          const Divider(height: 1, color: Color.fromARGB(240, 240, 240, 240)),
          
          // 半径设置
          _buildFenceRadiusSetting(),
          
          // 分隔线
          const Divider(height: 1, color: Color.fromARGB(240, 240, 240, 240)),
          
          // 保存按钮
          _buildFenceSaveButton(),
        ],
      ),
    );
  }

  /// 构建围栏名称设置
  Widget _buildFenceNameSetting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: TextField(
              controller: TextEditingController(text: _newFenceName),
              onChanged: (value) {
                setState(() {
                  _newFenceName = value;
                });
              },
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter fence name',
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建围栏半径设置
  Widget _buildFenceRadiusSetting() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Radius',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  // 减号按钮
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _adjustRadius(-5),
                      icon: const Icon(Icons.remove, size: 16),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 半径输入框
                  Container(
                    width: 60,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextField(
                      controller: _radiusController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        height: 1.0, // 设置行高
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), // 移除垂直padding
                        isDense: true, // 使输入框更紧凑
                      ),
                      // ✅ 重新启用onChanged实现实时更新，但使用优化的防抖策略
                      onChanged: (value) => _applyRadiusFromInputRealtime(),
                      onSubmitted: (value) => _applyRadiusFromInput(),      // 保留：用户按回车
                      onEditingComplete: () => _applyRadiusFromInput(),     // 保留：失去焦点时
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 加号按钮
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _adjustRadius(5),
                      icon: const Icon(Icons.add, size: 16),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'meters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建围栏保存按钮
  Widget _buildFenceSaveButton() {
    // 只有选择了位置且未在保存中才能保存
    final bool canSave = _fencePreview.hasCenter && _newFenceName.trim().isNotEmpty && !_isSavingFence;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: canSave ? () async {
          await _saveFence();
        } : null, // 未选择位置或正在保存时禁用按钮
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63), // 粉红色
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: _isSavingFence
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              canSave ? 'SAVE' : (_fencePreview.hasCenter ? 'Please enter name' : 'Please select location first'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.0,
                color: canSave ? Colors.white : Colors.grey.shade300,
              ),
            ),
      ),
    );
  }

  /// 调整半径（通过+/-按钮）- 优化版本
  void _adjustRadius(double delta) {
    final currentRadius = _fencePreview.radius;
    final newRadius = (currentRadius + delta).clamp(5.0, 500.0);
    
    // 🎯 优化：检查是否实际发生了变化
    if ((newRadius - currentRadius).abs() < 0.1) {
      debugPrint('🔄 [RADIUS] 按钮调整无变化，跳过更新');
      return;
    }
    
    // 取消之前的防抖定时器
    _radiusDebounceTimer?.cancel();
    
    // 立即更新输入框显示和预览管理器（无需等待）
    _radiusController.text = newRadius.toStringAsFixed(0);
    _fencePreview.setRadius(newRadius);
    
    // 🎯 优化：只在预览模式时才触发UI重建
    if (_fencePreview.isActive) {
      debugPrint('🔄 [RADIUS] 按钮调整半径: $currentRadius → $newRadius');
      _radiusDebounceTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// 从输入框应用半径（实时更新版本）
  /// 用于onChanged事件，提供实时的圆圈更新
  void _applyRadiusFromInputRealtime() {
    // 取消之前的定时器
    _radiusDebounceTimer?.cancel();
    
    // 🎯 实时更新：使用较短的防抖时间，提供即时反馈
    _radiusDebounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        debugPrint('🔄 [RADIUS] 实时更新防抖定时器触发');
        _applyRadiusImmediately();
      }
    });
  }

  /// 从输入框应用半径（确认版本）
  /// 用于onSubmitted和onEditingComplete事件
  void _applyRadiusFromInput() {
    // 取消之前的定时器
    _radiusDebounceTimer?.cancel();
    
    // 🎯 确认更新：立即应用，包含完整的验证和提示
    if (mounted) {
      debugPrint('🔄 [RADIUS] 用户确认输入，立即应用半径');
      _applyRadiusWithValidation();
    }
  }

  /// 应用半径并进行完整验证（用于确认操作）
  void _applyRadiusWithValidation() {
    final inputText = _radiusController.text.trim();
    if (inputText.isEmpty) return;
    
    final newRadius = double.tryParse(inputText);
    if (newRadius == null) {
      // 确认时显示错误提示
      _radiusController.text = _fencePreview.radius.toStringAsFixed(0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter a valid number', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
      return;
    }
    
    // 限制半径范围
    final clampedRadius = newRadius.clamp(5.0, 500.0);
    
    // 更新预览管理器的半径
    _fencePreview.setRadius(clampedRadius);
    
    // 同步更新输入框显示（如果被限制了）
    if (clampedRadius != newRadius) {
      _radiusController.text = clampedRadius.toStringAsFixed(0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Radius adjusted to ${clampedRadius.toInt()} meters (range: 5-500m)', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    }
    
    // 触发UI重建
    if (mounted) {
      setState(() {
        // 状态已由预览管理器管理
      });
    }
  }

  /// 立即应用半径（内部方法）
  void _applyRadiusImmediately() {
    final inputText = _radiusController.text.trim();
    if (inputText.isEmpty) {
      // 🎯 实时更新优化：空输入时不显示错误，保持当前圆圈
      return;
    }
    
    final newRadius = double.tryParse(inputText);
    if (newRadius == null) {
      // 🎯 实时更新优化：无效输入时不显示错误提示，避免干扰用户输入
      debugPrint('🔄 [RADIUS] 输入无效，跳过更新: $inputText');
      return;
    }
    
    // 限制半径范围
    final clampedRadius = newRadius.clamp(5.0, 500.0);
    
    // 检查是否实际发生了变化，避免无意义的更新
    if ((clampedRadius - _fencePreview.radius).abs() < 0.1) {
      return; // 半径变化太小，不需要更新
    }
    
    // 更新预览管理器的半径
    _fencePreview.setRadius(clampedRadius);
    
    // 🎯 实时更新优化：只在预览模式时才触发UI重建
    if (_fencePreview.isActive && mounted) {
      debugPrint('🔄 [RADIUS] 实时更新半径: ${_fencePreview.radius} → $clampedRadius');
      setState(() {
        // 状态已由预览管理器管理，这里只是触发重建以更新圆圈显示
      });
    }
    
    // 🎯 实时更新优化：范围限制提示只在确认时显示，避免实时输入时的干扰
    // 范围限制的提示移到确认方法中处理
  }

  /// 保存围栏
  Future<void> _saveFence() async {
    // 🔧 防止重复保存：检查是否正在保存中
    if (_isSavingFence) {
      debugPrint('🔄 [FENCE] 正在保存中，跳过重复请求');
      return;
    }
    
    if (!_fencePreview.hasCenter) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select fence position on the map first', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 20,
            right: 20,
          ),
        ),
      );
      return;
    }

    // 🔧 设置保存标志，防止重复操作
    _isSavingFence = true;
    debugPrint('🔄 [FENCE] 开始保存围栏: $_newFenceName');

    try {
      
      final request = VirtualFenceCreateRequest(
        name: _newFenceName,
        center: _fencePreview.center!,
        radius: _fencePreview.radius,
        icon: _newFenceIcon,
        activateImmediately: _newFenceActivateImmediately,
      );

      final success = await _fenceApiService.createFence(request);
      
      if (success) {
        // 本地持久化
        final fenceId = 'local_${DateTime.now().millisecondsSinceEpoch}_${_newFenceName.hashCode.abs()}';
        final localFence = VirtualFence(
          id: fenceId,
          name: _newFenceName,
          description: null,
          type: VirtualFenceType.safe,
          shape: VirtualFenceShape.circle,
          status:
              _newFenceActivateImmediately ? VirtualFenceStatus.active : VirtualFenceStatus.inactive,
          center: LatLng(_fencePreview.center!.latitude, _fencePreview.center!.longitude),
          radius: _fencePreview.radius,
          polygonPoints: const [],
          icon: _newFenceIcon,
          activateImmediately: _newFenceActivateImmediately,
          createdAt: DateTime.now(),
          updatedAt: null,
        );
        await _localFenceStore.addFence(localFence);
        
        // 🔧 修复重复问题：先结束预览，再重新加载所有围栏，确保数据一致性
        _fencePreview.endPreview();
        await _loadVirtualFences();
        
        setState(() {
          // 重置半径输入框
          _radiusController.text = _fencePreview.radius.toStringAsFixed(0);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fence created successfully!', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fence creation failed, please try again', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150,
              left: 20,
              right: 20,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('🔄 [FENCE] 保存围栏异常: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creation failed: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 150,
            left: 20,
            right: 20,
          ),
        ),
      );
    } finally {
      // 🔧 无论成功还是失败，都要重置保存标志
      _isSavingFence = false;
      debugPrint('🔄 [FENCE] 保存操作结束，重置标志');
    }
  }

  /// 构建地图标记集合
  Set<StandardMarker> _buildMapMarkers() {
    final markers = <StandardMarker>[];
    
    final userMarker = StandardMarker(
      id: 'user_location',
      position: StandardLatLng(_userData.location.latitude, _userData.location.longitude),
      title: 'My Location',
      snippet: 'Current Location',
      iconType: 'user',
    );
    markers.add(userMarker);
    
    if (_petData != null) {
      final petMarker = StandardMarker(
        id: 'pet_location',
        position: StandardLatLng(_petData!.location.latitude, _petData!.location.longitude),
        title: _petData!.name,
        snippet: 'Pet Location - Battery: ${_petData!.batteryLevel}%',
        iconType: 'pet',
      );
      markers.add(petMarker);
    }
    
    return markers.toSet();
  }

  /// 构建路径折线
  StandardPolyline _buildRoutePolyline() {
    if (_currentRoute == null) {
      return StandardPolyline(
        id: 'empty_route',
        points: [],
        color: Colors.blue,
        width: 3.0,
      );
    }
    
    final polyline = StandardPolyline(
      id: 'navigation_route',
      points: _currentRoute!.points,
      color: _selectedRouteType == 'walking' 
          ? Colors.green 
          : _selectedRouteType == 'driving' 
              ? Colors.blue 
              : Colors.orange,
      width: 4.0,
    );
    
    return polyline;
  }

  /// 处理地图点击事件
  void _handleMapTap(StandardLatLng position) {
    if (_fencePreview.isActive) {
      // 检查是否实际改变了位置，避免重复设置相同位置
      final currentCenter = _fencePreview.center;
      if (currentCenter != null && 
          (currentCenter.latitude - position.latitude).abs() < 0.00001 &&
          (currentCenter.longitude - position.longitude).abs() < 0.00001) {
        return; // 位置没有明显变化，跳过更新
      }
      
      _fencePreview.setCenter(position);
      
      // 使用轻量级的防抖，避免快速连续点击造成的性能问题
      _radiusDebounceTimer?.cancel();
      _radiusDebounceTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }
}
