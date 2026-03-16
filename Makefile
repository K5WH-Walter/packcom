# ===========================================================================
#  Makefile for PackCom  (GNU Make, GCC/Clang)
#  Usage:
#    make              – build release
#    make debug        – build with debug symbols
#    make clean        – remove build artefacts
# ===========================================================================

CXX      ?= g++
CXXFLAGS  = -std=c++17 -Wall -Wextra -Iinclude
LDFLAGS   =

UNAME := $(shell uname 2>/dev/null || echo Windows)

ifeq ($(UNAME),Windows)
    CXXFLAGS += -DPACKCOM_WINDOWS
    TARGET    = packcom.exe
else
    CXXFLAGS += -DPACKCOM_POSIX
    LDFLAGS  += -lpthread
    TARGET    = packcom
endif

SRCS = src/main.cpp    \
       src/platform.cpp \
       src/serial.cpp   \
       src/terminal.cpp \
       src/input.cpp    \
       src/config.cpp   \
       src/yapp.cpp     \
       src/fileops.cpp  \
       src/app.cpp

OBJS = $(SRCS:.cpp=.o)

# ---- Default: release build ----
release: CXXFLAGS += -O2 -DNDEBUG
release: $(TARGET)

# ---- Debug build ----
debug: CXXFLAGS += -g -O0 -DPACKCOM_DEBUG
debug: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)
	@echo "Built: $@"

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: release debug clean
