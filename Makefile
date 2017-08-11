TARGET = frunzik

CC = gcc
CFLAGS += -g -Wall -std=c99 -MMD -MP -DDEBUG 

LINK = gcc
LINKFLAGS = -g

SOURCE_FOLDER = src
SOURCES = $(shell find $(SOURCE_FOLDER) -name '*.c')
OBJECTS = $(patsubst %.c, %.o, $(SOURCES))
DEPENDENCIES = $(patsubst %.c, %.d, $(SOURCES))

all: $(TARGET)
	@echo -------------------------------------
	@./$(TARGET)
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
