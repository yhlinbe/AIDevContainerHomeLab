# 全局 AI 團隊運作規範與 SOP

## 1. AI 專家角色切換
當使用者或系統指令提及 `@角色`（如 `@PO`, `@SA`, `@SRE`, `@Conclusion_Master`）時，請切換至 `.ai/skills.json` 中對應角色的 `system_instruction` 與 `output_format` 進行回答。

## 2. 討論與決策文檔自動化規範

每當與使用者進行對話、規劃或開發時，必須嚴格依照以下階段建立/更新 `.ai/docs/` 下的 Markdown 文檔：

### Phase 1: 討論階段 (Discussion)
* **檔案路徑**：`.ai/docs/discussions/discussion-YYYY-MM-DD-000x.md`
* **命名邏輯**：`YYYY-MM-DD` 為當日日期；`000x` 為當日流水號（若當日已有 `0001`，則自動遞增為 `0002`；換日自動歸零重算）。
* **內容要求**：記錄本次對話中各 AI 角色的發言摘要、爭議點與初步共識。

### Phase 2: 決策與準備階段 (Conclusion & Checklist)
當確定決策後，必須建立二份檔案（`v00x` 為專案版本號，依版本推進）：
1. **決策文檔**：`.ai/docs/conclusions/conclusion-v00x.md`
   * 記錄最終採納的架構、商業邏輯或運算策略。
2. **待辦清單**：`.ai/docs/conclusions/conclusion-v00x-todo-checklist.md`
   * **結構要求**：
     * **[要做的事 (Task)]**：明確的程式碼修改或設定步驟。
     * **[實現目標 (Goal)]**：該任務是為了滿足什麼業務或技術需求。

### Phase 3: 執行與變更歷程 (Changelog & Review Guide)
在執行任務的過程中與完成後：
1. **變更歷程**：在 `conclusion-v00x.md` 的末端追蹤新增、修改、刪除的檔案與 Diff 摘要。
2. **Review 指南**：建立 `.ai/docs/conclusions/conclusion-v00x-review.md`
   * **內容要求**：詳細說明使用者該如何驗證本次變更（包含：啟動指令、測試範例、API 呼叫方式、期望結果）。

### Phase 4: 反饋處理 (User Feedback)
若使用者提出 Feedback：
* 將反饋內容追加寫入 `.ai/docs/feedback/user-feedback.md`。
* 自動召集相關 AI 專家（如 `@SA` + `@QA`）對反饋進行討論，並更新 `discussion-YYYY-MM-DD-000x.md` 與 `conclusion-v00x`。