# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.


# The package path prefix, if you want to install to another root, set DESTDIR to that root
PREFIX = /usr
# The library path excluding prefix
LIB = /lib
# The resource path excluding prefix
DATA = /share
# The library path including prefix
LIBDIR = $(PREFIX)$(LIB)
# The resource path including prefix
DATADIR = $(PREFIX)$(DATA)
# The generic documentation path including prefix
DOCDIR = $(DATADIR)/doc
# The info manual documentation path including prefix
INFODIR = $(DATADIR)/info
# The license base path including prefix
LICENSEDIR = $(DATADIR)/licenses

# The name of the package as it should be installed
PKGNAME = solar-python

# The major version number of the current Python installation
PY_MAJOR = 3
# The minor version number of the current Python installation
PY_MINOR = 5
# The version number of the current Python installation without a dot
PY_VER = $(PY_MAJOR)$(PY_MINOR)
# The version number of the current Python installation with a dot
PY_VERSION = $(PY_MAJOR).$(PY_MINOR)

# The modules this library is comprised of
SRC = solar_python

# Filename extension for -OO optimised python files
ifeq ($(shell test $(PY_VER) -ge 35 ; echo $$?),0)
PY_OPT2_EXT = opt-2.pyc
else
PY_OPT2_EXT = pyo
endif



.PHONY: default
default: base info

.PHONY: all
all: base doc

.PHONY: base
base: compiled optimised


.PHONY: compiled
compiled: $(foreach M,$(SRC),src/__pycache__/$(M).cpython-$(PY_VER).pyc)

.PHONY: optimised
optimised: $(foreach M,$(SRC),src/__pycache__/$(M).cpython-$(PY_VER).$(PY_OPT2_EXT))


src/__pycache__/%.cpython-$(PY_VER).pyc: src/%.py
	python -m compileall $<

src/__pycache__/solar_python.cpython-$(PY_VER).$(PY_OPT2_EXT): src/solar_python.py
	python -OO -m compileall $<


.PHONY: doc
doc: info pdf dvi ps

.PHONY: info
info: bin/solar-python.info
bin/%.info: doc/info/%.texinfo
	@mkdir -p bin
	$(MAKEINFO) $<
	mv $*.info $@

.PHONY: pdf
pdf: bin/solar-python.pdf
bin/%.pdf: doc/info/%.texinfo
	@! test -d obj/pdf || rm -rf obj/pdf
	@mkdir -p bin obj/pdf
	cd obj/pdf && texi2pdf ../../"$<" < /dev/null
	mv obj/pdf/$*.pdf $@

.PHONY: dvi
dvi: bin/solar-python.dvi
bin/%.dvi: doc/info/%.texinfo
	@! test -d obj/dvi || rm -rf obj/dvi
	@mkdir -p bin obj/dvi
	cd obj/dvi && $(TEXI2DVI) ../../"$<" < /dev/null
	mv obj/dvi/$*.dvi $@

.PHONY: ps
ps: bin/solar-python.ps
bin/%.ps: doc/info/%.texinfo
	@! test -d obj/ps || rm -rf obj/ps
	@mkdir -p bin obj/ps
	cd obj/ps && texi2pdf --ps ../../"$<" < /dev/null
	mv obj/ps/$*.ps $@



.PHONY: install
install: install-base install-info

.PHONY: install-all
install-all: install-base install-doc

.PHONY: install-base
install-base: install-lib install-copyright


.PHONY: install-lib
install-lib: install-source install-compiled install-optimised

.PHONY: install-source
install-source: $(foreach M,$(SRC),src/$(M).py)
	install -dm755 -- "$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)"
	install -m644 $^ -- "$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)"

.PHONY: install-compiled
install-compiled: $(foreach M,$(SRC),src/__pycache__/$(M).cpython-$(PY_VER).pyc)
	install -dm755 -- "$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)/__pycache__"
	install -m644 $^ -- "$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)/__pycache__"

.PHONY: install-optimised
install-optimised: $(foreach M,$(SRC),src/__pycache__/$(M).cpython-$(PY_VER).$(PY_OPT2_EXT))
	install -dm755 -- "$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)/__pycache__"
	install -m644 $^ -- "$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)/__pycache__"


.PHONY: install-copyright
install-copyright: install-copying install-license

.PHONY: install-copying
install-copying: COPYING
	install -dm755 -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	install -m644 $^ -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"

.PHONY: install-license
install-license: LICENSE
	install -dm755 -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	install -m644 $^ -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"


.PHONY: install-doc
install-doc: install-info install-pdf install-dvi install-ps

.PHONY: install-info
install-info: bin/solar-python.info
	install -dm755 -- "$(DESTDIR)$(INFODIR)"
	install -m644 $< -- "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"

.PHONY: install-pdf
install-pdf: bin/solar-python.pdf
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 -- "$<" "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"

.PHONY: install-dvi
install-dvi: bin/solar-python.dvi
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 -- "$<" "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"

.PHONY: install-ps
install-ps: bin/solar-python.ps
	install -dm755 -- "$(DESTDIR)$(DOCDIR)"
	install -m644 -- "$<" "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"



.PHONY: uninstall
uninstall:
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/LICENSE"
	-rm -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)/COPYING"
	-rmdir -- "$(DESTDIR)$(LICENSEDIR)/$(PKGNAME)"
	-rm -- $(foreach M,$(SRC),"$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)/__pycache__/$(M).cpython-$(PY_VER).$(PY_OPT2_EXT)")
	-rm -- $(foreach M,$(SRC),"$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)/__pycache__/$(M).cpython-$(PY_VER).pyc")
	-rm -- $(foreach M,$(SRC),"$(DESTDIR)$(LIBDIR)/python$(PY_VERSION)/$(M).py")
	-rm -- "$(DESTDIR)$(INFODIR)/$(PKGNAME).info"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).pdf"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).dvi"
	-rm -- "$(DESTDIR)$(DOCDIR)/$(PKGNAME).ps"



.PHONY: clean
clean:
	-rm -r src/__pycache__ obj bin

