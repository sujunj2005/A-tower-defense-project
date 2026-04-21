# 案例 1：Compute Shader Plus 插件 —— GPU 计算封装架构

> **适用版本**: Godot 4.6+  
> **来源**: `compositor-effect-library/addons/compute_shader_plus/`  
> **重要性**: 🔴 必读 — 所有 GPU 计算的基础框架

---

## 一、架构概述

Compute Shader Plus 是一个将 Godot 原生 `RenderingDevice` API 进行系统化封装的插件。它统一了 Compute Shader 的创建、管线管理、Uniform 绑定、Push Constant 传递、资源释放的完整生命周期。

### 核心组件

| 组件 | 文件 | 职责 |
|------|------|------|
| `ComputeHelper` | `compute_helper.gd` | 统一 shader 创建、管线管理、uniform 绑定、dispatch |
| `Uniform` (基类) | `uniforms/uniform.gd` | 抽象 uniform 绑定接口，通过信号通知 rid 更新 |
| `ImageUniform` | `uniforms/image_uniform.gd` | 读写纹理 uniform，支持 get_image / get_image_async |
| `SamplerUniform` | `uniforms/sampler_uniform.gd` | 采样纹理 uniform，携带 sampler state |
| `ByteArrayHelper` | `byte_array_helper.gd` | Array → PackedByteArray 转换，处理 GLSL std430 对齐 |

---

## 二、ComputeHelper 核心实现

### 2.1 生命周期管理

```gdscript
# addons/compute_shader_plus/compute_helper.gd
@tool
extends Object
class_name ComputeHelper

static var rd := RenderingServer.get_rendering_device()
static var view := RDTextureView.new()
static var version: int = Engine.get_version_info()["minor"]

var compute_shader: RID
var pipeline: RID
var uniforms: Array[Uniform]
var uniform_set: RID
var uniform_set_dirty := true

static func create(shader_path: String) -> ComputeHelper:
    var compute_helper := ComputeHelper.new()
    var shader_file: RDShaderFile = load(shader_path)
    var shader_spirv := shader_file.get_spirv()
    compute_helper.compute_shader = rd.shader_create_from_spirv(shader_spirv)
    compute_helper.pipeline = rd.compute_pipeline_create(compute_helper.compute_shader)
    return compute_helper
```

### 2.2 Uniform 绑定机制

```gdscript
func add_uniform(uniform: Uniform) -> void:
    uniforms.append(uniform)
    uniform.rid_updated.connect(make_uniform_set_dirty)
    uniform_set_dirty = true

func add_uniform_array(uniform_array: Array[Uniform]) -> void:
    uniforms.append_array(uniform_array)
    for uniform: Uniform in uniform_array:
        uniform.rid_updated.connect(make_uniform_set_dirty)
    uniform_set_dirty = true
```

**核心设计**：每个 uniform 在内部 RID 变更时发出 `rid_updated` 信号，ComputeHelper 收到后标记 `uniform_set_dirty`，下次 `run()` 时重建 uniform set。这避免了每帧重复创建 RID 的开销。

### 2.3 Run 方法 —— 统一的 Dispatch 入口

```gdscript
func run(groups: Vector3i, push_constant := PackedByteArray()) -> void:
    if uniform_set_dirty:
        var bindings: Array[RDUniform] = []
        for uniform_index in uniforms.size():
            bindings.append(uniforms[uniform_index].get_rd_uniform(uniform_index))
        if uniform_set.is_valid() and rd.uniform_set_is_valid(uniform_set):
            rd.free_rid(uniform_set)
        uniform_set = rd.uniform_set_create(bindings, compute_shader, 0)
        uniform_set_dirty = false

    var compute_list := rd.compute_list_begin()
    rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
    rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)

    if !push_constant.is_empty():
        while push_constant.size() % 16 != 0:
            push_constant.append(0)
        rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())

    rd.compute_list_dispatch(compute_list, groups.x, groups.y, groups.z)
    rd.compute_list_end()
```

### 2.4 资源释放

```gdscript
func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE:
        if compute_shader.is_valid():
            rd.free_rid(compute_shader)
        if rd.uniform_set_is_valid(uniform_set):
            rd.free_rid(uniform_set)
        if rd.compute_pipeline_is_valid(pipeline):
            rd.free_rid(pipeline)
```

---

## 三、ImageUniform 纹理操作

### 3.1 从 Image 创建纹理

