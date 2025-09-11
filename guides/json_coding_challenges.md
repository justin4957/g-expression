# Coding Challenges in JSON G-Expression Format

This guide provides the same coding challenges from the previous guide, but represented in pure JSON format that can be directly consumed by AI systems, APIs, and cross-platform implementations.

## Table of Contents

1. [JSON Format Specification](#json-format-specification)
2. [Array/List Processing](#arraylist-processing)
3. [String Manipulation](#string-manipulation)
4. [Mathematical Algorithms](#mathematical-algorithms)
5. [Tree and Graph Problems](#tree-and-graph-problems)
6. [Dynamic Programming](#dynamic-programming)
7. [Sorting Algorithms](#sorting-algorithms)
8. [Search Algorithms](#search-algorithms)
9. [Logic Puzzles](#logic-puzzles)
10. [Usage with APIs](#usage-with-apis)

## JSON Format Specification

G-Expressions are represented in JSON using the standard format:

```json
{
  "g": "expression_type",
  "v": "value_or_structure"
}
```

Where `expression_type` can be:
- `"lit"` - Literal values
- `"ref"` - Variable references  
- `"app"` - Function applications
- `"vec"` - Vectors/arrays
- `"lam"` - Lambda functions
- `"fix"` - Fixed-point combinator
- `"match"` - Pattern matching

## Array/List Processing

### Find Maximum Element

**🧠 AI-FRIENDLY REPRESENTATION:** This JSON format enables direct consumption by Large Language Models and API-based code generation systems.

```json
{
  "challenge": "find_maximum_element",
  "description": "Find the maximum element in a list using recursive comparison",
  "gexpression": {
    "g": "fix",
    "v": {
      "g": "lam",
      "v": {
        "params": ["f"],
        "body": {
          "g": "lam",
          "v": {
            "params": ["list"],
            "body": {
              "g": "match",
              "v": {
                "expr": {
                  "g": "app",
                  "v": {
                    "fn": {"g": "ref", "v": "eq?"},
                    "args": {
                      "g": "vec",
                      "v": [
                        {
                          "g": "app",
                          "v": {
                            "fn": {"g": "ref", "v": "cdr"},
                            "args": {"g": "ref", "v": "list"}
                          }
                        },
                        {"g": "lit", "v": []}
                      ]
                    }
                  }
                },
                "branches": [
                  {
                    "pattern": {"lit_pattern": true},
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "car"},
                        "args": {"g": "ref", "v": "list"}
                      }
                    }
                  },
                  {
                    "pattern": "else_pattern",
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "max"},
                        "args": {
                          "g": "vec",
                          "v": [
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "car"},
                                "args": {"g": "ref", "v": "list"}
                              }
                            },
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "f"},
                                "args": {
                                  "g": "app",
                                  "v": {
                                    "fn": {"g": "ref", "v": "cdr"},
                                    "args": {"g": "ref", "v": "list"}
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  },
  "test_case": {
    "input": [3, 1, 4, 1, 5, 9, 2, 6],
    "expected_output": 9
  },
  "complexity": {
    "time": "O(n)",
    "space": "O(n)"
  }
}
```

### Filter Even Numbers

```json
{
  "challenge": "filter_even_numbers",
  "description": "Filter out only even numbers from a list",
  "gexpression": {
    "g": "fix",
    "v": {
      "g": "lam",
      "v": {
        "params": ["f"],
        "body": {
          "g": "lam",
          "v": {
            "params": ["list"],
            "body": {
              "g": "match",
              "v": {
                "expr": {
                  "g": "app",
                  "v": {
                    "fn": {"g": "ref", "v": "eq?"},
                    "args": {
                      "g": "vec",
                      "v": [
                        {"g": "ref", "v": "list"},
                        {"g": "lit", "v": []}
                      ]
                    }
                  }
                },
                "branches": [
                  {
                    "pattern": {"lit_pattern": true},
                    "result": {"g": "lit", "v": []}
                  },
                  {
                    "pattern": "else_pattern",
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "cond"},
                        "args": {
                          "g": "vec",
                          "v": [
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "even?"},
                                "args": {
                                  "g": "app",
                                  "v": {
                                    "fn": {"g": "ref", "v": "car"},
                                    "args": {"g": "ref", "v": "list"}
                                  }
                                }
                              }
                            },
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "cons"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "car"},
                                        "args": {"g": "ref", "v": "list"}
                                      }
                                    },
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "f"},
                                        "args": {
                                          "g": "app",
                                          "v": {
                                            "fn": {"g": "ref", "v": "cdr"},
                                            "args": {"g": "ref", "v": "list"}
                                          }
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            },
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "f"},
                                "args": {
                                  "g": "app",
                                  "v": {
                                    "fn": {"g": "ref", "v": "cdr"},
                                    "args": {"g": "ref", "v": "list"}
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  },
  "test_case": {
    "input": [1, 2, 3, 4, 5, 6, 7, 8],
    "expected_output": [2, 4, 6, 8]
  }
}
```

### Reverse List

```json
{
  "challenge": "reverse_list",
  "description": "Reverse a list using accumulator pattern",
  "gexpression": {
    "g": "lam",
    "v": {
      "params": ["list"],
      "body": {
        "g": "app",
        "v": {
          "fn": {
            "g": "fix",
            "v": {
              "g": "lam",
              "v": {
                "params": ["f"],
                "body": {
                  "g": "lam",
                  "v": {
                    "params": ["lst", "acc"],
                    "body": {
                      "g": "match",
                      "v": {
                        "expr": {
                          "g": "app",
                          "v": {
                            "fn": {"g": "ref", "v": "eq?"},
                            "args": {
                              "g": "vec",
                              "v": [
                                {"g": "ref", "v": "lst"},
                                {"g": "lit", "v": []}
                              ]
                            }
                          }
                        },
                        "branches": [
                          {
                            "pattern": {"lit_pattern": true},
                            "result": {"g": "ref", "v": "acc"}
                          },
                          {
                            "pattern": "else_pattern",
                            "result": {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "f"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "cdr"},
                                        "args": {"g": "ref", "v": "lst"}
                                      }
                                    },
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "cons"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "car"},
                                                "args": {"g": "ref", "v": "lst"}
                                              }
                                            },
                                            {"g": "ref", "v": "acc"}
                                          ]
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            }
                          }
                        ]
                      }
                    }
                  }
                }
              }
            }
          },
          "args": {
            "g": "vec",
            "v": [
              {"g": "ref", "v": "list"},
              {"g": "lit", "v": []}
            ]
          }
        }
      }
    }
  },
  "test_case": {
    "input": [1, 2, 3, 4, 5],
    "expected_output": [5, 4, 3, 2, 1]
  }
}
```

## Mathematical Algorithms

### Greatest Common Divisor (Euclidean Algorithm)

```json
{
  "challenge": "greatest_common_divisor",
  "description": "Euclidean algorithm for finding GCD of two numbers",
  "historical_significance": "Algorithm dates back to 300 BCE - Euclid's Elements",
  "gexpression": {
    "g": "fix",
    "v": {
      "g": "lam",
      "v": {
        "params": ["f"],
        "body": {
          "g": "lam",
          "v": {
            "params": ["a", "b"],
            "body": {
              "g": "match",
              "v": {
                "expr": {
                  "g": "app",
                  "v": {
                    "fn": {"g": "ref", "v": "eq?"},
                    "args": {
                      "g": "vec",
                      "v": [
                        {"g": "ref", "v": "b"},
                        {"g": "lit", "v": 0}
                      ]
                    }
                  }
                },
                "branches": [
                  {
                    "pattern": {"lit_pattern": true},
                    "result": {"g": "ref", "v": "a"}
                  },
                  {
                    "pattern": "else_pattern",
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "f"},
                        "args": {
                          "g": "vec",
                          "v": [
                            {"g": "ref", "v": "b"},
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "mod"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {"g": "ref", "v": "a"},
                                    {"g": "ref", "v": "b"}
                                  ]
                                }
                              }
                            }
                          ]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  },
  "test_cases": [
    {"input": [48, 18], "expected_output": 6},
    {"input": [17, 13], "expected_output": 1},
    {"input": [100, 25], "expected_output": 25}
  ]
}
```

### Prime Number Check

```json
{
  "challenge": "prime_number_check",
  "description": "Check if a number is prime using trial division",
  "gexpression": {
    "g": "lam",
    "v": {
      "params": ["n"],
      "body": {
        "g": "app",
        "v": {
          "fn": {"g": "ref", "v": "cond"},
          "args": {
            "g": "vec",
            "v": [
              {
                "g": "app",
                "v": {
                  "fn": {"g": "ref", "v": "<="},
                  "args": {
                    "g": "vec",
                    "v": [
                      {"g": "ref", "v": "n"},
                      {"g": "lit", "v": 1}
                    ]
                  }
                }
              },
              {"g": "lit", "v": false},
              {
                "g": "app",
                "v": {
                  "fn": {
                    "g": "fix",
                    "v": {
                      "g": "lam",
                      "v": {
                        "params": ["f"],
                        "body": {
                          "g": "lam",
                          "v": {
                            "params": ["num", "divisor"],
                            "body": {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "cond"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": ">"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "*"},
                                                "args": {
                                                  "g": "vec",
                                                  "v": [
                                                    {"g": "ref", "v": "divisor"},
                                                    {"g": "ref", "v": "divisor"}
                                                  ]
                                                }
                                              }
                                            },
                                            {"g": "ref", "v": "num"}
                                          ]
                                        }
                                      }
                                    },
                                    {"g": "lit", "v": true},
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "cond"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "eq?"},
                                                "args": {
                                                  "g": "vec",
                                                  "v": [
                                                    {
                                                      "g": "app",
                                                      "v": {
                                                        "fn": {"g": "ref", "v": "mod"},
                                                        "args": {
                                                          "g": "vec",
                                                          "v": [
                                                            {"g": "ref", "v": "num"},
                                                            {"g": "ref", "v": "divisor"}
                                                          ]
                                                        }
                                                      }
                                                    },
                                                    {"g": "lit", "v": 0}
                                                  ]
                                                }
                                              }
                                            },
                                            {"g": "lit", "v": false},
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "f"},
                                                "args": {
                                                  "g": "vec",
                                                  "v": [
                                                    {"g": "ref", "v": "num"},
                                                    {
                                                      "g": "app",
                                                      "v": {
                                                        "fn": {"g": "ref", "v": "+"},
                                                        "args": {
                                                          "g": "vec",
                                                          "v": [
                                                            {"g": "ref", "v": "divisor"},
                                                            {"g": "lit", "v": 1}
                                                          ]
                                                        }
                                                      }
                                                    }
                                                  ]
                                                }
                                              }
                                            }
                                          ]
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  },
                  "args": {
                    "g": "vec",
                    "v": [
                      {"g": "ref", "v": "n"},
                      {"g": "lit", "v": 2}
                    ]
                  }
                }
              }
            ]
          }
        }
      }
    }
  },
  "test_cases": [
    {"input": 2, "expected_output": true},
    {"input": 17, "expected_output": true},
    {"input": 15, "expected_output": false},
    {"input": 97, "expected_output": true}
  ]
}
```

### Fibonacci Sequence

```json
{
  "challenge": "fibonacci_sequence",
  "description": "Calculate fibonacci numbers using Y-combinator",
  "mathematical_significance": "Demonstrates the Golden Ratio and natural recursive patterns",
  "gexpression": {
    "g": "fix",
    "v": {
      "g": "lam",
      "v": {
        "params": ["f"],
        "body": {
          "g": "lam",
          "v": {
            "params": ["n"],
            "body": {
              "g": "match",
              "v": {
                "expr": {
                  "g": "app",
                  "v": {
                    "fn": {"g": "ref", "v": "<="},
                    "args": {
                      "g": "vec",
                      "v": [
                        {"g": "ref", "v": "n"},
                        {"g": "lit", "v": 1}
                      ]
                    }
                  }
                },
                "branches": [
                  {
                    "pattern": {"lit_pattern": true},
                    "result": {"g": "ref", "v": "n"}
                  },
                  {
                    "pattern": "else_pattern",
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "+"},
                        "args": {
                          "g": "vec",
                          "v": [
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "f"},
                                "args": {
                                  "g": "app",
                                  "v": {
                                    "fn": {"g": "ref", "v": "-"},
                                    "args": {
                                      "g": "vec",
                                      "v": [
                                        {"g": "ref", "v": "n"},
                                        {"g": "lit", "v": 1}
                                      ]
                                    }
                                  }
                                }
                              }
                            },
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "f"},
                                "args": {
                                  "g": "app",
                                  "v": {
                                    "fn": {"g": "ref", "v": "-"},
                                    "args": {
                                      "g": "vec",
                                      "v": [
                                        {"g": "ref", "v": "n"},
                                        {"g": "lit", "v": 2}
                                      ]
                                    }
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  },
  "test_cases": [
    {"input": 0, "expected_output": 0},
    {"input": 1, "expected_output": 1},
    {"input": 5, "expected_output": 5},
    {"input": 8, "expected_output": 21}
  ]
}
```

## Dynamic Programming

### Longest Common Subsequence

```json
{
  "challenge": "longest_common_subsequence",
  "description": "Find the longest common subsequence between two sequences",
  "applications": ["DNA sequence analysis", "Version control diff algorithms", "Text similarity"],
  "gexpression": {
    "g": "fix",
    "v": {
      "g": "lam",
      "v": {
        "params": ["f"],
        "body": {
          "g": "lam",
          "v": {
            "params": ["s1", "s2"],
            "body": {
              "g": "match",
              "v": {
                "expr": {
                  "g": "app",
                  "v": {
                    "fn": {"g": "ref", "v": "or"},
                    "args": {
                      "g": "vec",
                      "v": [
                        {
                          "g": "app",
                          "v": {
                            "fn": {"g": "ref", "v": "empty?"},
                            "args": {"g": "ref", "v": "s1"}
                          }
                        },
                        {
                          "g": "app",
                          "v": {
                            "fn": {"g": "ref", "v": "empty?"},
                            "args": {"g": "ref", "v": "s2"}
                          }
                        }
                      ]
                    }
                  }
                },
                "branches": [
                  {
                    "pattern": {"lit_pattern": true},
                    "result": {"g": "lit", "v": []}
                  },
                  {
                    "pattern": "else_pattern",
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "cond"},
                        "args": {
                          "g": "vec",
                          "v": [
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "eq?"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "car"},
                                        "args": {"g": "ref", "v": "s1"}
                                      }
                                    },
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "car"},
                                        "args": {"g": "ref", "v": "s2"}
                                      }
                                    }
                                  ]
                                }
                              }
                            },
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "cons"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "car"},
                                        "args": {"g": "ref", "v": "s1"}
                                      }
                                    },
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "f"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "cdr"},
                                                "args": {"g": "ref", "v": "s1"}
                                              }
                                            },
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "cdr"},
                                                "args": {"g": "ref", "v": "s2"}
                                              }
                                            }
                                          ]
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            },
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "longer"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "f"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "cdr"},
                                                "args": {"g": "ref", "v": "s1"}
                                              }
                                            },
                                            {"g": "ref", "v": "s2"}
                                          ]
                                        }
                                      }
                                    },
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "f"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {"g": "ref", "v": "s1"},
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "cdr"},
                                                "args": {"g": "ref", "v": "s2"}
                                              }
                                            }
                                          ]
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            }
                          ]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  },
  "test_case": {
    "input": [["A", "B", "C", "D", "G", "H"], ["A", "E", "D", "F", "H", "R"]],
    "expected_output": ["A", "D", "H"]
  }
}
```

## Sorting Algorithms

### Quick Sort

```json
{
  "challenge": "quicksort",
  "description": "Divide-and-conquer sorting algorithm",
  "inventor": "Tony Hoare (1960)",
  "average_complexity": "O(n log n)",
  "gexpression": {
    "partition_function": {
      "g": "fix",
      "v": {
        "g": "lam",
        "v": {
          "params": ["f"],
          "body": {
            "g": "lam",
            "v": {
              "params": ["pivot", "list", "less", "greater"],
              "body": {
                "g": "match",
                "v": {
                  "expr": {
                    "g": "app",
                    "v": {
                      "fn": {"g": "ref", "v": "empty?"},
                      "args": {"g": "ref", "v": "list"}
                    }
                  },
                  "branches": [
                    {
                      "pattern": {"lit_pattern": true},
                      "result": {
                        "g": "app",
                        "v": {
                          "fn": {"g": "ref", "v": "make_pair"},
                          "args": {
                            "g": "vec",
                            "v": [
                              {"g": "ref", "v": "less"},
                              {"g": "ref", "v": "greater"}
                            ]
                          }
                        }
                      }
                    },
                    {
                      "pattern": "else_pattern",
                      "result": {
                        "g": "app",
                        "v": {
                          "fn": {"g": "ref", "v": "cond"},
                          "args": {
                            "g": "vec",
                            "v": [
                              {
                                "g": "app",
                                "v": {
                                  "fn": {"g": "ref", "v": "<"},
                                  "args": {
                                    "g": "vec",
                                    "v": [
                                      {
                                        "g": "app",
                                        "v": {
                                          "fn": {"g": "ref", "v": "car"},
                                          "args": {"g": "ref", "v": "list"}
                                        }
                                      },
                                      {"g": "ref", "v": "pivot"}
                                    ]
                                  }
                                }
                              },
                              {
                                "g": "app",
                                "v": {
                                  "fn": {"g": "ref", "v": "f"},
                                  "args": {
                                    "g": "vec",
                                    "v": [
                                      {"g": "ref", "v": "pivot"},
                                      {
                                        "g": "app",
                                        "v": {
                                          "fn": {"g": "ref", "v": "cdr"},
                                          "args": {"g": "ref", "v": "list"}
                                        }
                                      },
                                      {
                                        "g": "app",
                                        "v": {
                                          "fn": {"g": "ref", "v": "cons"},
                                          "args": {
                                            "g": "vec",
                                            "v": [
                                              {
                                                "g": "app",
                                                "v": {
                                                  "fn": {"g": "ref", "v": "car"},
                                                  "args": {"g": "ref", "v": "list"}
                                                }
                                              },
                                              {"g": "ref", "v": "less"}
                                            ]
                                          }
                                        }
                                      },
                                      {"g": "ref", "v": "greater"}
                                    ]
                                  }
                                }
                              },
                              {
                                "g": "app",
                                "v": {
                                  "fn": {"g": "ref", "v": "f"},
                                  "args": {
                                    "g": "vec",
                                    "v": [
                                      {"g": "ref", "v": "pivot"},
                                      {
                                        "g": "app",
                                        "v": {
                                          "fn": {"g": "ref", "v": "cdr"},
                                          "args": {"g": "ref", "v": "list"}
                                        }
                                      },
                                      {"g": "ref", "v": "less"},
                                      {
                                        "g": "app",
                                        "v": {
                                          "fn": {"g": "ref", "v": "cons"},
                                          "args": {
                                            "g": "vec",
                                            "v": [
                                              {
                                                "g": "app",
                                                "v": {
                                                  "fn": {"g": "ref", "v": "car"},
                                                  "args": {"g": "ref", "v": "list"}
                                                }
                                              },
                                              {"g": "ref", "v": "greater"}
                                            ]
                                          }
                                        }
                                      }
                                    ]
                                  }
                                }
                              }
                            ]
                          }
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      }
    },
    "quicksort_function": {
      "g": "fix",
      "v": {
        "g": "lam",
        "v": {
          "params": ["f"],
          "body": {
            "g": "lam",
            "v": {
              "params": ["list"],
              "body": {
                "g": "match",
                "v": {
                  "expr": {
                    "g": "app",
                    "v": {
                      "fn": {"g": "ref", "v": "or"},
                      "args": {
                        "g": "vec",
                        "v": [
                          {
                            "g": "app",
                            "v": {
                              "fn": {"g": "ref", "v": "empty?"},
                              "args": {"g": "ref", "v": "list"}
                            }
                          },
                          {
                            "g": "app",
                            "v": {
                              "fn": {"g": "ref", "v": "empty?"},
                              "args": {
                                "g": "app",
                                "v": {
                                  "fn": {"g": "ref", "v": "cdr"},
                                  "args": {"g": "ref", "v": "list"}
                                }
                              }
                            }
                          }
                        ]
                      }
                    }
                  },
                  "branches": [
                    {
                      "pattern": {"lit_pattern": true},
                      "result": {"g": "ref", "v": "list"}
                    },
                    {
                      "pattern": "else_pattern",
                      "result": {
                        "g": "app",
                        "v": {
                          "fn": {"g": "ref", "v": "append"},
                          "args": {
                            "g": "vec",
                            "v": [
                              {
                                "g": "app",
                                "v": {
                                  "fn": {"g": "ref", "v": "f"},
                                  "args": {"g": "ref", "v": "partitioned_less"}
                                }
                              },
                              {
                                "g": "app",
                                "v": {
                                  "fn": {"g": "ref", "v": "cons"},
                                  "args": {
                                    "g": "vec",
                                    "v": [
                                      {
                                        "g": "app",
                                        "v": {
                                          "fn": {"g": "ref", "v": "car"},
                                          "args": {"g": "ref", "v": "list"}
                                        }
                                      },
                                      {
                                        "g": "app",
                                        "v": {
                                          "fn": {"g": "ref", "v": "f"},
                                          "args": {"g": "ref", "v": "partitioned_greater"}
                                        }
                                      }
                                    ]
                                  }
                                }
                              }
                            ]
                          }
                        }
                      }
                    }
                  ]
                }
              }
            }
          }
        }
      }
    }
  },
  "test_case": {
    "input": [3, 1, 4, 1, 5, 9, 2, 6],
    "expected_output": [1, 1, 2, 3, 4, 5, 6, 9]
  }
}
```

## Logic Puzzles

### Tower of Hanoi

```json
{
  "challenge": "tower_of_hanoi",
  "description": "Classic recursive puzzle - move disks between towers",
  "historical_context": "Invented by French mathematician Édouard Lucas in 1883",
  "legend": "Brahmin priests moving 64 golden disks - when complete, the world ends",
  "mathematical_property": "Minimum moves = 2^n - 1",
  "gexpression": {
    "g": "fix",
    "v": {
      "g": "lam",
      "v": {
        "params": ["f"],
        "body": {
          "g": "lam",
          "v": {
            "params": ["n", "from", "to", "aux"],
            "body": {
              "g": "match",
              "v": {
                "expr": {
                  "g": "app",
                  "v": {
                    "fn": {"g": "ref", "v": "eq?"},
                    "args": {
                      "g": "vec",
                      "v": [
                        {"g": "ref", "v": "n"},
                        {"g": "lit", "v": 1}
                      ]
                    }
                  }
                },
                "branches": [
                  {
                    "pattern": {"lit_pattern": true},
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "cons"},
                        "args": {
                          "g": "vec",
                          "v": [
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "make_move"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {"g": "ref", "v": "from"},
                                    {"g": "ref", "v": "to"}
                                  ]
                                }
                              }
                            },
                            {"g": "lit", "v": []}
                          ]
                        }
                      }
                    }
                  },
                  {
                    "pattern": "else_pattern",
                    "result": {
                      "g": "app",
                      "v": {
                        "fn": {"g": "ref", "v": "append"},
                        "args": {
                          "g": "vec",
                          "v": [
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "f"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "-"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {"g": "ref", "v": "n"},
                                            {"g": "lit", "v": 1}
                                          ]
                                        }
                                      }
                                    },
                                    {"g": "ref", "v": "from"},
                                    {"g": "ref", "v": "aux"},
                                    {"g": "ref", "v": "to"}
                                  ]
                                }
                              }
                            },
                            {
                              "g": "app",
                              "v": {
                                "fn": {"g": "ref", "v": "append"},
                                "args": {
                                  "g": "vec",
                                  "v": [
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "cons"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "make_move"},
                                                "args": {
                                                  "g": "vec",
                                                  "v": [
                                                    {"g": "ref", "v": "from"},
                                                    {"g": "ref", "v": "to"}
                                                  ]
                                                }
                                              }
                                            },
                                            {"g": "lit", "v": []}
                                          ]
                                        }
                                      }
                                    },
                                    {
                                      "g": "app",
                                      "v": {
                                        "fn": {"g": "ref", "v": "f"},
                                        "args": {
                                          "g": "vec",
                                          "v": [
                                            {
                                              "g": "app",
                                              "v": {
                                                "fn": {"g": "ref", "v": "-"},
                                                "args": {
                                                  "g": "vec",
                                                  "v": [
                                                    {"g": "ref", "v": "n"},
                                                    {"g": "lit", "v": 1}
                                                  ]
                                                }
                                              }
                                            },
                                            {"g": "ref", "v": "aux"},
                                            {"g": "ref", "v": "to"},
                                            {"g": "ref", "v": "from"}
                                          ]
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            }
                          ]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  },
  "test_cases": [
    {
      "input": [1, "A", "C", "B"],
      "expected_output": [{"from": "A", "to": "C"}]
    },
    {
      "input": [2, "A", "C", "B"],
      "expected_output": [
        {"from": "A", "to": "B"},
        {"from": "A", "to": "C"},
        {"from": "B", "to": "C"}
      ]
    }
  ],
  "complexity": {
    "time": "O(2^n)",
    "space": "O(n)",
    "optimal_moves": "2^n - 1"
  }
}
```

## Usage with APIs

### Python Usage Example

```python
import json
import requests

# Load a G-Expression challenge
with open('gcd_challenge.json') as f:
    challenge = json.load(f)

# Send to G-Expression evaluation API
response = requests.post('https://api.gexpr.ai/evaluate', json={
    'gexpression': challenge['gexpression'],
    'arguments': [48, 18],
    'context': 'enhanced'
})

result = response.json()
print(f"GCD(48, 18) = {result['value']}")  # Should output 6
```

### JavaScript Usage Example

```javascript
const fs = require('fs');

// Load multiple challenges
const challenges = [
    JSON.parse(fs.readFileSync('max_element.json')),
    JSON.parse(fs.readFileSync('prime_check.json')),
    JSON.parse(fs.readFileSync('fibonacci.json'))
];

// Process challenges in parallel
const results = await Promise.all(
    challenges.map(async (challenge) => {
        const response = await fetch('https://api.gexpr.ai/evaluate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                gexpression: challenge.gexpression,
                test_cases: challenge.test_cases
            })
        });
        return response.json();
    })
);

console.log('All challenge results:', results);
```

### Elixir Usage Example

```elixir
# Parse JSON G-Expression and convert to internal format
json_gexpr = File.read!("fibonacci.json") |> Jason.decode!()
internal_gexpr = Gexpr.from_json(json_gexpr["gexpression"])

# Evaluate with context
{:ok, context} = Gexpr.bootstrap_enhanced()
{:ok, result} = Gexpr.eval(internal_gexpr, context, [8])

IO.puts("Fibonacci(8) = #{result}")  # Should output 21
```

### REST API Endpoint Specification

```json
{
  "endpoint": "/api/v1/gexpression/evaluate",
  "method": "POST",
  "content_type": "application/json",
  "request_body": {
    "gexpression": {
      "description": "The G-Expression in JSON format",
      "type": "object",
      "required": true
    },
    "arguments": {
      "description": "Array of arguments to pass to the function",
      "type": "array",
      "required": false
    },
    "context": {
      "description": "Context level: 'basic', 'enhanced', or 'full'",
      "type": "string",
      "default": "basic"
    },
    "compile_target": {
      "description": "Optional compilation target: 'javascript', 'python', etc.",
      "type": "string",
      "required": false
    }
  },
  "response": {
    "success": {"type": "boolean"},
    "result": {"type": "any"},
    "execution_time_ms": {"type": "number"},
    "compiled_code": {"type": "string", "description": "If compile_target specified"},
    "error": {"type": "string", "description": "If success is false"}
  }
}
```

## Philosophical Significance of JSON Representation

**🧠 UNIVERSAL INTEROPERABILITY:** JSON format enables G-expressions to serve as a true lingua franca between:

1. **AI Systems** - Large Language Models can generate and manipulate G-expressions directly
2. **Cross-Platform APIs** - Any language with JSON support can process G-expressions
3. **Distributed Computing** - G-expressions become network-serializable computational units
4. **Version Control** - Git can track algorithmic changes at the semantic level
5. **Documentation Systems** - Algorithms become self-documenting through structured metadata

**🧠 COMPUTATIONAL ARCHAEOLOGY:** This JSON representation creates a permanent, human-readable record of algorithmic thinking that can be:

- **Analyzed by future AI systems** for pattern recognition
- **Translated between programming paradigms** automatically  
- **Verified for correctness** through formal methods
- **Optimized across target platforms** while preserving semantics
- **Composed into larger systems** through modular assembly

**🧠 AI-NATIVE PROGRAMMING:** These JSON G-expressions represent the future of AI-assisted development:

- **Prompt-to-Code**: AI generates G-expressions from natural language
- **Code-to-Explanation**: G-expressions provide semantic clarity for AI analysis  
- **Cross-Language Migration**: One specification, infinite implementations
- **Automated Optimization**: AI can reason about and improve G-expression structures
- **Formal Verification**: Mathematical properties can be proven directly on G-expressions

This JSON representation proves that G-expressions successfully bridge the gap between human algorithmic thinking, AI reasoning capabilities, and practical computational execution across all platforms.