# 📘 IPv4 Addressing & Subnetting Reference

| CIDR | Subnet Mask         | Hosts per Subnet    | Descrizione                                      |
|------|---------------------|---------------------|-------------------------------------------------|
| /32  | 255.255.255.255     | 1                   | Host singolo (loopback, host ID, ACL)           |
| /31  | 255.255.255.254     | 2 (no broadcast)    | Point-to-point links (RFC 3021)                 |
| /30  | 255.255.255.252     | 2                   | Point-to-point links                            |
| /29  | 255.255.255.248     | 6                   | Subnet per router o gateway                     |
| /28  | 255.255.255.240     | 14                  | Minireti (es. dispositivi)                      |
| /27  | 255.255.255.224     | 30                  | Reti piccole (es. DMZ)                          |
| /26  | 255.255.255.192     | 62                  | Quarto di rete C                                |
| /25  | 255.255.255.128     | 126                 | Mezza rete C                                    |
| /24  | 255.255.255.0       | 254                 | Rete classe C (es. 192.168.1.0/24)             |
| /23  | 255.255.254.0       | 510                 |                                                 |
| /22  | 255.255.252.0       | 1,022               |                                                 |
| /21  | 255.255.248.0       | 2,046               |                                                 |
| /20  | 255.255.240.0       | 4,094               |                                                 |
| /19  | 255.255.224.0       | 8,190               |                                                 |
| /18  | 255.255.192.0       | 16,382              |                                                 |
| /17  | 255.255.128.0       | 32,766              |                                                 |
| /16  | 255.255.0.0         | 65,534              | Rete classe B (es. 172.16.0.0/16)              |
| /15  | 255.254.0.0         | 131,070             |                                                 |
| /14  | 255.252.0.0         | 262,142             |                                                 |
| /13  | 255.248.0.0         | 524,286             |                                                 |
| /12  | 255.240.0.0         | 1,048,574           | Rete grande (es. 10.0.0.0/12)                  |
| /11  | 255.224.0.0         | 2,097,150           |                                                 |
| /10  | 255.192.0.0         | 4,194,302           |                                                 |
| /9   | 255.128.0.0         | 8,388,606           |                                                 |
| /8   | 255.0.0.0           | 16,777,214          | Rete classe A (es. 10.0.0.0/8)                 |
| /7   | 254.0.0.0           | 33,554,430          |                                                 |
| /6   | 252.0.0.0           | 67,108,862          |                                                 |
| /5   | 248.0.0.0           | 134,217,726         |                                                 |
| /4   | 240.0.0.0           | 268,435,454         |                                                 |
| /3   | 224.0.0.0           | 536,870,910         |                                                 |
| /2   | 192.0.0.0           | 1,073,741,822       | Quarto spazio IPv4                              |
| /1   | 128.0.0.0           | 2,147,483,646       | Mezzo spazio IPv4                               |
| /0   | 0.0.0.0             | 4,294,967,294       | Tutto lo spazio IPv4 (non subnettato)          |

### 🧠 Note:
- Il numero di host = 2^(32 - CIDR) - 2, eccetto per /31 e /32.
- /31 è usato per collegamenti punto-punto (senza broadcast).
- /32 identifica un singolo host (es. loopback, ACL).

---

## 🏷️ Classful IPv4 Address Ranges

| Classe | Inizio IP       | Fine IP         | Default Subnet Mask | Descrizione                           |
|--------|-----------------|-----------------|---------------------|---------------------------------------|
| A      | 0.0.0.0         | 127.255.255.255 | 255.0.0.0 (/8)      | Grandi reti (0-127)                   |
| B      | 128.0.0.0       | 191.255.255.255 | 255.255.0.0 (/16)   | Medie reti (128-191)                  |
| C      | 192.0.0.0       | 223.255.255.255 | 255.255.255.0 (/24) | Reti piccole (192-223)                |
| D      | 224.0.0.0       | 239.255.255.255 | N/A                 | Multicast                             |
| E      | 240.0.0.0       | 255.255.255.255 | N/A                 | Riservato per uso futuro/sperimentale |

---

## 🔒 Private IPv4 Address Ranges

| Classe | Inizio IP       | Fine IP         | CIDR          | Descrizione                  |
|--------|-----------------|-----------------|---------------|------------------------------|
| A      | 10.0.0.0        | 10.255.255.255 | 10.0.0.0/8    | Rete privata classe A        |
| B      | 172.16.0.0      | 172.31.255.255 | 172.16.0.0/12 | Rete privata classe B        |
| C      | 192.168.0.0     | 192.168.255.255| 192.168.0.0/16| Rete privata classe C        |

---

## 🚫 Bogon IPv4 Address Ranges

| Rete              | Descrizione                                 |
|-------------------|---------------------------------------------|
| 0.0.0.0/8         | Indirizzi non instradabili (this network)   |
| 10.0.0.0/8        | Private                                     |
| 100.64.0.0/10     | Carrier-grade NAT                           |
| 127.0.0.0/8       | Loopback                                    |
| 169.254.0.0/16    | Link-local (APIPA)                          |
| 172.16.0.0/12     | Private                                     |
| 192.0.2.0/24      | TEST-NET-1 (documentazione)                 |
| 192.88.99.0/24    | IPv6-to-IPv4 relay (obsoleto)               |
| 192.168.0.0/16    | Private                                     |
| 198.18.0.0/15     | Test interfacce di rete                     |
| 198.51.100.0/24   | TEST-NET-2 (documentazione)                 |
| 203.0.113.0/24    | TEST-NET-3 (documentazione)                 |
| 224.0.0.0/4       | Multicast                                   |
| 240.0.0.0/4       | Riservato                                   |
| 255.255.255.255/32| Broadcast                                   |

---
