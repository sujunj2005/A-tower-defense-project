# 图片导入指南

> 适用版本：Godot 4.x | 来源：godot-docs-master/tutorials/assets_pipeline/importing_images.rst

---

## 一、支持的图片格式

| 格式 | 扩展名 | 特殊说明 |
|------|--------|----------|
| **BMP** | `.bmp` | 不支持16bpp；支持1/4/8/24/32 bpp |
| **DDS** | `.dds` | 如有 mipmap 会直接加载；可用于自定义 mipmap 效果 |
| **KTX** | `.ktx` | libktx 解码；仅支持2D图像；不支持 Cubemap Array 等 |
| **OpenEXR** | `.exr` | ✅ **支持HDR**（强烈推荐全景天空） |
| **Radiance HDR** | `.hdr` | ✅ **支持HDR**（强烈推荐全景天空） |
| **JPEG** | `.jpg`, `.jpeg` | ❌ **不支持透明** |
| **PNG** | `.png` | 导入精度限于8bpc（不支持HDR） |
| **Targa** | `.tga` | - |
| **SVG** | `.svg` | ThorVG 光栅化；复杂矢量可能渲染不正确；文本必须转为路径 |
| **WebP** | `.webp` | 支持透明；支持有损/无损压缩；精度8bpc |

> **注意**：从源码编译 Godot 时若禁用了某些模块，部分格式可能不可用

---

## 二、纹理导入（默认行为）

默认情况下，Godot 将图片作为**纹理（Texture）**导入：

- 存储**在显存**中
- CPU 无法直接访问像素数据（除非转换为 Image）
- 这使得绘制效率很高

**导入选项**（在 FileSystem dock中选择图片后可见，超过12项）：

---

## 三、更改导入类型

在 Import dock 中可选择其他资源类型：

### 3.1 可选导入类型

| 类型 | 说明 | 能否直接显示 |
|------|------|-------------|
| **BitMap** | 1位单色纹理（用于点击掩码） | ❌ 只能脚本查询像素值 |
| **Cubemap** | 6面立方体纹理（无缝插值） | 需自定义着色器 |
| **CubemapArray** | 立方体纹理集合 | 需自定义着色器；仅 Forward+/Mobile |
| **Font Data** | 位图字体（等宽） | 见 GUI 字体文档 |
| **Image** | 原始图像 | ❌ 只能脚本查询像素值 |
| **Texture2D** | 2D纹理（**默认**） | ✅ 2D/3D表面 |
| **Texture2DArray** | 2D纹理集合 | ❌ 需自定义着色器 |
| **Texture3D** | 3D体积纹理（非表面贴图） | 用于雾密度图、粒子吸引子等 |
| **PortAtlas** | 图集（多个纹理打包成一张） | 优化 Draw Call |

### 3.2 使用场景示例

**BitMap** - 点击检测：
```gdscript
var bitmap = load("res://click_mask.bmp")
if bitmap.get_pixel(mouse_pos.x, mouse_pos.y):
    print("点击有效区域")
```

**Image** - 像素级操作：
```gdscript
var image = load("res://terrain.png")
var pixel = image.get_pixel(x, y)
print("R:", pixel.r, "G:", pixel.g, "B:", pixel.b)
```

**Cubemap** - 天空盒：
```gdscript
var cubemap = load("res://skybox.dds")
$WorldEnvironment.environment.sky.sky_material.panorama = cubemap
```

---

## 四、重要导入选项详解

### 4.1 压缩模式（Compression）

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| **Lossless** | 无压缩（高质量） | UI元素、需要精确像素的纹理 |
| **Lossy** | 有损压缩（VRAM占用小） | 大型纹理、3D材质 |
| **Video RAM** | 压缩为GPU原生格式 | 通用3D纹理（推荐） |
| **Basis Universal** | 跨平台压缩格式 | Web/移动端优化 |
| **Uncompressed** | 不压缩（最快加载） | 开发调试阶段 |

### 4.2 Mipmap（多级渐远纹理）

**作用**：生成逐渐缩小的纹理副本，远处物体使用较小版本。

**优点**：
- 减少远距离锯齿
- 提升缓存命中率（性能更好）

**启用条件**：
- 纹理尺寸是2的幂（如256×512）
- 或强制启用（可能质量略降）

### 4.3 过滤模式（Filter）

| 模式 | 效果 |
|------|------|
| **Linear** | 双线性过滤（平滑，默认） |
| **Nearest** | 最近邻过滤（像素风格） |
| **Nearest Mipmap** | 像素风格 + mipmap |

**像素艺术游戏**应使用 **Nearest** 模式！

### 4.4 重复模式（Repeat）

