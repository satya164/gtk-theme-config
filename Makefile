CC=valac
CFLAGS=--pkg gtk+-3.0

all: gtk-theme-config

gtk-theme-config: src/gtk-theme-config.vala
	mkdir -p build
	$(CC) $(CFLAGS) src/gtk-theme-config.vala -o build/gtk-theme-config

clean:
	rm -rf build
