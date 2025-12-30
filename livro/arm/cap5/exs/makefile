# ==== Configuração ====

AS      = aarch64-linux-gnu-as
LD      = aarch64-linux-gnu-ld
QEMU    = qemu-aarch64

ASFLAGS =
LDFLAGS =

TARGET  = main
OBJS    = main.o dict.o utils.o

# ==== Regras ====

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

main.o: main.s colon.inc words.inc
	$(AS) $(ASFLAGS) -o $@ main.s

dict.o: dict.s
	$(AS) $(ASFLAGS) -o $@ dict.s

utils.o: utils.s
	$(AS) $(ASFLAGS) -o $@ utils.s

run: $(TARGET)
	$(QEMU) ./$(TARGET)

clean:
	rm -f $(OBJS) $(TARGET)
