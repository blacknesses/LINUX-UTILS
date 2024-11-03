#!/bin/bash

# Atualizar o sistema e instalar pacotes necessários
echo "Atualizando o sistema e instalando pacotes necessários..."
sudo apt update && sudo apt install -y figlet lolcat htop rustscan fping plocate lm-sensors wine

# Verificar se há suporte para 'sensors' para monitorar temperatura da CPU
if ! command -v sensors &> /dev/null; then
    echo "Instalando o pacote lm-sensors para monitoramento de temperatura."
    sudo apt install -y lm-sensors
    sudo sensors-detect --auto
fi

# Configurar aliases
echo "Configurando aliases..."
cat << 'EOF' >> ~/.bashrc

## MEUS ALIASES ##
alias remove="apt-get purge -y && update"
alias update="sudo apt-get update ; sudo apt-get full-upgrade -y ; sudo apt install -f -y ; sudo dpkg --configure -a ; sudo apt clean -y && sudo apt autoremove -y && sudo apt autoclean -y && sudo apt remove -f -y && apt-get -u dist-upgrade -y && apt-get install linux-headers-$(uname -r) -y && chmod 777 /dev/vmnet0 && updatedb && ssh-add .ssh/routerx"
alias cache="echo 'limpando caches...' ; sync && echo 1 > /proc/sys/vm/drop_caches ; sync && echo 2 > /proc/sys/vm/drop_caches ; sync && echo 3 > /proc/sys/vm/drop_caches && clear && echo -e 'caches limpos e sistema atualizado !!\n'"
alias swap-clean="swapoff -a && swapon -a && echo 'cache swap limpo!';"
alias ipa="ip -c -br a"
alias install="sudo apt-get install -y"
alias monitor="htop"
alias rustscan="rustscan --ulimit 5000 -a"
alias desligar="update && cache && shutdown -h now"
alias locate="plocate"
alias pong="fping -s"
alias suspender="systemctl unmask sleep.target suspend"
alias winbox="mkdir -p ~/myapp/prefix && export WINEPREFIX=$HOME/myapp/prefix && export WINEARCH=win32 && export WINEPATH=$HOME/myapp && wineboot --init && cd /home/fabio/Downloads/packges.zip/WinBox_Linux && wine Winbox"
alias dns-authtoritative="host -t NS"
alias virtual="source codigos/virtual/bin/activate && which python"
alias vencord=". /vencord.sh"
alias clean-log="sudo rm -rf /var/log/journal/*"

## BANNER ##
figlet "Debian" | lolcat --seed 1000
echo "## SYSTEM"
echo -e "Operacional System: \033[32m$(uname)\033[0m"
echo -e "Kernel: \033[32m$(uname -s)\033[0m"
echo -e "Kernel version: \033[32m$(uname -r)\033[0m"

# Cálculo da porcentagem de uso de memória
mem_total=$(free | awk '/Mem/ {print $2}')
mem_used=$(free | awk '/Mem/ {print $3}')
mem_percentage=$(awk "BEGIN {printf \"%.2f\", ($mem_used / $mem_total) * 100}")
echo -e "Memory usage: \033[32m${mem_percentage}%\033[0m of \033[32m$(free -h | awk '/Mem/ {print $2}')\033[0m"

# Cálculo da porcentagem de uso de swap
swap_total=$(free | awk '/Swap/ {print $2}')
swap_used=$(free | awk '/Swap/ {print $3}')
if [[ $swap_total -gt 0 ]]; then
  swap_percentage=$(awk "BEGIN {printf \"%.2f\", ($swap_used / $swap_total) * 100}")
  echo -e "Swap usage: \033[32m${swap_percentage}%\033[0m of \033[32m$(free -h | awk '/Swap/ {print $2}')\033[0m"
else
  echo -e "Swap usage: \033[32m0%\033[0m of \033[32m0B\033[0m"
fi

# Armazenamento total em porcentagem e GB
storage_usage=$(df -h --total | awk '/total/ {print $5}')
storage_total=$(df --total -BG | awk '/total/ {print $2}' | sed 's/G//')
echo -e "Storage usage: \033[32m${storage_usage}\033[0m of \033[32m${storage_total}GB\033[0m"

# Temperatura da CPU e outros dados
echo -e "CPU temp: \033[32m$(sensors | awk '/Core 0/ {print $3}')\033[0m"

# Cálculo de System Load em porcentagem
load_1min=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}')
cpu_cores=$(nproc)
load_percentage=$(awk -v load="$load_1min" -v cores="$cpu_cores" 'BEGIN {printf "%.2f", (load / cores) * 100}')
echo -e "System load (1 min): \033[32m${load_percentage}%\033[0m"

echo
echo "## OSINT"
echo -e "Local users: \033[32m$(who | wc -l)\033[0m"
echo -e "Uptime: \033[32m$(uptime -p)\033[0m"

# Concatenar os IPs das interfaces wlo1 e enx00e04c680ab4 em uma linha separada por vírgula
active_ips=""
for iface in wlo1 enx00e04c680ab4; do
  ip_addr=$(ip -o -4 addr show "$iface" | awk '{print $4}' | cut -d'/' -f1)
  if [[ -n "$ip_addr" ]]; then
    if [[ -n "$active_ips" ]]; then
      active_ips+=", "
    fi
    active_ips+="$ip_addr"
  fi
done
echo -e "Active IPs: \033[32m$active_ips\033[0m"
EOF

# Aplicar as alterações
source ~/.bashrc
echo "Instalação concluída! Abra uma nova sessão para ver o banner e usar os aliases."
