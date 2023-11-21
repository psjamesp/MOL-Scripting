function Invoke-Speech {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true)]           #A
        [string[]]$Text
    )
    BEGIN {
        Add-Type -AssemblyName System.Speech        #B
        $speech = New-Object -TypeName 
å System.Speech.Synthesis.SpeechSynthesizer
    }
    PROCESS {
        foreach ($phrase in $text) {
            $speech.speak($phrase)
        }
    }
    END {}
}
"One","Two","Three" | Invoke-Speech
#A Command that takes pipeline input
#B Loads the assembly once
