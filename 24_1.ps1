function Get-DiskInfo {
    foreach ($domain in (Get-ADForest).domains) { 
      $hosts = Get-ADDomainController -filter * -server $domain | 
      Sort-Object -Prop hostname
      ForEach ($h   in $hosts) { 
       $cs = Get-CimInstance -ClassName Win32_ComputerSystem `
                            # -ComputerName $h
       $props = @{'ComputerName' = $h
                  'DomainController' = $h
                  'Manufacturer' = $cs.manufacturer
                  'Model' = $cs.model
                  'TotalPhysicalMemory(GB)'=$cs.totalphysicalmemory / 1GB
                  }
        New-Object -Type PSObject -Prop $props
      } #foreach $h
     } #foreach $domain
   } #function
   Export-ModuleMember -function Get-DiskInfo
   