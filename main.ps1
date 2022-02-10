######################################################################
#    ____             __ _                       _   _               #
#   / ___|___  _ __  / _(_) __ _ _   _ _ __ __ _| |_(_) ___  _ __    #
#  | |   / _ \| '_ \| |_| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \   #
#  | |__| (_) | | | |  _| | (_| | |_| | | | (_| | |_| | (_) | | | |  #
#   \____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|  #
#                          |___/                                     #
######################################################################

# Enable SSH verbosity?
$sshVerbosity = $false

# Enable SSH Agent Forwarding?
$sshForward = $true

# Set the time OpenSSH will wait for connection in seconds before timing out
$sshConnectionTimeout = 3

# Set the profile Windows Terminal will use as a base
$wtProfile = ''



#############################
#    ____          _        #
#   / ___|___   __| | ___   #
#  | |   / _ \ / _` |/ _ \  #
#  | |__| (_) | (_| |  __/  #
#   \____\___/ \__,_|\___|  #
#                           #
#############################

$inputURI = $args[0]
$inputArguments = @{}

if ($inputURI -match '(?<Protocol>\w+)\:\/\/(?:(?<Username>[\w|\@|\.]+)@)?(?<HostAddress>[^\:\/]+)(\:(?<Port>\d{2,5})){0,1}\/?(?<Path>.*)') {
    $inputArguments.Add('Protocol', $Matches.Protocol)
    $inputArguments.Add('Username', $Matches.Username) # Optional
    $inputArguments.Add('Port', $Matches.Port)
    $inputArguments.Add('TargetPath', $Matches.Path)
    $rawHost = $Matches.HostAddress
	
    switch -Regex ($rawHost) {
        '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$' {
            # Basic test for IP Address 
            $inputArguments.Add('HostAddress', $rawHost)
            Break
        }
        '(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9]\.)*[a-zA-Z]{2,63}$)' { 
            # Test for a valid Hostname
            $inputArguments.Add('HostAddress', $rawHost)
            Break
        }
        Default {
            Write-Warning 'The Hostname/IP Address passed is invalid. Exiting...'
            Exit
        }
    }
}
else {
    Write-Warning 'The URL passed to the handler script is invalid. Exiting...'
    Exit
}

$windowsTerminalStatus = Get-AppxPackage -Name 'Microsoft.WindowsTerminal*' | Select-Object -ExpandProperty 'Status'
if ($windowsTerminalStatus -eq 'Ok') {
    $appExec = Get-Command 'wt.exe' | Select-Object -ExpandProperty 'Source'
    if (Test-Path $appExec) {
        $windowsTerminal = $appExec
    }
    else {
        Write-Warning 'Could not verify Windows Terminal executable path. Exiting...'
        Exit
    }
}
else {
    Write-Warning 'Windows Terminal is not installed. Exiting...'
    Exit
}

$sshArguments = ''


$appExec = Get-Command 'ssh.exe' | Select-Object -ExpandProperty 'Source'
if (Test-Path $appExec) {
    $SSHClient = $appExec
}
else {
    Write-Warning 'Could not find ssh.exe in Path. Exiting...'
    Exit
}
    
if ($sshVerbosity) {
    $sshArguments += " -v"
}

if ($sshForward) {
    $sshArguments += " -A"
}

if ($inputArguments.TargetPath) {
    $sshArguments += " -t"
}

if ($sshConnectionTimeout) {
    $sshArguments += " -o ConnectTimeout={0}" -f $sshConnectionTimeout
}

if ($inputArguments.Username) {
    $sshArguments += " {0} -l {1}" -f $inputArguments.HostAddress, $inputArguments.Username
}
else {
    $sshArguments += " {0}" -f $inputArguments.HostAddress
}

if ($inputArguments.Port) {
    $sshArguments += " -p {0}" -f $inputArguments.Port
}

if ($inputArguments.TargetPath) {
    $sshArguments += " ''cd {0} && {1}''" -f $inputArguments.TargetPath, '$SHELL'
}

$wtArguments = ''

if ($wtProfile) {
    $wtArguments += "-p {0} " -f $wtProfile
}

$sshCommand = $SSHClient + ' ' + $sshArguments
$wtArguments += 'new-tab ' + $sshCommand

Write-Output $wtArguments

#Write-Output "Start-Process Command: $windowsTerminal Arguments: $wtArguments"

Start-Process -FilePath $windowsTerminal -ArgumentList $wtArguments