TARGET=cosmos
DEBUG=$(TARGET)-debug
SRCS=$(TARGET).d src/cosmos/face.d src/cosmos/exception.d src/cosmos/board.d src/cosmos/canvas.d src/cosmos/window.d src/cosmos/resources.d src/cosmos/game.d
DROPT=-release -inline -O
DDOPT=-debug

all: $(TARGET)
debug: $(DEBUG)

clean:
	$(RM) $(TARGET) $(DEBUG) *.o *.deps

$(TARGET): $(SRCS)
	dmd $(DROPT) -w -Isrc -L-Llib -of$@ $^

$(DEBUG): $(SRCS)
	dmd $(DDOPT) -w -Isrc -L-Llib -of$@ $^
