<#
.SYNOPSIS
    Timestamp_Changer - A GUI tool for modifying file timestamps in Windows

.DESCRIPTION
    This PowerShell script provides a user-friendly graphical interface for changing 
    file creation, modification, and access timestamps. Users can browse for files, 
    select custom dates and times, and choose which timestamps to modify.

.NOTES
    File Name      : Timestamp_Changer.ps1
    Author         : pjhiggins
    Email          : pjhiggins@gmail.com
    Prerequisite   : PowerShell 5.0 or higher
    Version        : 1.0
    Date           : 2025-06-20
    License        : MIT License

.EXAMPLE
    .\Timestamp_Changer.ps1
    Launches the GUI application for modifying file timestamps.

.LINK
    https://github.com/pjhiggins

.LICENSE
    MIT License
    
    Copyright (c) 2025 pjhiggins
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

# Hide the PowerShell console window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) # 0 = hide

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "File Timestamp Changer"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# File selection group
$fileGroupBox = New-Object System.Windows.Forms.GroupBox
$fileGroupBox.Location = New-Object System.Drawing.Point(10, 10)
$fileGroupBox.Size = New-Object System.Drawing.Size(460, 80)
$fileGroupBox.Text = "File Selection"

# File path textbox
$fileTextBox = New-Object System.Windows.Forms.TextBox
$fileTextBox.Location = New-Object System.Drawing.Point(10, 25)
$fileTextBox.Size = New-Object System.Drawing.Size(350, 20)
$fileTextBox.ReadOnly = $true

# Browse button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(370, 23)
$browseButton.Size = New-Object System.Drawing.Size(80, 25)
$browseButton.Text = "Browse..."

# File info label
$fileInfoLabel = New-Object System.Windows.Forms.Label
$fileInfoLabel.Location = New-Object System.Drawing.Point(10, 50)
$fileInfoLabel.Size = New-Object System.Drawing.Size(440, 20)
$fileInfoLabel.Text = "No file selected"
$fileInfoLabel.ForeColor = [System.Drawing.Color]::Gray

# Add controls to file group
$fileGroupBox.Controls.Add($fileTextBox)
$fileGroupBox.Controls.Add($browseButton)
$fileGroupBox.Controls.Add($fileInfoLabel)

# Date/Time selection group
$dateTimeGroupBox = New-Object System.Windows.Forms.GroupBox
$dateTimeGroupBox.Location = New-Object System.Drawing.Point(10, 100)
$dateTimeGroupBox.Size = New-Object System.Drawing.Size(460, 120)
$dateTimeGroupBox.Text = "Date and Time Selection"

# Date picker
$dateLabel = New-Object System.Windows.Forms.Label
$dateLabel.Location = New-Object System.Drawing.Point(10, 25)
$dateLabel.Size = New-Object System.Drawing.Size(40, 20)
$dateLabel.Text = "Date:"

$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = New-Object System.Drawing.Point(55, 23)
$datePicker.Size = New-Object System.Drawing.Size(200, 20)
$datePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Short

# Time picker
$timeLabel = New-Object System.Windows.Forms.Label
$timeLabel.Location = New-Object System.Drawing.Point(270, 25)
$timeLabel.Size = New-Object System.Drawing.Size(40, 20)
$timeLabel.Text = "Time:"

$timePicker = New-Object System.Windows.Forms.DateTimePicker
$timePicker.Location = New-Object System.Drawing.Point(315, 23)
$timePicker.Size = New-Object System.Drawing.Size(130, 20)
$timePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Time
$timePicker.ShowUpDown = $true

# Current time button
$currentTimeButton = New-Object System.Windows.Forms.Button
$currentTimeButton.Location = New-Object System.Drawing.Point(10, 55)
$currentTimeButton.Size = New-Object System.Drawing.Size(120, 25)
$currentTimeButton.Text = "Use Current Time"

# Original time button
$originalTimeButton = New-Object System.Windows.Forms.Button
$originalTimeButton.Location = New-Object System.Drawing.Point(140, 55)
$originalTimeButton.Size = New-Object System.Drawing.Size(120, 25)
$originalTimeButton.Text = "Use Original Time"
$originalTimeButton.Enabled = $false

