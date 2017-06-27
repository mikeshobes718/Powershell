clear
Clear-Content C:\Users\u584422\Desktop\Script\Powershell\found.txt
#The pid of our script
$pid_holder = $PID

#Get all PID's of "file name" and grep it like linux
$data = Get-WmiObject Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%fileManager.ps1%'" | Select-String -Pattern "Handle" -CaseSensitive


#Get count of times script is running
$count = (Get-WmiObject Win32_Process -Filter "Name='powershell.exe' AND CommandLine LIKE '%fileManager.ps1%'").count

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

$dirType = 1, 2, 3, 4
$drives  = @()

echo "Searching..."
echo ""

foreach($drive in $dirType) {
    $value = GET-WMIOBJECT win32_logicaldisk -Filter "DriveType=$drive" | ForEach-Object -Process {$_.DeviceID}
    $drives += $value
}

$timeout = new-timespan -Minutes 90 #Instructions were ten minutes
$sw = [diagnostics.stopwatch]::StartNew()
while ($sw.elapsed -lt $timeout){
    if (test-path C:){

        function Display_File_Details($Fullname,$size,$mode,$psdate,$owner) { 
            if($mode -NotMatch "d"){

            $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970') 
            $epoch_dt =  (New-TimeSpan -Start $epoch -End $psdate).TotalSeconds 

            $file_data = " $fullname | $size | $mode| $epoch_dt | $owner"
            $file_data | Out-File C:\Users\u584422\Desktop\Script\Powershell\found.txt -append -noClobber
            }
        } 
        foreach($driveArray in $drives){
        $driven = echo $driveArray
        echo "Currently Searching the $driven Drive"
        Get-ChildItem $driven\ -File -Force -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Display_File_Details $_.FullName $_.Length $_.Mode $_.LastWriteTime } #****Works without the Get-ACL command****
        #Get-ChildItem $driven\ -File -Force -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Display_File_Details $_.FullName $_.Length $_.Mode $_.LastWriteTime ((Get-ACL $_.FullName).Owner) }
        }

        echo ""
        echo ""
        echo "Finished!"
        Start-Sleep -m 1000000000
        return
        }
    else {start-sleep -seconds 5}
}

write-host "Timed out"

###################End of Script###################