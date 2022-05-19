# MSSA Lab
# Working with WMI
# Date 18 May 2022


$ComputerName = Get-WmiObject Win32_OperatingSystem | Select -ExpandProperty PSComputerName

#Get Computer Caption and Last Boot Up Time
$OSinfo = Get-WmiObject Win32_OperatingSystem -Property Caption,LastBootUpTime -ComputerName $ComputerName

#Convert Last Boot Up Time to readable date
$BootTime = Get-WmiObject Win32_OperatingSystem | Select-Object @{label='LastBoot';expression={$_.ConvertToDateTime($_.LastBootUpTime)}}

#ShorterVersion 
$lastboot = $OSinfo.ConvertToDateTime($OSinfo.LastBootUpTime)

#Get C Drvie
$Cdrive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID = 'C:'"

#Calculate C Drive Free Space in GB as an interger with 2 decimals
$FreeSpace = $Cdrive.FreeSpace / 1GB -as [int]

# Set Current Time
$CurrentDate = (Get-Date)

# Calculate Total Up Tme as a number with 2 decimals
$UpTime = New-TimeSpan -Start $BootTime.LastBoot -End $CurrentDate.DateTime | Select -ExpandProperty TotalHours | ForEach {$_.ToString("###.## Hrs")}

#ShorterVersion
$CurrentDate - $lastboot

$CurrentDate - $lastboot | Select -ExpandProperty TotalHours | ForEach {$_.ToString("###.##")}

$Running = Get-Service -ComputerName $ComputerName | Where-Object Status -eq "Running"

#create Hash Table

$Properties = [ordered] @{
    "Computer Name" = $ComputerName;
    "Operating System" = $OSinfo.Caption;
    "Last Boot Time" = $BootTime.LastBoot;
    "Up Time Hours" = $UpTime;
    "Running Services" = $Running
    "C: Free Space" = $FreeSpace.ToString("### GBs")
}

$Properties

#Turn Hash Table into an object
$Object = New-Object -TypeName PSObject -Property $Properties

#Export To CSV

$Properties.GetEnumerator() |
    Select-Object -Property Key,Value |
    Export-Csv -NoTypeInformation -Path C:\PropertiesChallenge.csv

$FormatEnumerationLimit = -1
Write-Output $Object