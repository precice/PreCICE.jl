CC=gcc 
 
CFLAGS=-c -Wall -fPIC
 
SOURCES=DummyParticipant.c 
OBJECTS=$(SOURCES:.c=.o)
 
.c.o:
	$(CC) $(CFLAGS) $< -o $@ 
 
lib: $(OBJECTS)
	$(CC) -shared -fPIC -o libprecice.so $(OBJECTS)
 
clean:
	rm *.o *.so
