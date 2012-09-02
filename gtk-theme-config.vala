using Gtk;

public class Preferences : Dialog {

	private File gtk3_config_file;

	private ColorButton color_button;
	private Widget apply_button;

	private string color_value;

	public Preferences () {

		this.title = "GTK theme preferences";
		this.border_width = 10;
		set_default_size (250, 300);

		// Set window icon
		try {
			this.icon = IconTheme.get_default ().load_icon ("preferences-desktop-wallpaper", 48, 0);
			} catch (Error e) {
			stderr.printf ("Could not load application icon: %s\n", e.message);
			}

		// Methods
		read_config();
		create_widgets ();
		connect_signals ();
	}

	private void read_config () {

		// Detect the theme name
		// var settings = new GLib.Settings ("org.gnome.desktop.interface");
		// var gtk_theme = settings.get_string ("gtk-theme");

		// Set the path of config file
		var gtk3_path = File.new_for_path (Environment.get_user_config_dir ());
		
		gtk3_config_file = gtk3_path.get_child ("gtk-3.0").get_child ("gtk.css");

		// Read the config file and create path if doesn't exist
		if (gtk3_config_file.query_exists ()) {
			try {
				var dis = new DataInputStream (gtk3_config_file.read ());
				string line;
				while ((line = dis.read_line (null)) != null) {
					if ("@define-color selected_bg_color" in line) {
						color_value = line.substring (32, line.length-33);
					}
				}
			} catch (Error e) {
				stderr.printf ("%s", e.message);
			}
		} else {
			set_defaults();
			gtk3_config_file.get_parent().get_path();
				
			try {
				gtk3_config_file.get_parent().make_directory(null);
			} catch (Error e) {
				stderr.printf ("%s", e.message);
			}
		}
	}

	private void set_defaults () {

		// Delete the config file
		if (gtk3_config_file.query_exists ()) {
			try {
				gtk3_config_file.delete ();
			} catch (Error e) {
				stderr.printf ("%s", e.message);
			}
		}

		// Set default config
		color_value = "#398ee7";
	}

	private void create_widgets () {

		// Create and setup widgets
		var description = new Label ("Change GTK theme color");

		var color_label = new Label ("Selected color:");

		var tip = new Label (null);
		tip.set_markup ("<b>Tip:</b> Changes will not take effect until you restart the running applications.");
		tip.set_line_wrap (true);

		// Read config file and set values
		read_config();

		var color = Gdk.RGBA ();
		color.parse ("%s".printf(color_value.to_string()));

		this.color_button = new ColorButton.with_rgba (color);

		// Layout widgets
		var hbox = new Box (Orientation.HORIZONTAL, 10);
		hbox.pack_start (color_label, true, true, 0);
		hbox.pack_start (this.color_button, true, true, 0);
		var content = get_content_area () as Box;
		content.pack_start (description, false, true, 0);
		content.pack_start (hbox, false, true, 0);
		content.pack_start (tip, false, true, 0);
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
			on_color_set();
			this.apply_button.sensitive = true;
		});	
		this.response.connect (on_response);
	}

	private void on_response (Dialog source, int response_id) {
		switch (response_id) {
		case ResponseType.ACCEPT:
			set_defaults();
			break;
		case ResponseType.APPLY:
			on_set_clicked ();
			break;
		case ResponseType.CLOSE:
			destroy ();
			break;
		}
	}

	private void on_color_set () {
		var color =  this.color_button.get_rgba ();
		color_value = "%s".printf(color.to_string());
	}

	private void on_set_clicked () {
		write_config ();
		this.apply_button.sensitive = false;
	}

	private void write_config () {
		if (gtk3_config_file.query_exists ()) {
			try {
				gtk3_config_file.delete ();
			} catch (Error e) {
				stderr.printf ("%s", e.message);
			}
		}
		try {
			var dos = new DataOutputStream (gtk3_config_file.create (FileCreateFlags.REPLACE_DESTINATION));
			dos.put_string ("/* GTK theme preferences */\n");
			string text = "@define-color selected_bg_color %s;\n@define-color theme_selected_bg_color %s;".printf(color_value, color_value);
			uint8[] data = text.data;
			long written = 0;
			while (written < data.length) {
				written += dos.write (data[written:data.length]);
			}
		} catch (Error e) {
			stderr.printf ("%s", e.message);
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
