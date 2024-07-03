# Pipelined Floating Point Multiplication and Hardware Testing Techniques in Verilog

This project involves two major sections: the implementation of pipelined floating-point multiplication and the implementation of hardware testing techniques such as Random Test Socket (RTS) and STUMPS using Verilog.

## Section 1: Pipelined Floating Point Multiplication

### Overview

A pipelined floating-point multiplier is implemented using Verilog. The design uses a 4-stage pipeline to perform multiplication operations on floating-point numbers. 

### Pipeline Stages

1. **Stage 1: Exponent Alignment**
    - Exponents of the two numbers are aligned.
    - The difference between the exponents is calculated.
    - The aligned exponent is adjusted.

2. **Stage 2: Mantissa Multiplication**
    - The mantissas of the two numbers are multiplied.
    - Intermediate results are stored and prepared for normalization.

3. **Stage 3: Normalization**
    - The product is normalized.
    - The result is adjusted to fit the floating-point format.

4. **Stage 4: Result Composition**
    - The final floating-point result is composed.
    - The result is written back to the destination register.

### Testing

The pipelined floating-point multiplier is tested using various test cases to ensure correct functionality. The tests include:

1. **Exponent Alignment Verification**.
2. **Mantissa Multiplication Accuracy**.
3. **Normalization Correctness**.
4. **Final Result Validation**.

## Section 2: Hardware Testing Techniques (RTS and STUMPS)

### Overview

This section implements hardware testing techniques using Verilog, specifically Random Test Socket (RTS) and STUMPS (Self-Test Using Multiple-Input Signature Analysis).

### Random Test Socket (RTS)

RTS uses a Pseudo-Random Pattern Generator (PRPG) and a Multiple Input Signature Register (MISR) at the primary inputs and outputs of the Circuit Under Test (CUT). Additionally, it includes:

- **SRSG**: Pseudo-random scan input generator.
- **SISA**: Serial input signature analyzer.

### STUMPS Structure

STUMPS uses three separate scan chains driven by the parallel output of a PRPG. This results in pseudo-random serial test data shifting into the scan chains. The structure includes:

- **MISR**: Collects output responses.
- **PRPG**: Provides input test data.

### Key Components

- **MISR (Multiple Input Signature Register)**: Used for output response analysis.
- **SISA (Serial Input Signature Analyzer)**: Similar to SISR, used for generating signatures.
- **PRPG (Pseudo Random Pattern Generator)**: LFSR-based TPG with parallel outputs.
- **SRSG (Pseudo Random Sequence Generator)**: LFSR-based TPG with a single serial output.

### Testing Process

1. **Initialization**:
    - PRPG and MISR are initialized.
    - The BIST controller asserts NbarT to apply PRPG output to the CUT’s primary inputs.

2. **Test Execution**:
    - The CUT’s clock is applied, and primary outputs are clocked into the MISR.
    - The PRPG generates a new input vector for the next test round.
    - The MISR collects the output of the current test.

3. **Signature Comparison**:
    - The BIST controller compares SISA and MISR outputs with expected signatures at the end of each test round.

## Reference

The design and testing techniques are based on the book "Digital System Test and Testable Design" by Prof. Zeinolabedin Navabi.

## Important Note

The provided Verilog codes do not include netlist and fault collapsing files. To use these components, you must modify the code accordingly.

## Conclusion

This project demonstrates the implementation of a pipelined floating-point multiplier and hardware testing techniques using Verilog. The RTS and STUMPS methods provide efficient ways to test digital circuits, ensuring reliability and correctness.

