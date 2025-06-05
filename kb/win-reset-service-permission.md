# Commands to Manage Service Permissions

## Display all permissions on the service
```batch
sc sdshow "service-name"
```

## Retrieve the SID of the user to be added to the service
```batch
wmic useraccount where name="user" get sid
```

## Example string to add permissions to a single service in addition to the existing ones
```batch
sc sdset "service-name" D:(A;;LORPWPDT;;;S-1-5-21-1960659504-1021078182-2569522015-1011)(A;;CCLCSWRPWPDTLOCRRC;;;SY);;;WD)
```

## Verify permissions
```batch
sc query "service-name"
```

---

## Legend of the DACL Access Control Entry (ACE) String

Example of a DACL ACE:

```text
(A;;CCLCSWRPWPDTLOCRRC;;;SY)
```

### Explanation of the String:
- **"A"** means "Allow" - this ACE describes what the user is allowed to do.
- **"SY"** indicates that the described user is the local system.

The rights in the middle consist of pairs of letters:

- **CC** - `SERVICE_QUERY_CONFIG` - asks the SCM for the current service configuration.
- **LC** - `SERVICE_QUERY_STATUS` - asks the SCM for the current service status.
- **SW** - `SERVICE_ENUMERATE_DEPENDENTS` - lists dependent services.
- **RP** - `SERVICE_START` - starts the service.
- **WP** - `SERVICE_STOP` - stops the service.
- **DT** - `SERVICE_PAUSE_CONTINUE` - pauses/continues the service.
- **LO** - `SERVICE_INTERROGATE` - asks the service for its current status.
- **CR** - `SERVICE_USER_DEFINED_CONTROL` - sends a user-defined control to the service.
- **RC** - `READ_CONTROL` - reads the security descriptor of this service.
