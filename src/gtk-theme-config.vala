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

	private Gdk.RGBA color_rgb;

	private File config_dir;
	private File home_dir;

	private File gtk3_config_file;
	private File gtk2_config_file;

	private File gtk3_saved_file;
	private File gtk2_saved_file;

	private File config_path;
	private File theme_path;

	private string color_hex;

	private string color_value;
	private string panelbg_value;
	private string panelfg_value;
	private string menubg_value;
	private string menufg_value;

	private string selected_color_changed;

	internal ThemePrefWindow (ThemePrefApp app) {
		Object (application: app, title: "GTK theme preferences");

		this.window_position = WindowPosition.CENTER;
		this.resizable = false;
		this.border_width = 10;

		// Set window icon
		try {
			this.icon = IconTheme.get_default ().load_icon ("preferences-desktop-theme", 48, 0);
		} catch (Error e) {
			stderr.printf ("Could not load application icon: %s\n", e.message);
		}

		// Methods
		read_values ();
		create_widgets ();
		connect_signals ();
	}

	private void read_values () {

		// Read the current values
		var settings = new GLib.Settings ("org.gnome.desktop.interface");
		var color_scheme = settings.get_string ("gtk-color-scheme");
		var theme_name = settings.get_string ("gtk-theme");

		// Set paths of config files
		config_dir = File.new_for_path (Environment.get_user_config_dir ());
		home_dir = File.new_for_path (Environment.get_home_dir ());

		gtk3_config_file = config_dir.get_child ("gtk-3.0").get_child ("gtk.css");
		gtk3_saved_file = config_dir.get_child ("gtk-3.0").get_child ("gtk.css.saved");	

		gtk2_config_file = home_dir.get_child (".gtkrc-2.0");
		gtk2_saved_file = home_dir.get_child (".gtkrc-2.0.saved");

		// Create path if doesn't exist
		if (!gtk3_config_file.get_parent().query_exists ()) {
			try {
				gtk3_config_file.get_parent().make_directory_with_parents(null);
			} catch (Error e) {
				stderr.printf ("Could not create parent directory: %s\n", e.message);
			}
		}

		// Detect current theme path
		if (home_dir.get_child (".themes/%s/gtk-3.0/gtk-main.css".printf (theme_name)).query_exists ()) {
			theme_path = home_dir.get_child (".themes/%s/gtk-3.0/gtk-main.css".printf (theme_name));
		} else if (home_dir.get_child (".themes/%s/gtk-3.0/gtk.css".printf (theme_name)).query_exists ()) {
			theme_path = home_dir.get_child (".themes/%s/gtk-3.0/gtk.css".printf (theme_name));
		} else if (File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk-main.css".printf (theme_name)).query_exists ()) {
			theme_path = File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk-main.css".printf (theme_name));
		} else if (File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk.css".printf (theme_name)).query_exists ()) {
			theme_path = File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk.css".printf (theme_name));
		} else {
			theme_path = gtk3_config_file;
		}

		if ("#" in color_scheme) {
			color_value = color_scheme.substring (18, color_scheme.length-19);
		} else if (!home_dir.get_child (".themes/%s/gtk-3.0/gtk.gresource".printf (theme_name)).query_exists () && !File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk.gresource".printf (theme_name)).query_exists () && theme_path.query_exists ()) {
			try {
				var dis = new DataInputStream (theme_path.read ());
				string line;
				while ((line = dis.read_line (null)) != null) {
					if ("@define-color selected_bg_color" in line) {
						color_value = line.substring (32, line.length-33);
					}
				}
			} catch (Error e) {
				stderr.printf ("Could not read user theme: %s\n", e.message);
			}
		} else {
			color_value = "#398ee7";
		}

		// Read the config file
		if (gtk3_config_file.query_exists ()) {
			config_path = gtk3_config_file;
		} else {
			config_path = gtk3_saved_file;
		}

		if (config_path.query_exists ()) {
			try {
				var dis = new DataInputStream (config_path.read ());
				string line;
				while ((line = dis.read_line (null)) != null) {
					if ("@define-color panel_bg_color" in line) {
						panelbg_value = line.substring (29, line.length-30);
					}
					if ("@define-color panel_fg_color" in line) {
						panelfg_value = line.substring (29, line.length-30);
					}
					if ("@define-color menu_bg_color" in line) {
						menubg_value = line.substring (28, line.length-29);
					}
					if ("@define-color menu_fg_color" in line) {
						menufg_value = line.substring (28, line.length-29);
					}
				}
			} catch (Error e) {
				stderr.printf ("Could not read configuration: %s\n", e.message);
			}
		} else {
			panelbg_value = "#cccccc";
			panelfg_value = "#333333";
			menubg_value = "#eeeeee";
			menufg_value = "#333333";
		}

		// Parse colors
		color = Gdk.RGBA ();
		color.parse ("%s".printf (color_value.to_string()));
		panelbg = Gdk.RGBA ();
		panelbg.parse ("%s".printf (panelbg_value.to_string()));
		panelfg = Gdk.RGBA ();
		panelfg.parse ("%s".printf (panelfg_value.to_string()));
		menubg = Gdk.RGBA ();
		menubg.parse ("%s".printf (menubg_value.to_string()));
		menufg = Gdk.RGBA ();
		menufg.parse ("%s".printf (menufg_value.to_string()));
	}

	private void create_widgets () {

		// Create and setup widgets
		this.custom_switch = new Switch ();
		this.custom_switch.set_halign (Gtk.Align.END);

		if (gtk3_config_file.query_exists ()) {
			this.custom_switch.set_active (true);
		}

		this.separator1 = new Separator (Gtk.Orientation.HORIZONTAL);
		this.separator2 = new Separator (Gtk.Orientation.HORIZONTAL);

		this.heading1 = new Label.with_mnemonic ("_<b>Colors</b>");
		this.heading1.set_use_markup (true);
		this.heading1.set_halign (Gtk.Align.START);
		this.heading2 = new Label.with_mnemonic ("_<b>Widgets</b>");
		this.heading2.set_use_markup (true);
		this.heading2.set_halign (Gtk.Align.START);
		this.tip = new Label.with_mnemonic ("_<b>Tip:</b> You need to logout and login back to apply changes.");
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
		custom_switch.notify["active"].connect (() => {
			if ((custom_switch as Switch).get_active()) {
				restore_config ();
			} else {
				save_config ();
			}
		});
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
			on_settings_applied ();
			this.apply_button.sensitive = false;
			this.reset_button.sensitive = true;
		});
		reset_button.clicked.connect (() => {
			reset_color_scheme ();
			reset_config ();
			this.apply_button.sensitive = false;
			this.reset_button.sensitive = false;
			this.custom_switch.set_active (false);
		});
		close_button.clicked.connect (() => {
			destroy ();
		});
	}

	private void rgb_to_hex () {
		int r = (int)Math.round (color_rgb.red * 255);
		int g = (int)Math.round (color_rgb.green * 255);
		int b = (int)Math.round (color_rgb.blue * 255);

		color_hex = "#%02x%02x%02x".printf (r, g, b);
	}

	private void on_selected_color_set () {
		color_rgb =  this.color_button.get_rgba ();
		rgb_to_hex ();
		color_value = color_hex;
		selected_color_changed = "true";
	}

	private void on_panelbg_color_set () {
		color_rgb =  this.panelbg_button.get_rgba ();
		rgb_to_hex ();
		panelbg_value = color_hex;
	}

	private void on_panelfg_color_set () {
		color_rgb =  this.panelfg_button.get_rgba ();
		rgb_to_hex ();
		panelfg_value = color_hex;
	}

	private void on_menubg_color_set () {
		color_rgb =  this.menubg_button.get_rgba ();
		rgb_to_hex ();
		menubg_value = color_hex;
	}

	private void on_menufg_color_set () {
		color_rgb =  this.menufg_button.get_rgba ();
		rgb_to_hex ();
		menufg_value = color_hex;
	}

	private void on_settings_applied () {
		if (selected_color_changed == "true") {
			set_color_scheme ();
		}
		if ((custom_switch as Switch).get_active()) {
			reset_config ();
			write_config ();
		}
	}

	private void set_color_scheme () {
		string color_scheme = "\"selected_bg_color:%s;\"".printf (color_value);

		try {
			Process.spawn_command_line_sync ("gsettings set org.gnome.desktop.interface gtk-color-scheme %s".printf (color_scheme));
			Process.spawn_command_line_sync ("gconftool-2 -s /desktop/gnome/interface/gtk_color_scheme -t string %s".printf (color_scheme));
			Process.spawn_command_line_sync ("xfconf-query -n -c xsettings -p /Gtk/ColorScheme -t string -s %s".printf (color_scheme));
		} catch (Error e) {
			stderr.printf ("Could not set color scheme: %s\n", e.message);
		}
	}

	private void reset_color_scheme () {
		try {
			Process.spawn_command_line_sync ("gsettings reset org.gnome.desktop.interface gtk-color-scheme");
			Process.spawn_command_line_sync ("gconftool-2 -u /desktop/gnome/interface/gtk_color_scheme");
			Process.spawn_command_line_sync ("xfconf-query -c xsettings -p /Gtk/ColorScheme -r");
		} catch (Error e) {
			stderr.printf ("Could not reset color scheme: %s\n", e.message);
		}
	}

	private void restore_config () {
		try {
			if (gtk3_saved_file.query_exists ()) {
				gtk3_saved_file.set_display_name ("gtk.css");
			}
			if (gtk2_saved_file.query_exists ()) {
				gtk2_saved_file.set_display_name (".gtkrc-2.0");
			}
		} catch (Error e) {
			stderr.printf ("Could not restore configuration: %s\n", e.message);
		}
	}
			
	private void save_config () {
		try {
			if (gtk3_config_file.query_exists ()) {
				gtk3_config_file.set_display_name ("gtk.css.saved");
			}
			if (gtk2_config_file.query_exists ()) {
				gtk2_config_file.set_display_name (".gtkrc-2.0.saved");
			}
		} catch (Error e) {
			stderr.printf ("Could not save configuration: %s\n", e.message);
		}
	}
			
	private void reset_config () {
		if (gtk3_config_file.query_exists ()) {
			try {
				gtk3_config_file.delete ();
			} catch (Error e) {
				stderr.printf ("Could not reset gtk3 configuration: %s\n", e.message);
			}
		}

		if (gtk2_config_file.query_exists ()) {
			try {
				gtk2_config_file.delete ();
			} catch (Error e) {
				stderr.printf ("Could not reset gtk2 configuration: %s\n", e.message);
			}
		}
	}

	private void write_config () {
		try {
			var dos = new DataOutputStream (gtk3_config_file.create (FileCreateFlags.REPLACE_DESTINATION));
			dos.put_string ("/* GTK theme preferences */\n");
			string text = "@define-color panel_bg_color %s;\n@define-color panel_fg_color %s;\n@define-color menu_bg_color %s;\n@define-color menu_fg_color %s;\nPanelWidget,PanelApplet,PanelToplevel,PanelSeparator,.gnome-panel-menu-bar,PanelApplet > GtkMenuBar.menubar,PanelApplet > GtkMenuBar.menubar.menuitem,PanelMenuBar.menubar,PanelMenuBar.menubar.menuitem,PanelAppletFrame,UnityPanelWidget,.unity-panel,.unity-panel.menubar,.unity-panel .menubar{background-image:-gtk-gradient(linear,left top,left bottom,from(shade(@panel_bg_color,1.2)),to (shade(@panel_bg_color,0.9)));border-color:shade(@panel_bg_color,0.8);color:@panel_fg_color;}\nPanelApplet .button:prelight,.unity-panel.menubar.menuitem:hover,.unity-panel.menubar .menuitem *:hover{background-image:-gtk-gradient(linear,left top,left bottom,from (shade(@panel_bg_color,1.5)),to (shade(@panel_bg_color,1.2)));border-color:shade(@panel_bg_color,0.85);color:@panel_fg_color;}\nPanelApplet .button{background-image:-gtk-gradient(linear,left top,left bottom,from (shade(@panel_bg_color,1.3)),to (shade(@panel_bg_color,1.0)));border-color:shade(@panel_bg_color,0.7);color:@panel_fg_color;text-shadow:none;}\nPanelApplet .button:prelight:active,PanelApplet .button:active{background-image:-gtk-gradient(linear,left top,left bottom,from (shade(@panel_bg_color,0.85)),to (shade(@panel_bg_color,1.0)));border-color:shade(@panel_bg_color,0.7);}\nGtkTreeMenu.menu,GtkMenuToolButton.menu,GtkComboBox .menu,.primary-toolbar .button .menu,.toolbar .menu,.toolbar .primary-toolbar .menu,.menu{background-color:@menu_bg_color;color:@menu_fg_color;border-color:shade(@menu_bg_color,0.7);box-shadow:none;-unico-inner-stroke-width:0;}\nGtkTreeMenu .menuitem *,GtkMenuToolButton .menuitem *,GtkComboBox .menuitem *,GtkTreeMenu.menu .menuitem,GtkMenuToolButton.menu .menuitem,GtkComboBox .menu .menuitem,.primary-toolbar .button .menu .menuitem,.toolbar .menu .menuitem,.toolbar .primary-toolbar .menu .menuitem,.menu .menuitem{color:@menu_fg_color;text-shadow:none;}\nGtkTreeMenu .menuitem *:insensitive,GtkMenuToolButton .menuitem *:insensitive,GtkComboBox .menuitem *:insensitive,.menu .menuitem *:insensitive,GtkTreeMenu.menu .menuitem:insensitive,GtkMenuToolButton.menu .menuitem:insensitive,GtkComboBox .menu .menuitem:insensitive,.primary-toolbar .button .menu .menuitem:insensitive,.toolbar .menu .menuitem:insensitive,.toolbar .primary-toolbar .menu .menuitem:insensitive,.menu .menuitem:insensitive{color:mix(@menu_fg_color,@menu_bg_color,0.4);text-shadow:none;}\n.menuitem .accelerator{color:alpha(@menu_fg_color,0.6);}\n.menuitem .accelerator:insensitive{color:alpha(mix(@menu_fg_color,@menu_bg_color,0.5),0.6);text-shadow:none;}\n.menuitem.separator{color:shade(@menu_bg_color,0.9);border-color:shade(@menu_bg_color,0.9);}".printf(panelbg_value, panelfg_value, menubg_value, menufg_value);
			uint8[] data = text.data;
			long written = 0;
			while (written < data.length) {
				written += dos.write (data[written:data.length]);
			}
		} catch (Error e) {
			stderr.printf ("Could not write gtk3 configuration: %s\n", e.message);
		}
		try {
			var dos = new DataOutputStream (gtk2_config_file.create (FileCreateFlags.REPLACE_DESTINATION));
			dos.put_string ("# GTK theme preferences\n");
			string text = "style\"gtk-theme-config-panel\"\nwidget_class\"*PanelToplevel*\"style\"gtk-theme-config-panel\"\nwidget_class\"*notif*\"style\"gtk-theme-config-panel\"\nwidget_class\"*Notif*\"style\"gtk-theme-config-panel\"\nwidget_class\"*Tray*\"style\"gtk-theme-config-panel\"\nwidget_class\"*tray*\"style\"gtk-theme-config-panel\"\nwidget\"*Xfce*Panel*\"style\"gtk-theme-config-panel\"\nclass\"*Xfce*Panel*\"style\"gtk-theme-config-panel\"style\"gtk-theme-config-menu\"{\nbg[NORMAL]=\"%s\"\nbg[ACTIVE]=\"%s\"\nbg[INSENSITIVE]=\"%s\"\nfg[NORMAL]=\"%s\"\nfg[INSENSITIVE]=mix(0.5,\"%s\",\"%s\")\n}\nwidget_class\"*<GtkMenu>*\"style\"gtk-theme-config-menu\"\nstyle\"gtk-theme-config-panel\"{\nbg[NORMAL]=\"%s\"\nbg[PRELIGHT]=shade(1.1,\"%s\")\nbg[ACTIVE]=shade(0.9,\"%s\")\nbg[SELECTED]=shade(0.97,\"%s\")\nfg[NORMAL]=\"%s\"\nfg[PRELIGHT]=\"%s\"\nfg[SELECTED]=\"%s\"\nfg[ACTIVE]=\"%s\"\n}\nclass\"PanelApp*\"style\"gtk-theme-config-panel\"\nclass\"PanelToplevel*\"style\"gtk-theme-config-panel\"\nwidget\"*PanelWidget*\"style\"gtk-theme-config-panel\"\nwidget\"*PanelApplet*\"style\"gtk-theme-config-panel\"\nwidget\"*fast-user-switch*\"style\"gtk-theme-config-panel\"\nwidget\"*CPUFreq*Applet*\"".printf(panelbg_value, panelbg_value, panelbg_value, panelbg_value, panelfg_value, panelfg_value, panelfg_value, panelfg_value, menubg_value, menubg_value, menubg_value, menufg_value, menufg_value, menubg_value);
			uint8[] data = text.data;
			long written = 0;
			while (written < data.length) {
				written += dos.write (data[written:data.length]);
			}
		} catch (Error e) {
			stderr.printf ("Could not write gtk2 configuration: %s\n", e.message);
		}
	}
}

class ThemePrefApp : Gtk.Application {
	protected override void activate () {

		var window = new ThemePrefWindow (this);
		window.show_all (); //show all the things
	}

	internal ThemePrefApp () {
		Object (application_id: "org.themepref.app");
	}
}

int main (string[] args) {
	return new ThemePrefApp ().run (args);
}
