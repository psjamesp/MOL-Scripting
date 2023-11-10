$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
Describe "Set-ComputerState" {
    Mock Restart-Computer { return 1 }
    Mock Stop-Computer { return 1 }
    It "accepts and restarts one computer name" {
        Set-ComputerState -computername SERVER1 -Action Restart
        Assert-MockCalledShould -Invoke Restart-Computer -Exactly 1 -Scope It
    }
    It "accepts and restarts many names" {
        $names = @('SERVER1','SERVER2','SERVER3')
        Set-ComputerState -computername $names -Action Restart
        Assert-MockCalledShould -Invoke Restart-Computer -Exactly 3 -Scope It
    }
    It "accepts and restarts from the pipeline" {
        $names = @('SERVER1','SERVER2','SERVER3')
        $names | Set-ComputerState -Action Restart
        Assert-MockCalledShould -Invoke Restart-Computer -Exactly 3 -Scope It
    }
    It "accepts and force-restarts one computer name" {
        Set-ComputerState -computername SERVER1 -Action Restart -Force
        Assert-MockCalledShould -Invoke Restart-Computer -Exactly 1 -Scope It
    }
    It "accepts and shuts down one computer name" {
        Set-ComputerState -computername SERVER1 -Action Shutdown
        Assert-MockCalledShould -Invoke Stop-Computer -Exactly 1 -Scope It
    }
}
