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

    public class Image {

        public signal void update();

        public int width = 0;
        public int height = 0;
        public double scale = 1;
        public string path;
        public Gdk.Pixbuf pixbuf;

        public Image(string path) {
            this.set_from_path(path, false);
        }

        public Image.from_pixbuf(Gdk.Pixbuf pixbuf) {
            this.set_from_pixbuf(pixbuf, false);
        }

        public void set_from_path(string path, bool update = true) {
            try {
                this.path = path;
                this.pixbuf = new Gdk.Pixbuf.from_file(path);
                this.width = this.pixbuf.get_width();
                this.height = this.pixbuf.get_height();

                if (update) {
                    this.update();
                }
            } catch (GLib.Error error) {
                print("Error trying load a image: %s does not exist\n", path);
            }
        }

        public void set_from_path_at_size(string path, int width, int height, bool update = true) {
            try {
                this.path = path;
                this.width = width;
                this.height = height;
                this.pixbuf = new Gdk.Pixbuf.from_file_at_size(path, width, height);
            } catch (GLib.Error error) {
                print("Error trying load a image: %s does not exists\n", path);
            }
        }

        public void set_from_pixbuf(Gdk.Pixbuf pixbuf, bool update = true) {
            this.pixbuf = pixbuf;
            this.width = this.pixbuf.get_width();
            this.height = this.pixbuf.get_height();

            if (update) {
                this.update();
            }
        }

        public int get_width() {
            return this.width;
        }

        public int get_height() {
            return this.height;
        }
    }

    public class Frame: Vame.Image {

        public int rows;
        public int columns;
        public int x = 0;
        public int y = 0;
        public int total_width;
        public int total_height;
        public int frame_width;
        public int frame_height;

        public Gdk.Pixbuf total_pixbuf;

        public Frame(string path, int rows = 1, int columns = 1, int x = 0, int y = 0) {
            base(path);  // Ignore this

            this.rows = rows;
            this.columns = columns;
            this.x = x;
            this.y = y;

            try {
                this.total_pixbuf = new Gdk.Pixbuf.from_file(path);
                this.total_width = this.total_pixbuf.get_width();
                this.total_height = this.total_pixbuf.get_height();
                this.frame_width = width / rows;
                this.frame_height = height / columns;

                this.make_subpixbuf(x, y, false);
            } catch (GLib.Error error) {
                print("Error trying load a image: %s does not exists\n", path);
            }
        }

        public void make_subpixbuf(int x, int y, bool update = true) {
            this.pixbuf = new Gdk.Pixbuf.subpixbuf(this.total_pixbuf, x * this.frame_width, y * this.frame_height, this.frame_width, this.frame_height);

            if (update) {
                this.update();
            }
        }

        public void make_subpixbuf_with_all_values(int x, int y, int width, int height, bool update = true) {
            this.pixbuf = new Gdk.Pixbuf.subpixbuf(this.total_pixbuf, x, y, width, height);

            if (update) {
                this.update();
            }
        }

        public new int get_width() {
            return this.frame_width;
        }

        public new int get_height() {
            return this.frame_height;
        }
    }
}
