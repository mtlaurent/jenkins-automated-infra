AdminMachine.sh                                                                                                            
#!/bin/bash

export HTTP_PROXY=http://${HAPROXY_IP}:80
export HTTPS_PROXY=http://${HAPROXY_IP}:80

yum update -y

exit;