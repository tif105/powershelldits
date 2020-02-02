

function pingout()
{
    $pingtarget= $hostfield.text
    $ptimer.start()
    Start-Job -Name pinger  -ArgumentList $hostfield.Text -ScriptBlock {param($target)Test-Connection $target -count 2}  -OutVariable $global:pingresult
    $outbox.text = "Started"
}

function updater()
{
    $pingresult = Receive-Job pinger -keep
    #$outbox.Text = $pingresult.count
    $job = Get-Job -Name pinger
    if ($job.State -eq "completed") {
        $pingresult = Receive-Job pinger
        if ($pingresult.count -eq 2 ){$outbox.Text = "System up" }
        if ($pingresult.count -lt 2 ){$outbox.Text = "Connection test failed" }
        remove-job $job
        $ptimer.stop()
    }
    if ($job.State -eq "Running"){$outbox.text = "checking"}

    

}

add-type -AssemblyName system.windows.forms
$form = new-object System.Windows.Forms.Form
$form.AutoSize = $true
$form.text="test computer"
$ptimer = New-Object System.Windows.Forms.Timer
$ptimer.interval=1000
$ptimer.add_tick({updater})


#create textbox and add to form
$hostfield = New-Object System.Windows.Forms.TextBox
$form.Controls.Add($hostfield)

$outbox = New-Object System.Windows.Forms.TextBox
$outbox.Multiline = $true
$outbox.location = new-object system.drawing.size(0,200)
$outbox.Size = New-Object system.drawing.size(600,400)
$form.controls.Add($outbox)

$pingbutton = New-Object System.Windows.Forms.Button
$pingbutton.text = "Test connection"
$pingbutton.location = New-Object system.drawing.size(30,30)
$pingbutton.AutoSize = $true

$pingbutton.add_click({pingout})
$form.controls.Add($pingbutton)



$form.ShowDialog()


$ptimer.stop()

Get-Job | Remove-Job