# Reset button
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Location = New-Object System.Drawing.Point(270, 55)
$resetButton.Size = New-Object System.Drawing.Size(80, 25)
$resetButton.Text = "Reset"

# Add controls to date/time group
$dateTimeGroupBox.Controls.Add($dateLabel)
$dateTimeGroupBox.Controls.Add($datePicker)
$dateTimeGroupBox.Controls.Add($timeLabel)
$dateTimeGroupBox.Controls.Add($timePicker)
$dateTimeGroupBox.Controls.Add($currentTimeButton)
$dateTimeGroupBox.Controls.Add($originalTimeButton)
$dateTimeGroupBox.Controls.Add($resetButton)

# Timestamp options group
$optionsGroupBox = New-Object System.Windows.Forms.GroupBox
$optionsGroupBox.Location = New-Object System.Drawing.Point(10, 230)
$optionsGroupBox.Size = New-Object System.Drawing.Size(460, 80)
$optionsGroupBox.Text = "Timestamp Options"

# Checkboxes for timestamp types
$creationCheckBox = New-Object System.Windows.Forms.CheckBox
$creationCheckBox.Location = New-Object System.Drawing.Point(10, 25)
$creationCheckBox.Size = New-Object System.Drawing.Size(120, 20)
$creationCheckBox.Text = "Creation Time"
$creationCheckBox.Checked = $true

$modifiedCheckBox = New-Object System.Windows.Forms.CheckBox
$modifiedCheckBox.Location = New-Object System.Drawing.Point(140, 25)
$modifiedCheckBox.Size = New-Object System.Drawing.Size(120, 20)
$modifiedCheckBox.Text = "Modified Time"
$modifiedCheckBox.Checked = $true

$accessedCheckBox = New-Object System.Windows.Forms.CheckBox
$accessedCheckBox.Location = New-Object System.Drawing.Point(270, 25)
$accessedCheckBox.Size = New-Object System.Drawing.Size(120, 20)
$accessedCheckBox.Text = "Accessed Time"
$accessedCheckBox.Checked = $true

# Select/Deselect all buttons
$selectAllButton = New-Object System.Windows.Forms.Button
$selectAllButton.Location = New-Object System.Drawing.Point(10, 50)
$selectAllButton.Size = New-Object System.Drawing.Size(80, 25)
$selectAllButton.Text = "Select All"

$deselectAllButton = New-Object System.Windows.Forms.Button
$deselectAllButton.Location = New-Object System.Drawing.Point(100, 50)
$deselectAllButton.Size = New-Object System.Drawing.Size(80, 25)
$deselectAllButton.Text = "Deselect All"

# Add controls to options group
$optionsGroupBox.Controls.Add($creationCheckBox)
$optionsGroupBox.Controls.Add($modifiedCheckBox)
$optionsGroupBox.Controls.Add($accessedCheckBox)
$optionsGroupBox.Controls.Add($selectAllButton)
$optionsGroupBox.Controls.Add($deselectAllButton)

# Action buttons
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Location = New-Object System.Drawing.Point(300, 320)
$applyButton.Size = New-Object System.Drawing.Size(80, 30)
$applyButton.Text = "Apply"
$applyButton.BackColor = [System.Drawing.Color]::LightGreen
$applyButton.Enabled = $false

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Location = New-Object System.Drawing.Point(390, 320)
$closeButton.Size = New-Object System.Drawing.Size(80, 30)
$closeButton.Text = "Close"

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 330)
$statusLabel.Size = New-Object System.Drawing.Size(280, 20)
$statusLabel.Text = "Ready"
$statusLabel.ForeColor = [System.Drawing.Color]::Blue

# Add all controls to form
$form.Controls.Add($fileGroupBox)
$form.Controls.Add($dateTimeGroupBox)
$form.Controls.Add($optionsGroupBox)
$form.Controls.Add($applyButton)
$form.Controls.Add($closeButton)
$form.Controls.Add($statusLabel)

# Global variables - using script scope
$script:selectedFile = $null
$script:originalCreationTime = $null
$script:originalModifiedTime = $null
$script:originalAccessedTime = $null

