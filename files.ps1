#Gets all files like Linux
clear

#dir c:\Users\u584422

Get-ChildItem C:\Build -recurse | where {! $_.PSIsContainer} | sort Length | Format-Table Name, Length, Directory, Mode, LastWriteTime

Start-Sleep -m 1000000000