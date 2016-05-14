/*
Copyright (C) 2016, Cristian García <cristian99garcia@gmail.com>

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

public class KeyboardControlExample: Gtk.Window {

    public Vame.GameArea area;
    public Vame.Image image;
    public Vame.Sprite sprite;

    public string local_path;

    public KeyboardControlExample(string local_path) {
        this.local_path = local_path;

        this.set_title("¡Presiona las flechas para mover a mario!");

        this.area = new Vame.GameArea();
        this.area.set_size_request(400, 400);
        this.area.key_pressed.connect(this.key_pressed_cb);
        this.add(this.area);

        this.image = new Vame.Image(this.get_image_path("sprite.png"));
        this.sprite = new Vame.Sprite(this.image);
        this.area.add_sprite(this.sprite);

        int width = this.sprite.image.width;
        int height = this.sprite.image.height;
        this.sprite.set_pos(400 / 2 - width / 2, 400 / 2 - height);

        this.destroy.connect(Gtk.main_quit);
    }

    public string get_image_path(string name) {
        return GLib.Path.build_filename(this.local_path, @"src/icons/$name");
    }

    public void key_pressed_cb(Vame.GameArea area, string key) {
        int sprite_width = this.sprite.image.width;
        int sprite_height = this.sprite.image.height;
        int area_width, area_height;
        this.area.get_size(out area_width, out area_height);

        switch (key) {
            case Vame.K_LEFT:
                if (this.sprite.x - 5 >= 0) {
                    this.sprite.x -= 5;
                } else {
                    this.sprite.x = 0;
                }
                break;

            case Vame.K_RIGHT:
                if (this.sprite.x + 5 + sprite_width <= area_width) {
                    this.sprite.x += 5;
                } else {
                    this.sprite.x = area_width - sprite_width;
                }
                break;

            case Vame.K_UP:
                if (this.sprite.y - 5 >= 0) {
                    this.sprite.y -= 5;
                } else {
                    this.sprite.y = 0;
                }

                break;

            case Vame.K_DOWN:
                if (this.sprite.y + 5 + sprite_height <= area_height) {
                    this.sprite.y += 5;
                } else {
                    this.sprite.y = area_height - sprite_height;
                }
                break;
        }
    }
}

void main(string[] args) {
    Gtk.init(ref args);

    string path = GLib.File.new_for_commandline_arg(args[0]).get_parent().get_path();
    var example = new KeyboardControlExample(path);
    example.show_all();

    Gtk.main();
}