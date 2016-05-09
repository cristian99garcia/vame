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

public class CollisionExample: Gtk.Window {

    public Gtk.Box box;
    public Gtk.Scale vscale;
    public Gtk.Scale hscale;

    public Vame.Sprite sprite;
    public Vame.GameArea area;

    public string local_path;

    public CollisionExample(string local_path) {
        this.local_path = local_path;

        this.set_resizable(false);

        this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        this.box.set_border_width(10);
        this.add(this.box);

        Gtk.Box hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        this.box.pack_start(hbox, true, true, 2);

        this.area = new Vame.GameArea();  // Make a new GameArea instance
        this.area.set_size_request(400, 400);
        hbox.pack_start(this.area, true, true, 2);  // And add it into a Gtk.Widget

        Vame.Image image = new Vame.Image(this.get_image_path("sprite.png"));
        int width = image.width;
        int height = image.height;

        this.sprite = new Vame.Sprite(image);
        this.sprite.set_pos(400 / 2 - width / 2, 400 / 2 - height / 2);
        this.area.add_sprite(this.sprite);

        this.vscale = new Gtk.Scale.with_range(Gtk.Orientation.VERTICAL, 0, 400 - height, 1);
        this.vscale.set_draw_value(false);
        this.vscale.set_value(400 / 2 - height / 2);
        this.vscale.value_changed.connect(this.y_changed);
        hbox.pack_end(this.vscale, false, false, 0);

        this.hscale = new Gtk.Scale.with_range(Gtk.Orientation.HORIZONTAL, 0, 400 - width, 1);
        this.hscale.set_draw_value(false);
        this.hscale.set_value(400 / 2 - width / 2);
        this.hscale.value_changed.connect(this.x_changed);
        this.box.pack_end(this.hscale, false, false, 0);
    }

    public string get_image_path(string name) {
        string path = GLib.Path.build_filename(this.local_path, @"src/icons/$name");
        return path;
    }

    public void x_changed(Gtk.Range range) {
        this.sprite.x = (int)this.hscale.get_value();
    }

    public void y_changed(Gtk.Range range) {
        this.sprite.y = (int)this.vscale.get_value();
    }
}

void main(string[] args) {
    Gtk.init(ref args);

    CollisionExample example = new CollisionExample(GLib.File.new_for_commandline_arg(args[0]).get_parent().get_path());
    example.show_all();

    Gtk.main();
}