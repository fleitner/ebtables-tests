
TESTS := brouting \
		forward \
		input \
		netns-brouting \
		netns-forward \
		netns-input \
		netns-output \
		netns-postrouting \
		netns-prerouting \
		output \
		postrouting \
		prerouting


all: $(TESTS)

$(TESTS):
	@echo "Testing $@"
	( cd $@ ; ./test.sh )

.SILENT: $(TESTS)
.PHONY: all $(TESTS)
