# RecallManager

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2011-0078D6.svg?logo=windows)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE.svg?logo=powershell)](https://learn.microsoft.com/powershell/)

A simple PowerShell tool to manage the Windows **Recall** feature using DISM. It checks whether Recall is currently enabled, then lets you disable or enable it interactively — with clear success/failure reporting and a heads-up when a restart is required.

## Features

- **Check Recall status** — shows whether the Recall feature is currently enabled or disabled.
- **Enable/Disable Recall** — prompts you to toggle the feature based on its current state.
- **Reliable result reporting** — uses DISM exit codes to report success, failure, or a pending restart.
- **Admin privileges check** — warns and exits if the script isn't run elevated (required by DISM).

## How It Works

The script uses Deployment Image Servicing and Management (DISM) commands to query and change the Recall optional feature:

- Check Recall status:

  ```powershell
  dism /Online /Get-FeatureInfo /FeatureName:Recall
  ```

- Disable Recall:

  ```powershell
  dism /Online /Disable-Feature /FeatureName:Recall /NoRestart
  ```

- Enable Recall:

  ```powershell
  dism /Online /Enable-Feature /FeatureName:Recall /NoRestart
  ```

Changes to the feature may require a restart to take effect — the script tells you when that's the case (DISM exit code `3010`).

## Installation

1. Download or clone the repository:

   ```powershell
   git clone https://github.com/antonflor/RecallManager.git
   ```

2. Open an **elevated** PowerShell terminal (Run as Administrator — required by DISM).

3. Run the script:

   ```powershell
   .\RecallManager.ps1
   ```

   > If script execution is blocked by your execution policy, you can run it for the current session only with:
   > `powershell -ExecutionPolicy Bypass -File .\RecallManager.ps1`

## Usage

1. Run the script as Administrator. If it isn't elevated, it warns you and exits.
2. The script displays whether Recall is currently **enabled** or **disabled**.
3. Answer the prompt (`Y/N`) to toggle the feature.
4. The script reports the result. If Windows needs a restart to complete the change, it says so.

## Example Output

```
Recall is currently ENABLED.
Recall is enabled. Do you want to disable it? (Y/N): Y
Disabling Recall...
[==========================100.0%==========================]
Recall has been disabled. A RESTART is required to complete the change.
```

## Requirements

- **Windows 11** (a build/edition where the Recall optional feature is available)
- **PowerShell 5.1 or newer**
- **Administrator privileges** (required to modify system features with DISM)

## Disclaimer

This script modifies system-level settings. **Run at your own risk.** The author is not responsible for any damage or unintended effects resulting from its use. Make sure you have backups of important data and understand the script before running it.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

Feel free to fork this repository and submit pull requests for improvements or additional features!

## Author

Created by [Tony Flores](https://github.com/antonflor)
