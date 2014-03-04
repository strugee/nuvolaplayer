/*
 * Copyright 2014 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace Nuvola
{

public class WebAppController : Diorite.Application
{
	public Gtk.ApplicationWindow? main_window {get; private set; default = null;}
	public Diorite.Storage? storage {get; private set; default = null;}
	public Diorite.ActionsRegistry? actions {get; private set; default = null;}
	public weak Gtk.Settings gtk_settings {get; private set;}
	private Gtk.Menu pop_down_menu;
	private bool show_menubar = false;
	
	public WebAppController(Diorite.Storage? storage, WebApp web_app)
	{
		var app_id = web_app.meta.id;
		base("%sX%s".printf(UNIQUE_NAME, app_id), "%s - %s".printf(web_app.meta.name, NAME), "%s-%s.desktop".printf(APPNAME, app_id), "%s-%s".printf(APPNAME, app_id));
		icon = APP_ICON;
		version = VERSION;
		this.storage = storage;
		
	}
	
	public override void activate()
	{
		if (main_window == null)
			start();
		main_window.present();
	}
	
	private void start()
	{
		gtk_settings = Gtk.Settings.get_default();
		main_window = new Gtk.ApplicationWindow(this);
		main_window.show_all();
	}
}

} // namespace Nuvola
