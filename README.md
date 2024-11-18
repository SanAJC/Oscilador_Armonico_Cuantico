# Oscilador Cuántico - Guía de Instalación

## Prerrequisitos

### Linux
- **GCC** y **Make** suelen estar instalados por defecto en la mayoría de distribuciones.
- Si no están instalados, el **Makefile** los instalará automáticamente.

### Windows
Necesitará instalar:

#### Hacer para Windows:
1. **Chocolatey (Recomendado)**
    ```powershell
    # Ejecutar PowerShell como administrador
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Instalar make
    choco install make
    ```

## Instalación

### Clona el repositorio:
```bash
git clone [URL_DEL_REPOSITORIO]
cd [NOMBRE_DEL_DIRECTORIO]
```
### Clona el repositorio:
```bash
# En Linux/macOS
make run

# En Windows (después de instalar make)
make run
```

## Nota adicional
-Si prefiere no instalar make, puede ejecutar los comandos manualmente:
```bash
gcc main.c -o oscillator.exe -Wall -O2 -lm
./oscillator.exe
```
