build: 
	@for i in / $(TOGO); do \
		test $$i != / && echo xx $(D)/$$i ; \
	done; true

