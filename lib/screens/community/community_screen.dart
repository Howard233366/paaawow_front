// 导入Flutter基础UI组件库
import 'package:flutter/material.dart';
// 导入Riverpod状态管理库，用于管理应用状态
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 导入应用主题颜色配置
import 'package:pet_talk/theme/app_colors.dart';
// 导入社区相关的数据模型（帖子、评论等）
import 'package:pet_talk/models/community_models.dart';
// 导入网络图片缓存库，用于加载和缓存网络图片
import 'package:cached_network_image/cached_network_image.dart';

// 创建一个状态提供者，用于管理当前选中的标签页索引（0=推荐，1=关注，2=消息）
final selectedTabProvider = StateProvider<int>((ref) => 0);

// 创建一个状态提供者，用于管理用户点赞的帖子ID集合
final likedPostsProvider = StateProvider<Set<String>>((ref) => {});

// 定义社区页面类，继承自ConsumerWidget（Riverpod的响应式组件）
class CommunityScreen extends ConsumerWidget {
  // 构造函数，super.key是传递给父类的唯一标识符
  const CommunityScreen({super.key});

  // 重写build方法，这是Flutter组件的核心方法，用于构建UI
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听当前选中的标签页索引，当状态改变时会自动重新构建UI
    final selectedTab = ref.watch(selectedTabProvider);
    // 定义三个标签页的标题数组
    final tabs = ['Recommendations', 'Followers', 'Messages'];
    
