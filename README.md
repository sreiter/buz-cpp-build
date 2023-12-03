# buz-cpp-build

Easy cmake and ninja based c++ builds for SublimeText on windows.

Clone this repository into your SublimeText Packages folder.

# Requirements
- cmake
- ninja
- Visual Studio 2022
- LLVM tools (optional)
- LSP SublimeText plugin (optional)

# LSP code model
A `compile_commands.json` file is generated during the build and copied into your source folder.
It can be used by the Sublime-LSP plugin with clangd for a complete code model in SublimeText.
