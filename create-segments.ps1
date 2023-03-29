# Variables
$viCred                = Get-Credential '46058176@ad.mmu.ac.uk'
$nsxtServer            = "10.39.0.3" # MMU AVS NSX-T Manager
$connectedGatewayName  = "TNT17-T1" # Main T1 Gateway in MMU AVS
$transportZoneId       = "TNT17-OVERLAY-TZ" # Main overlay to use in MMU AVS
$csvFilePath           = ".\segments.csv" # csv file with segments to loop through
$c1                    = 0
$exportData            = @()

# Import segment data from CSV
$segmentData = Import-Csv -Path $csvFilePath

# Connect to NSX-T Manager
Connect-NsxtServer -Server $nsxtServer -Credential $viCred

# Get connected gateway object
$connectedGateway = Get-NsxtSddcGateway -Name $connectedGatewayName

# Loop through each row and create overlay segments
foreach ($row in $segmentData) {
    $segmentName = $row.Name
    $subnets = $row.Subnets # -split ','
    $c1++
    Write-Progress -Id 0 -Activity 'Creating Segments' -Status "Processing $segmentName - $($c1) of $($segmentData.Count) NSX-T Segments"
    #Write-Output $segmentName
    #Write-Output $subnets
    #Write-Output ""
    #Start-Sleep -Seconds 1

    # Create overlay segment
    $segment = New-NsxtSegment -DisplayName $segmentName -TransportZoneId $transportZoneId -Subnet $subnets -ConnectivityPath $connectedGateway

    # Log segment information
    $segmentData = Get-NsxtSegment -DisplayName $segment
    $exportData += $segmentData
}

$exportData
