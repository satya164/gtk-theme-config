CC=valac
CFLAGS=--pkg gtk+-3.0
LDFLAGS=-X -lm
SOURCE=gtk-theme-config.vala
BINARY=gtk-theme-config
ICON=gtk-theme-config.svg
DESKTOPFILE=gtk-theme-config.desktop
GTK_UPDATE_ICON_CACHE=gtk-update-icon-cache -f -t
CLEAN=rm -f
INSTALL=install
INSTALL_PROGRAM=$(INSTALL) -Dpm 0755
INSTALL_DATA=$(INSTALL) -Dpm 0644

all: $(BINARY)

$(BINARY): $(SOURCE)
	$(CC) $(CFLAGS) $(LDFLAGS) $(SOURCE) -o $(BINARY)

clean:
	$(CLEAN) $(BINARY)

install: all
	$(INSTALL_PROGRAM) $(BINARY) $(DESTDIR)/usr/bin/$(BINARY)
	$(INSTALL_DATA) $(ICON) $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/$(ICON)
	$(INSTALL_DATA) $(DESKTOPFILE) $(DESTDIR)/usr/share/applications/$(DESKTOPFILE)
	@-if test -z $(DESTDIR); then $(GTK_UPDATE_ICON_CACHE) $(DESTDIR)/usr/share/icons/hicolor; fi

uninstall:
	$(CLEAN) $(DESTDIR)/usr/bin/$(BINARY)
	$(CLEAN) $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/$(ICON)
	$(CLEAN) $(DESTDIR)/usr/share/applications/$(DESKTOPFILE)
	@-if test -z $(DESTDIR); then $(GTK_UPDATE_ICON_CACHE) $(DESTDIR)/usr/share/icons/hicolor; fi

