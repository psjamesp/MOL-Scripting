function Invoke-Speech {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]
        [string[]]$Text,
        [switch]$Asynchronous
    )
    BEGIN {
        Add-Type -AssemblyName System.Speech
        $speech = New-Object -TypeName 
å System.Speech.Synthesis.SpeechSynthesizer
    }
    PROCESS {
        foreach ($phrase in $text) {
            if ($Asynchronous) {
                $null = $speech.SpeakAsync($phrase) #A
            } else {
                $speech.speak($phrase)
            }
        }
    }
    END {}
}
1..10 | Invoke-Speech -Asynchronous
Write-Host "This appears"
#A $null to the left to surpress the output 
