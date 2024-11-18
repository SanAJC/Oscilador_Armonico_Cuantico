# Detección del Sistema Operativo
ifeq ($(OS),Windows_NT)
    detected_OS := Windows
    EXE := .exe
    RM := del /Q
    GNUPLOT_CMD := wgnuplot
    # En Windows, especificamos la ruta completa a gcc y las DLLs después de la instalación de MinGW
    MINGW_PATH := C:\ProgramData\mingw64\mingw64
    MINGW_BIN := $(MINGW_PATH)\bin
    CC := $(MINGW_BIN)\gcc
    # Lista de DLLs necesarias
    REQUIRED_DLLS := libwinpthread-1.dll libgcc_s_seh-1.dll libstdc++-6.dll
    # Comando de ejecución específico para Windows
    EXEC_CMD := .\\
else
    detected_OS := $(shell uname -s)
    EXE :=
    RM := rm -f
    GNUPLOT_CMD := gnuplot
    CC := gcc
    # Comando de ejecución específico para Linux/Unix
    EXEC_CMD := ./
endif

TARGET = oscillator$(EXE)

CFLAGS = -Wall -O2
LDFLAGS = -lm

SRC = main.c

.PHONY: all clean help check-deps install-deps run refresh-env copy-dlls

# Nueva regla para copiar DLLs necesarias
copy-dlls:
ifeq ($(detected_OS),Windows)
	@echo "Copiando DLLs necesarias..."
	@for %%D in ($(REQUIRED_DLLS)) do ( \
		if exist "$(MINGW_BIN)\%%D" ( \
			copy /Y "$(MINGW_BIN)\%%D" "." \
		) \
	)
endif

refresh-env:
ifeq ($(detected_OS),Windows)
	@echo "Refrescando variables de entorno..."
	@powershell -Command "$$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')"
	@set PATH=$(MINGW_BIN);%PATH%
endif

all: check-deps refresh-env copy-dlls $(TARGET)

install-deps:
	@echo "Verificando e instalando dependencias..."
ifeq ($(detected_OS),Windows)
	@echo "Instalando dependencias en Windows..."
	@if not exist "$(MINGW_BIN)" (choco install -y mingw)
	@if not exist "C:\Program Files\gnuplot" (choco install -y gnuplot)
else ifeq ($(detected_OS),Darwin)
	$(install_macos)
else
	sudo apt-get update
	sudo apt-get install -y gcc gnuplot
endif

check-deps:
	@echo "Verificando dependencias..."
ifeq ($(detected_OS),Windows)
	@if not exist "$(MINGW_BIN)\gcc.exe" (echo "gcc no encontrado. Instalando dependencias..." && $(MAKE) install-deps)
	@if not exist "C:\Program Files\gnuplot\bin\$(GNUPLOT_CMD).exe" (echo "gnuplot no encontrado. Instalando dependencias..." && $(MAKE) install-deps)
else
	@which gcc >/dev/null 2>&1 || (echo "gcc no encontrado. Instalando dependencias..." && $(MAKE) install-deps)
	@which $(GNUPLOT_CMD) >/dev/null 2>&1 || (echo "gnuplot no encontrado. Instalando dependencias..." && $(MAKE) install-deps)
endif

$(TARGET): $(SRC)
	@echo "Compilando para $(detected_OS)..."
	"$(CC)" $(SRC) -o $(TARGET) $(CFLAGS) $(LDFLAGS)
	@echo "Compilación completada."

run: all
	@echo "Ejecutando $(TARGET)..."
	$(EXEC_CMD)$(TARGET)
	@echo "Ejecución completada."
	@echo "La gráfica se ha guardado como 'energy_levels_plot.png'"

clean:
	@echo "Limpiando archivos generados..."
	$(RM) $(TARGET) *.txt *.gnu *.png $(REQUIRED_DLLS)
	@echo "Limpieza completada."

help:
	@echo "=== Makefile Universal para Oscilador Cuántico ==="
	@echo "Sistema detectado: $(detected_OS)"
	@echo ""
	@echo "Este Makefile instalará automáticamente todas las dependencias necesarias:"
	@echo "- Compilador GCC"
	@echo "- Gnuplot"
	@echo "- Herramientas de desarrollo necesarias"
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  make           - Compila el programa"
	@echo "  make run      - Compila y ejecuta el programa"
	@echo "  make clean    - Limpia archivos generados"
	@echo "  make help     - Muestra esta ayuda"
	@echo "  make install-deps - Instala manualmente las dependencias"
	@echo ""
	@echo "El sistema instalará automáticamente las dependencias si son necesarias."
	@echo "Si hay problemas, puede ejecutar 'make install-deps' manualmente."