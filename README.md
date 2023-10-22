# Making an OS (x86)

This is my code to learn a little bit assembly when I came across the interesting YouTube playlist ["Making an OS (x86)"](https://www.youtube.com/watch?v=MwPjvJ9ulSc&list=PLm3B56ql_akNcvH8vvJRYOc7TbYhRs19M) by [Daedalus Community](https://www.youtube.com/@DaedalusCommunity).
Its aim is to create a 512-byte-long boot sector in `nasm`, an asssembler for the x86 CPU architecture.

Besides `nasm`, the machine emulator `qemu` must also be installed.
I tested my code in [Kali WSL](https://www.kali.org/docs/wsl/wsl-preparations/), so it should work in other Linux distros too.
For Debian-based distro, you can use:

```bash
sudo apt install nasm qemu-system
```

The `asm` and `bin` files are located in the directories that correspond to the videos as follows:

| Directory | Video                                                                                                                                                     | Description                                    |
|-----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|
| boot2     | [Chapter 2 - BIOS, Printing the Alphabet, Conditional Jumps](https://www.youtube.com/watch?v=APiHPkPmwwU&list=PLm3B56ql_akNcvH8vvJRYOc7TbYhRs19M&index=2) | Print the alphabet in alternating caps aBcD... |

To run the operating system, use the script `boot.sh` with the directory number.
For example:

```bash
./boot.sh 2
```