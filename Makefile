VERSION 	= 0.1
PACKAGE 	= cdua-scripts-$(VERSION)
SUBDIRS 	= admin backup calc cjgd convert devel file fun grep gzip \
		  man mtools multimedia net probe rcs-utils redhat roff \
		  sed stow sw-knife text time utils words xutils cdr mozilla
SUBDIR_MAKEF	= $(patsubst %,%/Makefile,$(SUBDIRS))
DIST_MAKEF	= Mk-dist

BIN		= $(HOME)/bin
ifeq ($(BIN),/bin)
default:
	@echo "error: can't find home directory"
endif

all install: $(DIST_MAKEF)
	$(MAKE) -f $(DIST_MAKEF) $@

$(DIST_MAKEF): Makefile $(SUBDIR_MAKEF)
	for i in $(SUBDIRS); do \
		( cd $$i && $(MAKE) D=$$i build >>/tmp/smk.xyz ); \
	done
	awk '/^xx /{ x[n++] = $$2 } \
	END { \
	  printf "all: \n\t@echo %ctype make install to install: %c\n",39,39; \
	  for (i=0;i<n;i++) printf "\t@echo %c  %s%c\n",39,x[i],39; \
	  print ""; \
	  printf "install: "; \
	  for (i=0;i<n;i++) { \
	    p=index(x[i],"/"); if (p==0) continue; \
	    s=substr(x[i],p+1); \
	    printf "$(BIN)/%s ",s; \
	  } print "\n"; \
	  for (i=0;i<n;i++) { \
	    p=index(x[i],"/"); if (p==0) continue; \
	    s=substr(x[i],p+1); \
	    printf "$(BIN)/%s: %s\n\tcp -pf %s $$@\n\n",s,x[i],x[i]; \
	  } \
	}' /tmp/smk.xyz > $(DIST_MAKEF)
	rm -f /tmp/smk.xyz

###

dist: $(PACKAGE).tar.gz

$(PACKAGE).tar.gz : $(PACKAGE).tar 
	gzip $(PACKAGE).tar

$(PACKAGE).tar : 
	rm -f $@
	find . ! -type d -print | sed \
	  -e '/\/RCS\/.*,v$$/d'	\
	  -e '/\/RCS$$/d' \
	  -e 's/^./$(PACKAGE)/' | sort > /tmp/@$$.=
	pwd | (cd .. && ln -s `cat` $(PACKAGE) && \
	  tar cf $(PACKAGE).tar `cat /tmp/@$$.=` && \
	  mv $(PACKAGE).tar $(PACKAGE) && \
	  cd $(PACKAGE) && \
	  rm ../$(PACKAGE) /tmp/@$$.= )
