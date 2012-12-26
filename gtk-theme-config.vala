using Gtk;

class ThemePrefWindow : ApplicationWindow {
	Label heading1;
	Label heading2;
	Label heading3;

	Label selectbg_label;
	Label selectfg_label;
	Label panelbg_label;
	Label panelfg_label;
	Label menubg_label;
	Label menufg_label;

	ColorButton selectbg_button;
	ColorButton selectfg_button;
	ColorButton panelbg_button;
	ColorButton panelfg_button;
	ColorButton menubg_button;
	ColorButton menufg_button;

	CheckButton selectbg_check;
	CheckButton selectfg_check;
	CheckButton panelbg_check;
	CheckButton panelfg_check;
	CheckButton menubg_check;
	CheckButton menufg_check;

	Button apply_button;
	Button reset_button;
	Button close_button;

	Gdk.RGBA selectbg;
	Gdk.RGBA selectfg;
	Gdk.RGBA panelbg;
	Gdk.RGBA panelfg;
	Gdk.RGBA menubg;
	Gdk.RGBA menufg;

	Gdk.RGBA color_rgb;

	File config_dir;
	File home_dir;

	File gtk3_config_file;
	File gtk2_config_file;

	File gtk3_saved_file;
	File gtk2_saved_file;

	File theme_path;

	string color_hex;

	string color_scheme;

	string selectbg_value;
	string selectfg_value;
	string panelbg_value;
	string panelfg_value;
	string menubg_value;
	string menufg_value;

	string selectbg_state1;
	string selectbg_state2;
	string selectfg_state1;
	string selectfg_state2;
	string panelbg_state1;
	string panelbg_state2;
	string panelfg_state1;
	string panelfg_state2;
	string menubg_state1;
	string menubg_state2;
	string menufg_state1;
	string menufg_state2;

	string panelbg_gtk2;
	string panelfg_gtk2;
	string menubg_gtk2;
	string menufg_gtk2;

	internal ThemePrefWindow (ThemePrefApp app) {
		Object (application: app, title: "GTK theme preferences");

		// Set window properties
		this.window_position = WindowPosition.CENTER;
		this.resizable = false;
		this.border_width = 10;

		// Set window icon
		try {
			this.icon = IconTheme.get_default ().load_icon ("preferences-desktop-theme", 48, 0);
		} catch (Error e) {
			stderr.printf ("Could not load application icon: %s\n", e.message);
		}

		// GMenu
		var about_action = new SimpleAction ("about", null);
		about_action.activate.connect (this.show_about);
		this.add_action (about_action);

		var quit_action = new SimpleAction ("quit", null);
		quit_action.activate.connect (this.quit_window);
		this.add_action (quit_action);

		// Methods
		create_widgets ();
		connect_signals ();
	}

	void show_about (SimpleAction simple, Variant? parameter) {
		string license = "This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.\n\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\nYou should have received a copy of the GNU General Public License along with This program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA";

		Gtk.show_about_dialog (this,
			"program-name", ("GTK theme preferences"),
			"copyright", ("Copyright \xc2\xa9 2012 Satyajit Sahoo"),
			"comments", ("A tool to configure the GTK theme"),
			"license", license,
			"wrap-license", true,
			"website", "http://github.com/satya164/gtk-theme-config",
			"website-label", ("GTK theme preferences on GitHub"),
			null);
	}

	void quit_window () {
		destroy ();
	}

