package com.pettalk.translator.pet_talk

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import androidx.core.view.WindowCompat
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.pettalk.translator.pet_talk/native"

    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
        
        Log.d("MainActivity", "🗺️ ========== MainActivity启动完成 ==========")
        Log.d("MainActivity", "🗺️ [MAIN] 包名: ${packageName}")
        Log.d("MainActivity", "🗺️ [MAIN] Application Context: ${applicationContext}")
        Log.d("MainActivity", "🗺️ [MAIN] 等待Flutter引擎配置...")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d("MainActivity", "🗺️ ========== 开始配置Flutter引擎 ==========")
        Log.d("MainActivity", "🗺️ [ENGINE] Flutter引擎: ${flutterEngine}")
        Log.d("MainActivity", "🗺️ [ENGINE] 应用上下文: ${applicationContext}")
        
        // 首先调用父类方法，确保所有插件正确注册
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "🗺️ [ENGINE] ✅ 父类configureFlutterEngine调用完成")
        Log.d("MainActivity", "🗺️ [ENGINE] 所有Flutter插件应该已经注册并获得Application Context")
        
        // Flutter插件将自动处理百度地图SDK注册
        
        // 配置原生方法通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                "requestBluetoothPermissions" -> {
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        Log.d("MainActivity", "🗺️ [ENGINE] ✅ Flutter引擎配置完成")
        Log.d("MainActivity", "🗺️ ========== Flutter引擎配置结束 ==========")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}