    // 返回Scaffold（脚手架），这是Flutter页面的基本结构
    return Scaffold(
      // 设置页面背景色
      backgroundColor: AppColors.background,
      // body是页面的主要内容区域
      body: Column( // Column是垂直布局组件
        children: [
          // 页面头部区域
          Container( // Container是一个容器组件，可以设置装饰、内边距等
            decoration: BoxDecoration( // 装饰器，用于设置背景、阴影、边框等
              color: Colors.white, // 背景色设为白色
              boxShadow: [ // 添加阴影效果
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // 阴影颜色（黑色，透明度10%）
                  blurRadius: 4, // 模糊半径
                  offset: const Offset(0, 2), // 阴影偏移（水平0，垂直2）
                ),
              ],
            ),
            child: SafeArea( // SafeArea确保内容不会被状态栏等系统UI遮挡
              child: Padding( // Padding组件添加内边距
                padding: const EdgeInsets.all(16.0), // 四周各16像素的内边距
                child: Column( // 垂直布局
                  crossAxisAlignment: CrossAxisAlignment.start, // 子组件左对齐
                  children: [
                    // 问候语
                    const Text( // Text组件显示文本
                      'Hi Bobo', // 显示的文本内容
                      style: TextStyle( // 文本样式
                        fontSize: 28, // 字体大小28
                        fontWeight: FontWeight.bold, // 字体粗细为粗体
                        color: AppColors.textPrimary, // 字体颜色使用主题中的主要文本色
                      ),
                    ),
                    const SizedBox(height: 16), // SizedBox用于添加空白间距（高度16）
                    
                    // 标签栏（推荐、关注、消息）
                    Row( // Row是水平布局组件
                      children: tabs.asMap().entries.map((entry) { // 将tabs数组转换为带索引的键值对，然后遍历
                        final index = entry.key; // 获取索引（0,1,2）
                        final title = entry.value; // 获取标题文本
                        final isSelected = selectedTab == index; // 判断当前标签是否被选中
                        
                        return Expanded( // Expanded让子组件平均分配水平空间
                          child: GestureDetector( // GestureDetector用于检测手势（点击、滑动等）
                            onTap: () { // 点击事件处理
                              // 更新选中的标签索引状态
                              ref.read(selectedTabProvider.notifier).state = index;
                            },
                            child: Container( // 标签容器
                              padding: const EdgeInsets.symmetric(vertical: 12), // 上下内边距12像素
                              decoration: BoxDecoration( // 装饰器
                                border: Border( // 边框设置
                                  bottom: BorderSide( // 底部边框
                                    color: isSelected  // 根据是否选中设置颜色
                                        ? AppColors.primary  // 选中时使用主色
                                        : Colors.transparent, // 未选中时透明
                                    width: 2, // 边框宽度2像素
                                  ),
                                ),
                              ),
                              child: Text( // 标签文本
                                title, // 显示标签标题
                                textAlign: TextAlign.center, // 文本居中对齐
                                style: TextStyle( // 文本样式
                                  fontSize: 14, // 字体大小14
                                  fontWeight: isSelected  // 根据是否选中设置字体粗细
                                      ? FontWeight.bold  // 选中时粗体
                                      : FontWeight.normal, // 未选中时正常
                                  color: isSelected  // 根据是否选中设置文本颜色
                                      ? AppColors.primary  // 选中时主色
                                      : AppColors.textSecondary, // 未选中时次要文本色
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(), // 将map结果转换为List
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 内容区域
          Expanded( // Expanded让内容区域占据剩余的所有垂直空间
            child: IndexedStack( // IndexedStack根据索引显示对应的子组件，其他组件保持状态但不显示
              index: selectedTab, // 根据选中的标签索引显示对应内容
              children: [
                _buildRecommendationsContent(ref), // 推荐页面内容
                _buildFollowersContent(ref), // 关注页面内容
                _buildMessagesContent(), // 消息页面内容
              ],
            ),
          ),
        ],
      ),
      // 浮动操作按钮（右下角的+号按钮）
      floatingActionButton: FloatingActionButton(
        onPressed: () { // 点击事件
          _showCreatePostDialog(context); // 显示创建帖子的对话框
        },
        backgroundColor: AppColors.primary, // 按钮背景色
        child: const Icon(Icons.add, color: Colors.white), // 按钮图标（白色+号）
      ),
    );
  }

  // 构建推荐页面内容的方法
  Widget _buildRecommendationsContent(WidgetRef ref) {
    final samplePosts = _getSamplePosts(); // 获取示例帖子数据
    
    // 返回网格视图
    return GridView.builder(
      padding: const EdgeInsets.all(8), // 网格内边距8像素
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // 网格布局代理
        crossAxisCount: 2, // 每行显示2列
        crossAxisSpacing: 2, // 列之间的间距8像素
        mainAxisSpacing: 2, // 行之间的间距8像素
        childAspectRatio: 0.75, // 子组件宽高比（宽:高 = 0.75:1，即高比宽长）
      ),
      itemCount: samplePosts.length, // 网格项目总数
      itemBuilder: (context, index) { // 构建每个网格项的方法
        return _buildPetCard(ref, samplePosts[index]); // 返回宠物卡片组件
      },
    );
  }

  // 构建关注页面内容的方法
  Widget _buildFollowersContent(WidgetRef ref) {
    final samplePosts = _getSamplePosts(); // 获取示例帖子数据
    final likedPosts = ref.watch(likedPostsProvider); // 监听用户点赞的帖子集合
    // 筛选出用户点赞过的帖子（即关注的宠物）
    final followedPosts = samplePosts.where((post) => 
        likedPosts.contains(post.id)).toList();
    
    // 如果没有关注的宠物，显示空状态页面
    if (followedPosts.isEmpty) {
      return Center( // Center组件让子组件居中显示
        child: Column( // 垂直布局
          mainAxisAlignment: MainAxisAlignment.center, // 主轴居中对齐
          children: [
            const Icon( // 显示图标
              Icons.favorite_border, // 空心爱心图标
              size: 80, // 图标大小80像素
              color: AppColors.textSecondary, // 图标颜色
            ),
            const SizedBox(height: 16), // 垂直间距16像素
            const Text( // 主提示文本
              'No followed pets yet', // 文本内容
              style: TextStyle(
                fontSize: 18, // 字体大小18
                fontWeight: FontWeight.w600, // 字体粗细
                color: AppColors.textSecondary, // 文本颜色
              ),
            ),
            const SizedBox(height: 8), // 垂直间距8像素
            Text( // 副提示文本
              'Go to recommendations and like pets you enjoy!', // 文本内容
              style: TextStyle(
                fontSize: 14, // 字体大小14
                color: AppColors.textSecondary.withOpacity(0.7), // 文本颜色（70%透明度）
              ),
            ),
          ],
        ),
      );
    }
    
    // 如果有关注的宠物，显示网格视图
    return GridView.builder(
      padding: const EdgeInsets.all(8), // 网格内边距
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount( // 网格布局代理
        crossAxisCount: 2, // 每行2列
        crossAxisSpacing: 8, // 列间距
        mainAxisSpacing: 8, // 行间距
        childAspectRatio: 0.75, // 宽高比
      ),
      itemCount: followedPosts.length, // 关注帖子的数量
      itemBuilder: (context, index) { // 构建每个网格项
        return _buildPetCard(ref, followedPosts[index]); // 返回宠物卡片
      },
    );
  }

  // 构建消息页面内容的方法
  Widget _buildMessagesContent() {
    return Center( // 居中显示
      child: Column( // 垂直布局
        mainAxisAlignment: MainAxisAlignment.center, // 主轴居中对齐
        children: [
          Icon( // 消息图标
            Icons.message_outlined, // 消息轮廓图标
            size: 80, // 图标大小
            color: AppColors.textSecondary.withOpacity(0.5), // 图标颜色（50%透明度）
          ),
          const SizedBox(height: 24), // 垂直间距24像素
          const Text( // 标题文本
            'Messages', // 消息
            style: TextStyle(
              fontSize: 20, // 字体大小20
              fontWeight: FontWeight.w600, // 字体粗细
              color: AppColors.textSecondary, // 文本颜色
            ),
          ),
          const SizedBox(height: 8), // 垂直间距8像素
          Text( // 副标题文本
            'Coming soon...', // 即将推出...
            style: TextStyle(
              fontSize: 14, // 字体大小14
              color: AppColors.textSecondary.withOpacity(0.7), // 文本颜色（70%透明度）
            ),
          ),
        ],
      ),
    );
  }

  // 构建宠物卡片的方法
  Widget _buildPetCard(WidgetRef ref, CommunityPost post) {
    final likedPosts = ref.watch(likedPostsProvider); // 监听点赞帖子状态
    final isLiked = likedPosts.contains(post.id); // 判断当前帖子是否被点赞

    return Card( // Card组件提供圆角和阴影效果
      elevation: 2, // 阴影高度
      shape: RoundedRectangleBorder( // 卡片形状
        borderRadius: BorderRadius.circular(12), // 圆角半径12像素
      ),
      child: Stack( // Stack允许组件重叠显示
        children: [
          Column( // 垂直布局
            crossAxisAlignment: CrossAxisAlignment.start, // 子组件左对齐
            children: [
              // 宠物图片区域
              Expanded( // Expanded让图片区域占据3/5的空间
                flex: 3, // 弹性系数3
                child: Container( // 图片容器
                  width: double.infinity, // 宽度填满父容器
                  decoration: const BoxDecoration( // 装饰器
                    borderRadius: BorderRadius.vertical( // 垂直方向圆角
                      top: Radius.circular(12), // 只设置顶部圆角
                    ),
                  ),
                  child: ClipRRect( // ClipRRect用于裁剪子组件为圆角
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12), // 顶部圆角12像素
                    ),
                    child: post.images.isNotEmpty // 如果帖子有图片
                        ? (post.images.first.startsWith('assets/') // 判断是否为本地资源
                            ? Image.asset( // 加载本地图片
                                post.images.first, // 图片路径
                                fit: BoxFit.cover, // 图片填充方式（覆盖）
                              )
                            : CachedNetworkImage( // 加载网络图片
                                imageUrl: post.images.first, // 图片URL
                                fit: BoxFit.cover, // 图片填充方式
                                placeholder: (context, url) => Container( // 加载中的占位符
                                  color: AppColors.background,
                                  child: const Center(child: CircularProgressIndicator()), // 加载指示器
                                ),
                                errorWidget: (context, url, error) => Container( // 加载失败的占位符
                                  color: AppColors.background,
                                  child: Icon(Icons.pets, size: 40, color: AppColors.textSecondary), // 宠物图标
                                ),
                              ))
                        : Container( // 如果没有图片，显示默认图标
                            color: AppColors.background,
                            child: Icon(Icons.pets, size: 40, color: AppColors.textSecondary),
                          ),
                  ),
                ),
              ),
              
              // 宠物信息区域
              Expanded( // Expanded让信息区域占据2/5的空间
                flex: 2, // 弹性系数2
                child: Padding( // 添加内边距
                  padding: const EdgeInsets.all(12), // 四周12像素内边距
                  child: Column( // 垂直布局
                    crossAxisAlignment: CrossAxisAlignment.start, // 子组件左对齐
                    children: [
                      // 从content中解析宠物名称和品种
                      Builder(builder: (context) { // Builder用于创建局部作用域
                        final parts = post.content.split('|'); // 按|分割字符串
                        final petName = parts.isNotEmpty ? parts[0] : 'Pet'; // 获取宠物名称（第一部分）
                        final breed = parts.length > 1 ? parts[1] : 'Adorable Pet'; // 获取品种（第二部分）
                        return Column( // 垂直布局显示名称和品种
                          crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
                          children: [
                            Text( // 宠物名称文本
                              petName, // 显示宠物名称
                              style: const TextStyle(
                                fontSize: 14, // 字体大小18
                                fontWeight: FontWeight.w800, // 字体粗细（很粗）
                                color: AppColors.textPrimary, // 主要文本颜色
                              ),
                              maxLines: 1, // 最大行数1
                              overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                            ),
                            const SizedBox(height: 2), // 垂直间距4像素
                            Text( // 品种文本
                              breed, // 显示品种
                              style: TextStyle(
                                fontSize: 12, // 字体大小13
                                color: AppColors.textSecondary.withOpacity(0.8) // 次要文本颜色（80%透明度）
                              ),
                              maxLines: 1, // 最大行数1
                              overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                            ),
                          ],
                        );
                      }),
                      const Spacer(), // Spacer占据剩余空间，将下面的内容推到底部
                      
                      // 主人信息
                      Row( // 水平布局
                        children: [
                          CircleAvatar( // 圆形头像
                            radius: 10, // 半径10像素
                            backgroundColor: AppColors.primary, // 背景色
                            child: post.userAvatar?.isNotEmpty == true // 如果有头像URL
                                ? CachedNetworkImage( // 加载网络头像
                                    imageUrl: post.userAvatar!, // 头像URL
                                    imageBuilder: (context, imageProvider) => Container( // 自定义图片显示
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle, // 圆形
                                        image: DecorationImage(
                                          image: imageProvider, // 图片提供者
                                          fit: BoxFit.cover, // 图片填充方式
                                        ),
                                      ),
                                    ),
                                  )
                                : const Icon( // 如果没有头像，显示默认图标
                                    Icons.person, // 人物图标
                                    size: 12, // 图标大小12像素
                                    color: Colors.white, // 白色图标
                                  ),
                          ),
                          const SizedBox(width: 6), // 水平间距6像素
                          Expanded( // Expanded让文本占据剩余空间
                            child: Text( // 主人姓名文本
                              post.userName, // 显示用户名
                              style: TextStyle(
                                fontSize: 12, // 字体大小12
                                color: AppColors.textSecondary.withOpacity(0.6), // 文本颜色（60%透明度）
                              ),
                              maxLines: 1, // 最大行数1
                              overflow: TextOverflow.ellipsis, // 超出部分显示省略号
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // 点赞按钮（悬浮在卡片右上角）
          Positioned( // Positioned用于在Stack中定位组件
            top: 8, // 距离顶部8像素
            right: 8, // 距离右边8像素
            child: GestureDetector( // 手势检测器
              onTap: () { // 点击事件处理
                final currentLiked = ref.read(likedPostsProvider); // 读取当前点赞状态
                final newLiked = Set<String>.from(currentLiked); // 复制当前点赞集合
                
                if (isLiked) { // 如果已点赞
                  newLiked.remove(post.id); // 移除点赞
                } else { // 如果未点赞
                  newLiked.add(post.id); // 添加点赞
                }
                
                // 更新点赞状态
                ref.read(likedPostsProvider.notifier).state = newLiked;
              },
              child: Container( // 按钮容器
                padding: const EdgeInsets.all(6), // 内边距6像素
                decoration: BoxDecoration( // 装饰器
                  color: Colors.white.withOpacity(0.9), // 白色背景（90%透明度）
                  shape: BoxShape.circle, // 圆形
                ),
                child: Icon( // 心形图标
                  isLiked ? Icons.favorite : Icons.favorite_border, // 根据点赞状态选择实心或空心
                  size: 20, // 图标大小20像素
                  color: isLiked ? Colors.red : AppColors.textSecondary, // 根据点赞状态选择红色或灰色
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示创建帖子对话框的方法
  void _showCreatePostDialog(BuildContext context) {
    showDialog( // 显示对话框
      context: context, // 上下文
      builder: (context) => AlertDialog( // 警告对话框
        title: const Text('Share Pet Activity'), // 对话框标题
        content: const Column( // 对话框内容（垂直布局）
          mainAxisSize: MainAxisSize.min, // 主轴大小最小化（内容决定高度）
          children: [
            Icon( // 相机图标
              Icons.camera_alt, // 相机图标
              size: 60, // 图标大小60像素
              color: AppColors.primary, // 主色
            ),
            SizedBox(height: 16), // 垂直间距16像素
            Text( // 主提示文本
              'Feature in development...', // 功能开发中...
              style: TextStyle(fontSize: 16), // 字体大小16
            ),
            SizedBox(height: 8), // 垂直间距8像素
            Text( // 副提示文本
              'Post activity feature coming soon!', // 发布动态功能即将推出！
              style: TextStyle(
                fontSize: 14, // 字体大小14
                color: AppColors.textSecondary, // 次要文本颜色
              ),
            ),
          ],
        ),
        actions: [ // 对话框操作按钮
          TextButton( // 文本按钮
            onPressed: () => Navigator.of(context).pop(), // 点击关闭对话框
            child: const Text('OK'), // 按钮文本
          ),
        ],
      ),
    );
  }

  // 获取示例帖子数据的方法
  List<CommunityPost> _getSamplePosts() {
    return [
      // 创建示例帖子1 - Marlie（暹罗猫）
      CommunityPost(
        id: '1', // 帖子唯一标识
        userId: 'user1', // 用户ID
        userName: 'Luccuy', // 用户名
        userAvatar: '', // 用户头像（空字符串使用默认头像）
        // content格式: "宠物名称|品种"
        content: 'Marlie|Siamese', // 宠物信息
        images: ['assets/images/addpet/PaaaWOW0001 (1)_06.png'], // 宠物图片（本地资源）
        timestamp: DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch, // 时间戳（2小时前）
        likes: 23, // 点赞数
        comments: 5, // 评论数
      ),
      // 创建示例帖子2 - Bella（金毛寻回犬）
      CommunityPost(
        id: '2',
        userId: 'user2',
        userName: 'Sarah',
        userAvatar: '',
        content: 'Bella|Golden Retriever',
        images: ['assets/images/addpet/PaaaWOW0001 (1)_07.png'],
        timestamp: DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch, // 5小时前
        likes: 42,
        comments: 8,
      ),
      // 创建示例帖子3 - Max（拉布拉多）
      CommunityPost(
        id: '3',
        userId: 'user3',
        userName: 'Mike',
        userAvatar: '',
        content: 'Max|Labrador',
        images: ['assets/images/addpet/PaaaWOW0001 (1)_08.png'],
        timestamp: DateTime.now().subtract(const Duration(hours: 8)).millisecondsSinceEpoch, // 8小时前
        likes: 18,
        comments: 3,
      ),
      // 创建示例帖子4 - Lessie（哈士奇）
      CommunityPost(
        id: '4',
        userId: 'user4',
        userName: 'Emma',
        userAvatar: '',
        content: 'Lessie|Husky',
        images: ['assets/images/addpet/PaaaWOW0001 (1)_09.png'],
        timestamp: DateTime.now().subtract(const Duration(hours: 12)).millisecondsSinceEpoch, // 12小时前
        likes: 31,
        comments: 7,
      ),
      // 创建示例帖子5 - Luna（比格犬）
      CommunityPost(
        id: '5',
        userId: 'user5',
        userName: 'Alex',
        userAvatar: '',
        content: 'Luna|Beagle',
        images: ['assets/images/addpet/PaaaWOW0001 (1)_12.png'],
        timestamp: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch, // 1天前
        likes: 15,
        comments: 2,
      ),
      // 创建示例帖子6 - Ruby（贵宾犬）
      CommunityPost(
        id: '6',
        userId: 'user6',
        userName: 'Lisa',
        userAvatar: '',
        content: 'Ruby|Poodle',
        images: ['assets/images/addpet/PaaaWOW0001 (1)_13.png'],
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)).millisecondsSinceEpoch, // 1天6小时前
        likes: 27,
        comments: 4,
      ),
    ];
  }
}