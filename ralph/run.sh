#!/bin/bash

# ==========================================
# 环境变量配置
# ==========================================
export PROJECT_NAME="xxx" # 可以根据实际任务修改
CUR_DIR=$(pwd)
export RALPH_WORKSPACE_DIR="${CUR_DIR}/../ralph-workspace/${PROJECT_NAME}"

# 确保 Ralph 的状态目录结构存在
mkdir -p "${RALPH_WORKSPACE_DIR}/worklog"

# 初始化轮次
ROUND=1
MAX_ROUNDS=25

echo "🚀 正在启动 Ralph Loop，当前工程项目：${PROJECT_NAME}"
echo "📁 Ralph 状态目录: ${RALPH_WORKSPACE_DIR}"

while true; do
    # 动态注入当前的 Agent 序号
    export AGENT_INDEX=${ROUND}

    echo "================================================="
    echo "🔄 Ralph Agent Iteration: ${AGENT_INDEX}"
    echo "================================================="

    # 1. 启动前安全检查：如果前几轮已经生成了 done.md，说明任务已完成
    if [ -f "${RALPH_WORKSPACE_DIR}/done.md" ]; then
        echo "🎉 检测到 done.md！目标已达成，Ralph Loop 圆满结束。"
        break
    fi

    # 2. 读取并渲染 Markdown 模板
    # 注意：使用 envsubst 注入 ${AGENT_INDEX} 和 ${RALPH_DIR} 到提示词中
    RALPH_PROMPT=$(envsubst '${AGENT_INDEX} ${RALPH_WORKSPACE_DIR}' < "prompt.md")

    # 3. 唤醒 Codex 执行当前轮次
    echo "🤖 正在唤醒 Agent ${AGENT_INDEX} 执行微步进推进..."
    codex exec -m "gpt-5.4" --yolo --cd ${WORKING_DIR} --config model_reasoning_effort="medium" "$RALPH_PROMPT"

    # 4. 执行后状态检查：Agent 是否在本轮宣布了目标达成？
    if [ -f "${RALPH_DIR}/done.md" ]; then
        echo "🎉 Agent ${AGENT_INDEX} 宣布目标达成 (已生成 done.md)！"
        echo "📝 详情请查阅 ${RALPH_DIR}/done.md 和本轮的 worklog。"
        break
    fi

    # 5. 防死循环机制
    if [ "$ROUND" -ge "$MAX_ROUNDS" ]; then
        echo "⚠️ 已达到最大迭代次数（${MAX_ROUNDS}）。"
        echo "当前状态可能陷入停滞，或任务过于庞大。为防止死循环，脚本即将退出。"
        break
    fi

    ROUND=$((ROUND + 1))
    
    # 可选：稍微停顿一下，防止日志刷屏过快，也给文件系统一点同步的时间
    sleep 2 
done