# Earthly timeout issue

13 September 2022

12:56

Original
resoltuion:

1. Create
a file: /etc/wsl.conf.

2. Put
the following lines in the file in order to ensure the your DNS changes do not
get blown away

[network]

generateResolvConf=false

3. In a
cmd window, run wsl --shutdown

4.
Restart WSL2

5. Create
a file: /etc/resolv.conf. If it exists, replace existing one with this new
file.

6. Put
the following line in the file

nameserver
8.8.8.8 # Or use your DNS server instead of 8.8.8.8 which is a Google DNS
server

7. Repeat
step 3 and 4. You will see git working fine now.

Credit: [https://github.com/microsoft/WSL/issues/4285#issuecomment-522201021](https://github.com/microsoft/WSL/issues/4285#issuecomment-522201021)

docker
kill earthly-buildkitd