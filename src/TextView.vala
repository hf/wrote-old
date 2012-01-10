using Gtk;
using Pango;
using Cairo;

public class Wrote.TextView: Gtk.TextView {
  
  public weak Wrote.Document document { get; private set; }
  
  construct {
    this.app_paintable = true;
    this.wrap_mode = Gtk.WrapMode.WORD_CHAR;
    
    this.set_size_request(Wrote.Theme.EDITOR_WIDTH, Wrote.Theme.EDITOR_HEIGHT);
    
    this.pixels_inside_wrap = Wrote.Theme.LEADING;
    this.pixels_above_lines = Wrote.Theme.ABOVE_PARAGRAPH;
    this.pixels_below_lines = Wrote.Theme.BELOW_PARAGRAPH;
    
    this.override_font(Wrote.Theme.regular_font());
    this.override_color(Gtk.StateFlags.NORMAL, Wrote.Theme.COLOR);
  }
  
  public TextView(Wrote.Document document) {
    Object(buffer: document.buffer);
  }
  
  public override bool draw(Cairo.Context ctx) {
    double x, y, w, h;
    ctx.clip_extents(out x, out y, out w, out h);
    
    ctx.save();
    
    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);
    
    ctx.paint();
    
    ctx.restore();
    
    ctx.save();
    
    base.draw(ctx);
    
    ctx.restore();
    
    ctx.save();
    
    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);
    
    ctx.rectangle(0, 0, this.get_allocated_width(), 10);
    ctx.clip();    
    ctx.mask(Wrote.Theme.TOP_FADE_MASK);
    
    ctx.restore();
    
    ctx.save();
    
    ctx.translate(0, this.get_allocated_height() - Wrote.Theme.FADE_SIZE);
    
    ctx.set_source(Wrote.Theme.BACKGROUND_PATTERN);
    
    ctx.rectangle(0, 0, this.get_allocated_width(), Wrote.Theme.FADE_SIZE);
    ctx.clip();
    ctx.mask(Wrote.Theme.BOTTOM_FADE_MASK);
    
    ctx.restore();
    
    ctx.clip();
    
    return true;
  }
}