| 模式 | 效果 |
|------|------|
| **Disabled** | 默认，钳位到边缘 |
| **Enabled** | 纹理平铺重复 |
| **Mirror** | 镜像重复 |
| **Mirror Repeat** | 先镜像后重复（适用于无缝平铺） |

### 4.5 HDR / sRGB

- **sRGB**：大多数颜色纹理应启用（正确色彩空间）
- **HDR**：法线贴图、粗糙度贴图等数据纹理应**禁用**

---

## 五、SVG 特殊说明

### 5.1 限制

- 使用 **ThorVG** 引擎光栅化
- 复杂矢量可能无法正确渲染
- **文本必须转换为路径**（否则不会显示）

### 5.2 验证工具

- ThorVG Web Viewer: https://www.thorvg.org/viewer

### 5.3 备选方案

对于复杂 SVG，更好的方案是用 **Inkscape** 导出为 PNG：
```bash
inkscape input.svg --export-type=png --export-width=1024
```

Inkscape 支持命令行，可自动化批量转换。

---

## 六、导入工作流程最佳实践

### 6.1 像素艺术项目

```
导入设置：
├─ Compression: Lossless
├─ Filter: Nearest
├─ Mipmap: False（通常不需要）
├─ HDR/sRGB: 启用 sRGB
└─ Size Limit: 保持原始分辨率
```

### 6.2 现代3D项目

```
导入设置：
├─ Compression: Vram Compressed (或 Basis Universal for Web)
├─ Filter: Linear
├─ Mipmap: True（3D必需）
├─ HDR/sRGB: Albedo用sRGB，数据纹理禁用
└─ Size Limit: 根据目标平台调整（最大4096/2048/1024）
```

### 6.2 UI/HUD项目

```
导入设置：
├─ Compression: Lossless（UI需要清晰边缘）
├─ Filter: Linear
├─ Mipmap: False
├─ HDR/sRGB: 启用 sRGB
└─ Size Limit: 原始分辨率或2x
```

### 6.3 全景天空（HDR）

```
格式选择：
├─ .exr 或 .hdr 格式
├─ Compression: Lossless（保留HDR数据）
├─ HDR/sRGB: 禁用 sRGB（这是数据）
└─ 用途：Sky/Cubemap 材质
```

---

## 七、运行时纹理操作

### 7.1 从 Image 创建 Texture

```gdscript
var image = Image.create(256, 256, false, Image.FORMAT_RGBA8)
image.fill(Color.RED)

var texture = ImageTexture.create_from_image(image)
$Sprite2D.texture = texture
```

### 7.2 修改已有纹理

```gdscript
var texture = $Sprite2D.texture
var image = texture.get_image()

# 修改像素
image.set_pixel(x, y, Color.BLUE)

# 应用回去
texture.update(image)
```

### 7.2 保存截图

```gdscript
await RenderingServer.frame_post_draw
var image = get_viewport().get_texture().get_image()
image.save_png("res://screenshot.png")
```

---

## 八、性能优化建议

| 优化项 | 方法 | 收益 |
|--------|------|------|
| **纹理图集** | 将小纹理打包成大图 | 减少 Draw Call |
| **压缩格式** | VRAM Compressed / Basis Universal | 显存占用降低50-80% |
| **合理分辨率** | 移动端 ≤ 1024，PC ≤ 2048 | 显存+带宽节省 |
| **Mipmap** | 3D纹理启用 | 远距离性能提升 |
| **纹理流送** | 使用 TextureLayered（高级） | 按需加载 |
| **格式匹配** | Albedo=sRGB, Normal=Linear | 避免颜色错误 |

---

## 九、常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 纹理模糊 | 使用了 Linear 过滤 | 像素艺术改用 Nearest |
| PNG透明消失 | JPEG不支持透明 | 改用PNG/WebP |
| SVG显示不全 | ThorVG限制 | 转换为PNG |
| 显存爆满 | 纹理未压缩/太大 | 使用压缩格式，降低分辨率 |
| HDR数据丢失 | 导入时启用了sRGB | 数据纹理禁用sRGB |
| 粒子/ foliage 排序错 | Alpha混合排序问题 | 使用 Alpha Scissor 模式 |

---

## 十、参考链接

- [Image 官方文档](https://docs.godotengine.org/en/stable/classes/class_image.html)
- [Texture2D 官方文档](https://docs.godotengine.org/en/stable/classes/class_texture2d.html)
- [ImageTexture 官方文档](https://docs.godotengine.org/en/stable/classes/class_imagetexture.html)
- [Import 流程文档](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/import_process.html)
- [StandardMaterial3D 教程](13D_Standard_Material_3D.md)
- [Canvas Item Shader 教程](10C_Canvas_Item_Shader.md)
