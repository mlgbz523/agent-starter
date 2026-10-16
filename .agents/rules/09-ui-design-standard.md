---
description: UI 任务的设计系统对齐与界面验收协议
globs: ["**/*.tsx", "**/*.jsx", "**/*.vue", "**/*.css", "**/*.scss", "**/*.html", "**/*.svelte"]
always_on: false
---

# 09 — UI 设计规范

## 适用范围
仅适用于用户界面、样式、视觉体系和前端交互表现任务。若当前项目不是 Web UI 或工具无法判断相关文件类型，应按实际项目设计系统执行，不机械套用清单。

## 1. 设计优先

- 开始界面任务前检查项目根目录 `DESIGN.md`。若不存在或仍是未填写的占位骨架，告知用户，并按现有产品风格及已确认要求采用保守方案。
- 新建页面、变更整体视觉体系或影响范围较大的 UI 任务，先用 1–2 句话复述风格理解并在规则要求时等待确认；调小间距、修正文案等低风险小改动可简短说明后直接执行。
- 以 `DESIGN.md` 和现有实现为准。没有设计系统时，不应擅自添加复杂动效或新依赖。

## 2. Design Tokens

- 若项目已使用 Design Tokens，沿用其颜色、字体、间距、圆角和阴影变量。
- 新建或调整设计系统时，先确定所需 tokens，再应用到页面和组件；避免局部硬编码造成同一语义出现多套值。
- 不为一次局部调整擅自重写整个设计系统。

## 3. 交付自检

根据项目实际支持能力核对：
- 颜色与设计 token 一致；
- 字体、字号和层级符合设计系统；
- 间距节奏一致；
- 涉及的桌面/移动断点可用；
- 暗色模式仅在产品要求或设计系统支持时核验；
- 交互状态、可访问性和可读性符合任务需要；
- 有条件时提供截图或浏览器实际检查证据。

不存在的能力或当前无法验证的项目应标注“未验证/不适用”，不要假报通过。

## 4. 前端布局与滚动容器铁律 (Layout & Scrollport Principles)

在涉及表格、管理后台、双栏或复杂数据看板时，必须严格遵守以下布局几何法则：
- **单一滚动视口法则 (The Single Scrollport Law)**：
  - 一个组件区域内**严格只允许一个合法的滚动宿主（Scroll Host）**，严禁父子或兄弟容器同时触发滚动条；
  - 宿主容器内部的所有子级包裹层（如 `.cxd-Table-content`、`.cxd-Table-wrapper`）必须显式强制声明 `overflow: visible !important; transform: none !important;`；
  - 宿主外部的所有父级弹性容器必须声明 `overflow: visible !important; min-height: 0 !important;`，杜绝并排双垂直滚动条。
- **视口高度预算守恒与横向滚动条常驻 (Viewport Budget & Sticky Scrollbar)**：
  - 在固定视口布局（100vh）下，凡上方存在固定标头（如 HeaderRow），子容器的高度计算必须扣除标头高度：
    `height: calc(100vh - var(--header-height)) !important; max-height: calc(100vh - var(--header-height)) !important; flex: 1 1 auto; min-height: 0;`；
  - 严禁子容器单独声明 `height: 100vh`，否则导致页面高度超标（100vh + headerHeight），底部的水平滚动条被挤出视口下方造成操作锁死。
- **跨平台滚动条样式规范 (Scrollbar Spec Harmony)**：
  - 采用标准 `::-webkit-scrollbar` 规范，宽度/高度统一设为 8px，圆角 4px，滑块高对比度颜色 `#475569`（悬停 `#38bdf8`），禁止在同一元素上叠加大一统 `scrollbar-color` 导致 Chromium 回退为 Windows 原生粗灰色带箭头滚动条。

## 5. 微交互、浮窗与低代码引擎避坑规范 (Micro-Interactions & Low-Code Defense)

- **浮窗去冗余与定向锚定 (Popover Cleanliness)**：
  - 悬停浮窗（Hover Popover）内严禁放置无业务含义的解释性标题（如“包含关联标签 (2)”）；
  - 浮窗必须明确声明定向弹出方向（优先 `position: 'right'`），配合轻量偏移，绝不能居中弹出遮挡用户正在审阅的行内容。
- **低代码引擎缺省行为回退防御 (Fallback Contract Defense)**：
  - 在 amis 等基于 JSON Schema 的低代码引擎中，若需彻底移除工具栏（如 `footerToolbar`），必须显式声明为空数组 `footerToolbar: []`；省略或传 `undefined` 会触发引擎默认补全策略注入默认组件；
  - CSS 类名选择器需兼容 BEM 双横线与单横线写法（如 `.cxd-Crud-toolbar--bottom, .cxd-Crud-toolbar-bottom`）。

## 6. 自动化布局防御探针断言模板 (Automated Layout Probes)

交付包含滚动或高密度表格的界面前，推荐在测试中植入以下正则/DOM 断言：
```javascript
// 探针 1: 验证无双重滚动
assert.ok(!css.includes('.cxd-Table-content { overflow: auto'), '子内容包装器禁止开启独立滚动');
// 探针 2: 验证视口高度预算
assert.ok(css.includes('max-height: calc(100vh -'), '滚动容器必须减除顶栏高度预算');
// 探针 3: 验证滚动条宽度
assert.ok(css.includes('::-webkit-scrollbar { width: 8px; height: 8px; }'), '滚动条必须采用标准高对比度 8px 规范');
```