# Event handlers
$browseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "Select a file to modify"
    $openFileDialog.Filter = "All files (*.*)|*.*"
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $script:selectedFile = Get-Item $openFileDialog.FileName
        $fileTextBox.Text = $script:selectedFile.FullName
        
        # Store original timestamps
        $script:originalCreationTime = $script:selectedFile.CreationTime
        $script:originalModifiedTime = $script:selectedFile.LastWriteTime
        $script:originalAccessedTime = $script:selectedFile.LastAccessTime
        
        # Update file info
        $fileInfoLabel.Text = "Size: {0:N0} bytes | Created: {1} | Modified: {2}" -f $script:selectedFile.Length, $script:selectedFile.CreationTime.ToString("yyyy-MM-dd HH:mm:ss"), $script:selectedFile.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        $fileInfoLabel.ForeColor = [System.Drawing.Color]::Black
        
        # Enable buttons
        $applyButton.Enabled = $true
        $originalTimeButton.Enabled = $true
        
        $statusLabel.Text = "File selected: " + $script:selectedFile.Name
        $statusLabel.ForeColor = [System.Drawing.Color]::Blue
    }
})

$currentTimeButton.Add_Click({
    $now = Get-Date
    $datePicker.Value = $now.Date
    $timePicker.Value = $now
    $statusLabel.Text = "Set to current time"
    $statusLabel.ForeColor = [System.Drawing.Color]::Blue
})

$originalTimeButton.Add_Click({
    if ($script:selectedFile) {
        $datePicker.Value = $script:originalModifiedTime.Date
        $timePicker.Value = $script:originalModifiedTime
        $statusLabel.Text = "Set to original file time"
        $statusLabel.ForeColor = [System.Drawing.Color]::Blue
    }
})

$resetButton.Add_Click({
    $datePicker.Value = Get-Date
    $timePicker.Value = Get-Date
    $statusLabel.Text = "Date/time reset"
    $statusLabel.ForeColor = [System.Drawing.Color]::Blue
})

$selectAllButton.Add_Click({
    $creationCheckBox.Checked = $true
    $modifiedCheckBox.Checked = $true
    $accessedCheckBox.Checked = $true
})

$deselectAllButton.Add_Click({
    $creationCheckBox.Checked = $false
    $modifiedCheckBox.Checked = $false
    $accessedCheckBox.Checked = $false
})

$applyButton.Add_Click({
    # Check if file is selected (check both script variable and textbox)
    if (-not $script:selectedFile -or [string]::IsNullOrEmpty($fileTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a file first.", "No File Selected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    # Verify file still exists
    if (-not (Test-Path $script:selectedFile.FullName)) {
        [System.Windows.Forms.MessageBox]::Show("The selected file no longer exists.", "File Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }
    
    if (-not ($creationCheckBox.Checked -or $modifiedCheckBox.Checked -or $accessedCheckBox.Checked)) {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one timestamp option.", "No Options Selected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    try {
        # Combine date and time
        $newDateTime = $datePicker.Value.Date + $timePicker.Value.TimeOfDay
        
        # Apply selected timestamps
        $file = Get-Item $script:selectedFile.FullName
        
        if ($creationCheckBox.Checked) {
            $file.CreationTime = $newDateTime
        }
        
        if ($modifiedCheckBox.Checked) {
            $file.LastWriteTime = $newDateTime
        }
        
        if ($accessedCheckBox.Checked) {
            $file.LastAccessTime = $newDateTime
        }
        
        # Update file info display
        $script:selectedFile = Get-Item $script:selectedFile.FullName  # Refresh file info
        $fileInfoLabel.Text = "Size: {0:N0} bytes | Created: {1} | Modified: {2}" -f $script:selectedFile.Length, $script:selectedFile.CreationTime.ToString("yyyy-MM-dd HH:mm:ss"), $script:selectedFile.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        
        $statusLabel.Text = "Timestamps updated successfully!"
        $statusLabel.ForeColor = [System.Drawing.Color]::Green
        
        [System.Windows.Forms.MessageBox]::Show("File timestamps updated successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    catch {
        $statusLabel.Text = "Error: " + $_.Exception.Message
        $statusLabel.ForeColor = [System.Drawing.Color]::Red
        [System.Windows.Forms.MessageBox]::Show("Error updating timestamps: " + $_.Exception.Message, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$closeButton.Add_Click({
    $form.Close()
})

# Show the form
$form.ShowDialog()