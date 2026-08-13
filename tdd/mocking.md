# Mocking Strategy for xLLM TDD

Use test doubles only to isolate infrastructure that is expensive, nondeterministic, or unavailable in a narrow test. The assertion should still target xLLM behavior: scheduling decisions, token/cache state, tensor values, service response fields, or backend-visible execution results.

## Decision Rules

- Prefer a real collaborator when it is cheap and deterministic.
- Prefer a fake when the dependency is a whole subsystem but the test only needs a small stable surface.
- Prefer a stub when the dependency must return one or two fixed values.
- Prefer a mock only when the interaction itself is the behavior.
- Avoid mocking a private helper, an internal method chain, or a collaborator just because it is easier to reach.

## Good xLLM Fake: Scheduler Boundary

The scheduler tests in `/workspace/xllm-codex/tests/core/scheduler/chunked_prefill_scheduler_test.cpp` use a small `FakeEngine` instead of starting a model runtime. This is a good fit because the behavior under test is scheduling and KV block accounting, while the real model forward path is irrelevant.

```cpp
class FakeTokenizer : public Tokenizer {
 public:
  std::unique_ptr<Tokenizer> clone() const {
    return std::make_unique<FakeTokenizer>();
  }

  bool encode(const std::string_view& text,
              std::vector<int32_t>* ids,
              bool add_special_tokens) const {
    NOT_IMPLEMENTED();
  }
};

class FakeEngine : public Engine {
 public:
  FakeEngine(int32_t num_blocks, int32_t block_size) {
    BlockManagerPool::Options opt;
    opt.num_blocks_ = num_blocks;
    opt.block_size_ = block_size;
    opt.enable_prefix_cache_ = false;
    fake_tokenizer_ = std::make_unique<FakeTokenizer>();
    fake_block_manager_ = std::make_unique<BlockManagerPool>(opt, 1);
  }

  const Tokenizer* tokenizer() const { return fake_tokenizer_.get(); }
  BlockManagerPool* block_manager_pool() const {
    return fake_block_manager_.get();
  }
  bool init() override { return true; }

 private:
  std::unique_ptr<Tokenizer> fake_tokenizer_;
  std::unique_ptr<BlockManagerPool> fake_block_manager_;
};
```

The useful pattern is not the exact class body. The useful pattern is:

- keep the real `BlockManagerPool`, because the scheduler behavior depends on block availability.
- leave unrelated model execution APIs as `NOT_IMPLEMENTED()`, so accidental test coupling fails loudly.
- assert scheduler outcomes through `add_request(...)`, `prepare_batch_test()`, and remaining block counts.

Example behavior assertion:

```cpp
auto engine = std::make_unique<FakeEngine>(512, 32);
auto scheduler = std::make_unique<ChunkedPrefillScheduler>(engine.get(), opt);

for (auto& req : requests) {
  scheduler->add_request(req);
}

auto total_blocks = util::max(engine->block_manager_pool()->num_free_blocks());
auto batch = scheduler->prepare_batch_test();

EXPECT_EQ(batch.size(), 1);
EXPECT_EQ(batch[0].size(), 3);
EXPECT_EQ(util::max(engine->block_manager_pool()->num_free_blocks()),
          total_blocks - expected_blocks);
```

This test does not check which private helper made the scheduling choice. It checks the observable scheduling result and resource accounting.

## Good xLLM Mock: Collective Boundary

The MLU layer tests in `/workspace/xllm-codex/tests/core/layers/mlu/tests_utils.h` define a reusable `MockProcessGroup`. This is appropriate because distributed collectives are an infrastructure boundary. Tests can inject collective outputs and verify tensor reconstruction without launching real multi-rank communication.

```cpp
class MockProcessGroup : public xllm::ProcessGroup {
 public:
  MockProcessGroup(const torch::Device& device,
                   int64_t rank = 0,
                   int64_t world_size = 1)
      : xllm::ProcessGroup(rank, world_size, device) {
    pg_ = std::make_unique<MockBackend>(rank, world_size);
  }

  void allgather(const torch::Tensor& input,
                 std::vector<torch::Tensor>& outputs) override {
    outputs.resize(this->world_size());
    if (!allgather_outputs_.empty()) {
      CHECK_EQ(allgather_outputs_.size(), outputs.size());
      for (size_t i = 0; i < outputs.size(); ++i) {
        outputs[i] = allgather_outputs_[i].clone();
      }
      return;
    }

    for (size_t i = 0; i < this->world_size(); ++i) {
      outputs[i] = input.clone();
    }
  }

  void set_allgather_outputs(std::vector<torch::Tensor> outputs) {
    allgather_outputs_ = std::move(outputs);
  }

 private:
  std::vector<torch::Tensor> allgather_outputs_;
};
```

The tests in `/workspace/xllm-codex/tests/core/layers/mlu/dp_utils_test.cpp` use the mock to inject rank shards, then assert the public tensor result:

```cpp
auto* mock_pg = dynamic_cast<test::MockProcessGroup*>(process_group.get());
ASSERT_NE(mock_pg, nullptr);

auto shards = make_global_shards(dp_tokens, /*tp_size=*/2);
mock_pg->set_allgather_outputs(shards);

auto output = gather_global_tokens(shards[1], dp_tokens, args);

test::verify_tensor_close(output,
                          torch::tensor({{0.0f},
                                         {1.0f},
                                         {100.0f},
                                         {101.0f}}));
```

This is a good mock because the test does not care whether `gather_global_tokens` calls one helper or another. It cares that uneven DP/TP shards are restored in the correct global order.

## Good Device Fake: Executor Boundary

The CUDA graph executor tests in `/workspace/xllm-codex/tests/core/runtime/cuda_graph_executor_test.cpp` define `FakeAttnCausalLM`, a minimal model that still runs real attention and KV cache paths. This is better than mocking the executor internals because graph capture/replay correctness is only meaningful when compared against an eager execution baseline.

Use this shape when the behavior requires backend execution:

- build the smallest model that exercises the real kernel/runtime path.
- run eager and graph/device modes with the same inputs and cache.
- assert numerical equivalence or expected state transitions.
- skip only when the required device is unavailable.

## Red Flags

- The test fails after renaming or splitting a private helper while xLLM behavior is unchanged.
- The test verifies `EXPECT_CALL(...).Times(1)` for an internal collaborator but never checks tokens, tensors, batches, cache state, or service output.
- The fake returns values that a real xLLM subsystem could not produce.
- The mock hides memory/device/backend constraints that caused the original bug.
- The test needs broad production API changes solely to make private state injectable.

## Checklist

Before committing a test double:

- Name the expensive or nondeterministic boundary being replaced.
- Keep real domain objects on the side of the behavior under test.
- Make unsupported fake methods fail loudly.
- Assert the public outcome, not the internal route.
- Add the helper near the tests unless multiple nearby files already share it.
