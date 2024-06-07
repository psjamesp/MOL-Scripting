
# Import the AutomatedLab module
Import-Module AutomatedLab

# Define the lab name
$labName = 'HyperVLab'

# Create a new lab
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

# Add a Hyper-V host
Add-LabVirtualNetworkDefinition -Name 'Internal' -AddressSpace 192.168.10.0/24

# Define the domain information
$domainName = 'contoso.com'

# Add domain controller
Add-LabDomainDefinition -Name $domainName -AdminUser Install -AdminPassword 'P@ssw0rd'

# Define the operating system images
Set-LabInstallationCredential -Username Install -Password 'P@ssw0rd'
Add-LabIsoImageDefinition -Name 'WS2022' -Path 'C:\ISO\en_windows_server_2022_x64_dvd.iso'
Add-LabIsoImageDefinition -Name 'Win11' -Path 'C:\ISO\en-us_windows_11_consumer_editions_x64_dvd.iso'

# Add machines to the lab
Add-LabMachineDefinition -Name DC1 -Memory 4GB -Network 'Internal' -IpAddress 192.168.10.10 -Gateway 192.168.10.1 -DnsServer1 192.168.10.10 -DomainName $domainName -Roles RootDC -OperatingSystem 'Windows Server 2022 Datacenter (Desktop Experience)'

Add-LabMachineDefinition -Name SRV01 -Memory 2GB -Network 'Internal' -IpAddress 192.168.10.11 -Gateway 192.168.10.1 -DnsServer1 192.168.10.10 -DomainName $domainName -OperatingSystem 'Windows Server 2022 Datacenter (Desktop Experience)'

Add-LabMachineDefinition -Name SRV02 -Memory 2GB -Network 'Internal' -IpAddress 192.168.10.12 -Gateway 192.168.10.1 -DnsServer1 192.168.10.10 -DomainName $domainName -OperatingSystem 'Windows Server 2022 Datacenter (Desktop Experience)'

Add-LabMachineDefinition -Name Client -Memory 2GB -Network 'Internal' -IpAddress 192.168.10.20 -Gateway 192.168.10.1 -DnsServer1 192.168.10.10 -DomainName $domainName -OperatingSystem 'Windows 11 Pro'

# Install the lab
Install-Lab

# Output the lab summary
Show-LabDeploymentSummary -Detailed
