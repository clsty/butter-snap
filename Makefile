.PHONY: all install uninstall clean

PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
MANDIR := $(PREFIX)/share/man/man1

SRC := buttersnap
MAN := share/man/man1/buttersnap.1

all:
	@echo "Nothing to build. Use 'make install' to install the script and man page."

install: $(SRC) $(MAN)
	@echo "Installing buttersnap to $(BINDIR) and man page to $(MANDIR)"
	@install -d "$(DESTDIR)$(BINDIR)"
	@install -m 0755 "$(SRC)" "$(DESTDIR)$(BINDIR)/buttersnap"
	@install -d "$(DESTDIR)$(MANDIR)"
	@install -m 0644 "$(MAN)" "$(DESTDIR)$(MANDIR)/buttersnap.1"

uninstall:
	@echo "Removing installed files from $(DESTDIR)$(PREFIX)"
	-@rm -f "$(DESTDIR)$(BINDIR)/buttersnap"
	-@rm -f "$(DESTDIR)$(MANDIR)/buttersnap.1"

clean:
	@echo "Nothing to clean."
