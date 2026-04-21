# Godot 4.x AnimationTree 动画树

> 适用版本：Godot 4.x | 来源：知识库整合

---

## 目录

1. [AnimationTree 概述](#1-animationtree-概述)
2. [与 AnimationPlayer 对比](#2-与-animationplayer-对比)
3. [状态机](#3-状态机)
4. [混合树](#4-混合树)

---

## 1. AnimationTree 概述

### 1.1 什么是 AnimationTree

AnimationNode 是用于管理复杂动画状态的节点。它包含一棵由 AnimationNode 组成的"树"，每个节点可以混合动画、执行逻辑或修改动画。

### 1.2 启用 AnimationTree

```gdscript
@onready var animation_tree = $AnimationTree

func _ready():
    animation_tree.active = true  # 必须启用才能工作
    animation_tree.set("parameters/Idle/blend_position", 0.5)
```

> **踩坑点**：AnimationTree 默认不激活！必须设置 `active = true`。

---

## 2. 与 AnimationPlayer 对比

| 特性 | AnimationPlayer | AnimationTree |
|------|-----------------|--------------|
| 复杂度 | 简单 | 复杂 |
| 状态管理 | 手动代码 | 内置状态机 |
| 混合支持 | 有限 | 强大 |
| 适用场景 | 简单动画 | 角色控制器 |

---

## 3. 状态机

### 3.1 创建状态机

1. 添加 AnimationTree 节点
2. 设置 AnimationTree 属性中的 Tree Root 为新 AnimationNodeStateMachine
3. 在 AnimationTree 编辑器中添加状态和过渡

### 3.2 代码控制

```gdscript
var state_machine: AnimationNodeStateMachinePlayback = null

func _ready():
    state_machine = $AnimationTree.get("parameters/playback")

func change_state(state_name: String):
    state_machine.travel(state_name)

func is_playing(anim_name: String) -> bool:
    return state_machine.get_current_node() == anim_name
```

### 3.3 过渡条件

可以在编辑器中为过渡添加条件：
- 自动过渡（时间到）
- 条件过渡（参数满足）

---

## 4. 混合树

### 4.1 AnimationBlendTree

用于混合多个动画：

```
Blend2 (run_blend)
├── idle
└── run
```

### 4.2 参数控制

```gdscript
func set_run_blend(value: float):
    $AnimationTree.set("parameters/run_blend/blend_amount", value)
    
func set_direction(x: float):
    $AnimationTree.set("parameters/direction/x", x)
```

### 4.3 混合空间

**BlendSpace1D / BlendSpace2D**：
- 根据位置在多个动画之间插值
- 适用于移动方向、速度等连续变化的参数

---

## 参考资料

本文档内容基于 Godot 官方文档整理。
