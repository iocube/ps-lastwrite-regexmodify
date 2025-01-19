## Custom variables
$pattern_replace = '  "version": "2025-01-20-1234-NEW",'  # Pattern to replace with  #ex. with a line in a JSON file
$period_length = "-1"  # Example: -1 = last 24 hours ; -2 = last two days etc.

## Initial var setup
$pattern_search = '  "version":.*'  # Pattern to search for #ex. with a line in a JSON file
$subfile = "subfolder\manifest.json"  # a \ dir separator is included before this in the actual command

## Step 1 - Create Array
# Included are folders which contain a flag file modified in the last 1 day
$files = Get-ChildItem "E:\Application\Album_*\manifest.bin" -Recurse | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays($period_length) } | ForEach-Object {$_.DirectoryName}


## Step 2 - Draw GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(550,450)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,350)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,350)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please make a selection from the list below:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(500,40)

$listBox.SelectionMode = 'MultiExtended'


foreach ($f in $files){ [void] $listBox.Items.Add($f) }

$listBox.Height = 300
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $listBox.SelectedItems
    #$x  ## Print array

    # Modify files per regex on each selected directory
    foreach ($uijson in $x){ Get-ChildItem "$uijson\$subfile" -recurse |% { (gc $_) -replace "$pattern_search", "$pattern_replace" | Set-Content $_ } ; Write-Output "Changed $uijson\$subfile" }
}
