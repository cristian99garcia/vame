/*
Copyright (C) 2015, Cristian García <cristian99garcia@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

namespace Vame {

    public class GameArea: Gtk.DrawingArea {

        public signal void click(Vame.ButtonType button, int x, int y);
        public signal void click_released(Vame.ButtonType button, int x, int y);
        public signal void pointer_motion(int x, int y);
        public signal void key_pressed(string key);
        public signal void key_released(string key);
        public signal void size_changed(int width, int height);
        public signal void draw_background(Cairo.Context context);

        public GLib.List<Vame.Sprite> sprites;
        public GLib.List<Vame.Text> texts;
        public Vame.SoundManager sound_manager;
        public Vame.BGType bg_type;

        public double[] background_color = { 1, 1, 1 };
        public Vame.Image background_image;

        private int[] size = { 0, 0 };
        private string[] pressed_keys;

        public int key_delay = 15;

        public GameArea() {
            this.sprites = new GLib.List<Vame.Sprite>();
            this.texts = new GLib.List<Vame.Text>();
            this.sound_manager = new Vame.SoundManager();
            this.bg_type = Vame.BGType.COLOR;
            this.pressed_keys = { };

            this.set_can_focus(true);
            this.add_events(Gdk.EventMask.BUTTON_PRESS_MASK |
                            Gdk.EventMask.BUTTON_RELEASE_MASK |
                            Gdk.EventMask.POINTER_MOTION_MASK |
                            Gdk.EventMask.KEY_PRESS_MASK |
                            Gdk.EventMask.KEY_RELEASE_MASK);

            this.button_press_event.connect(this.button_press_event_cb);
            this.button_release_event.connect(this.button_release_event_cb);
            this.motion_notify_event.connect(this.motion_notify_event_cb);
            this.key_press_event.connect(this.key_press_event_cb);
            this.key_release_event.connect(this.key_release_event_cb);
            this.draw.connect(this.draw_cb);
        }

        private bool button_press_event_cb(Gtk.Widget self, Gdk.EventButton event) {
            if (event.get_event_type() == Gdk.EventType.BUTTON_PRESS &&
                event.get_event_type() != Gdk.EventType.DOUBLE_BUTTON_PRESS &&
                event.get_event_type() != Gdk.EventType.TRIPLE_BUTTON_PRESS) {

                ButtonType type = ButtonType.LEFT;
                if (event.button == 1) {
                    type = ButtonType.LEFT;
                } else if (event.button == 2) {
                    type = ButtonType.MIDDLE;
                } else if (event.button == 3) {
                    type = ButtonType.RIGHT;
                }

                this.click_released(type, (int)event.x, (int)event.y);
                this.click(type, (int)event.x, (int)event.y);
            }
            return false;
        }

        private bool button_release_event_cb(Gtk.Widget self, Gdk.EventButton event) {
            if (event.get_event_type() == Gdk.EventType.BUTTON_RELEASE &&
                event.get_event_type() != Gdk.EventType.DOUBLE_BUTTON_PRESS &&
                event.get_event_type() != Gdk.EventType.TRIPLE_BUTTON_PRESS) {

                ButtonType type = ButtonType.LEFT;
                if (event.button == 1) {
                    type = ButtonType.LEFT;
                } else if (event.button == 2) {
                    type = ButtonType.MIDDLE;
                } else if (event.button == 3) {
                    type = ButtonType.RIGHT;
                }

                this.click_released(type, (int)event.x, (int)event.y);
            }
            return false;
        }

        private bool motion_notify_event_cb(Gtk.Widget self, Gdk.EventMotion event) {
            this.pointer_motion((int)event.x, (int)event.y);
            return false;
        }

        private bool key_press_event_cb(Gtk.Widget self, Gdk.EventKey event) {
            string? key = Gdk.keyval_name(event.keyval);

            // check with (key != null && !(key in this.pressed_keys)) throw some warnings
            if (key == null) {
                return false;
            }

            foreach (string _key in this.pressed_keys) {
                if (_key == key) {
                    return false;
                }
            }

            this.pressed_keys += key;

            GLib.Timeout.add(this.key_delay, () => {
                this.key_pressed(key);

                // check with (key in this.pressed_keys) throw some warnings
                foreach (string _key in this.pressed_keys) {
                    if (_key == key) {
                        return true;
                    }
                }

                return false;
            });

            return false;
        }

        private bool key_release_event_cb(Gtk.Widget self, Gdk.EventKey event) {
            string? key = Gdk.keyval_name(event.keyval);

            // check with (key != null && key in this.pressed_keys) throw some warnings
            if (key == null) {
                return false;
            }

            string[] keys = { };
            foreach (string _key in this.pressed_keys) {
                if (_key != key) {
                    keys += _key;
                }
            }

            this.pressed_keys = keys;
            this.key_released(key);

            return false;
        }

        private bool draw_cb(Gtk.Widget self, Cairo.Context context) {
            Gtk.Allocation alloc;
            this.get_allocation(out alloc);

            if (this.size[0] != alloc.width || this.size[1] != alloc.height) {
                this.size = { alloc.width, alloc.height };
                this.size_changed(alloc.width, alloc.height);
            }

            // Draw background
            switch (this.bg_type) {
                case Vame.BGType.COLOR:
                    context.set_source_rgb(this.background_color[0], this.background_color[1], this.background_color[2]);
                    context.rectangle(0, 0, alloc.width, alloc.height);
                    context.fill();
                    break;

                case Vame.BGType.FUNCTION:
                    this.draw_background(context);
                    break;
            }

            // Draw all sprites
            foreach (Vame.Sprite sprite in this.sprites) {
                Cairo.Surface surface = Gdk.cairo_surface_create_from_pixbuf(sprite.image.pixbuf, 1, null);  // FIXME: change scale
                int x = sprite.x + sprite.anchor_x;
                int y = sprite.y + sprite.anchor_y;

                context.save();
                context.translate(x, y);

                context.rotate(Vame.Utils.degrees_to_radians(sprite.rotation));

                context.set_source_surface(surface, -sprite.anchor_x, -sprite.anchor_y);
                context.rectangle(-sprite.anchor_x, -sprite.anchor_y, sprite.image.get_width(), sprite.image.get_height());
                context.fill();

                context.restore();
            }

            foreach (Vame.Text text in this.texts) {
                context.move_to(text.x, text.y);
                context.set_source_rgb(text.color[0], text.color[1], text.color[2]);
                context.set_font_size(text.font_size);
                context.select_font_face(text.font_face, Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
                context.show_text(text.text);
            }

            return false;
        }

        public void add_sprite(Vame.Sprite sprite) {
            sprite.set_area(this);
            sprite.update.connect(() => { this.redraw(); });
            sprite.cursor_changed.connect((cursor) => { this.set_cursor(cursor); });
            this.sprites.append(sprite);
            this.redraw();
        }

        public void remove_sprite(Vame.Sprite sprite) {
            foreach (Vame.Sprite spr in this.sprites) {  // Checking if sprite is in this.sprites
                if (spr == sprite) {
                    sprite.remove_of_the_box();
                    this.sprites.remove(sprite);
                    this.redraw();
                    break;
                }
            }
        }

        public void add_text(Vame.Text text) {
            text.update.connect(() => {
                this.redraw();
            });
            this.texts.append(text);
            this.redraw();
        }

        public void remove_text(Vame.Text text) {
            foreach (Vame.Text txt in this.texts) {
                if (txt == text) { // Checking if text is in this.texts
                    this.texts.remove(text);
                    this.redraw();
                    break;
                }
            }
        }

        public void set_cursor(Gdk.CursorType type) {
            Gdk.Window win = this.get_window();
            Gdk.Cursor cursor = new Gdk.Cursor.for_display(Gdk.Display.get_default(), type);
            win.set_cursor(cursor);
        }

        public Vame.SoundManager get_sound_manager() {
            return this.sound_manager;
        }

        public void set_background_color(double? r = null, double? g = null, double? b = null) {
            this.bg_type = Vame.BGType.COLOR;

            double red = (r != null)? r: this.background_color[0];
            double green = (g != null)? g: this.background_color[1];
            double blue = (b != null)? b: this.background_color[2];

            this.background_color = { red, green, blue };
            this.redraw();
        }

        public void set_use_background_function() {
            this.bg_type = Vame.BGType.FUNCTION;
        }

        public void redraw() {
            GLib.Idle.add(() => {
                this.queue_draw();
                return false;
            });
        }

        public string[] get_pressed_keys() {
            return this.pressed_keys;
        }

        public void get_size(out int width, out int height) {
            width = this.size[0];
            height = this.size[1];
        }
    }
}