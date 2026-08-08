# Ada Garbage Collection Simulator (Mark & Sweep)

## Project Overview
This repository implements a robust memory simulation and tracing garbage collector based on the [Mark and Sweep](https://en.wikipedia.org/wiki/Mark_and_sweep) algorithm in Ada 2012. Given Ada's native manual/RAII memory management, this project builds a managed heap ecosystem with custom nodes and references to accurately model GC behavior.

## Features
The project implements all primary variants of the Mark and Sweep algorithm:
1. **Naive Recursive Mark and Sweep**: The standard DFS approach. Clean, but susceptible to stack overflows on deeply nested object graphs.
2. **Iterative Mark and Sweep**: Uses an explicit work-stack array instead of the call stack, providing bounded memory guarantees for real-time/embedded systems.
3. **Tri-Color Mark and Sweep (Dijkstra's)**: Categorizes objects into White (condemned), Gray (pending), and Black (survived) sets. Essential for concurrent GC adaptations.

## Testing (Verification & Validation)
This project adheres to rigorous Verification and Validation (V&V) principles tailored for critical systems. 

**Test Philosophy**: *Assume the code is completely broken.* 
A test is considered a "PASS" only when it actively disproves a pessimistic assumption (e.g., assuming a cycle will cause a stack overflow, and proving it doesn't).

### What Each Test Category Verifies:
*   **Functional Correctness (Tests 1-3, 6-9, 10):** Verifies that live roots protect child nodes from reclamation, validating that the software matches basic behavioral requirements.
*   **Edge Cases & Cycles (Tests 4, 5, 8, 11, 12):** Validates the system against infinite loops and memory leaks. In tracing GC, unrooted cyclic references (A->B, B->A) are notoriously difficult to clean; these tests mathematically prove our algorithms identify and reclaim them.
*   **Error Handling & Robustness (Tests 13-15):** Ensures system integrity under adverse conditions (Out of Memory, illegal memory addressing, out-of-bounds references). Critical for preventing arbitrary code execution and memory corruption.

### Why These Tests Matter:
In critical systems, unpredictable memory growth or dangling pointers are fatal. By systematically testing the limits of stack depth, graph cycles, and invalid states, we transition the GC from *“it seems to work”* to a mathematically verifiable mechanism.

## Usage

### Compilation
Ensure you have the GNAT Ada compiler installed (e.g., via `gnat` or `gcc-ada`).

Using **Make**:
```bash
make all
