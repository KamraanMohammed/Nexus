#Installation for Nexus script is located in /nexus-install.

#Add the following code to visudo upon prompt

nexus ALL=(ALL) NOPASSWD: ALL

#Uncomment "run_as_user" line in nexus.rc file and add "nexus" user

#Copy the following linex into nexus.service file

[Unit]
Description=nexus service
After=network.target
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort
[Install]
WantedBy=multi-user.target

