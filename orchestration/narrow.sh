#!/usr/bin/env bash
set -euo pipefail

# =========================
# 基础路径与时间
# =========================
CURRENT_TIME="$(date +%Y%m%d%H%M%S)"

export PROJECT_PATH="/workspace/xllm-codex"
export WORKSPACE="${PROJECT_PATH}/agent-workspace/${CURRENT_TIME}"
mkdir -p "${WORKSPACE}"

# =========================
# 参数：允许指定 origin branch
# 默认 main
# =========================
if [[ $# -ge 1 && -n "${1}" ]]; then
    export ORIGIN_BRANCH="${1}"
else
    export ORIGIN_BRANCH="main"
fi

# =========================
# Prompt 文件
# =========================
REVIEW_PROMPT_FILE="${PROJECT_PATH}/prompts/narrowdown/investigate.md"
IMPLEMENT_PROMPT_FILE="${PROJECT_PATH}/prompts/narrowdown/implement.md"

if [[ ! -f "${REVIEW_PROMPT_FILE}" ]]; then
    echo "[ERROR] Review prompt file not found: ${REVIEW_PROMPT_FILE}"
    exit 1
fi

# =========================
# 渲染 review prompt
# =========================
REVIEW_PROMPT="$(envsubst '${ORIGIN_BRANCH} ${WORKSPACE}' < "${REVIEW_PROMPT_FILE}")"

echo "[INFO] WORKSPACE=${WORKSPACE}"
echo "[INFO] ORIGIN_BRANCH=${ORIGIN_BRANCH}"
echo "[INFO] Running review agent..."

# =========================
# 执行 review agent
# =========================
codex -m "gpt-5.4" \
  --yolo \
  --cd "${PROJECT_PATH}" \
  --config model_reasoning_effort="high" \
  "${REVIEW_PROMPT}"

# =========================
# 检查 review.md 是否生成
# =========================
REVIEW_FILE="${WORKSPACE}/review.md"

if [[ ! -f "${REVIEW_FILE}" ]]; then
    echo "[ERROR] review.md was not generated: ${REVIEW_FILE}"
    exit 1
fi

echo "[INFO] review.md generated: ${REVIEW_FILE}"

# =========================
# 解析 decision / confidence
# 支持：
# decision: proceed
# - decision: proceed
# 前后空格都尽量兼容
# =========================
DECISION="$(
    sed -nE 's/^[[:space:]-]*decision:[[:space:]]*(proceed|hold|defer)[[:space:]]*$/\1/ip' "${REVIEW_FILE}" \
    | head -n 1 \
    | tr '[:upper:]' '[:lower:]'
)"

CONFIDENCE="$(
    sed -nE 's/^[[:space:]-]*confidence:[[:space:]]*(high|medium|low)[[:space:]]*$/\1/ip' "${REVIEW_FILE}" \
    | head -n 1 \
    | tr '[:upper:]' '[:lower:]'
)"

if [[ -z "${DECISION}" ]]; then
    echo "[ERROR] Failed to parse decision from review.md"
    echo "[INFO] review.md content preview:"
    sed -n '1,40p' "${REVIEW_FILE}"
    exit 1
fi

echo "[INFO] decision=${DECISION}"
if [[ -n "${CONFIDENCE}" ]]; then
    echo "[INFO] confidence=${CONFIDENCE}"
fi

# =========================
# 根据 decision 决定是否继续
# =========================
case "${DECISION}" in
    proceed)
        echo "[INFO] decision=proceed, continue to implement agent."

        if [[ ! -f "${IMPLEMENT_PROMPT_FILE}" ]]; then
            echo "[ERROR] decision=proceed but implement prompt file not found: ${IMPLEMENT_PROMPT_FILE}"
            exit 1
        fi

        IMPLEMENT_PROMPT="$(envsubst '${ORIGIN_BRANCH} ${WORKSPACE}' < "${IMPLEMENT_PROMPT_FILE}")"

        echo "[INFO] Running implement agent..."
        codex -m "gpt-5.4" \
          --yolo \
          --cd "${PROJECT_PATH}" \
          --config model_reasoning_effort="high" \
          "${IMPLEMENT_PROMPT}"
        ;;
    hold)
        echo "[INFO] decision=hold, stop workflow. No implement action will be taken."
        ;;
    defer)
        echo "[INFO] decision=defer, stop workflow for now. More evidence/context is needed before implement."
        ;;
    *)
        echo "[ERROR] Unsupported decision value: ${DECISION}"
        exit 1
        ;;
esac

echo "[INFO] Workflow finished."