TARGET = libfrunzik.so

CC = gcc
CFLAGS += -g -Wall -std=c99 -MMD -MP -DDEBUG -fPIC

LINK = gcc
LINKFLAGS = -g -shared

SOURCE_FOLDER = src
SOURCES = $(shell find $(SOURCE_FOLDER) -name '*.c')
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))
DEPENDENCIES = $(patsubst %.c, %.d, $(SOURCES))

.PHONY: all

all: $(TARGET)
	@echo -------------------------------------
	@echo runt tests here
	@echo -------------------------------------

$(TARGET): $(OBJECTS)
	$(LINK) $(LINKFLAGS) $^ -o $@

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm $(TARGET)
	rm $(OBJECTS)
	rm $(DEPENDENCIES)

-include $(DEPENDENCIES)
