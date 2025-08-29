package com.pettalk.translator.pet_talk

import android.app.Application
import android.content.Context
import android.util.Log
import io.flutter.app.FlutterApplication

/**
 * 自定义Application类
 * 继承FlutterApplication以确保Flutter插件能正确获取Application Context
 */
class PetTalkApplication : FlutterApplication() {
    
    override fun onCreate() {
        super.onCreate()
        
        Log.d("PetTalkApp", "🗺️ ========== FlutterApplication启动 ==========")
        Log.d("PetTalkApp", "🗺️ [APP] Application类: ${this.javaClass.simpleName}")
        Log.d("PetTalkApp", "🗺️ [APP] 包名: ${this.packageName}")
        Log.d("PetTalkApp", "🗺️ [APP] Flutter应用上下文已准备就绪")
        
        // 尝试通过反射调用百度地图SDK的初始化
        try {
            Log.d("PetTalkApp", "🗺️ [REFLECT] 尝试通过反射初始化百度地图SDK...")
            
            val sdkInitializerClass = Class.forName("com.baidu.mapapi.SDKInitializer")
            val initializeMethod = sdkInitializerClass.getMethod("initialize", Context::class.java)
            initializeMethod.invoke(null, this.applicationContext)
            
            Log.d("PetTalkApp", "🗺️ [REFLECT] ✅ 反射调用SDKInitializer.initialize()成功")
            
            // 设置坐标系
            val coordTypeClass = Class.forName("com.baidu.mapapi.CoordType")
            val bd09llField = coordTypeClass.getField("BD09LL")
            val bd09llValue = bd09llField.get(null)
            
            val setCoordTypeMethod = sdkInitializerClass.getMethod("setCoordType", coordTypeClass)
            setCoordTypeMethod.invoke(null, bd09llValue)
            
            Log.d("PetTalkApp", "🗺️ [REFLECT] ✅ 反射设置坐标系成功")
            
        } catch (e: Exception) {
            Log.w("PetTalkApp", "🗺️ [REFLECT] ⚠️ 反射初始化失败（这是正常的，Flutter插件会处理）: ${e.message}")
            Log.w("PetTalkApp", "🗺️ [REFLECT] 错误类型: ${e.javaClass.simpleName}")
        }
        
        Log.d("PetTalkApp", "🗺️ [INFO] FlutterApplication将为所有Flutter插件提供正确的Context")
        Log.d("PetTalkApp", "🗺️ ========== FlutterApplication启动完成 ==========")
    }
}
