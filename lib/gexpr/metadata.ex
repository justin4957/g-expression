defmodule Gexpr.Metadata do
  @moduledoc """
  Metadata support for G-Expressions, enabling computation archaeology and provenance tracking.
  
  This module provides utilities for attaching, extracting, and reasoning about
  metadata associated with G-Expressions, supporting use cases like:
  
  - AI-generated code tracking
  - Performance profiling  
  - Security auditing
  - Compliance verification
  - Debugging and introspection
  """

  @type metadata :: %{
    # Core provenance
    generated_by: String.t(),
    timestamp: String.t(),
    source_prompt: String.t(),
    
    # AI-specific
    model_version: String.t(),
    confidence: float(),
    prompt_hash: String.t(),
    
    # Review and approval
    review_status: :pending | :approved | :rejected,
    reviewer: String.t(),
    review_notes: String.t(),
    
    # Performance
    execution_time_us: integer(),
    memory_usage_bytes: integer(),
    optimization_level: integer(),
    
    # Security
    security_level: :public | :internal | :confidential | :secret,
    access_permissions: list(String.t()),
    data_classification: String.t(),
    
    # Versioning
    version: String.t(),
    parent_hash: String.t(),
    mutation_type: :creation | :modification | :optimization,
    
    # Custom fields
    tags: list(String.t()),
    custom: map()
  }

  @type gexpr_with_metadata :: %{
    g: String.t(),
    v: any(),
    m: metadata()
  }

  @doc """
  Creates a new G-Expression with metadata.
  """
  @spec with_metadata(map(), metadata()) :: gexpr_with_metadata()
  def with_metadata(gexpr, metadata) do
    Map.put(gexpr, "m", metadata)
  end

  @doc """
  Extracts metadata from a G-Expression.
  """
  @spec extract_metadata(gexpr_with_metadata()) :: metadata() | nil
  def extract_metadata(%{"m" => metadata}), do: metadata
  def extract_metadata(_gexpr), do: nil

  @doc """
  Adds provenance information for AI-generated code.
  """
  @spec add_ai_provenance(map(), String.t(), String.t(), float()) :: gexpr_with_metadata()
  def add_ai_provenance(gexpr, model, prompt, confidence) do
    metadata = %{
      "generated_by" => model,
      "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "source_prompt" => prompt,
      "confidence" => confidence,
      "prompt_hash" => hash_prompt(prompt),
      "review_status" => "pending"
    }
    
    with_metadata(gexpr, metadata)
  end

  @doc """
  Adds performance metadata after execution.
  """
  @spec add_performance_data(gexpr_with_metadata(), integer(), integer()) :: gexpr_with_metadata()
  def add_performance_data(gexpr, execution_time_us, memory_bytes) do
    existing_meta = extract_metadata(gexpr) || %{}
    
    performance_meta = Map.merge(existing_meta, %{
      "execution_time_us" => execution_time_us,
      "memory_usage_bytes" => memory_bytes,
      "profiled_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    })
    
    Map.put(gexpr, "m", performance_meta)
  end

  @doc """
  Marks a G-Expression as approved after review.
  """
  @spec approve(gexpr_with_metadata(), String.t(), String.t()) :: gexpr_with_metadata()
  def approve(gexpr, reviewer, notes \\ "") do
    existing_meta = extract_metadata(gexpr) || %{}
    
    approval_meta = Map.merge(existing_meta, %{
      "review_status" => "approved",
      "reviewer" => reviewer,
      "review_notes" => notes,
      "approved_at" => DateTime.utc_now() |> DateTime.to_iso8601()
    })
    
    Map.put(gexpr, "m", approval_meta)
  end

  @doc """
  Creates a mutation of a G-Expression with updated metadata.
  """
  @spec mutate(gexpr_with_metadata(), atom(), map()) :: gexpr_with_metadata()
  def mutate(original_gexpr, mutation_type, new_gexpr_data) do
    original_meta = extract_metadata(original_gexpr) || %{}
    parent_hash = hash_gexpr(original_gexpr)
    
    mutation_meta = Map.merge(original_meta, %{
      "mutation_type" => Atom.to_string(mutation_type),
      "parent_hash" => parent_hash,
      "mutated_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "version" => increment_version(Map.get(original_meta, "version", "0.1.0"))
    })
    
    new_gexpr_data
    |> Map.put("m", mutation_meta)
  end

  @doc """
  Queries G-Expressions by metadata criteria.
  """
  @spec query_by_metadata(list(gexpr_with_metadata()), map()) :: list(gexpr_with_metadata())
  def query_by_metadata(gexprs, criteria) do
    Enum.filter(gexprs, fn gexpr ->
      metadata = extract_metadata(gexpr)
      metadata && matches_criteria?(metadata, criteria)
    end)
  end

  @doc """
  Creates a security audit trail for a G-Expression.
  """
  @spec create_audit_trail(gexpr_with_metadata()) :: %{
    gexpr_hash: String.t(),
    metadata: metadata(),
    security_score: float(),
    compliance_status: String.t(),
    audit_timestamp: String.t()
  }
  def create_audit_trail(gexpr) do
    metadata = extract_metadata(gexpr) || %{}
    
    %{
      "gexpr_hash" => hash_gexpr(gexpr),
      "metadata" => metadata,
      "security_score" => calculate_security_score(metadata),
      "compliance_status" => determine_compliance_status(metadata),
      "audit_timestamp" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "audit_trail_version" => "1.0"
    }
  end

  @doc """
  Generates a human-readable report of G-Expression provenance.
  """
  @spec provenance_report(gexpr_with_metadata()) :: String.t()
  def provenance_report(gexpr) do
    metadata = extract_metadata(gexpr) || %{}
    
    """
    G-Expression Provenance Report
    ==============================
    
    Generated By: #{Map.get(metadata, "generated_by", "Unknown")}
    Timestamp: #{Map.get(metadata, "timestamp", "Unknown")}
    Source: #{Map.get(metadata, "source_prompt", "N/A")}
    Confidence: #{Map.get(metadata, "confidence", "N/A")}
    
    Review Status: #{Map.get(metadata, "review_status", "Unreviewed")}
    Reviewer: #{Map.get(metadata, "reviewer", "N/A")}
    
    Performance:
    - Execution Time: #{Map.get(metadata, "execution_time_us", "N/A")} μs
    - Memory Usage: #{Map.get(metadata, "memory_usage_bytes", "N/A")} bytes
    
    Security Level: #{Map.get(metadata, "security_level", "Unclassified")}
    Version: #{Map.get(metadata, "version", "N/A")}
    
    Hash: #{hash_gexpr(gexpr)}
    """
  end

  # Private helper functions

  defp hash_prompt(prompt) do
    :crypto.hash(:sha256, prompt)
    |> Base.encode16(case: :lower)
    |> String.slice(0, 16)
  end

  defp hash_gexpr(gexpr) do
    gexpr_without_meta = Map.delete(gexpr, "m")
    
    :crypto.hash(:sha256, :erlang.term_to_binary(gexpr_without_meta))
    |> Base.encode16(case: :lower)
    |> String.slice(0, 16)
  end

  defp increment_version(version) do
    case String.split(version, ".") do
      [major, minor, patch] ->
        new_patch = String.to_integer(patch) + 1
        "#{major}.#{minor}.#{new_patch}"
      _ ->
        "0.1.1"
    end
  end

  defp matches_criteria?(metadata, criteria) do
    Enum.all?(criteria, fn {key, expected_value} ->
      Map.get(metadata, key) == expected_value
    end)
  end

  defp calculate_security_score(metadata) do
    base_score = 0.5
    
    # Increase score for approved code
    score = if Map.get(metadata, "review_status") == "approved", do: base_score + 0.3, else: base_score
    
    # Increase score for high confidence AI
    score = if Map.get(metadata, "confidence", 0) > 0.9, do: score + 0.1, else: score
    
    # Decrease score for old code
    score = if recent_timestamp?(Map.get(metadata, "timestamp")), do: score + 0.1, else: score - 0.1
    
    max(0.0, min(1.0, score))
  end

  defp determine_compliance_status(metadata) do
    cond do
      Map.get(metadata, "review_status") == "approved" -> "compliant"
      Map.get(metadata, "generated_by") == "human" -> "compliant"
      Map.get(metadata, "confidence", 0) > 0.95 -> "likely_compliant"
      true -> "requires_review"
    end
  end

  defp recent_timestamp?(nil), do: false
  defp recent_timestamp?(timestamp_str) do
    case DateTime.from_iso8601(timestamp_str) do
      {:ok, timestamp, _} ->
        diff = DateTime.diff(DateTime.utc_now(), timestamp, :day)
        diff <= 30  # Consider recent if within 30 days
      _ ->
        false
    end
  end
end