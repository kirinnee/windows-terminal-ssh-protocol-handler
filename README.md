# SSH Protocol Handler for Windows Terminal
Allows browsers to recognize the SSH protocol and open it in [Windows Terminal](https://www.microsoft.com/en-sg/p/windows-terminal/9n0dx20hk701?SilentAuth=1&wa=wsignin1.0&activetab=pivot:overviewtab) and perform the SSH.

# Pre-Requisite
- Windows Terminal
- SSH.exe (check in PowerShell with `gcm ssh`)

## Installation
1. Clone this repository in your `C:\Users\<user>\Documents\PowerShell\Scripts` folder
    ```
    git clone https://github.com/kirinnee/windows-terminal-ssh-protocol-handler.git
    ```
2. Open `browser-ssh-handler.reg` and change line 15's `<user>` to your Window user
    ```
    @="powershell \"C:\\Users\\<user>\\Documents\\PowerShell\\Scripts\\windows-terminal-ssh-protocol-handler\\main.ps1\" %1"
    ```
3. Edit the configuration in `main.ps1` to your liking
4. Double click `browser-ssh-handler.reg` to install it to in the register.
