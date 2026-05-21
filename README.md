# 32-bit Comparator RTL Design and Verification

## Overview

This project implements and verifies a 32-bit Comparator with interrupt generation using Verilog and SystemVerilog.

The design compares a 32-bit `count` value with a programmable `match_counter` value. When both values are equal, the module asserts the `match_int` signal.

The project includes:

* RTL Design
* Constrained-Random Verification
* Functional Coverage
* Scoreboard-Based Checking
* Mailbox Communication
* Waveform Analysis
* RTL Schematic Verification

---

## Features

* 32-bit equality comparison
* Interrupt generation
* Enable-controlled operation
* Power-aware logic
* Asynchronous reset support
* Functional coverage implementation
* Scoreboard-based verification

---

## Verification Architecture

The verification environment includes:

* Generator
* Driver
* Monitor
* Scoreboard
* Functional Coverage
* Interface with clocking blocks

Mailbox-based communication is used between components.

---

## Tools Used

* Verilog HDL
* SystemVerilog
* QuestaSim
* EDA Playground
* EPWave
* Vivado RTL Schematic Viewer

---

## Verification Results

* All test cases passed successfully
* Functional coverage achieved: 100%
* Waveform verification completed
* RTL schematic verified

---

## Project Files

* RTL Design
* Testbench
* Specification Document
* Verification Architecture
* Waveform Output
* Coverage Report
* RTL Schematic

---

## Applications

* Interrupt generation systems
* Timer systems
* FPGA digital designs
* ASIC subsystem verification
* Counter comparison logic

---

## Author

Narasimhamurthy B
