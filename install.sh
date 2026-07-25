#!/bin/bash
SYNC_DIR_NAME='synced-directories'
  

# 1. Detectar o Sistema Operacional
OS="$(uname -s)"
case "${OS}" in
  Linux*)
    # Verifica se é Android (Termux) ou Linux Desktop
    if [ -d "/data/data/com.termux" ]; then
      echo "Detectado: Android (Termux)"
      CONFIG_DIR="$HOME/.config/syncthing"
      SYNC_PATH="$HOME/Storage/$SYNC_DIR_NAME"
    else
      echo "Detectado: Linux"
      if [ -d "$HOME/.local/state/syncthing" ]; then
        CONFIG_DIR="$HOME/.local/state/syncthing"
      elif [ -d "$HOME/.config/syncthing" ]; then
        CONFIG_DIR="$HOME/.config/syncthing"
      else
        # Caso o Syncthing nunca tenha rodado na máquina, assume o padrão moderno
        CONFIG_DIR="$HOME/.local/state/syncthing"
      fi
      SYNC_PATH="$HOME/$SYNC_DIR_NAME"
    fi
    ;;
  Darwin*)
    echo "Detectado: macOS"
    CONFIG_DIR="$HOME/Library/Application Support/Syncthing"
    SYNC_PATH="$HOME/$SYNC_DIR_NAME"
    ;;
  CYGWIN*|MINGW32*|MSYS*|MINGW*)
    echo "Detectado: Windows"
    echo "Sistema não suportado. Abortado."
    exit 1
    ;;
  *)
    echo "Sistema operacional desconhecido."
    exit 1
    ;;
esac

# 2. Criar o diretório de sincronização se não existir
mkdir -p "$SYNC_PATH"



# 3. Validar se o Syncthing já gerou o config.xml inicial
if [ ! -f "$CONFIG_DIR/config.xml" ]; then
  echo "Erro: config.xml não encontrado. Inicie o Syncthing uma vez para gerar o arquivo base."
  exit 1
fi

# ID único da pasta (precisa ser IGUAL em todos os dispositivos)
#
COLD_BACKUP_ID="0hdd-storage-cold-backup"
DRAWINGS_ID="krita-drawings"
EMACS_ID="emac-main"
OBSIDIAN_ID="nsya9-d4te9"

echo "Configurando a pasta no diretório: $CONFIG_DIR"

# Pegar a API Key automaticamente do arquivo de configuração
API_KEY=$(grep -oP '(?<=<apikey>)[^<]+' "$CONFIG_DIR/config.xml")

echo "API KEY IS: $API_KEY"
# Adicionar a pasta via API enviando um JSON com o caminho correto detectado pelo script

#essa é a mais pesada, pra testes eu vou usar a do doom emacs
#curl -X POST -H "X-API-Key: $API_KEY" -d '{
#  "id": "'"$COLD_BACKUP_ID"'",
#  "label": "cold-backup",
#  "path": "'"$SYNC_PATH"'",
#  "type": "send"
#}' http://127.0.0.1

curl -X POST -H "X-API-Key: $API_KEY" -d '{
  "id": "'"$EMACS_ID"'",
  "label": "emacs-dir",
  "path": "'"$SYNC_PATH/emacs"'",
  "type": "sendreceive"
}' http://127.0.0.1:8384

