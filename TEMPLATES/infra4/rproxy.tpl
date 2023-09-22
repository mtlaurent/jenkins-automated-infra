#!/bin/bash
sudo yum update -y
sudo yum install -y haproxy
echo "Z2xvYmFsCiAgICBsb2cgICAgICAgICAxMjcuMC4wLjEgbG9jYWwyCgogICAgY2hyb290ICAgICAgL3Zhci9saWIvaGFwcm94eQogICAgcGlkZmlsZSAgICAgL3Zhci9ydW4vaGFwcm94eS5waWQKICAgIG1heGNvbm4gICAgIDQwMDAKICAgIHVzZXIgICAgICAgIGhhcHJveHkKICAgIGdyb3VwICAgICAg>
cat << EOF >> /etc/haproxy/haproxy.cfg

frontend web_front
        bind *:80
        mode http
        use_backend web_back
backend web_back
        balance roundrobin
        mode http
        server srv1 ${WEB_IP_A}:80
        server srv2 ${WEB_IP_B}:80
        server srv3 ${WEB_IP_C}:80

EOF
systemctl enable --now haproxy
exit