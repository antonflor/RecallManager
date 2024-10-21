# Function to check and set the execution policy
function Set-ExecutionPolicyIfNeeded {
    $executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
    if ($executionPolicy -ne 'RemoteSigned') {
        Write-Host "Current Execution Policy is: $executionPolicy"
        Write-Host "The script requires the 'RemoteSigned' execution policy to be enabled."
        
        $response = Read-Host "Do you want to set the execution policy to 'RemoteSigned'? (Y/N)"
        if ($response -eq 'Y') {
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
            Write-Host "Execution Policy has been changed to 'RemoteSigned'. You may now run scripts."
        } else {
            Write-Host "Script execution policy not changed. Exiting the script."
            exit
        }
    } else {
        Write-Host "Execution Policy is already set to 'RemoteSigned'. Proceeding with script execution."
    }
}

# Call the function to ensure script execution is allowed
Set-ExecutionPolicyIfNeeded

# Define function to check if Recall is enabled
function Check-Recall {
    $featureInfo = (dism /Online /Get-FeatureInfo /FeatureName:Recall)
    if ($featureInfo -like "*State : Enabled*") {
        Write-Host "Recall is currently ENABLED."
        return $true
    } elseif ($featureInfo -like "*State : Disabled*") {
        Write-Host "Recall is currently DISABLED."
        return $false
    } else {
        Write-Host "Unable to determine the status of Recall."
        return $null
    }
}

# Function to disable Recall
function Disable-Recall {
    Write-Host "Disabling Recall..."
    dism /Online /Disable-Feature /FeatureName:Recall
    if (Check-Recall -eq $false) {
        Write-Host "Recall has been successfully disabled."
    } else {
        Write-Host "Failed to disable Recall."
    }
}

# Function to enable Recall
function Enable-Recall {
    Write-Host "Enabling Recall..."
    dism /Online /Enable-Feature /FeatureName:Recall
    if (Check-Recall -eq $true) {
        Write-Host "Recall has been successfully enabled."
    } else {
        Write-Host "Failed to enable Recall."
    }
}

# Main Script Execution
# Prompt for admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires running as Administrator!"
    Pause
    exit
}

# Check current status of Recall
$status = Check-Recall

if ($status -eq $true) {
    $response = Read-Host "Recall is enabled. Do you want to disable it? (Y/N)"
    if ($response -eq 'Y') {
        Disable-Recall
    } else {
        Write-Host "No changes made."
    }
} elseif ($status -eq $false) {
    $response = Read-Host "Recall is disabled. Do you want to enable it? (Y/N)"
    if ($response -eq 'Y') {
        Enable-Recall
    } else {
        Write-Host "No changes made."
    }
}
