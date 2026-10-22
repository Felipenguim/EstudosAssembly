# ==== Configuração ====

AS      = aarch64-linux-gnu-as
LD      = aarch64-linux-gnu-ld
QEMU    = qemu-aarch64

ASFLAGS =
LDFLAGS =

TARGET  = strip
OBJS    = strip.o utils.o

# ==== Regras ====

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

strip.o: strip.s
	$(AS) $(ASFLAGS) -o $@ strip.s

utils.o: utils.s
	$(AS) $(ASFLAGS) -o $@ utils.s

run: $(TARGET)
	$(QEMU) ./$(TARGET)

clean:
	rm -f $(OBJS) $(TARGET)