	void set_values () {

		// Set default values
		selectbg_value = "#398ee7";
		selectfg_value = "#eeeeee";
		panelbg_value = "#cccccc";
		panelfg_value = "#333333";
		menubg_value = "#eeeeee";
		menufg_value = "#333333";
		selectbg_check.set_active (false);
		selectfg_check.set_active (false);
		panelbg_check.set_active (false);
		panelfg_check.set_active (false);
		menubg_check.set_active (false);
		menufg_check.set_active (false);

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
		if (gtk3_config_file.query_exists ()) {
			theme_path = gtk3_config_file;
		} else if (home_dir.get_child (".themes/%s/gtk-3.0/gtk-main.css".printf (theme_name)).query_exists ()) {
			theme_path = home_dir.get_child (".themes/%s/gtk-3.0/gtk-main.css".printf (theme_name));
		} else if (home_dir.get_child (".themes/%s/gtk-3.0/gtk.css".printf (theme_name)).query_exists ()) {
			theme_path = home_dir.get_child (".themes/%s/gtk-3.0/gtk.css".printf (theme_name));
		} else if (File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk-main.css".printf (theme_name)).query_exists ()) {
			theme_path = File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk-main.css".printf (theme_name));
		} else if (File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk.css".printf (theme_name)).query_exists ()) {
			theme_path = File.parse_name ("/usr/share/themes/%s/gtk-3.0/gtk.css".printf (theme_name));
		} else {
			theme_path = gtk3_saved_file;
		}

		// Read the current theme file
		try {
			var dis = new DataInputStream (theme_path.read ());
			string line;
			while ((line = dis.read_line (null)) != null) {
				if ("@define-color selected_bg_color" in line) {
					selectbg_value = line.substring (32, line.length-33);
				}
				if ("@define-color selected_fg_color" in line) {
					selectfg_value = line.substring (32, line.length-33);
				}
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
				if ("/* selectbg-on */" in line) {
					selectbg_check.set_active (true);
				}
				if ("/* selectfg-on */" in line) {
					selectfg_check.set_active (true);
				}
				if ("/* panelbg-on */" in line) {
					panelbg_check.set_active (true);
				}
				if ("/* panelfg-on */" in line) {
					panelfg_check.set_active (true);
				}
				if ("/* menubg-on */" in line) {
					menubg_check.set_active (true);
				}
				if ("/* menufg-on */" in line) {
					menufg_check.set_active (true);
				}
			}
		} catch (Error e) {
			stderr.printf ("Could not read user theme: %s\n", e.message);
		}

		// Read the current color scheme
		if (";" in color_scheme) {
			string[] parts = color_scheme.split_set(";");
			if ("selected_bg_color:#" in parts[0]) {
				selectbg_value = parts[0].substring (18, parts[0].length-18);
				selectbg_check.set_active (true);
			}
			if ("selected_fg_color:#" in parts[1]) {
				selectfg_value = parts[1].substring (18, parts[1].length-18);
				selectfg_check.set_active (true);
			}
		}

		// Set colors
		selectbg = Gdk.RGBA ();
		selectbg.parse ("%s".printf (selectbg_value));
		selectbg_button.set_rgba (selectbg);
		selectfg = Gdk.RGBA ();
		selectfg.parse ("%s".printf (selectfg_value));
		selectfg_button.set_rgba (selectfg);
		panelbg = Gdk.RGBA ();
		panelbg.parse ("%s".printf (panelbg_value));
		panelbg_button.set_rgba (panelbg);
		panelfg = Gdk.RGBA ();
		panelfg.parse ("%s".printf (panelfg_value));
		panelfg_button.set_rgba (panelfg);
		menubg = Gdk.RGBA ();
		menubg.parse ("%s".printf (menubg_value));
		menubg_button.set_rgba (menubg);
		menufg = Gdk.RGBA ();
		menufg.parse ("%s".printf (menufg_value));
		menufg_button.set_rgba (menufg);

		apply_button.set_sensitive (false);
	}

