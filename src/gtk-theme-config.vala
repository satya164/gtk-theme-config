using Gtk;

public class Preferences : Dialog {

	private ColorButton color_button;
	private Widget apply_button;

	private string color_value;

	public Preferences () {

		this.title = "GTK theme preferences";
		this.window_position = WindowPosition.CENTER;
		this.border_width = 10;
		set_default_size (250, 250);

		// Set window icon
		try {
			this.icon = IconTheme.get_default ().load_icon ("preferences-desktop-wallpaper", 48, 0);
		} catch (Error e) {
			stderr.printf ("Could not load application icon: %s\n", e.message);
		}

		// Methods
		create_widgets ();
		connect_signals ();
	}

	private void create_widgets () {

		// Read the current value
		var settings = new GLib.Settings ("org.gnome.desktop.interface");
		var color_scheme = settings.get_string ("gtk-color-scheme");
		color_value = color_scheme.substring (18, color_scheme.length-19);

		var color = Gdk.RGBA ();
		color.parse ("%s".printf (color_value.to_string()));

		// Create and setup widgets
		var color_label = new Label.with_mnemonic ("_Selected color:");

		this.color_button = new ColorButton.with_rgba (color);

		// Layout widgets
		var hbox = new Box (Orientation.HORIZONTAL, 0);
		hbox.pack_start (color_label, true, true, 0);
		hbox.pack_start (color_button, true, true, 0);
		var content = get_content_area () as Box;
		content.pack_start (hbox, false, true, 0);
		content.spacing = 10;

		// Add buttons to button area at the bottom
		this.apply_button = add_button (Stock.APPLY, ResponseType.APPLY);
		this.apply_button.sensitive = false;
		add_button ("_Reset to defaults", ResponseType.ACCEPT);
		add_button (Stock.CLOSE, ResponseType.CLOSE);

		show_all ();
	}

	private void connect_signals () {
		color_button.color_set.connect (() => {
			on_color_set ();
			this.apply_button.sensitive = true;
		});
		this.response.connect (on_response);
	}

	private void on_response (Dialog source, int response_id) {
		switch (response_id) {
		case ResponseType.APPLY:
			on_set_clicked ();
			break;
		case ResponseType.ACCEPT:
			on_set_defaults ();
			break;
		case ResponseType.CLOSE:
			destroy ();
			break;
		}
	}

	private void on_set_defaults () {
		reset_defaults ();
		this.apply_button.sensitive = false;
	}

	private void on_set_clicked () {
		reset_defaults ();
		write_config ();
		this.apply_button.sensitive = false;
	}

	private void on_color_set () {
		var color =  this.color_button.get_rgba ();

		int r = (int)Math.round (color.red * 255);
		int g = (int)Math.round (color.green * 255);
		int b = (int)Math.round (color.blue * 255);

		color_value = "#%02x%02x%02x".printf (r, g, b);
	}

	private void reset_defaults () {
		try {
			Process.spawn_command_line_sync ("gsettings reset org.gnome.desktop.interface gtk-color-scheme");
			Process.spawn_command_line_sync ("gconftool-2 -u /desktop/gnome/interface/gtk_color_scheme");
			Process.spawn_command_line_sync ("xfconf-query -c xsettings -p /Gtk/ColorScheme -r");
		} catch (Error e) {
			stderr.printf ("Could not reset configuration: %s\n", e.message);
		}
	}

	private void write_config () {
		string color_scheme = "\"selected_bg_color:%s;\"".printf (color_value);

		try {
			Process.spawn_command_line_sync ("gsettings set org.gnome.desktop.interface gtk-color-scheme %s".printf (color_scheme));
			Process.spawn_command_line_sync ("gconftool-2 -s /desktop/gnome/interface/gtk_color_scheme -t string %s".printf (color_scheme));
			Process.spawn_command_line_sync ("xfconf-query -n -c xsettings -p /Gtk/ColorScheme -t string -s %s".printf (color_scheme));
		} catch (Error e) {
			stderr.printf ("Could not set configuration: %s\n", e.message);
		}
	}
}

int main (string[] args) {
	Gtk.init (ref args);
	var dialog = new Preferences ();
	dialog.destroy.connect (Gtk.main_quit);
	dialog.show ();
	Gtk.main ();
	return 0;
}
