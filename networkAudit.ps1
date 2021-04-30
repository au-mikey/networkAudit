# To use the 128 bit hex time converter function, simply pass it the hex value as a string.
# It doesn't matter if there are spaces or not, the function will strip the spaces,
# convert and return a date and time in 24 hour format.
#
# Examples:
# 128BitHex('e5 07 04 00 05 00 1e 00 0f 00 02 00 23 00 92 01')
# 128bithex("e507040005001e000f00020023009201")

# To use the Connection Auditor, simply call the function. the function will lookup the
# registry values, extract the network name, time created and time last connected and
# display the information in a human readable format. The date values are set by the
# local PC time at the time the connection was established.
#
# Example:
# connectionAudit


function 128BitHex {
    Param ([string]$hexVal)
    # Remove any spaces that may be present in the string
    $hexVal = $hexVal.Replace(' ','')

    # To convert the hex value into a time format, first we need to separate the string into sections two bytes, and the swap them around
    # e.g. we may start with hex value 'e5 07' we need to swap the bytes to '07 e5', then we can convert to decimal to get the value.

    # Get 2 characters in a string in the correct order, then convert it to a decimal value.
    $decYear = "{0:D4}" -f [convert]::ToInt32($hexVal.Substring(2,2)+$hexVal.Substring(0,2),16)
    $decMonth = "{0:D2}" -f [convert]::ToInt32($hexVal.Substring(6,2)+$hexVal.Substring(4,2),16)
    # The below line gets the value for the day of the week, but is not normally relevant. Uncomment if required
    #$decDOW = [convert]::ToInt32($hexVal.Substring(10,2)+$hexVal.Substring(8,2),16)
    $decDay = "{0:D2}" -f [convert]::ToInt32($hexVal.Substring(14,2)+$hexVal.Substring(12,2),16)
    $decHr = "{0:D2}" -f [convert]::ToInt32($hexVal.Substring(18,2)+$hexVal.Substring(16,2),16)
    $decMin = "{0:D2}" -f [convert]::ToInt32($hexVal.Substring(22,2)+$hexVal.Substring(20,2),16)
    $decSec = "{0:D2}" -f [convert]::ToInt32($hexVal.Substring(26,2)+$hexVal.Substring(24,2),16)
    # The below line gets the value for milliseconds, but is not relevant. Uncomment if required
    #$decMsec = [convert]::ToInt32($hexVal.Substring(30,2)+$hexVal.Substring(28,2),16)

    # Convert the decimal values to a correctly formated date and time
    $convertTime = (Get-Date -Year $decYear -Month $decMonth -Day $decDay -Hour $decHr -Minute $decMin -Second $decSec -Format 'dd MMM yyyy HH:mm:ss')

    # Return the formated date and time
    return $convertTime
}

function connectionAudit {
    # Get a list of registry keys for network connections
    $netList = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\')
    
    # For each key, get the profile name, date created and last connection date
    foreach ($profile in $netList)
    {
        $regKey = (Get-ItemProperty -Path Registry::$profile)
        # Get the network name value value from the registry key
        $netName = $regKey.ProfileName
        # Get the hex value for the created date
        $created = ($regKey.DateCreated | Format-Hex | Select-Object -Expand Bytes | ForEach-Object {'{0:x2}' -f $_ }) -join ' '
        # Get the hex value for the last connection date
        $lastConnection = ($regKey.DateCreated | Format-Hex | Select-Object -Expand Bytes | ForEach-Object {'{0:x2}' -f $_ }) -join ' '
        
        # Convert the hex values to a date and time
        $createdDate = 128bithex($created)
        $lastConnectionDate = 128bithex($lastConnection)

        # Display the Network name, created date and last connection date in a readable format
        Write-Host Network Name: $netName`nCreated Date: $createdDate`nLast Connection: $lastConnectionDate`n`n
    }
}

#echo off
#cls
# Uncomment below to run the script

#128BitHex('e5 07 04 00 05 00 1e 00 0f 00 02 00 23 00 92 01')
#128bithex("e507040005001e000f00020023009201")

#connectionAudit # Requires admin priveleges to run
#pause 
