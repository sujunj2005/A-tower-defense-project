# P11：get_canvas_transform() 方法位置错误

| 属性 | 值 |
|------|-----|
| **日期** | 2026-04 |
| **分类** | GDScript/API |
| **严重程度** | 🟡 中 |
| **涉及文件** | 毒圈技能放置相关脚本（CanvasLayer 派生类） |
| **知识库关联** | [UI 开发模式](../best-practices/UI%20开发模式.md) / [节点系统与场景树](../../节点系统与场景树.md) |

---

## 现象

在 `CanvasLayer` 派生类中调用：

```gdscript
var canvas_transform = get_canvas_transform()
```

报错：

```
Nonexistent function 'get_canvas_transform' in base 'CanvasLayer'
```

## 根因

`get_canvas_transform()` 是 **Viewport** 的方法，不是 `CanvasLayer` 的方法。两者的关系是：

- `CanvasLayer` 是画布层节点，用于分层渲染
- `Viewport` 是视口，管理坐标变换
- `CanvasLayer` 可以获取其所属 `Viewport` 的 canvas transform

在 Godot 节点继承体系中：
```
Node
  └── Viewport                    ← get_canvas_transform() 在这里
        └── Window
  └── CanvasLayer                 ← 不继承 Viewport，没有此方法
```

## 正确写法

```gdscript
# ❌ 错误：在 CanvasLayer 中直接调用
var canvas_transform = get_canvas_transform()

# ✅ 正确：通过 get_viewport() 获取 Viewport 再调用
var canvas_transform = get_viewport().get_canvas_transform()
```

## 典型使用场景：坐标转换（鼠标位置 → 世界坐标）

```gdscript
# 在 CanvasLayer 派生类中实现技能放置
func _get_world_mouse_position() -> Vector2:
    var viewport: Viewport = get_viewport()
    var mouse_pos: Vector2 = viewport.get_mouse_position()
    var canvas_transform: Transform2D = viewport.get_canvas_transform()
    return canvas_transform.affine_inverse() * mouse_pos

# 或一步到位
func _get_world_mouse_position() -> Vector2:
    return get_viewport().get_canvas_transform().affine_inverse() * \
           get_viewport().get_mouse_position()
```

## API 速查

| 方法 | 所属类 | 说明 |
|------|--------|------|
| `get_canvas_transform()` | Viewport | 获取画布变换矩阵 |
| `get_mouse_position()` | Viewport | 获取视口鼠标坐标 |
| `get_viewport()` | Node | 获取节点所在的 Viewport |
| `get_global_mouse_position()` | Node/Control | 获取全局鼠标坐标（CanvasLayer 坐标） |

## 教训

Godot 节点的 API 归属必须严格按照类继承关系来查找。在调用某个方法前，先确认该方法属于哪个类，以及当前脚本的 `extends` 是否包含该类。

---

*记录时间：2026-04-29*