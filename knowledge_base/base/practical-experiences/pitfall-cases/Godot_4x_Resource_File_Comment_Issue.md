# Godot 4.x 资源文件注释导致字段加载失败

## 📋 问题概述

**问题**：在 Godot 4.6.x 中，`.tres` 资源文件中的字段值后添加注释会导致该字段值无法正确加载，字段会被重置为默认值。

**严重程度**：🔴 严重 - 导致配置数据丢失，游戏功能异常

**影响范围**：所有使用 `.tres` 文件格式存储的资源配置（EnemyConfig、TowerConfig 等）

---

## 🔍 问题现象

### 错误表现
1. 怪物纹理不显示（`texture_path` 为空字符串）
2. 经验值异常低（`experience_drop` 为默认值 5，而非配置的 50）
3. 金币掉落正确（`gold_drop` 配置正确加载）

### 日志输出
```
[EnemyConfig]        - texture_path: 
[EnemyConfig]        - experience_drop: 5
[EnemyConfig]        - gold_drop: 20
```

### 实际配置文件
```tres
[resource]
script = ExtResource("1_heavy")
enemy_id = "heavy_armor"
enemy_name = "重甲怪"
max_health = 150.0
gold_drop = 20  # 🆕 高价值目标        # ⚠️ 注释导致加载失败！
experience_drop = 50  # 🆕 高经验奖励   # ⚠️ 注释导致加载失败！
texture_path = "res://images/enemies/marble_0_0.png"  # ⚠️ 注释导致加载失败！
```

---

## 🧪 根本原因

**Godot 4.x 资源解析器限制**：
- Godot 4.x 的 `.tres` 文件解析器在处理行内注释时存在 bug
- 当字段值后跟有 `#` 注释时，解析器无法正确识别字段值
- 被注释的字段会被重置为该字段的默认值（在脚本中定义的值）

**示例对比**：

❌ **错误写法**（带注释）：
```tres
gold_drop = 20  # 高价值目标
experience_drop = 50  # 高经验奖励
texture_path = "res://images/enemies/marble_0_0.png"
```

✅ **正确写法**（无注释）：
```tres
gold_drop = 20
experience_drop = 50
texture_path = "res://images/enemies/marble_0_0.png"
```

---

## 🛠️ 解决方案

### 立即修复
1. **移除所有 `.tres` 文件中的行内注释**
2. **重新保存资源文件**（在 Godot 编辑器中打开并保存）
3. **重启 Godot 编辑器**（清除缓存）

### 验证方法
在代码中添加调试输出验证配置是否正确加载：

```gdscript
# enemy_config.gd
static func set_map_config(map_config: MapConfig):
    _map_config = map_config
    if map_config:
        _registry = map_config.enemy_registry
        for key in _registry.keys():
            var value = _registry[key]
            if value is EnemyConfig:
                var ec: EnemyConfig = value as EnemyConfig
                print("[EnemyConfig] %s:" % key)
                print("  - texture_path: %s" % ec.texture_path)
                print("  - experience_drop: %d" % ec.experience_drop)
                print("  - gold_drop: %d" % ec.gold_drop)
```

---

## 📝 最佳实践

### ✅ 推荐做法

1. **不要在 `.tres` 文件中使用行内注释**
   - 字段值后不要添加 `# 注释`
   - 如需说明，使用单独的文档或在脚本中添加注释

2. **使用外部文档说明配置**
   ```
   resources/
   ├── enemies/
   │   ├── heavy_armor.tres          # 配置文件（无注释）
   │   ├── heavy_armor.tres.import   # 导入文件
   │   └── heavy_armor_config.md     # 配置说明文档
   ```

3. **在代码中添加配置说明**
   ```gdscript
   # enemy_config.gd
   @export_group("Rewards")
   @export var gold_drop: int = 10  # 击杀掉落金钱（默认值）
   @export var experience_drop: int = 5  # 击杀掉落经验（默认值）
   ```

4. **定期验证配置加载**
   - 在游戏启动时打印关键配置值
   - 使用单元测试验证资源配置

### ❌ 避免做法

1. **在 `.tres` 文件中添加行内注释**
   ```tres
   # ❌ 错误示例
   gold_drop = 20  # 高价值目标
   experience_drop = 50  # 高经验奖励
   ```

2. **依赖默认值而不验证**
   ```gdscript
   # ❌ 危险做法
   var exp = config.experience_drop  # 可能是默认值而非配置值！
   ```

3. **在 `.tres` 文件中使用复杂注释**
   ```tres
   # ❌ 多重注释
   gold_drop = 20  # 值：20  # 用途：击杀奖励  # 测试用
   ```

---

## 🧪 测试用例

### 测试脚本
```gdscript
# test_resource_loading.gd
extends Node

func _ready():
    test_enemy_config_loading()
    test_tower_config_loading()

func test_enemy_config_loading():
    print("=== 测试 EnemyConfig 加载 ===")
    
    var config = EnemyConfig.get_config("heavy_armor")
    assert(config != null, "配置加载失败")
    assert(config.texture_path != "", "texture_path 为空")
    assert(config.experience_drop == 50, "experience_drop 应为 50")
    assert(config.gold_drop == 20, "gold_drop 应为 20")
    
    print("✅ EnemyConfig 加载测试通过")

func test_tower_config_loading():
    print("=== 测试 TowerConfig 加载 ===")
    
    var config = TowerConfig.get_config("archer_tower")
    assert(config != null, "配置加载失败")
    assert(config.cost > 0, "cost 应为正值")
    assert(config.damage > 0, "damage 应为正值")
    
    print("✅ TowerConfig 加载测试通过")
```

---

## 📚 相关资源

- [Godot 资源系统文档](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot 4.x 已知问题列表](https://github.com/godotengine/godot/issues)
- [本项目知识库：Resources](file:///e:/Test_MCP/first/TestMCP/knowledge_base/02_Core_Systems/02C_Resources.md)

---

## 🔄 更新记录

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-04-03 | 1.0 | 初始版本 - 记录 Godot 4.6.x 资源文件注释问题 |

---

## 💡 快速检查清单

在提交资源文件前，请检查：

- [ ] `.tres` 文件中没有行内注释（`#` 注释）
- [ ] 所有导出字段都有正确的值
- [ ] 资源文件在 Godot 编辑器中能正确显示
- [ ] 运行游戏验证配置加载正确
- [ ] 关键配置值有单元测试覆盖

---

**总结**：Godot 4.x 的 `.tres` 资源文件解析器不支持行内注释，字段值后的注释会导致该字段加载失败。解决方案是移除所有注释，使用外部文档或代码注释来说明配置用途。
