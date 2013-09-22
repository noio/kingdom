# term makefile
#
#  files and directories
#

BINDIR = .
SOURCE = ./king.as
TARGET = $(BINDIR)/main.swf


#
#  compiler and debugger setup
#

COMPILER     = /Developer/SDKs/flex_sdk_4.6.0/bin/mxmlc
DEBUGGER     = /Developer/SDKs/flex_sdk_4.6.0/bin/fdb
ARGS_COMMON  = -source-path . -file-specs $(SOURCE) -o $(TARGET) -static-link-runtime-shared-libraries -strict -headless-server=true
ARGS_DEBUG   = -debug=true -define=CONFIG::debugging,true
ARGS_RELEASE = -debug=false -define=CONFIG::debugging,false


# if verbose=1 is supplied on the command line, then we will display the
# command lines executed

ifeq ($(verbose),1)
  export EC = 
else
  export EC = @
endif


#
#  targets
#

all:
	# ./convert_sounds.sh
	python convert_tiles.py
	python convert_weather.py
	$(EC)mkdir -p $(BINDIR)
	$(EC)rm -rf $(TARGET)
	$(EC)$(COMPILER) $(ARGS_COMMON) $(ARGS_DEBUG)
	# cp $(TARGET) "${HOME}/Google Drive/Art"
	open $(TARGET)

install:
	$(EC)mkdir -p $(BINDIR)
	$(EC)rm -rf $(TARGET)
	$(EC)$(COMPILER) $(ARGS_COMMON) $(ARGS_RELEASE)

run:
	open $(TARGET)

debug:
	$(DEBUGGER) $(TARGET)

clean:
	rm -rf $(TARGET)
