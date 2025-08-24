use crate::error::Result;
use crate::model_family::ModelFamily;
use crate::models::ContentItem;
use crate::models::ResponseItem;
use crate::openai_tools::OpenAiTool;
use crate::protocol::TokenUsage;
use codex_apply_patch::APPLY_PATCH_TOOL_INSTRUCTIONS;
use codex_protocol::config_types::ReasoningEffort as ReasoningEffortConfig;
use codex_protocol::config_types::ReasoningSummary as ReasoningSummaryConfig;
use futures::Stream;
use serde::Serialize;
use std::borrow::Cow;
use std::pin::Pin;
use std::task::Context;
use std::task::Poll;
use tokio::sync::mpsc;

/// The `instructions` field in the payload sent to a model should always start
/// with this content.
const BASE_INSTRUCTIONS: &str = include_str!("../prompt.md");

/// wraps user instructions message in a tag for the model to parse more easily.
const USER_INSTRUCTIONS_START: &str = "<user_instructions>\n\n";
const USER_INSTRUCTIONS_END: &str = "\n\n</user_instructions>";

/// API request payload for a single model turn
#[derive(Default, Debug, Clone)]
pub struct Prompt {
    /// Conversation context input items.
    pub input: Vec<ResponseItem>,

    /// Whether to store response on server side (disable_response_storage = !store).
    pub store: bool,

    /// Tools available to the model, including additional tools sourced from
    /// external MCP servers.
    pub tools: Vec<OpenAiTool>,

    /// Optional override for the built-in BASE_INSTRUCTIONS.
    pub base_instructions_override: Option<String>,
}

impl Prompt {
    pub(crate) fn get_full_instructions(&self, model: &ModelFamily) -> Cow<'_, str> {
        let base = self
            .base_instructions_override
            .as_deref()
            .unwrap_or(BASE_INSTRUCTIONS);
        let mut sections: Vec<&str> = vec![base];

        // When there are no custom instructions, add apply_patch if either:
        // - the model needs special instructions, or
        // - there is no apply_patch tool present
        let is_apply_patch_tool_present = self
            .tools
            .iter()
            .any(|t| matches!(t, OpenAiTool::Function(f) if f.name == "apply_patch"));
        if self.base_instructions_override.is_none()
            && (model.needs_special_apply_patch_instructions || !is_apply_patch_tool_present)
        {
            sections.push(APPLY_PATCH_TOOL_INSTRUCTIONS);
        }
        Cow::Owned(sections.join("\n"))
    }

    pub(crate) fn get_formatted_input(&self) -> Vec<ResponseItem> {
        self.input.clone()
    }

    /// Creates a formatted user instructions message from a string
    pub(crate) fn format_user_instructions_message(ui: &str) -> ResponseItem {
        ResponseItem::Message {
            id: None,
            role: "user".to_string(),
            content: vec![ContentItem::InputText {
                text: format!("{USER_INSTRUCTIONS_START}{ui}{USER_INSTRUCTIONS_END}"),
            }],
        }
    }
}

#[derive(Debug)]
pub enum ResponseEvent {
    Created,
    OutputItemDone(ResponseItem),
    Completed {
        response_id: String,
        token_usage: Option<TokenUsage>,
    },
    OutputTextDelta(String),
    ReasoningSummaryDelta(String),
    ReasoningContentDelta(String),
    ReasoningSummaryPartAdded,
}

#[derive(Debug, Serialize)]
pub(crate) struct Reasoning {
    pub(crate) effort: ReasoningEffortConfig,
    pub(crate) summary: ReasoningSummaryConfig,
}

/// Request object that is serialized as JSON and POST'ed when using the
/// Responses API.
#[derive(Debug, Serialize)]
pub(crate) struct ResponsesApiRequest<'a> {
    pub(crate) model: &'a str,
    pub(crate) instructions: &'a str,
    // TODO(mbolin): ResponseItem::Other should not be serialized. Currently,
    // we code defensively to avoid this case, but perhaps we should use a
    // separate enum for serialization.
    pub(crate) input: &'a Vec<ResponseItem>,
    pub(crate) tools: &'a [serde_json::Value],
    pub(crate) tool_choice: &'static str,
    pub(crate) parallel_tool_calls: bool,
    pub(crate) reasoning: Option<Reasoning>,
    /// true when using the Responses API.
    pub(crate) store: bool,
    pub(crate) stream: bool,
    pub(crate) include: Vec<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub(crate) prompt_cache_key: Option<String>,
}

pub(crate) fn create_reasoning_param_for_request(
    model_family: &ModelFamily,
    effort: ReasoningEffortConfig,
    summary: ReasoningSummaryConfig,
) -> Option<Reasoning> {
    if model_family.supports_reasoning_summaries {
        Some(Reasoning { effort, summary })
    } else {
        None
    }
}

pub(crate) struct ResponseStream {
    pub(crate) rx_event: mpsc::Receiver<Result<ResponseEvent>>,
}

impl Stream for ResponseStream {
    type Item = Result<ResponseEvent>;

    fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        self.rx_event.poll_recv(cx)
    }
}

#[cfg(test)]
mod tests {
    use crate::model_family::find_family_for_model;

    use super::*;

    #[test]
    fn get_full_instructions_no_user_content() {
        let prompt = Prompt {
            ..Default::default()
        };
        let expected = format!("{BASE_INSTRUCTIONS}\n{APPLY_PATCH_TOOL_INSTRUCTIONS}");
        let model_family = find_family_for_model("gpt-4.1").expect("known model slug");
        let full = prompt.get_full_instructions(&model_family);
        assert_eq!(full, expected);
    }
}
