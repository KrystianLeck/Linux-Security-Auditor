#!/bin/bash

# --- KONFIGURACJA KOLORÓW ---
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}    LINUX SECURITY AUDITOR v1.0      ${NC}"
echo -e "${BLUE}=====================================${NC}"

# 1. TEST UPRAWNIEŃ (Root Check)
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] BŁĄD: Uruchom skrypt przez: sudo ./audit.sh${NC}" 
   exit 1
fi

echo -e "${GREEN}[*] Uprawnienia administratora: OK${NC}"

# 2. TEST FIREWALLA (UFW)
echo -e "\n${YELLOW}[i] Sprawdzanie statusu Firewalla...${NC}"
if ufw status | grep -q "Status: active"; then
    echo -e "${GREEN}[+] Firewall (UFW) jest AKTYWNY.${NC}"
else
    echo -e "${RED}[-] ALARM: Firewall (UFW) jest WYŁĄCZONY!${NC}"
fi

# 3. TEST OTWARTYCH PORTÓW
echo -e "\n${YELLOW}[i] Wykryte otwarte porty (nasłuchiwanie):${NC}"
ss -tuln | grep LISTEN | awk '{print $5}' | cut -d: -f2 | sort -u | xargs echo -e "${BLUE}Otwarte porty:${NC}"

# 4. TEST PUSTYCH HASEŁ
echo -e "\n${YELLOW}[i] Sprawdzanie kont bez haseł...${NC}"
puste_hasla=$(sudo awk -F: '$2 == "" {print $1}' /etc/shadow)

if [ -z "$puste_hasla" ]; then
    echo -e "${GREEN}[+] Wszystkie konta systemowe mają hasła.${NC}"
else
    echo -e "${RED}[-] ALARM! Wykryto konta BEZ HASŁA: $puste_hasla${NC}"
fi

echo -e "\n${BLUE}=====================================${NC}"
echo -e "${GREEN}Audyt zakończony pomyślnie.${NC}"
