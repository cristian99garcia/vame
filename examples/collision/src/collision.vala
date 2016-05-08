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
    public Vame.GameArea area;
    public Vame.Text text;
    public Vame.Sprite sprite1;
    public Vame.Sprite sprite2;

    public string local_path;

    public CollisionExample(string local_path) {
        this.set_resizable(false);

        this.local_path = local_path;

        this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        this.box.set_border_width(10);
        this.add(this.box);

        this.area = new Vame.GameArea();  // Make a new GameArea instance
        this.area.set_size_request(400, 400);
        this.area.motion.connect(this.mouse_motion_cb);  // Connect "motion" signal
        this.box.pack_start(this.area, true, true, 0);  // And add it into a Gtk.Widget

        this.text = new Vame.Text("Sin colisión");
        this.area.add_text(this.text);

        this.text.color = { 0.1, 0.8, 0.1 };
        this.text.set_pos(400 / 2 - this.text.width / 2, 400 - this.text.height);

        Vame.Image image = new Vame.Image(this.get_image_path("sprite1.png"));
        this.sprite1 = new Vame.Sprite(image);
        this.area.add_sprite(this.sprite1);

        image = new Vame.Image(this.get_image_path("sprite2.png"));
        this.sprite2 = new Vame.Sprite(image);
        this.sprite2.set_pos(400 / 2 - this.sprite2.image.width / 2, 400 / 2 - this.sprite2.image.height);
        this.area.add_sprite(this.sprite2);

        this.destroy.connect(Gtk.main_quit);
    }

    public string get_image_path(string name) {
        return GLib.Path.build_filename(this.local_path, @"src/icons/$name");
    }

    public void mouse_motion_cb(Vame.GameArea area, int x, int y) {
        this.sprite1.set_pos(x - this.sprite1.image.width / 2, y - this.sprite1.image.height / 2);
        this.check_collision();
    }

    public void check_collision() {
        if (this.sprite1.check_collision(this.sprite2)) {
            this.text.text = "¡Colisión!";
            this.text.color = { 0.8, 0.1, 0.1 };
        } else {
            this.text.text = "Sin colisión";
            this.text.color = { 0.1, 0.8, 0.1 };
        }
    }
}

void main(string[] args) {
    Gtk.init(ref args);

    CollisionExample example = new CollisionExample(GLib.File.new_for_commandline_arg(args[0]).get_parent().get_path());
    example.show_all();

    Gtk.main();
}