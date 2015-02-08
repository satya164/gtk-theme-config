VERSION=0.1
VALAC=valac
CFLAGS=--pkg gtk+-3.0
LDFLAGS=-X -lm
GETTEXT_PACKAGE=gtk-theme-config
LOCALES_DIR=/usr/share/locale
VALAFLAGS=-X -DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\"
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
	$(VALAC) $(VALAFLAGS) $(CFLAGS) $(LDFLAGS) $(SOURCE) -o $(BINARY)

clean:
	$(CLEAN) $(BINARY)

install: all mo
	$(INSTALL_PROGRAM) $(BINARY) $(DESTDIR)/usr/bin/$(BINARY)
	$(INSTALL_DATA) $(ICON) $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/$(ICON)
	$(INSTALL_DATA) $(DESKTOPFILE) $(DESTDIR)/usr/share/applications/$(DESKTOPFILE)
	@-if test -z $(DESTDIR); then $(GTK_UPDATE_ICON_CACHE) $(DESTDIR)/usr/share/icons/hicolor; fi

uninstall:
	$(CLEAN) $(DESTDIR)/usr/bin/$(BINARY)
	$(CLEAN) $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/$(ICON)
	$(CLEAN) $(DESTDIR)/usr/share/applications/$(DESKTOPFILE)
	@-if test -z $(DESTDIR); then $(GTK_UPDATE_ICON_CACHE) $(DESTDIR)/usr/share/icons/hicolor; fi
	for folder in $(LOCALES_DIR)/*; do \
		file=$$folder/LC_MESSAGES/$(GETTEXT_PACKAGE).mo; \
		if [ -f $$file ]; then \
			rm $$file; \
			echo "Removing $$file"; \
		fi \
	done

pot:
	xgettext -d $(GETTEXT_PACKAGE) -o po/$(GETTEXT_PACKAGE).pot $(SOURCE) --keyword="_" \
		--from-code=UTF-8 --package-name=$(GETTEXT_PACKAGE) --package-version=$(VERSION)

mo: pot
	if [ -f po/*.po ]; then \
		for po_file in po/*.po; do \
			out_file=$(LOCALES_DIR)/$$(echo $$po_file | sed "s/^po\/\(.*\)\.po/\1/")/LC_MESSAGES/$(GETTEXT_PACKAGE).mo; \
			msgfmt -o $$out_file $$po_file; \
			echo "Installing $$out_file"; \
		done \
	fi

