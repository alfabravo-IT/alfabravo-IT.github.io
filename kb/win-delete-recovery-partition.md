# Commands to Delete the Recovery Partition Using DiskPart

## 1. Launch DiskPart
To start, open the command prompt as an administrator and launch `diskpart`:

```powershell
diskpart
```

## 2. List Available Disks
To view a list of disks connected to the system:

```powershell
list disk
```

## 3. Select the Disk to Modify
Select the disk that contains the Recovery Partition (e.g., disk 0):

```powershell
select disk 0
```

## 4. List Partitions on the Selected Disk
To view the partitions on the selected disk:

```powershell
list partition
```

## 5. Select the Recovery Partition
Once you've identified the Recovery Partition (usually a "Recovery" partition), select it. For example, if it's partition 3:

```powershell
select partition 3
```

## 6. Delete the Recovery Partition
To remove the selected partition:

```powershell
delete partition override
```

The `override` parameter is required to force the deletion, even if the partition is protected or in use.

## 7. Exit DiskPart
Once the operation is complete, you can exit `diskpart`:

```powershell
exit
```

**Important Note:** Deleting the Recovery Partition is irreversible. Make sure you have a proper backup before proceeding.