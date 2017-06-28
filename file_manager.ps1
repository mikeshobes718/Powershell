clear
$countDown = 2
for($i=$countDown;$i-gt0;$i--){
clear
if($i-gt1){
echo "Will began searching in $i seconds"
}else{
echo "Will began searching in $i second"
}
Start-Sleep -s 1
}

clear
echo "Enter CTRL+C to quit program"
Start-Sleep -s 2

$swatch = [Diagnostics.Stopwatch]::StartNew()

clear
Clear-Content C:\Users\u584422\Desktop\Script\Powershell\found.txt

#The pid of our script
$pid_holder = $PID

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

clear

echo "Run the below command in Powershell to tail your output"
echo "Get-Content C:\Users\u584422\Desktop\Script\Powershell\found.txt -Wait"
echo ""

echo "Now Searching..."
echo ""

$dirType = 3
$drives  = @()

foreach($drive in $dirType) {
    $value = GET-WMIOBJECT win32_logicaldisk -Filter "DriveType=$drive" | ForEach-Object -Process {$_.DeviceID}
    $drives += $value
}

$timeout = new-timespan -Minutes 10 #Instructions were ten minutes
$sw = [diagnostics.stopwatch]::StartNew()
while ($sw.elapsed -lt $timeout){

        function Display_File_Details($Fullname,$size,$mode,$psdate,$owner) { 
            if($sw.elapsed -gt $timeout){
                echo "`n`nTimed out"
                break
                
            }
            #start-sleep -seconds 1
            if($mode -NotMatch "d"){

            $epoch = [timezone]::CurrentTimeZone.ToLocalTime([datetime]'1/1/1970') 
            $epoch_dt =  (New-TimeSpan -Start $epoch -End $psdate).TotalSeconds 

            $file_data = " $fullname | $size | $mode| $epoch_dt | $owner"
            $file_data | Out-File C:\Users\u584422\Desktop\Script\Powershell\found.txt -append -noClobber
            }
        } 
    
        foreach($driveArray in $drives){
            #$driven = echo $driveArray
            echo "Currently Searching the $driveArray Drive `n"
            Get-ChildItem $driven\ -File -Force -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Display_File_Details $_.FullName $_.Length $_.Mode $_.LastWriteTime } #****Works without the Get-ACL command****
            #Get-ChildItem $driven\ -File -Force -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Display_File_Details $_.FullName $_.Length $_.Mode $_.LastWriteTime ((Get-ACL $_.FullName).Owner) }
        }

        #echo ""
        #echo "Finished!"
        #Start-Sleep -m 1000000000 #Pauses when done searching
        #return

    #start-sleep -seconds 2

    break
}

$swatch.Stop()
$time = $swatch.Elapsed
#$time

$hours = $time | ForEach-Object -Process {$_.Hours}
#$hours
$minutes = $time | ForEach-Object -Process {$_.Minutes}
#$minutes
$seconds = $time | ForEach-Object -Process {$_.Seconds}
#$seconds
$milliseconds = $time | ForEach-Object -Process {$_.TotalMilliseconds}
#$milliseconds

if($hours -gt 0){
echo ""
echo "Your Program ran for $hours hours"
}elseif($minutes -gt 0){
echo ""
echo "Your Program ran for $minutes minutes"
}elseif($seconds -gt 0){
echo ""
echo "Your Program ran for $seconds seconds"
}else{
echo ""
echo "Your Program ran for $milliseconds milliseconds"
}

Start-Sleep -s 60

###################End of Script###################