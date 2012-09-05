CC=valac
CFLAGS=--pkg gtk+-3.0
INSTALL=install
INSTALL_PROGRAM=$(INSTALL) -Dpm 0755
INSTALL_DATA=$(INSTALL) -Dpm 0644

all: gtk-theme-config

gtk-theme-config: gtk-theme-config.vala
	$(CC) $(CFLAGS) gtk-theme-config.vala -o gtk-theme-config

clean:
	rm -rf gtk-theme-config

install: all
	$(INSTALL_PROGRAM) gtk-theme-config $(DESTDIR)/usr/bin/gtk-theme-config
	$(INSTALL_DATA) gtk-theme-config.desktop $(DESTDIR)/usr/share/applications/gtk-theme-config.desktop

uninstall:
	rm -f $(DESTDIR)/usr/bin/gtk-theme-config
	rm -f $(DESTDIR)/usr/share/applications/gtk-theme-config.desktop
