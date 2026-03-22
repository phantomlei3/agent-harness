## # Goal: 研报与财报自动化标准化解析引擎 (Standardized Financial Parser)

### 1. 核心任务目标 (Mission)
构建一套能够将非结构化（PDF/OCR/乱码文本）财务报告转化为**高保重、带有语义层级的结构化块 (Semantic Blocks)** 的处理流水线。该系统需为后续的分析型 Agent 提供精准、无噪声的 Context。

### 2. 最小可行性技术指标 (MVP Requirements)
* **多源兼容性：** 必须支持原生 PDF（带层级）、扫描件 PDF（需集成 OCR 逻辑）、以及从 Web 剪切的 Markdown/纯文本。
* **噪声消除率：** 自动识别并剔除 95% 以上的重复页眉、页脚、页码及目录页。
* **层级感知：** 准确识别“一、管理层讨论与分析”、“（二）财务报表”等典型财报标题层级，输出 JSON 或带层级标签的 Markdown。
* **表格对齐：** 解决表格跨页导致的断裂问题，确保资产负债表等核心数据块的完整性。

### 3. 核心功能拆解 (Task Decomposition)
1.  **Layout Analysis:** 使用布局分析模型（如 LayoutLM 或 PaddleLayout）区分正文、表格、图片和页眉页脚。
2.  **Semantic Chunking:** 放弃简单的按 Token 长度切分，改为按**语义标题**切分 Block。
3.  **Table Recovery:** 专门的表格提取模块，确保表格数据以 Markdown 表格或 CSV 结构保存，而非错位的文本。
4.  **Skills Packaging:** 将上述脚本封装为标准化的 API/Tool，并附带 `skills.md` 说明文档。

### 4. 交付物定义 (Definition of Done)
* 一套能够运行的 Python 脚本集（含数据清洗、正则去噪、层级提取）。
* 一份 `tools_manifest.yaml`，详细描述每个 Tool 的输入（如 PDF 路径）和输出（Cleaned Markdown）。
* 一个 `skills_guide.md`：告诉其他 Agent 在什么场景下调用哪个工具（例如：提取利润表选 `Table_Extractor`，提取经营分析选 `Semantic_Blocker`）。


### 5.可以参考进行使用的年报文档：
- cambricon-2025.pdf