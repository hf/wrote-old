/*
 * Window.vala
 * This file is part of Wrote
 *
 * Copyright (C) 2012 - Stojan Dimitrovski
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

using Gtk;
using Wrote;

public class Wrote.Window: Gtk.Window {

  public Wrote.Document document { get; construct set; }

  // UI
  public Gtk.Box container { get; private set; }

  public Wrote.Scroller scroller { get; private set; }
  public Wrote.TextView text_view { get; private set; }
  public Wrote.Status   status { get; private set; }

  public Gtk.ActionGroup actions { get; private set; }
  public Gtk.AccelGroup accels { get; private set; }

  public Window(Wrote.Document doc) {
    Object(document: doc);
  }

  construct {
    this.application = Wrote.App;

    this.app_paintable = true;

    this.make_title(true);

    this.default_width = Wrote.Theme.WIDTH;
    this.default_height = Wrote.Theme.HEIGHT;

    this.container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

    this.scroller = new Wrote.Scroller();
    this.text_view = new Wrote.TextView(this.document);

    this.scroller.add(this.text_view);

    this.container.pack_start(this.scroller, true, true, 0);

    this.status = new Wrote.Status(this.document);
    this.container.pack_start(this.status, false, false, 0);

    this.scroller.halign = Gtk.Align.CENTER;

    this.scroller.margin_top = Wrote.Theme.MARGIN_TOP;
    this.scroller.margin_left = Wrote.Theme.MARGIN_LEFT;
    this.scroller.margin_right = Wrote.Theme.MARGIN_RIGHT;
    this.scroller.margin_bottom = Wrote.Theme.MARGIN_BOTTOM / 2;

    this.status.margin_bottom = Wrote.Theme.MARGIN_BOTTOM / 2 + (Wrote.Theme.MARGIN_BOTTOM % 2);

    this.add(this.container);

    this.actions = new Gtk.ActionGroup("Actions");
    this.accels  = new Gtk.AccelGroup();

    (new Wrote.Actions.NewFile()).connect(this.actions, this.accels);
    (new Wrote.Actions.OpenFile()).connect(this.actions, this.accels);
    (new Wrote.Actions.SaveFile()).connect(this.actions, this.accels);
    (new Wrote.Actions.Close()).connect(this.actions, this.accels);
    (new Wrote.Actions.Quit()).connect(this.actions, this.accels);

    this.add_accel_group(this.accels);
  }

  public override void show() {
    base.show();

    this.load_document();
  }

  public override bool delete_event(Gdk.EventAny e) {
    this.close();

    return true;
  }

  public override bool draw(Cairo.Context ctx) {
    ctx.save();

    ctx.save();

    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);

    ctx.set_operator(Cairo.Operator.SOURCE);

    ctx.paint();

    ctx.restore();

    ctx.save();

    base.draw(ctx);

    ctx.restore();

    return true;
  }

  public void present_error(Error e) {
    if (e is Wrote.DocumentError.FILE_NOT_FOUND) {

      Gtk.MessageDialog msg = new Gtk.MessageDialog(
        this,
        Gtk.DialogFlags.MODAL,
        Gtk.MessageType.WARNING,
        Gtk.ButtonsType.NONE,
        "File could not be found. Would you like to choose another?");

      msg.add_buttons(
        "Yes, Select Another File", Gtk.ResponseType.YES,
        "No, Edit As New File", Gtk.ResponseType.NO);

      msg.format_secondary_text("The file does not seem to exist in the location you asked to open.\n" +
      "You can select another one, or keep editing this file.");

      int response = msg.run();

      if (response == Gtk.ResponseType.YES) {
        // TODO: Show Open File Dialog
      } else {
        this.document.move(null);
      }

      msg.destroy();
    } else if (e is Wrote.DocumentError.FILE_IS_DIRECTORY) {

      Gtk.MessageDialog msg = new Gtk.MessageDialog(
        this,
        Gtk.DialogFlags.MODAL,
        Gtk.MessageType.WARNING,
        Gtk.ButtonsType.NONE,
        "Can't open a directory. Would you like to select a file?");

      msg.add_buttons(
        "Yes, Select A File", Gtk.ResponseType.YES,
        "No, Edit As New File", Gtk.ResponseType.NO);

      msg.format_secondary_text("You asked to open what appears to be a directory.\n" +
        "Proceed by selecting a file to open, or keep editing as a new file.");

      int response = msg.run();

      if (response == Gtk.ResponseType.YES) {
        // TODO: Show Open File Dialog
      } else {
        this.document.move(null);
      }

      msg.destroy();
    } else if (e is Wrote.DocumentError.PERMISSION_DENIED) {

      Gtk.MessageDialog msg = new Gtk.MessageDialog(
        this,
        Gtk.DialogFlags.MODAL,
        Gtk.MessageType.ERROR,
        Gtk.ButtonsType.NONE,
        "Permission was denied for reading the file.");

      msg.add_buttons(
        "OK, I Understand", Gtk.ResponseType.OK);

      msg.format_secondary_text("You are not allowed to read the contents of the file you asked to open.\n" +
        "Contact your system administrator to learn what this means and how to change it.\n" +
        "You can now continue editing this file.");

      msg.run();

      this.document.move(null);

      msg.destroy();
    } else if (e is Wrote.DocumentError.ENCODING_NOT_SUPPORTED ||
               e is Wrote.DocumentError.ENCODING_CONVERSION_FAILED)
    {

      Gtk.MessageDialog msg = new Gtk.MessageDialog(
        this,
        Gtk.DialogFlags.MODAL,
        Gtk.MessageType.ERROR,
        Gtk.ButtonsType.NONE,
        e.message);

      Wrote.EncodingComboBox ecb = new Wrote.EncodingComboBox();
      ecb.encoding_string = this.document.encoding;

      Gtk.Label ecb_label = new Gtk.Label("Select Encoding:");

      Gtk.Box ebox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
      ebox.pack_start(ecb_label, false, false, 0);
      ebox.pack_start(ecb, true, true, 0);

      Gtk.Box msgbox = msg.get_message_area() as Gtk.Box;
      msgbox.pack_start(ebox, true, true, 0);

      msg.add_buttons(
        "Yes, Try Again", Gtk.ResponseType.YES,
        "No, Edit As New File", Gtk.ResponseType.NO);

      if (e is Wrote.DocumentError.ENCODING_NOT_SUPPORTED) {
        msg.format_secondary_text(
          "The file cannot be opened because it was saved in an encoding\n" +
          "that Wrote does not support. Proceed by selecting another\n" +
          "encoding and try again, or continue editing this file.");
      } else {
        msg.format_secondary_text(
          "The file cannot be opened because it does not appear to be encoded\n" +
          "as %s. Proceed by selecting another encoding and try again,\n" +
          "or continue editing this file.",
          this.document.encoding);
      }

      msg.show.connect(() => {
        msgbox.show_all();
      });

      int response = msg.run();

      if (response == Gtk.ResponseType.YES) {
        this.document.encoding = ecb.canonical_encoding;
        this.load_document();
      }

      msg.destroy();
    }
  }

  void load_document() {
    this.document.load.begin((o, r) => {
      try {
        this.document.load.end(r);
      } catch (Error e) {
        this.present_error(e);
      }
    });
  }

  public void close() {
    if (this.document.modified) {

      Gtk.MessageDialog msg = new Gtk.MessageDialog(this,
        Gtk.DialogFlags.MODAL,
        Gtk.MessageType.QUESTION,
        Gtk.ButtonsType.NONE,
        "Do you wish to save the changes made to the file?");

      msg.format_secondary_text(
        "The changes made to this file have not yet been saved.\n" +
        "Closing this window will destroy those changes.");

      msg.add_buttons(
        "Yes, Save Changes", Gtk.ResponseType.YES,
        "No, Discard Changes", Gtk.ResponseType.NO,
        "Cancel", Gtk.ResponseType.CANCEL);

      int response = msg.run();

      msg.destroy();

      if (response == Gtk.ResponseType.YES) {

        if (this.document.has_file) {
          this.document.save.begin((o, r) => {

            try {
              this.document.save.end(r);
              this.destroy();
            } catch (Error e) {
              this.present_error(e);
            }

          });
        } else {
          Wrote.SaveFileDialog sfd = new Wrote.SaveFileDialog(this);

          ulong saved_handler = 0;

          saved_handler = this.document.saved.connect((success) => {
            if (success) {
              this.close();
            }

            this.document.disconnect(saved_handler);
          });

          sfd.run();
        }

      } else if (response == Gtk.ResponseType.NO) {
        this.destroy();
      } else {
        return;
      }

    } else {
      this.destroy();
    }
  }

  void make_title(bool start_watching = false) {
    this.title = (this.document.modified ? "*" : "") + this.document.title;

    if (start_watching) {
      this.document.notify["modified"].connect(() => {
        this.make_title();
      });

      this.document.notify["title"].connect(() => {
        this.make_title();
      });
    }
  }
}
