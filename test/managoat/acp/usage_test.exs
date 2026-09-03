defmodule Managoat.ACP.UsageTest do
  use ExUnit.Case, async: true

  alias Managoat.ACP.Usage

  test "the `usage` object, with the cache fields when present" do
    assert Usage.from_prompt_result(%{
             "stopReason" => "end_turn",
             "usage" => %{
               "inputTokens" => 10,
               "outputTokens" => 4,
               "cachedReadTokens" => 8,
               "cachedWriteTokens" => nil,
               "totalTokens" => 22
             }
           }) == %{"input" => 10, "output" => 4, "cache_read" => 8}
  end

  test "falls back to _meta.inputTokens / outputTokens" do
    assert Usage.from_prompt_result(%{"_meta" => %{"inputTokens" => 3, "outputTokens" => "7"}}) ==
             %{"input" => 3, "output" => 7}
  end

  test "nil when nothing is reported, or nothing usable" do
    assert Usage.from_prompt_result(%{"stopReason" => "end_turn"}) == nil
    assert Usage.from_prompt_result(%{"_meta" => %{"other" => 1}}) == nil
    assert Usage.from_prompt_result(%{"usage" => %{"inputTokens" => -1}}) == nil
    assert Usage.from_prompt_result(%{"usage" => %{"inputTokens" => true}}) == nil
    assert Usage.from_prompt_result(nil) == nil
  end

  test "one side missing counts as zero for that side" do
    assert Usage.from_prompt_result(%{"usage" => %{"outputTokens" => 5.0}}) ==
             %{"input" => 0, "output" => 5}
  end

  describe "gemini's _meta.quota (quirk :gemini_usage_in_meta_quota)" do
    # Verbatim from gemini-cli's `packages/cli/src/acp/acpSession.ts`, which
    # returns this on every `session/prompt` outcome but `cancelled`.
    defp gemini_result(quota) do
      %{"stopReason" => "end_turn", "_meta" => %{"quota" => quota}}
    end

    test "reads the turn's totals" do
      assert Usage.from_prompt_result(
               gemini_result(%{
                 "token_count" => %{"input_tokens" => 1234, "output_tokens" => 567},
                 "model_usage" => [
                   %{
                     "model" => "gemini-3.1-pro-preview",
                     "token_count" => %{"input_tokens" => 1234, "output_tokens" => 567}
                   }
                 ]
               })
             ) == %{"input" => 1234, "output" => 567}
    end

    test "a turn that answered from a slash command reports zero, not nothing" do
      assert Usage.from_prompt_result(
               gemini_result(%{
                 "token_count" => %{"input_tokens" => 0, "output_tokens" => 0},
                 "model_usage" => []
               })
             ) == %{"input" => 0, "output" => 0}
    end

    test "no cache split: gemini reports none, so none is recorded" do
      usage =
        Usage.from_prompt_result(
          gemini_result(%{"token_count" => %{"input_tokens" => 9, "output_tokens" => 1}})
        )

      refute Map.has_key?(usage, "cache_read")
      refute Map.has_key?(usage, "cache_write")
    end

    test "the protocol's own field still wins over the vendor extension" do
      assert Usage.from_prompt_result(%{
               "usage" => %{"inputTokens" => 1, "outputTokens" => 2},
               "_meta" => %{"quota" => %{"token_count" => %{"input_tokens" => 999}}}
             }) == %{"input" => 1, "output" => 2}
    end

    test "an unusable quota falls through to the flat _meta shape" do
      assert Usage.from_prompt_result(%{
               "_meta" => %{
                 "quota" => %{"token_count" => %{"input_tokens" => "not a number"}},
                 "inputTokens" => 4,
                 "outputTokens" => 5
               }
             }) == %{"input" => 4, "output" => 5}
    end

    test "nil when the quota is absent or carries no counts" do
      assert Usage.from_meta_quota(%{"quota" => %{"model_usage" => []}}) == nil
      assert Usage.from_meta_quota(%{"quota" => %{"token_count" => %{}}}) == nil
      assert Usage.from_meta_quota(%{"inputTokens" => 1}) == nil
      assert Usage.from_prompt_result(gemini_result(%{"token_count" => %{}})) == nil
    end
  end
end
