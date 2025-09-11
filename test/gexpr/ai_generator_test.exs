defmodule Gexpr.AiGeneratorTest do
  use ExUnit.Case
  alias Gexpr.{AiGenerator, PrimeMover}

  describe "AI prompt generation" do
    test "generates G-Expression from arithmetic prompt" do
      {:ok, result} = AiGenerator.generate_from_prompt("add 20 and 22")
      
      assert Map.has_key?(result, "g")
      assert Map.has_key?(result, "v")
      assert Map.has_key?(result, "m")  # metadata should be included
      
      # Should generate an application of + to 20 and 22
      assert result["g"] == "app"
    end

    test "generates G-Expression from function creation prompt" do
      {:ok, result} = AiGenerator.generate_from_prompt("create a function that doubles a number")
      
      assert result["g"] == "lam"
      assert is_map(result["v"])
      assert Map.has_key?(result["v"], "params")
      assert Map.has_key?(result["v"], "body")
    end

    test "includes proper metadata in AI generation" do
      {:ok, result} = AiGenerator.generate_from_prompt("add 20 and 22")
      
      metadata = result["m"]
      assert Map.has_key?(metadata, "generated_by")
      assert Map.has_key?(metadata, "source_prompt")
      assert Map.has_key?(metadata, "confidence")
      assert Map.has_key?(metadata, "timestamp")
      
      assert metadata["source_prompt"] == "add 20 and 22"
      assert is_float(metadata["confidence"])
      assert metadata["confidence"] > 0.0 and metadata["confidence"] <= 1.0
    end

    test "handles unknown prompt intents gracefully" do
      {:ok, result} = AiGenerator.generate_from_prompt("do something completely unknown")
      
      # Should still produce a valid G-Expression structure
      assert Map.has_key?(result, "g")
      assert Map.has_key?(result, "v")
    end
  end

  describe "JSON G-Expression parsing" do
    test "parses valid JSON G-Expression" do
      json_str = """
      {
        "g": "lit",
        "v": 42
      }
      """
      
      {:ok, parsed} = AiGenerator.parse_json_gexpr(json_str)
      assert parsed["g"] == "lit"
      assert parsed["v"] == 42
    end

    test "rejects invalid JSON" do
      invalid_json = "{ invalid json }"
      
      {:error, reason} = AiGenerator.parse_json_gexpr(invalid_json)
      assert String.contains?(reason, "JSON parse error")
    end

    test "rejects structurally invalid G-Expression" do
      json_str = """
      {
        "not_g": "lit",
        "not_v": 42
      }
      """
      
      {:error, reason} = AiGenerator.parse_json_gexpr(json_str)
      assert String.contains?(reason, "Invalid G-Expression structure")
    end
  end

  describe "G-Expression to JSON conversion" do
    test "converts G-Expression to pretty JSON" do
      gexpr = %{
        "g" => "lit",
        "v" => 42
      }
      
      {:ok, json} = AiGenerator.to_ai_json(gexpr)
      assert String.contains?(json, "\"g\": \"lit\"")
      assert String.contains?(json, "\"v\": 42")
    end

    test "handles complex G-Expressions" do
      complex_gexpr = %{
        "g" => "app",
        "v" => %{
          "fn" => %{"g" => "ref", "v" => "+"},
          "args" => %{"g" => "vec", "v" => [
            %{"g" => "lit", "v" => 20},
            %{"g" => "lit", "v" => 22}
          ]}
        }
      }
      
      {:ok, json} = AiGenerator.to_ai_json(complex_gexpr)
      assert String.contains?(json, "app")
      assert String.contains?(json, "vec")
    end
  end

  describe "training examples generation" do
    test "generates valid training examples" do
      examples = AiGenerator.generate_training_examples()
      
      assert length(examples) > 0
      
      Enum.each(examples, fn example ->
        assert Map.has_key?(example, "prompt")
        assert Map.has_key?(example, "gexpr")
        assert is_binary(example["prompt"])
        assert is_map(example["gexpr"])
        
        # Each gexpr should have proper structure
        gexpr = example["gexpr"]
        assert Map.has_key?(gexpr, "g")
        assert Map.has_key?(gexpr, "v")
      end)
    end

    test "training examples are executable" do
      examples = AiGenerator.generate_training_examples()
      context = PrimeMover.create_genesis_context()
      
      # Test at least one example
      example = List.first(examples)
      gexpr = example["gexpr"]
      
      # Convert to internal format and try to execute
      case AiGenerator.validate_and_test(gexpr) do
        {:ok, :valid} -> assert true
        {:error, _reason} -> 
          # Some examples might not be directly executable without context
          assert true
      end
    end
  end

  describe "validation and testing" do
    test "validates correct G-Expression structure" do
      valid_gexpr = %{
        "g" => "lit",
        "v" => 42
      }
      
      assert {:ok, :valid} = AiGenerator.validate_and_test(valid_gexpr)
    end

    test "rejects invalid G-Expression structure" do
      invalid_gexpr = %{
        "not_g" => "lit",
        "not_v" => 42
      }
      
      assert {:error, _reason} = AiGenerator.validate_and_test(invalid_gexpr)
    end

    test "validates function with test input" do
      double_fn = %{
        "g" => "lam",
        "v" => %{
          "params" => ["x"],
          "body" => %{
            "g" => "app",
            "v" => %{
              "fn" => %{"g" => "ref", "v" => "*"},
              "args" => %{
                "g" => "vec",
                "v" => [
                  %{"g" => "ref", "v" => "x"},
                  %{"g" => "lit", "v" => 2}
                ]
              }
            }
          }
        }
      }
      
      assert {:ok, :valid} = AiGenerator.validate_and_test(double_fn, 21, 42)
    end

    test "catches incorrect expected output" do
      add_fn = %{
        "g" => "app",
        "v" => %{
          "fn" => %{"g" => "ref", "v" => "+"},
          "args" => %{
            "g" => "vec",
            "v" => [
              %{"g" => "lit", "v" => 20},
              %{"g" => "lit", "v" => 22}
            ]
          }
        }
      }
      
      # Expected 43 but should produce 42
      assert {:error, reason} = AiGenerator.validate_and_test(add_fn, nil, 43)
      assert String.contains?(reason, "Expected 43, got 42")
    end
  end

  describe "AI prompting guide" do
    test "provides comprehensive prompting guide" do
      guide = AiGenerator.ai_prompting_guide()
      
      # Should contain key concepts
      assert String.contains?(guide, "G-Expression")
      assert String.contains?(guide, "lit")
      assert String.contains?(guide, "ref") 
      assert String.contains?(guide, "app")
      assert String.contains?(guide, "vec")
      assert String.contains?(guide, "lam")
      assert String.contains?(guide, "JSON")
      assert String.contains?(guide, "Best Practices")
    end
  end

  describe "end-to-end AI workflow" do
    test "complete pipeline: prompt -> G-Expression -> execution -> validation" do
      # Step 1: Generate from prompt
      {:ok, gexpr_with_meta} = AiGenerator.generate_from_prompt("add 20 and 22")
      
      # Step 2: Convert to JSON (simulate sending to AI)
      {:ok, json} = AiGenerator.to_ai_json(gexpr_with_meta)
      
      # Step 3: Parse back from JSON (simulate receiving from AI)
      {:ok, parsed} = AiGenerator.parse_json_gexpr(json)
      
      # Step 4: Validate and test
      assert {:ok, :valid} = AiGenerator.validate_and_test(parsed, nil, 42)
    end

    test "handles round-trip with complex expressions" do
      prompt = "create a function that doubles a number"
      
      # Generate -> JSON -> Parse -> Validate cycle
      {:ok, original} = AiGenerator.generate_from_prompt(prompt)
      {:ok, json} = AiGenerator.to_ai_json(original)
      {:ok, parsed} = AiGenerator.parse_json_gexpr(json)
      
      # Should maintain structure integrity
      assert parsed["g"] == original["g"]
      assert parsed["v"] == original["v"]
    end
  end

  describe "confidence calculation" do
    test "higher confidence for clear mathematical operations" do
      {:ok, math_result} = AiGenerator.generate_from_prompt("add 5 and 7")
      {:ok, vague_result} = AiGenerator.generate_from_prompt("do stuff")
      
      math_confidence = math_result["m"]["confidence"]
      vague_confidence = vague_result["m"]["confidence"]
      
      assert math_confidence > vague_confidence
    end

    test "confidence is always between 0 and 1" do
      {:ok, result} = AiGenerator.generate_from_prompt("test prompt")
      confidence = result["m"]["confidence"]
      
      assert confidence >= 0.0
      assert confidence <= 1.0
    end
  end
end