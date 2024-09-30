shader_type canvas_item;

// 最大支持的点的数量
uniform int num_points;
uniform vec2 points[1024]; 
uniform int num_highlight_points;
uniform vec2 highlight_points[1024];
uniform float radius; // 半径范围
uniform vec2 size;
uniform vec2 offset;

void fragment() {
    // 初始化输出颜色
	vec4 color = texture(TEXTURE, UV);

    // 遍历所有的坐标点
    for (int i = 0; i < num_points; i++) {
        // 计算当前像素到点的距离
        float dist = distance(UV, (offset + highlight_points[i]) / size);
        if (dist < radius) {
            color.a = 0.0;
			break;
        }
		else {
			dist = distance(UV, (offset + points[i]) / size);
			if (dist < radius) {
				color = vec4(0, 0, 0, 0.5);
				break;
			}
		}
    }

     //输出颜色
    COLOR = color;
}
