# Recall Manager PowerShell Tool

This tool provides a simple way to manage the Windows "Recall" feature using DISM commands. It allows users to check the current status of the Recall feature, disable it if it's enabled, and re-enable it if desired. The script also ensures that the necessary execution policy is set, prompting the user to change it if required.

## Features

- **Check Recall Status**: Displays whether the "Recall" feature is currently enabled or disabled.
- **Enable/Disable Recall**: Offers the ability to disable or enable the Recall feature based on the current state.
- **Admin Privileges Check**: Ensures the script is run with administrative rights.
- **Execution Policy Check**: Automatically checks and updates the execution policy to allow scripts to run, prompting the user with a Yes/No option.

## How It Works

The tool leverages the Deployment Image Servicing and Management (DISM) commands to manage the Windows Recall feature. The script prompts the user for action based on the current state of Recall, confirming success after completing the operation. It also ensures the necessary execution policy (`RemoteSigned`) is set before the script can proceed.

### Command Breakdown:

- **Check Recall Status**:

  ```bash
  dism /Online /Get-FeatureInfo /FeatureName:Recall
  ```

- Disable Recall:

  ```
  dism /Online /Disable-Feature /FeatureName:Recall
  ```

- Enable Recall:

  ```
  dism /Online /Enable-Feature /FeatureName:Recall
  ```

## Installation

1. Download or clone the repository:

   ```
   git clone https://github.com/yourusername/RecallManager.git
   ```

2. Ensure you are running the script with Administrator privileges (required by DISM).

3. Execute the script from a PowerShell terminal:

   ```
   ./RecallManager.ps1
   ```

4. If the execution policy is not set to `RemoteSigned`, the script will prompt you to update the policy. You can choose "Yes" to update it and allow the script to run.

## Usage

1. **Run the script as Administrator**:
   - If the script detects it is not being run as an administrator, it will prompt you to run it with the required privileges.
2. **Check and Set Execution Policy**:
   - The script will check if your PowerShell execution policy is set to `RemoteSigned`. If not, it will ask if you want to update the policy to allow script execution.
3. **Check Recall Status**:
   - The script will display whether the "Recall" feature is currently enabled or disabled.
4. **Enable/Disable Recall**:
   - If the Recall feature is enabled, the script will prompt you to disable it.
   - If the Recall feature is disabled, it will offer the option to enable it.
5. **Confirmation**:
   - After the operation, the script will confirm if the action was successfully completed.

## Example Output

```
Recall is currently ENABLED.
Would you like to disable it? (Y/N): Y
Disabling Recall...
[==========================100.0%==========================]
Recall has been successfully disabled.
```

## Requirements

- **Windows 11 or newer**
- **PowerShell 5.1 or newer**
- **Administrator Privileges** to modify system features using DISM.

## Disclaimer

This script modifies system-level settings. **Run at your own risk.** The author of this tool is not responsible for any damage or unintended effects that may result from the use of this script. Ensure that you have backups of your important data and thoroughly understand the script before using it.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more information.

## Contributing

Feel free to fork this repository and submit pull requests for improvements or additional features!

## Author

Created by [Tony Flores](https://github.com/antonflor)
