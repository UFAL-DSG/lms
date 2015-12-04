INSTALL_PREFIX=$(PWD)/tools

all: cs es de fr ru

cs:
	./src/build_model.sh cs tmp/cs 120000 1000000000

de:
	./src/build_model.sh de_DE de tmp/de 120000 10000000

en:
	./src/build_model_en.sh 120000 10000000

es:
	./src/build_model.sh es tmp/es 120000 10000000

fr:
	./src/build_model.sh fr tmp/fr 120000 10000000

ru:
	./src/build_model.sh ru tmp/ru 120000 10000000

pt:
	./src/build_model.sh pt tmp/pt 120000 10000000


install: install-irstlm

install-irstlm: tools/irstlm/Makefile
	CC=gcc $(MAKE) -C $(INSTALL_PREFIX)/irstlm install
	@echo "IRSTLM installed to $(INSTALL_PREFIX)/{bin,lib}"

tools/irstlm/Makefile: tools/irstlm
	sed -i 's:ADD_SUBDIRECTORY (doc)::' $(INSTALL_PREFIX)/irstlm/CMakeLists.txt
	cd $(INSTALL_PREFIX)/irstlm && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$(INSTALL_PREFIX)"

tools/irstlm:
	git clone https://github.com/irstlm-team/irstlm.git  $(INSTALL_PREFIX)/irstlm

distclean:
	$(MAKE) -C $(INSTALL_PREFIX)/irstlm clean || echo -e '\n Error during cleaning irstlm \n'
	rm -f $(INSTALL_PREFIX)/irstlm/CMakeCache.txt

clean:
	rm -rf tmp

.PHONY: distclean clean install install-irstlm
