function Invoke-InputBox {
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$True)]
      [string]$Prompt,
      [Parameter(Mandatory=$True)]
      [string]$Title,
      [Parameter()]
      [string]$Default = ''
    )
    Add-Type -Assembly Microsoft.VisualBasic
    [microsoft.visualbasic.interaction]::inputbox($prompt,$title,$default)
  } #function
  