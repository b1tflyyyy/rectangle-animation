CC = nasm
LD = ld 

OPTIONS = -f elf64

SOURCES = source.asm
OBJECTS = prog.o

EXECUTABLE = prog

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(LD) -o $(EXECUTABLE) $(OBJECTS)

$(OBJECTS): $(SOURCES)
	$(CC) $(OPTIONS) $(SOURCES) -o $(OBJECTS)

clean:
	rm -rf $(OBJECTS) $(EXECUTABLE)
