clear
#The pid of our script
$pid_holder = $PID

#PowerShell -File C:\Users\u584422\Desktop\Script\Powershell\hang_file.ps1

#Get all PID's of "file name" and grep it like linux
$data = Get-WmiObject Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%file_manager.ps1%'" | Select-String -Pattern "Handle" -CaseSensitive

#Get count of times script is running
$count = (Get-WmiObject Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%file_manager.ps1%'").count

#Store all grep'd lines into array
$testArray = @()
foreach($item in $data)
{
    $testArray += $item
}

#Grep only PID information from $data variable
$pids = [regex]::matches($testArray,'(?<=\").+?(?=\")').value

if($count -gt 1){
#Kill prior instances
    foreach($items in $pids)
    {   
        #For int to string conversion
        try{
            #If there's an instance running already then kill it
            if($items -ne $pid_holder){
                Stop-Process $items -ErrorAction SilentlyContinue
            }
        }
        catch{
            #For int to string conversion
            #Write-Host{"Current Instance"}
        }
    }
}

###################FINDING FILE###################
#echo "Running $pid_holder..."

$timeout = new-timespan -Minutes 10
$sw = [diagnostics.stopwatch]::StartNew()
while ($sw.elapsed -lt $timeout){
    if (test-path C:\Users\u584422\Desktop\Script\Powershell\){ 

        clear
        echo "Please do not quit program till completion!"
        echo "Now finding files..."
        echo ""


        #Get hostname
        $hostname = hostname
        $hostname_saved = "    Hostname: $hostname"
        $hostname_saved | Out-File C:\Users\u584422\Desktop\Script\Powershell\found.txt
        #Get timestamp
        $date = Get-Date -Format g
        $date_saved = "    Timestamp: $date"
        $date_saved | Out-File C:\Users\u584422\Desktop\Script\Powershell\found.txt -append -noClobber
        #Find files and permissions
        try{
            function Display_File_Details($Fullname,$size,$mode,$psdate,$owner) { 
                if($mode -NotMatch "d"){

                $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970') 
                $epoch_dt =  (New-TimeSpan -Start $epoch -End $psdate).TotalSeconds 

                write-host " $fullname | $size | $mode| $epoch_dt | $owner"
                }
            } 
            Get-ChildItem H: -Recurse | ForEach-Object {  Display_File_Details $_.FullName $_.Length $_.Mode $_.LastWriteTime ((Get-ACL $_.FullName).Owner) }
        }catch{
        }
        return
        }
    else {start-sleep -seconds 5}
}

write-host "Timed out"

clear

echo "Finished!"

Start-Sleep -minutes 1000000000

###################End of Script###################