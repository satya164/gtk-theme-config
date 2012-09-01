CC=valac
CFLAGS=--pkg gtk+-3.0

all: gtk-theme-config

gtk-theme-config: gtk-theme-config.vala
	$(CC) $(CFLAGS) gtk-theme-config.vala -o gtk-theme-config

clean:
	rm -f gtk-theme-config
