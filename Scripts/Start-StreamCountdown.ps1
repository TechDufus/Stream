<#
.SYNOPSIS
    Create a countdown timer using a text file for Streamlabs OBS
.PARAMETER StartTime
    Provide the datetime formatted time for when the stream will start
    ie. 3:45pm, 15:45, 8:00am, 8:00, etc..
.PARAMETER MinutesUntilStart
    Provide the number of minutes from now to start the stream.
.EXAMPLE
    PS> .\Start-StreamCountdown.ps1 -StartTime 08:10:34

    Description
    -----------
    This will start a countdown, for 8:10:34 AM and create a countdown.txt file
.NOTES
    Author: Matthew J. DeGarmo
    Blog: matthewjdegarmo.com
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory, ParameterSetName = 'Time')]
    [System.DateTime] $StartTime,

    [Parameter(Mandatory, ParameterSetName = 'Ad-Hoc')]
    [System.String] $MinutesUntilStart
)

Begin {
    $CountdownFilePath = Join-Path $PSScriptRoot 'Countdown.txt'
    If (-Not(Test-Path $CountdownFilePath)) {
        $null = New-Item -Path $CountdownFilePath -ItemType File -Force
    }
}

Process {
    Try {
        $Now = Get-Date
        Switch ($PSCmdlet.ParameterSetName) {
            'Time' {
                $DestinationTime = $StartTime
            }
            'Ad-Hoc' {
                $DestinationTime = $Now.AddMinutes($MinutesUntilStart)
            }
        }
        Write-Progress -Activity 'Stream Countdown Progress'
        While ($DestinationTime -gt $Now) {
            $Now = Get-Date
            $RemainingTime = (New-TimeSpan -Start $Now -End $DestinationTime).ToString().Split('.')[0]

            $writeProgressSplat = @{
                Activity         = 'Stream Countdown Progress'
                SecondsRemaining = $($DestinationTime - $Now).TotalSeconds
                CurrentOperation = 'Countdown'
            }
            Write-Progress @writeProgressSplat
            $RemainingTime | Out-File -FilePath $CountdownFilePath -Force
            Start-Sleep -Milliseconds 100
        }
        Write-Progress -Activity 'Stream Countdown Progress' -Completed
    } Catch {
        Write-Error $_
    } Finally {
        $null = Remove-Item $CountdownFilePath -Force
    }
}
