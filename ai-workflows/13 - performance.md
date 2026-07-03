# Workflow 12 — Performance & Optimization

Correctness comes first.

Assume all features are already implemented and all tests pass.

Now optimize the engine.

---

## Rules

Never optimize blindly.

Always:

1. Benchmark.
2. Identify bottlenecks.
3. Explain why they are slow.
4. Propose alternatives.
5. Implement the simplest effective optimization.

---

## Areas to investigate

- parser allocations
- AST memory usage
- recursion
- matcher recursion
- backtracking
- quantifier execution
- capture allocation
- string slicing
- Unicode handling
- table allocations
- hot loops

---

## Constraints

Do not sacrifice readability for marginal performance gains.

Avoid premature optimization.

Prefer removing unnecessary work over adding complexity.

Document every optimization.

---

## Benchmarks

Measure:

- parse speed
- compile speed
- matching speed
- memory usage

Use representative regexes.

Compare before and after.

---

## Deliverables

Produce:

- benchmark report
- optimization report
- code changes
- updated benchmarks
- unchanged behavior
- passing tests