#!/bin/bash
set -e

# Inicia o serviço SSH
service ssh start

# Mantém o container rodando
tail -f /dev/null
