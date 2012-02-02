/*
 * Theme.vala
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

using Config;

namespace Wrote.Theme {
  public static const int WIDTH = 800;
  public static const int HEIGHT = 550;

  public static const int MARGIN_TOP = 36;
  public static const int MARGIN_BOTTOM = 36;

  public static const int MARGIN_LEFT = 45;
  public static const int MARGIN_RIGHT = 45;

  public static const int EDITOR_WIDTH = 630;
  public static const int EDITOR_HEIGHT = 300;

  public static const string FONT_FAMILY = "M+ 1m";
  public static const int FONT_SIZE = 12;

  public static const int LEADING = 6;
  public static const int ABOVE_PARAGRAPH = 3;
  public static const int BELOW_PARAGRAPH = 3;

  public static const int REFRESH_RATE = 1000 / 40; // ~25 fps
  public static const double FADING_RATE = 0.1;

  public static const uint INACTIVITY_TIMEOUT = 3; // seconds

  public static Gdk.RGBA? COLOR = null;

  public static const int FADE_SIZE = 10;

  public static const string BACKGROUND = Config.DATADIR + "/wrote/images/bg.png";

  // guaranteed to be non-null after init
  public static Cairo.ImageSurface? BACKGROUND_SURFACE = null;
  public static Cairo.Pattern? BACKGROUND_PATTERN = null;

  public static Cairo.Pattern? TOP_FADE_MASK = null;
  public static Cairo.Pattern? BOTTOM_FADE_MASK = null;

  public static Pango.FontDescription regular_font() {
    string regular_font =
      @"$(Wrote.Theme.FONT_FAMILY) Regular $(Wrote.Theme.FONT_SIZE)";

    Pango.FontDescription description = Pango.FontDescription.from_string(regular_font);

    return description;
  }

  public static Pango.FontDescription medium_font() {
    string medium_font =
      @"$(Wrote.Theme.FONT_FAMILY) Medium $(Wrote.Theme.FONT_SIZE)";

    Pango.FontDescription description = Pango.FontDescription.from_string(medium_font);

    return description;
  }

  public static Pango.FontDescription light_font() {
    string light_font =
      @"$(Wrote.Theme.FONT_FAMILY) Light $(Wrote.Theme.FONT_SIZE)";

    Pango.FontDescription description = Pango.FontDescription.from_string(light_font);

    return description;
  }

  public static void source(Cairo.Context ctx)
  requires (Wrote.Theme.BACKGROUND_PATTERN != null)
  {
    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);
  }

  public static void init()
  requires (
    Wrote.Theme.BACKGROUND_SURFACE == null &&
    Wrote.Theme.BACKGROUND_PATTERN == null &&
    Wrote.Theme.TOP_FADE_MASK      == null &&
    Wrote.Theme.BOTTOM_FADE_MASK   == null &&
    Wrote.Theme.COLOR              == null)
  {
    Wrote.Theme.BACKGROUND_SURFACE =
      new Cairo.ImageSurface.from_png(Wrote.Theme.BACKGROUND);

    Wrote.Theme.BACKGROUND_PATTERN =
      new Cairo.Pattern.for_surface(Wrote.Theme.BACKGROUND_SURFACE);
    Wrote.Theme.BACKGROUND_PATTERN.set_extend(Cairo.Extend.REPEAT);

    Wrote.Theme.TOP_FADE_MASK =
      new Cairo.Pattern.linear(0, 0, 0, Wrote.Theme.FADE_SIZE);
    Wrote.Theme.TOP_FADE_MASK.set_extend(Cairo.Extend.REPEAT);
    Wrote.Theme.TOP_FADE_MASK.add_color_stop_rgba(0.0, 0, 0, 0, 1.0);
    Wrote.Theme.TOP_FADE_MASK.add_color_stop_rgba(1.0, 0, 0, 0, 0.0);

    Wrote.Theme.BOTTOM_FADE_MASK =
      new Cairo.Pattern.linear(0, 0, 0, Wrote.Theme.FADE_SIZE);
    Wrote.Theme.BOTTOM_FADE_MASK.set_extend(Cairo.Extend.REPEAT);

    Wrote.Theme.BOTTOM_FADE_MASK.add_color_stop_rgba(0.0, 0, 0, 0, 0.0);
    Wrote.Theme.BOTTOM_FADE_MASK.add_color_stop_rgba(1.0, 0, 0, 0, 1.0);

    Wrote.Theme.COLOR = Gdk.RGBA() {
      red = 40.0 / 255.0,
      green = 28.0 / 255.0,
      blue = 22.0 / 255.0,
      alpha = 1.0
    };
  }

  public static void deinit()
  requires (
    Wrote.Theme.BACKGROUND_SURFACE != null &&
    Wrote.Theme.BACKGROUND_PATTERN != null &&
    Wrote.Theme.TOP_FADE_MASK      != null &&
    Wrote.Theme.BOTTOM_FADE_MASK   != null)
  {
    /* Wrote.Theme.BACKGROUND_PATTERN.destroy();
    Wrote.Theme.BACKGROUND_SURFACE.destroy(); */
  }
}
