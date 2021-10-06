[hosts]
%{ for addr in ipv4_addrs ~}
${addr}
%{ endfor ~}