
// ghostty 虚拟光标滑动拖影（仅在移动时出现）
// Author: wheregrassdreams

float rectSDF(vec2 p, vec2 center, vec2 size) {
    vec2 d = abs(p - center) - size;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float springEase(float t) {
    // 非线性弹性缓动，单调收敛
    return 1.0 - exp(-6.0 * t);
    // return 1.0 - exp(-6.0 * t) * cos(2.0 * t);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 base = texture(iChannel0, uv);

    // --- 计算移动进度 ---
    float duration = 0.1; // 拖影持续时间
    float elapsed = iTime - iTimeCursorChange;
    float t = clamp(elapsed / duration, 0.0, 1.0);

    // 若光标静止太久（t=1），则不显示虚拟光标
    if (t >= 1.0) { fragColor = base; return; }

    // --- 弹性缓动 ---
    float easeT = springEase(t);

    // --- 当前 / 上一位置 ---
    vec2 curr = iCurrentCursor.xy / iResolution.xy;
    vec2 prev = iPreviousCursor.xy / iResolution.xy;
    vec2 cursorPos = mix(prev, curr, easeT);

    // --- 计算移动距离（用于控制拉伸强度）---
    float distMoved = length(curr - prev);
    // float stretch = clamp(distMoved, * 40.0, 0.0, 0.6);

    // --- 虚拟光标形状与大小 ---
    vec2 cursorSize = (iCurrentCursor.zw / iResolution.xy) * 0.5;
    float dist = rectSDF(uv, cursorPos + cursorSize * vec2(1.0, -1.0), cursorSize);

    // --- 动态透明度：随着时间消散 ---
    float edge = 1.0 / iResolution.y;
    float alpha = 1.0 - smoothstep(0.0, edge, dist);
    float fade = 1.0 - smoothstep(0.0, 1.0, t);  // t 越大越透明

    // --- 混合颜色 ---
    vec3 cursorColor = vec3(.8, .8, .8);
    fragColor = base;
    fragColor.rgb = mix(fragColor.rgb, cursorColor, alpha * 0.8 * fade);
}
