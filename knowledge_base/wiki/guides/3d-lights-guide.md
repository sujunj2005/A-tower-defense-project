# 3D 灯光实战指南

> **适用版本**: Godot 4.x  
> **来源**: [Base 层 - 14C_3D_Lights.md](../../base/3d-development/14C_3D_Lights.md)  
> **重要性**: 🟡 推荐 - 3D 场景布光技巧

---

## 📋 概述

灯光是 3D 场景氛围营造的关键。Godot 4.x 提供了多种灯光类型和先进的全局光照系统。

---

## 🎯 灯光类型

### 1. DirectionalLight3D（方向光）

模拟太阳光，平行照射整个场景。

```gdscript
# 设置阴影
$DirectionalLight3D.shadow_enabled = true
$DirectionalLight3D.shadow_max_distance = 100
```

### 2. PointLight3D（点光源）

向所有方向发射光线，类似灯泡。

```gdscript
$PointLight3D.light_color = Color(1, 0.8, 0.6)  # 暖色
$PointLight3D.light_energy = 2.0
$PointLight3D.light_omission = 0.5  # 自发光
```

### 3. SpotLight3D（聚光灯）

锥形光束，类似手电筒。

```gdscript
$SpotLight3D.spot_angle = 45  # 角度
$SpotLight3D.spot_attenuation = 1.0  # 衰减
```

---

## 🔧 实战技巧

### 1. 三点布光法

```
主光（Key Light）: 45 度角，最强
补光（Fill Light）: 另一侧，较弱
背光（Back Light）: 背后，勾勒轮廓
```

### 2. 动态阴影

```gdscript
# 优化阴影质量
$DirectionalLight3D.shadow_max_distance = 50
$DirectionalLight3D.shadow_color = Color(0, 0, 0, 0.5)
```

---

## 🔗 相关资源

### Base 层
- [14C_3D_Lights.md](../../base/3d-development/14C_3D_Lights.md) - 3D 灯光详解

### Wiki 层
- [标准材质指南](../guides/standard-material-guide.md) - 材质与灯光交互

---

**最后更新**: 2026-04-07  
**维护者**: Knowledge Base Administrator  
**版本**: 1.0
