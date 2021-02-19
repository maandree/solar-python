.POSIX:

PREFIX = /usr

PYTHON_MAJOR = $$(python --version 2>&1 | cut -d . -f 1 | cut -d ' ' -f 2)
PYTHON_MINOR = $$(python$(PYTHON_MAJOR) --version 2>&1 | cut -d . -f 2)

all:
	@true

info: solar-python.info

solar-python.info: info/solar-python.texinfo info/fdl.texinfo
	$(MAKEINFO) info/solar-python.texinfo

install:
	mkdir -p -- "$(DESTDIR)$(PREFIX)/lib/python$(PYTHON_MAJOR).$(PYTHON_MINOR)/site-packages"
	cp -- solar_python.py "$(DESTDIR)$(PREFIX)/lib/python$(PYTHON_MAJOR).$(PYTHON_MINOR)/site-packages/"

install-info: solar-python.info
	mkdir -p -- "$(DESTDIR)$(PREFIX)/share/info"
	cp -- solar-python.info "$(DESTDIR)$(PREFIX)/share/info/"

uninstall:
	-rm -f -- "$(DESTDIR)$(PREFIX)/lib/python$(PYTHON_MAJOR).$(PYTHON_MINOR)/site-packages/solar_python.py"
	-rm -f -- "$(DESTDIR)$(PREFIX)/share/info/solar-python.info"

.PHONY: clean
clean:
	-rm -rf -- *.pyc *.pyo __pycache__ *.info

.PHONY: all info install install-info uninstall clean
