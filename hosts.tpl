[hosts]
%{ for addr in ipv4_addrs ~}
${addr}
%{ endfor ~}

%{ for i, name in names ~}
[${name}]
${ipv4_addrs[i]}

%{ endfor ~}