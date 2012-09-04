using Gtk;

class ThemePrefWindow : ApplicationWindow {

	private Separator separator1;
	private Separator separator2;

	private Label heading1;
	private Label heading2;

	private Label tip;

	private Label switch_label;
	private Label color_label;
	private Label panelbg_label;
	private Label panelfg_label;
	private Label menubg_label;
	private Label menufg_label;

	private ColorButton color_button;
	private ColorButton panelbg_button;
	private ColorButton panelfg_button;
	private ColorButton menubg_button;
	private ColorButton menufg_button;

	private Switch custom_switch;

	private Button apply_button;
	private Button reset_button;
	private Button close_button;

	private Gdk.RGBA color;
	private Gdk.RGBA panelbg;
	private Gdk.RGBA panelfg;
	private Gdk.RGBA menubg;
	private Gdk.RGBA menufg;

	private string color_value;
	private string panelbg_value;
	private string panelfg_value;
	private string menubg_value;
	private string menufg_value;

	internal ThemePrefWindow (ThemePrefApp app) {
		Object (application: app, title: "GTK theme preferences");

		this.window_position = WindowPosition.CENTER;
		this.border_width = 10;

		// Set window icon
		try {
			this.icon = IconTheme.get_default ().load_icon ("preferences-desktop-wallpaper", 48, 0);
		} catch (Error e) {
			stderr.printf ("Could not load application icon: %s\n", e.message);
		}

		// Methods
		read_values ();
		create_widgets ();
		connect_signals ();
	}

	private void read_values () {

		// Read the current value
		var settings = new GLib.Settings ("org.gnome.desktop.interface");
		var color_scheme = settings.get_string ("gtk-color-scheme");
		color_value = color_scheme.substring (18, color_scheme.length-19);

		color = Gdk.RGBA ();
		color.parse ("%s".printf (color_value.to_string()));
	}

