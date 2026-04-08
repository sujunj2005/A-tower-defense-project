# Task 4 GUT 测试说明

## 测试文件

- **主测试文件**: `tests/unit/test_task4_battle.gd`
  - 包含 10 个 GUT 测试用例
  - 测试 BattleManager 的核心功能
  - 测试 TowerData 和 EnemyData 的序列化
  - 测试战斗状态转换、老家生命值系统、金币奖励系统等

## 运行测试的方法

### 方法 1: 使用 Godot 编辑器运行

1. 在 Godot 编辑器中打开项目
2. 打开场景 `test/auto_run_task4_gut_tests.tscn`
3. 运行场景 (F6 或点击运行按钮)
4. 查看输出窗口的测试结果

### 方法 2: 使用 GUT 插件

1. 在 Godot 编辑器中，打开底部面板的 GUT 标签
2. 配置测试目录为 `res://tests/unit`
3. 设置前缀为 `test_`，后缀为 `.gd`
4. 点击 "Run All" 按钮运行所有测试

### 方法 3: 使用命令行（需要安装 Godot）

```bash
godot --headless --path . -s res://test/run_task4_headless.gd
```

## 测试配置

配置文件：`.gutconfig_task4.json`

```json
{
  "tests": ["res://tests/unit/test_task4_battle.gd"],
  "prefix": "test_",
  "suffix": ".gd",
  "log_level": 1,
  "should_exit": false,
  "hide_orphans": false,
  "junit_xml_file": "res://test/results_task4.xml"
}
```

## 测试用例列表

1. **test_battle_manager_initialization** - BattleManager 初始化测试
2. **test_home_health_system** - 老家生命值系统测试
3. **test_gold_reward_system** - 金币奖励系统测试
4. **test_battle_state_transitions** - 战斗状态转换测试
5. **test_defeat_condition** - 失败判定测试
6. **test_tower_data_validation** - 防御塔数据验证测试
7. **test_enemy_data_validation** - 敌人数据验证测试
8. **test_home_health_percent** - 老家生命值百分比计算测试
9. **test_wave_completion** - 波次完成检查测试
10. **test_vertical_slice_full_flow** - 垂直切片完整流程测试

## 预期结果

所有测试应该通过，输出类似：

```
========================================
Task 4 测试运行完成
========================================
总测试数：10
通过测试数：10
失败测试数：0

✅ 所有测试通过！
```

## 依赖

- GUT 9.6.0+
- Godot 4.6+
- 项目 autoloads (Global, GameState, 等)
