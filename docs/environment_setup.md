# Development Environment Setup

## Required tools

The verification workflow requires Git, Verilator for RTL linting, and Icarus Verilog for simulation (`iverilog` and `vvp`). The current checks have been verified with Verilator 5.020 and Icarus 12.0; rerun them when using another version. Icarus provides the four-state simulation used by the X/Z tests. The runner uses a POSIX shell (`sh`), supplied by Linux, WSL Ubuntu, and macOS.

No SKY130 PDK, Python, C++ compiler, synthesis tool, or waveform viewer is needed for these tests. The SKY130 notes describe future implementation targets.

## Windows: Ubuntu under WSL2

1. Open PowerShell as Administrator and install Ubuntu:

   ```powershell
   wsl --install -d Ubuntu
   ```

2. Restart Windows if prompted. Open Ubuntu and complete its Linux username/password setup. If Ubuntu is already installed, reuse it; `wsl --list --verbose` shows installed distributions and their WSL versions.
3. Run the following inside Ubuntu, not PowerShell or Git Bash:

   ```sh
   sudo apt update
   sudo apt install git iverilog verilator
   ```

4. Clone the project using the common instructions below, or enter an existing Windows checkout from Ubuntu. For example:

   ```sh
   cd /mnt/c/Users/lpez/Documents/Development/trama-efpga
   ```

   Replace this example with your own path. Windows drives are exposed under `/mnt/`; quote paths containing spaces. Installing these tools in Ubuntu makes them available inside WSL, not as native PowerShell commands. A checkout inside the Linux home directory is also suitable.

See Microsoft's [WSL installation guide](https://learn.microsoft.com/en-us/windows/wsl/install) for prerequisites and troubleshooting.

## Linux

On Ubuntu or Debian, open a terminal and run:

```sh
sudo apt update
sudo apt install git iverilog verilator
```

On other distributions, install Git, Icarus Verilog, and Verilator through the distribution's package manager. Package names and versions may differ; see the [Icarus installation guide](https://steveicarus.github.io/iverilog/usage/installation.html) if a suitable package is unavailable.

## macOS

Install [Homebrew](https://brew.sh/) if needed, following its instructions, including any Command Line Tools and shell PATH setup. Then open Terminal and run:

```sh
brew install git icarus-verilog verilator
```

The Homebrew package is named `icarus-verilog`; its commands are still `iverilog` and `vvp`. See the Homebrew formulas for [Icarus](https://formulae.brew.sh/formula/icarus-verilog) and [Verilator](https://formulae.brew.sh/formula/verilator).

## Get the repository and verify setup

In your Linux, Ubuntu WSL, or macOS terminal:

```sh
git clone https://github.com/lucapezza/trama-efpga.git
cd trama-efpga
git --version
iverilog -V
vvp -V
verilator --version
```

If you already have a checkout, enter that directory instead of cloning again. If a command is not found, check that installation completed and that you are using the intended terminal and PATH.

Next, follow the [test guide](../tb/test_guide.md). Run its commands from the repository root. Simulation outputs belong in `build/`, which is ignored by Git. Temporary extracted packages used for local checks are not persistent installations; use the installation steps above for normal development.

## Optional tools and current limits

[GTKWave](https://gtkwave.github.io/gtkwave/) can inspect waveforms, but the current testbench does not emit waveform files. Installing a viewer alone does not enable tracing. Verilator lint is part of `sh tb/run_checks.sh`; synthesis and CI workflows are not configured yet. Only `--lint-only` is used, so this workflow does not require compiling a C++ simulation model.

The lint and simulation workflow has been exercised with Verilator 5.020 and Icarus 12.0 under Ubuntu WSL. Linux and macOS installation instructions follow their package-manager workflows; those host environments have not been tested in this repository.