	private void create_widgets () {

		// Create and setup widgets
		this.custom_switch = new Switch ();
		this.custom_switch.set_halign (Gtk.Align.END);

		this.separator1 = new Separator (Gtk.Orientation.HORIZONTAL);
		this.separator2 = new Separator (Gtk.Orientation.HORIZONTAL);

		this.heading1 = new Label.with_mnemonic ("_<b>Colors</b>");
		this.heading1.set_use_markup (true);
		this.heading1.set_halign (Gtk.Align.START);
		this.heading2 = new Label.with_mnemonic ("_<b>Widgets</b>");
		this.heading2.set_use_markup (true);
		this.heading2.set_halign (Gtk.Align.START);
		this.tip = new Label.with_mnemonic ("_<b>Tip:</b> You need to restart running apps to apply changes.");
		this.tip.set_use_markup (true);
		this.tip.set_halign (Gtk.Align.START);

		this.switch_label = new Label.with_mnemonic ("_Custom widgets");
		this.switch_label.set_halign (Gtk.Align.START);
		this.color_label = new Label.with_mnemonic ("_Selected background color");
		this.color_label.set_halign (Gtk.Align.START);
		this.panelbg_label = new Label.with_mnemonic ("_Panel background color");
		this.panelbg_label.set_halign (Gtk.Align.START);
		this.panelfg_label = new Label.with_mnemonic ("_Panel text color");
		this.panelfg_label.set_halign (Gtk.Align.START);
		this.menubg_label = new Label.with_mnemonic ("_Menu background color");
		this.menubg_label.set_halign (Gtk.Align.START);
		this.menufg_label = new Label.with_mnemonic ("_Menu text color");
		this.menufg_label.set_halign (Gtk.Align.START);

		this.color_button = new ColorButton.with_rgba (color);
		this.panelbg_button = new ColorButton.with_rgba (panelbg);
		this.panelfg_button = new ColorButton.with_rgba (panelfg);
		this.menubg_button = new ColorButton.with_rgba (menubg);
		this.menufg_button = new ColorButton.with_rgba (menufg);

		this.apply_button = new Button.from_stock (Stock.APPLY);
		this.apply_button.sensitive = false;
		this.reset_button = new Button.from_stock(Stock.REVERT_TO_SAVED);
		this.close_button = new Button.from_stock (Stock.CLOSE);

		// Layout widgets
		var grid = new Grid ();
		grid.set_column_homogeneous (true);
		grid.set_column_spacing (10);
		grid.set_row_spacing (10);
		grid.set_border_width (10);
		grid.attach (heading1, 0, 0, 1, 1);
		grid.attach_next_to (separator1, heading1, Gtk.PositionType.RIGHT, 2, 1);
		grid.attach (color_label, 0, 1, 2, 1);
		grid.attach_next_to (color_button, color_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (heading2, 0, 2, 1, 1);
		grid.attach_next_to (separator2, heading2, Gtk.PositionType.RIGHT, 2, 1);
		grid.attach (tip, 0, 3, 3, 1);
		grid.attach (switch_label, 0, 4, 2, 1);
		grid.attach_next_to (custom_switch, switch_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (panelbg_label, 0, 5, 2, 1);
		grid.attach_next_to (panelbg_button, panelbg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (panelfg_label, 0,6, 2, 1);
		grid.attach_next_to (panelfg_button, panelfg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (menubg_label, 0, 7, 2, 1);
		grid.attach_next_to (menubg_button, menubg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (menufg_label, 0, 8, 2, 1);
		grid.attach_next_to (menufg_button, menufg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (apply_button, 0, 9, 1, 1);
		grid.attach_next_to (reset_button, apply_button, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach_next_to (close_button, reset_button, Gtk.PositionType.RIGHT, 1, 1);

		this.add (grid);
	}

	private void connect_signals () {
		color_button.color_set.connect (() => {
			on_selected_color_set ();
			this.apply_button.sensitive = true;
		});
		panelbg_button.color_set.connect (() => {
			on_panelbg_color_set ();
			this.apply_button.sensitive = true;
		});
		panelfg_button.color_set.connect (() => {
			on_panelfg_color_set ();
			this.apply_button.sensitive = true;
		});
		menubg_button.color_set.connect (() => {
			on_menubg_color_set ();
			this.apply_button.sensitive = true;
		});
		menufg_button.color_set.connect (() => {
			on_menufg_color_set ();
			this.apply_button.sensitive = true;
		});
		apply_button.clicked.connect (() => {
			reset_defaults ();
			write_config ();
			this.apply_button.sensitive = false;
		});
		reset_button.clicked.connect (() => {
			reset_defaults ();
			this.apply_button.sensitive = false;
			this.reset_button.sensitive = false;
		});
		close_button.clicked.connect (() => {
			destroy ();
		});
	}

	private void on_selected_color_set () {
		var color =  this.color_button.get_rgba ();

		int r = (int)Math.round (color.red * 255);
		int g = (int)Math.round (color.green * 255);
		int b = (int)Math.round (color.blue * 255);

		color_value = "#%02x%02x%02x".printf (r, g, b);
	}

	private void on_panelbg_color_set () {
		var color =  this.panelbg_button.get_rgba ();

		int r = (int)Math.round (color.red * 255);
		int g = (int)Math.round (color.green * 255);
		int b = (int)Math.round (color.blue * 255);

		panelbg_value = "#%02x%02x%02x".printf (r, g, b);
	}

	private void on_panelfg_color_set () {
		var color =  this.panelfg_button.get_rgba ();

		int r = (int)Math.round (color.red * 255);
		int g = (int)Math.round (color.green * 255);
		int b = (int)Math.round (color.blue * 255);

		panelfg_value = "#%02x%02x%02x".printf (r, g, b);
	}

	private void on_menubg_color_set () {
		var color =  this.menubg_button.get_rgba ();

		int r = (int)Math.round (color.red * 255);
		int g = (int)Math.round (color.green * 255);
		int b = (int)Math.round (color.blue * 255);

		menubg_value = "#%02x%02x%02x".printf (r, g, b);
	}

	private void on_menufg_color_set () {
		var color =  this.menufg_button.get_rgba ();

		int r = (int)Math.round (color.red * 255);
		int g = (int)Math.round (color.green * 255);
		int b = (int)Math.round (color.blue * 255);

		menufg_value = "#%02x%02x%02x".printf (r, g, b);
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

class ThemePrefApp : Gtk.Application {
	protected override void activate () {

		var window = new ThemePrefWindow (this);
		window.show_all (); //show all the things
	}

	internal ThemePrefApp () {
		Object (application_id: "org.example.checkbutton");
	}
}

int main (string[] args) {
	return new ThemePrefApp ().run (args);
}