```gdscript
static func create(image: Image) -> ImageUniform:
    var uniform := ImageUniform.new()
    uniform.texture_size = image.get_size()
    uniform.image_format = image.get_format()
    uniform.texture_format = ImageFormatHelper.create_rd_texture_format(uniform.image_format, uniform.texture_size)
    uniform.texture = ComputeHelper.rd.texture_create(uniform.texture_format, ComputeHelper.view, [image.get_data()])
    return uniform
```

### 3.2 异步读取 GPU 数据（Godot 4.4+）

```gdscript
func get_image_async() -> Signal:
    if ComputeHelper.version < 4:
        return async_image_retrieved
    ComputeHelper.rd.texture_get_data_async(texture, 0, _async_image_callback)
    return async_image_retrieved

func _async_image_callback(image_data: PackedByteArray) -> void:
    var image := Image.create_from_data(texture_size.x, texture_size.y, false, image_format, image_data)
    async_image_retrieved.emit(image)
```

> **警告**：`get_image()` / `get_image_async()` 从 GPU 读取数据非常慢，仅用于调试或离线处理，不要在每帧调用。

---

## 四、ByteArrayHelper —— GLSL std430 内存对齐

GLSL 的 `push_constant` 和 `uniform buffer` 使用 std430 内存布局，GDScript 的 `PackedByteArray` 默认不按此对齐。

```gdscript
const variant_sizes: Dictionary[int, int] = {
    TYPE_INT: 1, TYPE_FLOAT: 1,
    TYPE_VECTOR2: 2, TYPE_VECTOR2I: 2,
    TYPE_VECTOR3: 3, TYPE_VECTOR3I: 3,
    TYPE_VECTOR4: 4, TYPE_VECTOR4I: 4,
    TYPE_PROJECTION: 16
}

static func array_to_bytes(array: Array) -> PackedByteArray:
    var bytes := PackedByteArray()
    var alignment := 0

    for element: Variant in array:
        var size := variant_sizes[typeof(element)]
        var alignment_size := (size - 1) % 4 + 1
        if alignment_size == 3:
            alignment_size += 1  # vec3 占 4 个 slot

        while (4 - alignment) % alignment_size != 0:
            bytes.resize(bytes.size() + 4)
            alignment = (alignment + 1) % 4
        bytes.resize(bytes.size() + size * 4)
        alignment = (alignment + size) % 4

        match typeof(element):
            TYPE_INT:
                bytes.encode_s32(bytes.size() - 4, element)
            TYPE_FLOAT:
                bytes.encode_float(bytes.size() - 4, element)
            TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
                for i: int in size:
                    bytes.encode_float(bytes.size() - 4 * (size - i), element[i])
            TYPE_PROJECTION:
                for i: int in 16:
                    bytes.encode_float(bytes.size() - 4 * (size - i), element[i / 4][i % 4])
            _:
                printerr("ByteArrayHelper tried to convert an unsupported type")

    while bytes.size() % 16 != 0:
        bytes.resize(bytes.size() + 1)
    return bytes
```

**关键规则**：
- `vec3` 在 GLSL 中占 4 个 float slot（16 字节对齐），不是 3 个
- 整个 push_constant 块大小必须是 16 字的倍数
- 运行时补零：`while push_constant.size() % 16 != 0: push_constant.append(0)`

---

## 五、典型使用模式

```gdscript
# 1. 创建 Image
var image := Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBAF)
image.fill(Color.BLACK)

# 2. 创建 Compute Shader
var compute_shader := ComputeHelper.create("res://compute-shader.glsl")

# 3. 创建 Uniform
var input_texture := ImageUniform.create(image)
var output_texture := SharedImageUniform.create(input_texture)
compute_shader.add_uniform_array([input_texture, output_texture])

# 4. 运行
var work_groups := Vector3i(image_size.x, image_size.y, 1)
compute_shader.run(work_groups)

# 5. 读取结果
image = output_texture.get_image()
```

---

## 六、与本项目的关联

| 知识点 | 在 CompositorEffect 中的应用 |
|--------|----------------------------|
| ComputeHelper | RayTracing 使用 ComputeHelper 管理 compute shader |
| ImageUniform | RayTracing 的 color_image_uniform |
| SamplerUniform | 深度/法线/天空盒采样 uniform |
| ByteArrayHelper | RayTracing 的 push constant 构建 |
| uniform_set_dirty | 避免每帧重复创建 uniform set |

来源：`compositor-effect-library/addons/compute_shader_plus/compute_helper.gd`
