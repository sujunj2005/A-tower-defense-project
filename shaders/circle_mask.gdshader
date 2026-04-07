shader_type canvas_item;

// 圆形遮罩着色器
// 将矩形 ColorRect 裁剪为圆形

void fragment() {
    // 获取 UV 坐标（0-1）
    vec2 uv = UV;
    
    // 计算到中心点的距离
    vec2 center = vec2(0.5, 0.5);
    float distance = length(uv - center);
    
    // 如果距离超过 0.5（半径），则透明（实现圆形裁剪）
    if (distance > 0.5) {
        COLOR.a = 0.0;
    } else {
        // 边缘渐变效果（可选，让边缘更柔和）
        float edge_smooth = smoothstep(0.5, 0.45, distance);
        COLOR.a *= edge_smooth;
    }
}