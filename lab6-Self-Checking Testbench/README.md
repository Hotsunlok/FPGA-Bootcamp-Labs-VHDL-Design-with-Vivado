## 🧪 Lab 6 – Self-Checking Testbench for Thermostat

This lab extends **Lab 5 – Add Counter to Thermostat** by introducing a **self-checking testbench**.
The goal is to make the testbench more professional, readable, and automated using **procedures** and **assert statements**.

Instead of manually writing long repeated input sequences, we now use a **procedure** (`ApplyInputs`) to simplify stimulus generation, and **assert reports** to describe and verify system behavior at key clock cycles.

---

### 🧰 What’s New in This Lab

In Lab 6, we introduce:

* **Procedures** for simplifying repetitive input sequences

  * The `ApplyInputs` procedure groups all input assignments and delay timing into a single reusable call.
  * This reduces code duplication and improves readability.

* **Structured Testbench Design**

  * The testbench is divided into two clear parts:

    * **RTL Model** – includes the hardware port mapping, signal declarations, and UUT instantiation.
    * **Stimulus Model** – defines the test sequences using the procedure and assertions.

* **`assert` statements** for self-checking and logging

  * `assert false report ... severity note;` is used to display human-readable messages.
  * These messages describe **system states** (e.g., `IDLE`, `COOLON`, `ACNOWREADY`, `ACDONE`)
    and the status of A/C, furnace, fan, and countdown timers at specific clock edges.

* **Automatic simulation termination**

  * The simulation ends automatically when the system returns to the `IDLE` state,
    reported with `severity failure` to signal completion.

---

### 🧠 Mission – Build a Readable and Self-Checking Testbench

The aim of this lab is to make the **testbench intelligent**, so it can:

1. Apply test stimuli systematically using procedures.
2. Report key states and output behavior at the correct clock edges.
3. Stop automatically after verifying that the system returns to IDLE.

This approach makes the testbench easier to understand and maintain, similar to professional verification standards.


---

Would you like me to make it slightly more **formal academic** (like for your dissertation style) or **GitHub-friendly** (like Lab 5 with emojis + sections)?