	void create_widgets () {
		// Create and setup widgets
		heading1 = new Label.with_mnemonic ("_<b>Selection colors</b>");
		heading1.set_use_markup (true);
		heading1.set_halign (Gtk.Align.START);
		heading2 = new Label.with_mnemonic ("_<b>Panel colors</b>");
		heading2.set_use_markup (true);
		heading2.set_halign (Gtk.Align.START);
		heading3 = new Label.with_mnemonic ("_<b>Menu colors</b>");
		heading3.set_use_markup (true);
		heading3.set_halign (Gtk.Align.START);

		selectbg_label = new Label.with_mnemonic ("_Custom selection background");
		selectbg_label.set_halign (Gtk.Align.START);
		selectfg_label = new Label.with_mnemonic ("_Custom selection text");
		selectfg_label.set_halign (Gtk.Align.START);
		panelbg_label = new Label.with_mnemonic ("_Custom panel background");
		panelbg_label.set_halign (Gtk.Align.START);
		panelfg_label = new Label.with_mnemonic ("_Custom panel text");
		panelfg_label.set_halign (Gtk.Align.START);
		menubg_label = new Label.with_mnemonic ("_Custom menu background");
		menubg_label.set_halign (Gtk.Align.START);
		menufg_label = new Label.with_mnemonic ("_Custom menu text");
		menufg_label.set_halign (Gtk.Align.START);

		selectbg_button = new ColorButton ();
		selectfg_button = new ColorButton ();
		panelbg_button = new ColorButton ();
		panelfg_button = new ColorButton ();
		menubg_button = new ColorButton ();
		menufg_button = new ColorButton ();

		selectbg_check = new CheckButton ();
		selectbg_check.set_halign (Gtk.Align.END);
		selectfg_check = new CheckButton ();
		selectfg_check.set_halign (Gtk.Align.END);
		panelbg_check = new CheckButton ();
		panelbg_check.set_halign (Gtk.Align.END);
		panelfg_check = new CheckButton ();
		panelfg_check.set_halign (Gtk.Align.END);
		menubg_check = new CheckButton ();
		menubg_check.set_halign (Gtk.Align.END);
		menufg_check = new CheckButton ();
		menufg_check.set_halign (Gtk.Align.END);

		apply_button = new Button.from_stock (Stock.APPLY);
		reset_button = new Button.from_stock(Stock.REVERT_TO_SAVED);
		close_button = new Button.from_stock (Stock.CLOSE);

		// Buttons
		var buttons = new Box (Gtk.Orientation.HORIZONTAL, 5);
		buttons.set_homogeneous (true);
		buttons.add (apply_button);
		buttons.add (reset_button);
		buttons.add (close_button);

		// Layout widgets
		var grid = new Grid ();
		grid.set_column_homogeneous (false);
		grid.set_column_spacing (5);
		grid.set_row_spacing (5);
		grid.attach (heading1, 0, 0, 3, 1);
		grid.attach (selectbg_check, 0, 1, 1, 1);
		grid.attach_next_to (selectbg_label, selectbg_check, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach_next_to (selectbg_button, selectbg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (selectfg_check, 0, 2, 1, 1);
		grid.attach_next_to (selectfg_label, selectfg_check, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach_next_to (selectfg_button, selectfg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (heading2, 0, 3, 3, 1);
		grid.attach (panelbg_check, 0, 4, 1, 1);
		grid.attach_next_to (panelbg_label, panelbg_check, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach_next_to (panelbg_button, panelbg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (panelfg_check, 0, 5, 1, 1);
		grid.attach_next_to (panelfg_label, panelfg_check, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach_next_to (panelfg_button, panelfg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (heading3, 0, 6, 3, 1);
		grid.attach (menubg_check, 0, 7, 1, 1);
		grid.attach_next_to (menubg_label, menubg_check, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach_next_to (menubg_button, menubg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (menufg_check, 0, 8, 1, 1);
		grid.attach_next_to (menufg_label, menufg_check, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach_next_to (menufg_button, menufg_label, Gtk.PositionType.RIGHT, 1, 1);
		grid.attach (buttons, 0, 9, 4, 1);

		this.add (grid);

		set_values ();
	}

	void connect_signals () {
		selectbg_button.color_set.connect (() => {
			on_selectbg_color_set ();
			apply_button.set_sensitive (true);
		});
		selectfg_button.color_set.connect (() => {
			on_selectfg_color_set ();
			apply_button.set_sensitive (true);
		});
		panelbg_button.color_set.connect (() => {
			on_panelbg_color_set ();
			apply_button.set_sensitive (true);
		});
		panelfg_button.color_set.connect (() => {
			on_panelfg_color_set ();
			apply_button.set_sensitive (true);
		});
		menubg_button.color_set.connect (() => {
			on_menubg_color_set ();
			apply_button.set_sensitive (true);
		});
		menufg_button.color_set.connect (() => {
			on_menufg_color_set ();
			apply_button.set_sensitive (true);
		});
		selectbg_check.notify["active"].connect (() => {
			apply_button.set_sensitive (true);
		});
		selectfg_check.notify["active"].connect (() => {
			apply_button.set_sensitive (true);
		});
		panelbg_check.notify["active"].connect (() => {
			apply_button.set_sensitive (true);
		});
		panelfg_check.notify["active"].connect (() => {
			apply_button.set_sensitive (true);
		});
		menubg_check.notify["active"].connect (() => {
			apply_button.set_sensitive (true);
		});
		menufg_check.notify["active"].connect (() => {
			apply_button.set_sensitive (true);
		});
		apply_button.clicked.connect (() => {
			on_config_set ();
			apply_button.set_sensitive (false);
			reset_button.set_sensitive (true);
		});
		reset_button.clicked.connect (() => {
			on_config_reset ();
			reset_button.set_sensitive (false);
		});
		close_button.clicked.connect (() => {
			destroy ();
		});
	}

	void rgb_to_hex () {
		int r = (int)Math.round (color_rgb.red * 255);
		int g = (int)Math.round (color_rgb.green * 255);
		int b = (int)Math.round (color_rgb.blue * 255);

		color_hex = "#%02x%02x%02x".printf (r, g, b);
	}

	void on_selectbg_color_set () {
		color_rgb =  selectbg_button.get_rgba ();
		rgb_to_hex ();
		selectbg_value = color_hex;
	}

	void on_selectfg_color_set () {
		color_rgb =  selectfg_button.get_rgba ();
		rgb_to_hex ();
		selectfg_value = color_hex;
	}

	void on_panelbg_color_set () {
		color_rgb =  panelbg_button.get_rgba ();
		rgb_to_hex ();
		panelbg_value = color_hex;
	}

	void on_panelfg_color_set () {
		color_rgb =  panelfg_button.get_rgba ();
		rgb_to_hex ();
		panelfg_value = color_hex;
	}

	void on_menubg_color_set () {
		color_rgb =  menubg_button.get_rgba ();
		rgb_to_hex ();
		menubg_value = color_hex;
	}

	void on_menufg_color_set () {
		color_rgb =  menufg_button.get_rgba ();
		rgb_to_hex ();
		menufg_value = color_hex;
	}

	void on_config_set () {
		reset_config ();
		reset_color_scheme ();
		set_vars ();
		write_config ();
		set_color_scheme ();
		notify_change ();
	}

	void on_config_reset () {
		reset_config ();
		reset_color_scheme ();
		set_values ();
		notify_change ();
	}

	void set_vars () {
		// Determine color scheme
		if (selectbg_check.get_active() && selectfg_check.get_active()) {
			color_scheme = "\"selected_bg_color:%s;selected_fg_color:%s;\"".printf (selectbg_value, selectfg_value);
		} else if (selectbg_check.get_active() && !selectfg_check.get_active()) {
			color_scheme = "\"selected_bg_color:%s;\"".printf (selectbg_value);
		} else if (!selectfg_check.get_active() && selectfg_check.get_active()) {
			color_scheme = "\"selected_fg_color:%s;\"".printf (selectfg_value);
		} else {
			color_scheme = "\"\"";
		}
		
		// Determine states
		if (selectbg_check.get_active()) {
			selectbg_state1 = "/* selectbg-on */";
			selectbg_state2 = "/* selectbg-on */";
		} else {
			selectbg_state1 = "/* selectbg-off";
			selectbg_state2 = "selectbg-off */";
		}
		if (selectfg_check.get_active()) {
			selectfg_state1 = "/* selectfg-on */";
			selectfg_state2 = "/* selectfg-on */";
		} else {
			selectfg_state1 = "/* selectfg-off";
			selectfg_state2 = "selectfg-off */";
		}
		if (panelbg_check.get_active()) {
			panelbg_state1 = "/* panelbg-on */";
			panelbg_state2 = "/* panelbg-on */";
			panelbg_gtk2 = "bg[NORMAL]=\"%s\"\nbg[PRELIGHT]=shade(1.1,\"%s\")\nbg[ACTIVE]=shade(0.9,\"%s\")\nbg[SELECTED]=shade(0.97,\"%s\")".printf(panelbg_value, panelbg_value, panelbg_value, panelbg_value);
		} else {
			panelbg_state1 = "/* panelbg-off";
			panelbg_state2 = "panelbg-off */";
			panelbg_gtk2 = "";
		}
		if (panelfg_check.get_active()) {
			panelfg_state1 = "/* panelfg-on */";
			panelfg_state2 = "/* panelfg-on */";
			panelfg_gtk2 = "fg[NORMAL]=\"%s\"\nfg[PRELIGHT]=\"%s\"\nfg[SELECTED]=\"%s\"\nfg[ACTIVE]=\"%s\"".printf(panelfg_value, panelfg_value, panelfg_value, panelfg_value);
		} else {
			panelfg_state1 = "/* panelfg-off";
			panelfg_state2 = "panelfg-off */";
			panelfg_gtk2 = "";
		}
		if (menubg_check.get_active()) {
			menubg_state1 = "/* menubg-on */";
			menubg_state2 = "/* menubg-on */";
			menubg_gtk2 = "bg[NORMAL]=\"%s\"\nbg[ACTIVE]=\"%s\"\nbg[INSENSITIVE]=\"%s\"".printf(menubg_value, menubg_value, menubg_value);
		} else {
			menubg_state1 = "/* menubg-off";
			menubg_state2 = "menubg-off */";;
			menubg_gtk2 = "";
		}
		if (menufg_check.get_active()) {
			menufg_state1 = "/* menufg-on */";
			menufg_state2 = "/* menufg-on */";
			menufg_gtk2 = "fg[NORMAL]=\"%s\"".printf(menufg_value);
		} else {
			menufg_state1 = "/* menufg-off";
			menufg_state2 = "menufg-off */";
			menufg_gtk2 = "";
		}
	}

	void set_color_scheme () {
		try {
			Process.spawn_command_line_sync ("gsettings set org.gnome.desktop.interface gtk-color-scheme %s".printf (color_scheme));
		} catch (Error e) {
			stderr.printf ("Could not set color scheme for gtk3: %s\n", e.message);
		}
		try {
			Process.spawn_command_line_sync ("gconftool-2 -s /desktop/gnome/interface/gtk_color_scheme -t string %s".printf (color_scheme));
		} catch (Error e) {
			stderr.printf ("Could not set color scheme for gtk2: %s\n", e.message);
		}
		try {
			Process.spawn_command_line_sync ("xfconf-query -n -c xsettings -p /Gtk/ColorScheme -t string -s %s".printf (color_scheme));
		} catch (Error e) {
			stderr.printf ("Could not set color scheme for xfce: %s\n", e.message);
		}
	}

	void reset_color_scheme () {
		try {
			Process.spawn_command_line_sync ("gsettings reset org.gnome.desktop.interface gtk-color-scheme");
		} catch (Error e) {
			stderr.printf ("Could not reset color scheme for gtk3: %s\n", e.message);
		}
		try {
			Process.spawn_command_line_sync ("gconftool-2 -u /desktop/gnome/interface/gtk_color_scheme");
		} catch (Error e) {
			stderr.printf ("Could not reset color scheme for gtk2: %s\n", e.message);
		}
		try {
			Process.spawn_command_line_sync ("xfconf-query -c xsettings -p /Gtk/ColorScheme -r");
		} catch (Error e) {
			stderr.printf ("Could not reset color scheme for xfce: %s\n", e.message);
		}
	}
			
	void reset_config () {
		try {
			if (gtk3_config_file.query_exists () && !gtk3_saved_file.query_exists ()) {
				gtk3_config_file.set_display_name ("gtk.css.saved");
			}
		} catch (Error e) {
			stderr.printf ("Could not backup gtk3 configuration: %s\n", e.message);
		}
		try {
			if (gtk2_config_file.query_exists () && !gtk2_saved_file.query_exists ()) {
				gtk2_config_file.set_display_name (".gtkrc-2.0.saved");
			}
		} catch (Error e) {
			stderr.printf ("Could not backup gtk2 configuration: %s\n", e.message);
		}
		try {
			if (gtk3_config_file.query_exists ()) {
				gtk3_config_file.delete ();
			}
		} catch (Error e) {
			stderr.printf ("Could not delete previous gtk3 configuration: %s\n", e.message);
		}
		try {
			if (gtk2_config_file.query_exists ()) {
				gtk2_config_file.delete ();
			}
		} catch (Error e) {
			stderr.printf ("Could not delete previous gtk2 configuration: %s\n", e.message);
		}
	}

	void write_config () {
		try {
			var dos = new DataOutputStream (gtk3_config_file.create (FileCreateFlags.REPLACE_DESTINATION));
			dos.put_string ("/* GTK theme preferences */\n");
			string text = "%s\n@define-color selected_bg_color %s;\n%s\n%s\n@define-color selected_fg_color %s;\n%s\n%s\n@define-color panel_bg_color %s;\n*:selected,*:selected:focus{background-color:alpha(@theme_selected_bg_color,0.9);color:@theme_selected_fg_color;}\nPanelWidget,PanelApplet,PanelToplevel,PanelSeparator,.gnome-panel-menu-bar,PanelApplet > GtkMenuBar.menubar,PanelApplet > GtkMenuBar.menubar.menuitem,PanelMenuBar.menubar,PanelMenuBar.menubar.menuitem,PanelAppletFrame,UnityPanelWidget,.unity-panel,.unity-panel.menubar,.unity-panel .menubar{background-image:-gtk-gradient(linear,left top,left bottom,from(shade(@panel_bg_color,1.2)),to (shade(@panel_bg_color,0.9)));border-color:shade(@panel_bg_color,0.8);}\nPanelApplet .button:prelight,.unity-panel.menubar.menuitem:hover,.unity-panel.menubar .menuitem *:hover{background-image:-gtk-gradient(linear,left top,left bottom,from (shade(@panel_bg_color,1.5)),to (shade(@panel_bg_color,1.2)));border-color:shade(@panel_bg_color,0.85);}\nPanelApplet .button{background-image:-gtk-gradient(linear,left top,left bottom,from (shade(@panel_bg_color,1.3)),to (shade(@panel_bg_color,1.0)));border-color:shade(@panel_bg_color,0.7);text-shadow:none;}\nPanelApplet .button:prelight:active,PanelApplet .button:active{background-image:-gtk-gradient(linear,left top,left bottom,from (shade(@panel_bg_color,0.85)),to (shade(@panel_bg_color,1.0)));border-color:shade(@panel_bg_color,0.7);}\n%s\n%s\n@define-color panel_fg_color %s;\nPanelWidget,PanelApplet,PanelToplevel,PanelSeparator,.gnome-panel-menu-bar,PanelApplet > GtkMenuBar.menubar,PanelApplet > GtkMenuBar.menubar.menuitem,PanelMenuBar.menubar,PanelMenuBar.menubar.menuitem,PanelAppletFrame,UnityPanelWidget,.unity-panel,.unity-panel.menubar,.unity-panel .menubar{color:@panel_fg_color;}\nPanelApplet .button:prelight,.unity-panel.menubar.menuitem:hover,.unity-panel.menubar .menuitem *:hover{color:@panel_fg_color;}\nPanelApplet .button{color:@panel_fg_color}\n%s\n%s\n@define-color menu_bg_color %s;\nGtkTreeMenu.menu,GtkMenuToolButton.menu,GtkComboBox .menu,.primary-toolbar .button .menu,.toolbar .menu,.toolbar .primary-toolbar .menu,.menu{background-color:@menu_bg_color;border-color:shade(@menu_bg_color,0.7);box-shadow:none;-unico-inner-stroke-width:0;}\nGtkTreeMenu .menuitem *,GtkMenuToolButton .menuitem *,GtkComboBox .menuitem *,GtkTreeMenu.menu .menuitem,GtkMenuToolButton.menu .menuitem,GtkComboBox .menu .menuitem,.primary-toolbar .button .menu .menuitem,.toolbar .menu .menuitem,.toolbar .primary-toolbar .menu .menuitem,.menu .menuitem{text-shadow:none;}\n.menuitem.separator{color:shade(@menu_bg_color,0.9);border-color:shade(@menu_bg_color,0.9);}\n%s\n%s\n@define-color menu_fg_color %s;\nGtkTreeMenu.menu,GtkMenuToolButton.menu,GtkComboBox .menu,.primary-toolbar .button .menu,.toolbar .menu,.toolbar .primary-toolbar .menu,.menu{color:@menu_fg_color;}\nGtkTreeMenu .menuitem *,GtkMenuToolButton .menuitem *,GtkComboBox .menuitem *,GtkTreeMenu.menu .menuitem,GtkMenuToolButton.menu .menuitem,GtkComboBox .menu .menuitem,.primary-toolbar .button .menu .menuitem,.toolbar .menu .menuitem,.toolbar .primary-toolbar .menu .menuitem,.menu .menuitem{color:@menu_fg_color;}\n.menuitem .accelerator{color:alpha(@menu_fg_color,0.6);}\n%s".printf(selectbg_state1, selectbg_value, selectbg_state2, selectfg_state1, selectfg_value, selectfg_state2, panelbg_state1, panelbg_value, panelbg_state2, panelfg_state1, panelfg_value, panelfg_state2, menubg_state1, menubg_value, menubg_state2, menufg_state1, menufg_value, menufg_state2);
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
			string text = "style\"gtk-theme-config-panel\"{\n%s\n%s\n}\nstyle\"gtk-theme-config-menu\"{\n%s\n%s\n}\nclass\"PanelApp*\"style\"gtk-theme-config-panel\"\nclass\"PanelToplevel*\"style\"gtk-theme-config-panel\"\nwidget\"*PanelWidget*\"style\"gtk-theme-config-panel\"\nwidget\"*PanelApplet*\"style\"gtk-theme-config-panel\"\nwidget\"*fast-user-switch*\"style\"gtk-theme-config-panel\"\nwidget\"*CPUFreq*Applet*\"style\"gtk-theme-config-panel\"\nwidget_class\"*PanelToplevel*\"style\"gtk-theme-config-panel\"\nwidget_class\"*notif*\"style\"gtk-theme-config-panel\"\nwidget_class\"*Notif*\"style\"gtk-theme-config-panel\"\nwidget_class\"*Tray*\"style\"gtk-theme-config-panel\"\nwidget_class\"*tray*\"style\"gtk-theme-config-panel\"\nwidget\"*Xfce*Panel*\"style\"gtk-theme-config-panel\"\nclass\"*Xfce*Panel*\"style\"gtk-theme-config-panel\"\nwidget_class\"*<GtkMenu>*\"style\"gtk-theme-config-menu\"".printf(panelbg_gtk2, panelfg_gtk2, menubg_gtk2, menufg_gtk2);
			uint8[] data = text.data;
			long written = 0;
			while (written < data.length) {
				written += dos.write (data[written:data.length]);
			}
		} catch (Error e) {
			stderr.printf ("Could not write gtk2 configuration: %s\n", e.message);
		}
	}

	void notify_change() {
		try {
			Process.spawn_command_line_sync("notify-send -h int:transient:1 -i \"preferences-desktop-theme\" \"Changes applied.\" \"You might need to restart running applications.\"");
		} catch (Error e) {
			stderr.printf ("%s", e.message);
		}
	}
}

class ThemePrefApp : Gtk.Application {
	internal ThemePrefApp () {
		Object (application_id: "org.themepref.app");
	}

	protected override void activate () {
		var window = new ThemePrefWindow (this);
		window.show_all ();
	}

	protected override void startup () {
		base.startup ();

		var menu = new GLib.Menu ();
		menu.append ("About", "win.about");
		menu.append ("Quit", "win.quit");
		this.app_menu = menu;
	}
}

int main (string[] args) {
	return new ThemePrefApp ().run (args);
}
