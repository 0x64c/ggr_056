TOOLCHAIN_PATH=/opt/gcw0-toolchain
PATH=$(TOOLCHAIN_PATH)/usr/bin:$PATH
TOOLCHAIN=$(TOOLCHAIN_PATH)/usr/bin/mipsel-linux-
TARGET=mipsel-gcw0-linux-uclibc

ALLEGRO_LIB=$(TOOLCHAIN_PATH)/$(TARGET)/sysroot/usr/lib/liballeg.so.4.4

EXE=ggr
RM=/usr/bin/rm -rf
MKDIR=/usr/bin/mkdir -p
CP=/usr/bin/cp
OPK_DIR=opk_build

CC=$(TOOLCHAIN)gcc
CXX=$(TOOLCHAIN)g++
STRIP=$(TOOLCHAIN)strip
OPK=$(EXE).opk

ALLEGRO_CONFIG=$(TOOLCHAIN_PATH)/$(TARGET)/sysroot/usr/bin/allegro-config

LIB=-L$(TARGET)/usr/$(TARGET)/sysroot/usr/lib
INC=-I$(TARGET)/usr/$(TARGET)/sysroot/usr/include

#LDFLAGS += $(INC) -lSDL2 -lSDL2_ttf -lSDL2_mixer $(shell $(SDL_CONFIG) --libs)
#CFLAGS +=-D_GCW_ -O2 $(LIB) $(shell $(SDL_CONFIG) --cflags) -Wall -Wextra
LDFLAGS += $(INC) $(shell $(ALLEGRO_CONFIG) --libs)
CFLAGS += -O2 $(LIB) -std=gnu++98 -Dlinux -mips32 -Wno-write-strings
# -Wall -Wextra

SRCS=$(shell echo *.cpp)
OBJS=$(SRCS:%.cpp=%.o)

REMOTE_USER=od
REMOTE_IP=10.1.1.2
REMOTE_PATH=/media/data/apps

ALL : $(EXE)
.cpp.o:
	$(CXX) $(CFLAGS) $(CXXFLAGS) -c $*.cpp -o $*.o

$(EXE) : $(OBJS)
	$(CXX) $(OBJS) -o $(OPK_DIR)/$(EXE) $(LDFLAGS)
	$(STRIP) $(OPK_DIR)/$(EXE)

opk : $(EXE)
	mksquashfs ./opk_build/* ./data $(ALLEGRO_LIB) $(EXE).opk -all-root -noappend -no-exports -no-xattrs

upload : opk
	/usr/bin/scp -v ./$(OPK) $(REMOTE_USER)@$(REMOTE_IP):$(REMOTE_PATH)/$(OPK)

clean :
	$(RM) $(OBJS) $(OPK_DIR)/$(EXE) $(OPK)

.PHONY:opk clean install uninstall ALL
