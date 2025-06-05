# Procedure to reset the Built-in Administrator password on a Windows Server

If you don't have access to another administrator account, follow these steps:

1. **Mount the Windows Server installation ISO (or disk) into the server and restart the system.**
2. **Boot the server from the installation disk.** You might need to change the BIOS settings (or IDRAC settings) to boot from the disk.
3. **When you see the Windows setup screen, select "Repair your computer" in the lower-left corner.**
4. **Choose "Troubleshoot" and then "Advanced options".**
5. **Select "Command Prompt".** In the Command Prompt, type the following commands one by one and press Enter after each:
   ```batch
    diskpart
    list disk
    select disk 0  #(usually this is a C: disk)
    list volume
    select volume 1  #(usually this is a volume with Windows)
    assign LETTER=Y
    exit
    cd windows\system32
    ren utilman.exe utilman.exe.bak
    copy cmd.exe utilman.exe
    net user Administrator /active:yes
    ```
6. **Close the Command Prompt and restart the server.**
7. **On the login screen, click the accessibility icon in the lower-right corner.** This will open the Command Prompt. Type:
    ```batch
    net user Administrator new_password
    ```
8. **Close the Command Prompt and log in to the server using the new Administrator password.**
9. **After resolving the issue, restore the original Utilman.exe file to avoid leaving a security vulnerability.** Boot into the recovery environment and open the Command Prompt again:
    ```batch
    cd windows\system32
    del utilman.exe
    ren utilman.exe.bak utilman.exe
    ```

This method allows you to reset the password without needing access to another administrator account. Just be sure to follow the steps carefully to avoid any issues.

---

Once the procedure has been completed, any changes relating to the hardening of previously modified administrative users must be reapplied.
