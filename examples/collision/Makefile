VALAC = valac
OPTIONS = --target-glib 2.32

VALAPKG = --pkg gtk+-3.0 \
          --pkg gdk-3.0 \
          --pkg gstreamer-0.10

VAME_SRC = ../../src/area.vala \
           ../../src/image.vala \
           ../../src/sprite.vala \
           ../../src/text.vala \
           ../../src/sound.vala \
           ../../src/globals.vala \
           ../../src/utils.vala

SRC = src/collision.vala

BIN = collision

all:
	$(VALAC) $(OPTIONS) $(VALAPKG) $(VAME_SRC) $(SRC) -o $(BIN)

clean:
	rm -f $(BIN)
