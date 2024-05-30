function Test-IsAdmin {
    <#
    .SYNOPSIS
    Checks if the current user is an administrator on the machine.
    .DESCRIPTION
    This private function returns a Boolean value indicating whether
    the current user has administrator privileges on the machine.
    It does this by creating a new WindowsPrincipal object, passing
    in a WindowsIdentity object representing the current user, and
    then checking if that principal is in the Administrator role.
    .INPUTS
    None.
    .OUTPUTS
    Boolean. Returns True if the current user is an administrator, and False otherwise.
    .EXAMPLE
    PS C:\> Test-IsAdmin
    True
    #>

    # Create a new WindowsPrincipal object for the current user and check if it is in the Administrator role
    (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}