# 寻宠功能后端API文档

## 概述

本文档定义了寻宠功能所需的后端API接口，包括宠物位置获取、导航请求提交、位置历史查询等功能。

## 基础信息

- **基础URL**: `https://api.pettalk.com/v1`
- **认证方式**: Bearer Token
- **请求格式**: JSON
- **响应格式**: JSON

## 通用响应格式

```json
{
  "success": true,
  "message": "操作成功",
  "data": {},
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### 错误响应格式

```json
{
  "success": false,
  "message": "错误信息",
  "error_code": "PET_NOT_FOUND",
  "timestamp": "2024-01-20T10:30:00Z"
}
```

## API 接口详情

### 1. 获取宠物实时位置

获取指定宠物的当前位置信息。

**请求**
```
GET /pets/{petId}/location
```

**路径参数**
- `petId` (string, required): 宠物唯一标识符

**请求头**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**响应示例**
```json
{
  "success": true,
  "data": {
    "id": "pet_001",
    "name": "Mr.Mittens",
    "imageUrl": "https://api.pettalk.com/images/pets/pet_001.jpg",
    "latitude": 39.9042,
    "longitude": 116.4074,
    "address": "北京市东城区天安门广场",
    "lastUpdated": "2024-01-20T10:25:00Z",
    "batteryLevel": 85,
    "isOnline": true,
    "accuracy": 5.2,
    "altitude": 45.6,
    "speed": 0.0,
    "heading": 0.0
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### 2. 获取用户宠物列表

获取当前用户拥有的所有宠物及其位置信息。

**请求**
```
GET /user/pets
```

**请求头**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**查询参数**
- `include_offline` (boolean, optional): 是否包含离线宠物，默认为true
- `limit` (integer, optional): 返回数量限制，默认为50
- `offset` (integer, optional): 偏移量，用于分页，默认为0

**响应示例**
```json
{
  "success": true,
  "data": [
    {
      "id": "pet_001",
      "name": "Mr.Mittens",
      "imageUrl": "https://api.pettalk.com/images/pets/pet_001.jpg",
      "latitude": 39.9042,
      "longitude": 116.4074,
      "address": "北京市东城区天安门广场",
      "lastUpdated": "2024-01-20T10:25:00Z",
      "batteryLevel": 85,
      "isOnline": true
    },
    {
      "id": "pet_002",
      "name": "Fluffy",
      "imageUrl": "https://api.pettalk.com/images/pets/pet_002.jpg",
      "latitude": 39.9163,
      "longitude": 116.3972,
      "address": "北京市西城区西单商业区",
      "lastUpdated": "2024-01-20T10:20:00Z",
      "batteryLevel": 65,
      "isOnline": true
    }
  ],
  "pagination": {
    "total": 2,
    "limit": 50,
    "offset": 0,
    "hasMore": false
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### 3. 提交导航请求

向后端提交用户的导航请求，用于记录和分析。

**请求**
```
POST /pets/{petId}/navigate
```

**路径参数**
- `petId` (string, required): 宠物唯一标识符

**请求头**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**请求体**
```json
{
  "petId": "pet_001",
  "userLocation": {
    "latitude": 39.9200,
    "longitude": 116.4074
  },
  "routeType": "walking",
  "timestamp": "2024-01-20T10:30:00Z",
  "deviceInfo": {
    "platform": "android",
    "version": "1.0.0",
    "deviceId": "device_12345"
  }
}
```

**请求体字段说明**
- `petId` (string): 宠物ID
- `userLocation` (object): 用户当前位置
  - `latitude` (number): 纬度
  - `longitude` (number): 经度
- `routeType` (string): 导航类型，可选值: `walking`, `cycling`, `driving`
- `timestamp` (string): 请求时间戳
- `deviceInfo` (object, optional): 设备信息

**响应示例**
```json
{
  "success": true,
  "data": {
    "navigationId": "nav_001",
    "estimatedArrival": "2024-01-20T10:45:00Z",
    "routeDistance": 2.1,
    "routeDuration": 15
  },
  "message": "导航请求已记录",
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### 4. 获取宠物位置历史

获取指定宠物在指定时间范围内的位置历史记录。

**请求**
```
GET /pets/{petId}/location/history
```

**路径参数**
- `petId` (string, required): 宠物唯一标识符

**查询参数**
- `startTime` (string, required): 开始时间，ISO 8601格式
- `endTime` (string, required): 结束时间，ISO 8601格式
- `limit` (integer, optional): 返回数量限制，默认为100
- `interval` (string, optional): 时间间隔，可选值: `1min`, `5min`, `15min`, `1hour`，默认为`5min`

**请求头**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**响应示例**
```json
{
  "success": true,
  "data": [
    {
      "id": "pet_001",
      "name": "Mr.Mittens",
      "imageUrl": "https://api.pettalk.com/images/pets/pet_001.jpg",
      "latitude": 39.9042,
      "longitude": 116.4074,
      "address": "北京市东城区天安门广场",
      "lastUpdated": "2024-01-20T10:25:00Z",
      "batteryLevel": 85,
      "isOnline": true,
      "accuracy": 5.2,
      "speed": 1.2
    },
    {
      "id": "pet_001",
      "name": "Mr.Mittens",
      "imageUrl": "https://api.pettalk.com/images/pets/pet_001.jpg",
      "latitude": 39.9045,
      "longitude": 116.4070,
      "address": "北京市东城区天安门广场附近",
      "lastUpdated": "2024-01-20T10:20:00Z",
      "batteryLevel": 85,
      "isOnline": true,
      "accuracy": 4.8,
      "speed": 0.8
    }
  ],
  "pagination": {
    "total": 24,
    "limit": 100,
    "hasMore": false
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

### 5. 更新宠物位置

设备端向后端上报宠物的最新位置信息。

**请求**
```
PUT /pets/{petId}/location
```

**路径参数**
- `petId` (string, required): 宠物唯一标识符

**请求头**
```
Authorization: Bearer {device_token}
Content-Type: application/json
```

**请求体**
```json
{
  "latitude": 39.9042,
  "longitude": 116.4074,
  "accuracy": 5.2,
  "altitude": 45.6,
  "speed": 1.2,
  "heading": 180.0,
  "timestamp": "2024-01-20T10:30:00Z",
  "batteryLevel": 85,
  "isCharging": false,
  "signalStrength": -65,
  "deviceInfo": {
    "firmwareVersion": "1.2.3",
    "hardwareVersion": "2.1",
    "deviceId": "collar_12345"
  }
}
```

**响应示例**
```json
{
  "success": true,
  "message": "位置更新成功",
  "data": {
    "locationId": "loc_001",
    "processedAt": "2024-01-20T10:30:01Z"
  },
  "timestamp": "2024-01-20T10:30:01Z"
}
```

## 实时通信 (WebSocket)

### 连接地址
```
wss://api.pettalk.com/v1/ws/pets/{petId}/location
```

### 认证
连接时需要在查询参数中包含访问令牌：
```
wss://api.pettalk.com/v1/ws/pets/{petId}/location?token={access_token}
```

### 消息格式

**位置更新消息**
```json
{
  "type": "location_update",
  "data": {
    "petId": "pet_001",
    "latitude": 39.9042,
    "longitude": 116.4074,
    "accuracy": 5.2,
    "timestamp": "2024-01-20T10:30:00Z",
    "batteryLevel": 85,
    "isOnline": true
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

**连接状态消息**
```json
{
  "type": "connection_status",
  "data": {
    "petId": "pet_001",
    "isOnline": false,
    "lastSeen": "2024-01-20T10:25:00Z",
    "reason": "device_offline"
  },
  "timestamp": "2024-01-20T10:30:00Z"
}
```

## 错误代码

| 错误代码 | HTTP状态码 | 描述 |
|---------|-----------|------|
| `PET_NOT_FOUND` | 404 | 宠物不存在 |
| `PET_OFFLINE` | 503 | 宠物设备离线 |
| `INVALID_LOCATION` | 400 | 无效的位置数据 |
| `UNAUTHORIZED` | 401 | 未授权访问 |
| `FORBIDDEN` | 403 | 权限不足 |
| `RATE_LIMIT_EXCEEDED` | 429 | 请求频率超限 |
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |

## 数据模型

### PetLocationData
```typescript
interface PetLocationData {
  id: string;                    // 宠物唯一标识符
  name: string;                  // 宠物名称
  imageUrl: string;              // 宠物头像URL
  latitude: number;              // 纬度
  longitude: number;             // 经度
  address: string;               // 地址描述
  lastUpdated: string;           // 最后更新时间 (ISO 8601)
  batteryLevel: number;          // 电池电量 (0-100)
  isOnline: boolean;             // 是否在线
  accuracy?: number;             // 位置精度 (米)
  altitude?: number;             // 海拔高度 (米)
  speed?: number;                // 移动速度 (m/s)
  heading?: number;              // 移动方向 (度)
}
```

### NavigationRequest
```typescript
interface NavigationRequest {
  petId: string;                 // 宠物ID
  userLocation: {                // 用户位置
    latitude: number;
    longitude: number;
  };
  routeType: 'walking' | 'cycling' | 'driving'; // 导航类型
  timestamp: string;             // 请求时间
  deviceInfo?: {                 // 设备信息
    platform: string;
    version: string;
    deviceId: string;
  };
}
```

## 注意事项

1. **认证**: 所有API请求都需要有效的Bearer Token
2. **频率限制**: 位置更新API限制为每秒10次，查询API限制为每分钟100次
3. **数据保留**: 位置历史数据保留90天
4. **实时性**: WebSocket连接用于实时位置更新，建议客户端实现断线重连
5. **精度**: 位置精度取决于设备GPS性能，通常在5-10米范围内
6. **时区**: 所有时间戳使用UTC时间，客户端需要根据用户时区进行转换

## 测试环境

- **测试API地址**: `https://test-api.pettalk.com/v1`
- **测试WebSocket地址**: `wss://test-api.pettalk.com/v1/ws`
- **测试Token**: 请联系开发团队获取测试用的访问令牌

## 版本更新日志

- **v1.0.0** (2024-01-20): 初始版本，包含基础的位置获取和导航功能
