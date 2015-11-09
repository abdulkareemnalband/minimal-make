ODIR=obj
DEPDIR= deps
ifndef SRC
	SRC = src
endif
SOURCES = $(notdir $(wildcard $(SRC)/*.cpp))
_OBJ := $(patsubst %.cpp,%.o,$(SOURCES))
DEPEND := $(patsubst %.cpp,%.d,$(SOURCES))
DEPNDS = $(patsubst %,$(DEPDIR)/%,$(DEPEND))
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))
ifeq ($(VERBOSE),true)
CC = g++
CCDEPS = g++
else
CC = @g++
CCDEPS = @g++
endif
ifndef MAIN
	MAIN=$(shell pwd | xargs basename)
endif

ifdef PKG
	CXXFLAGS +=  $(shell pkg-config --cflags-only-I $(PKG))
	LIBS +=  $(shell pkg-config --libs $(PKG))
endif
CXXFLAGS += -I./include




rr =  "\$$(CC) -c -o \$$@ \$$< \$$(CXXFLAGS)"

.PHONY: all build clean clean-all rebuild garbage details

all: build $(OTHERS)

details:
	@echo -e "CXXFLAGS : " $(CXXFLAGS) "\n"
	@echo -e "LIBS : " $(LIBS) "\n"
	@echo -e "SOURCES : " $(SOURCES) "\n"
	@echo -e "PKGs : " $(PKG) "\n"


build :$(MAIN)
	@echo -e "################################################\nBuilt " $(MAIN) "\n################################################\n"
ifeq ($(notify),true)
	@notify-send "Built $(MAIN)"
endif


exec:
	./$(MAIN)


$(MAIN): $(OBJ)
	@echo "Linking " $(MAIN)
	$(CC) -o $@ $^ $(CXXFLAGS) $(LIBS)

clean:
	rm -fv $(ODIR)/*.o *~ core.*

clean-all: clean
	rm -fv $(MAIN)

rebuild : clean build

garbage :
	rm -fv *~ core.*


$(OBJ) :  | $(ODIR)

$(ODIR) :
	+mkdir -p $@

$(DEPDIR) :
	+mkdir -p $@

$(DEPDIR)/%.d: $(SRC)/%.cpp | $(DEPDIR)
	@rm -f $@;
	@echo "Genrating Dependencies :" $<
	$(CCDEPS) $< $(CXXFLAGS) -MM -MT "$(ODIR)/$(basename $(@F)).o" > $@
	@echo -e "\t@echo \"Compiling :\"" $< >> $@
	@echo -e '\t' $(rr) >> $@

include $(DEPNDS)
